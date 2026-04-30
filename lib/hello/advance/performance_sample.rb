# typed: true
# frozen_string_literal: true

require "benchmark"
require "benchmark/ips"
require "memory_profiler"
require "objspace"

module Hello
  module Advance
    # 性能优化 — Benchmark, ObjectSpace, GC 统计, 内存分析
    class PerformanceSample
      def self.run
        puts "=== 性能优化 — 测量与分析 ==="
        puts

        # --- 1. 字符串拼接性能 ---
        puts "--- 1. 字符串拼接性能对比 ---"
        n = 10_000
        Benchmark.bm(18) do |x|
          x.report("+= concat") do
            s = ""
            n.times { |i| s += "line#{i} " }
          end
          x.report("<< append") do
            s = String.new(capacity: n * 7)
            n.times { |i| s << "line#{i} " }
          end
          x.report("array.join") do
            arr = Array.new(n) { |i| "line#{i}" }
            arr.join(" ")
          end
        end
        puts
        puts "  结论: << append 和 array.join 远优于 += 拼接"
        puts

        # --- 2. Enumerable 方法性能 ---
        puts "--- 2. Enumerable 方法性能 ---"
        n = 100_000
        data = Array.new(n) { rand(1000) }

        Benchmark.bm(22) do |x|
          x.report("map (new array)") { data.map { |i| i * 2 } }
          x.report("map! (in-place)") { data.dup.map! { |i| i * 2 } }
          x.report("each_with_object") { data.each_with_object({}) { |i, h| h[i] = i * 2 } }
        end
        puts
        puts "  结论: 原地修改(map!)减少分配"
        puts

        # --- 3. 对象分配分析 ---
        puts "--- 3. 对象分配对比 ---"
        before1 = ObjectSpace.count_objects[:T_STRING]
        10_000.times { |i| "obj_#{i}".upcase }
        after1 = ObjectSpace.count_objects[:T_STRING]
        created = after1 - before1
        puts "  循环创建字符串: +~#{created} T_STRING"

        buffer = String.new
        before2 = ObjectSpace.count_objects[:T_STRING]
        10_000.times do |i|
          buffer.clear
          buffer << "obj_#{i}"
          buffer.upcase
        end
        after2 = ObjectSpace.count_objects[:T_STRING]
        reused = after2 - before2
        puts "  复用 buffer:      +~#{reused} T_STRING"
        puts "  减少分配: #{((1 - reused.fdiv(created)) * 100).round(1)}%"
        puts

        # --- 4. GC 统计 ---
        puts "--- 4. GC 统计 ---"
        gc_before = GC.count
        100_000.times { Object.new }
        GC.start
        gc_after = GC.count
        puts "  GC 运行次数: #{gc_before} → #{gc_after}"

        stats = GC.stat
        puts "  存活对象: #{stats[:heap_live_slots]}"
        puts "  空闲槽位: #{stats[:heap_free_slots]}"
        puts "  新分配槽位: #{stats[:heap_allocated_slots]}"
        puts

        # --- 5. ObjectSpace 对象统计 ---
        puts "--- 5. ObjectSpace 对象分布 ---"
        objects = ObjectSpace.count_objects
        puts "  总对象: #{objects[:TOTAL]}"
        puts "  T_OBJECT: #{objects[:T_OBJECT]}, T_ARRAY: #{objects[:T_ARRAY]}"
        puts "  T_HASH: #{objects[:T_HASH]}, T_STRING: #{objects[:T_STRING]}"
        puts "  T_SYMBOL: #{objects[:T_SYMBOL]}, T_DATA: #{objects[:T_DATA]}"
        puts

        # --- 6. 字符串冻结 ---
        puts "--- 6. frozen_string_literal 内存优化 ---"
        unfrozen = 100.times.map { "sample".dup }.uniq(&:object_id).length
        frozen_str1 = "frozen_sample"
        frozen_str2 = "frozen_sample"
        same_id = frozen_str1.object_id == frozen_str2.object_id

        puts "  未冻结 dup: 100 次产生 #{unfrozen} 个对象"
        puts "  冻结字面量: object_id 相同? #{same_id ? '是(共享内存)' : '否'}"
        puts

        # --- 7. Lazy vs Eager ---
        puts "--- 7. Lazy vs Eager 求值 ---"
        n = 1_000_000

        eager_count = 0
        eager_time = Benchmark.realtime do
          result = (1..n).map { |i| eager_count += 1; i * 2 }.select(&:even?).take(10)
        end
        puts "  Eager: 处理了 #{eager_count} 个元素 (#{eager_time.round(4)}s)"

        lazy_count = 0
        lazy_time = Benchmark.realtime do
          result = (1..n).lazy.map { |i| lazy_count += 1; i * 2 }.select(&:even?).take(10).force
        end
        puts "  Lazy: 处理了 #{lazy_count} 个元素 (#{lazy_time.round(4)}s)"
        puts "  优化比: #{(eager_count.fdiv(lazy_count)).round(1)}x 减少处理量"
        puts

        # --- 8. 热路径优化 ---
        puts "--- 8. 热路径优化 ---"
        n = 200_000

        Benchmark.bm(24) do |x|
          x.report("naive: to_s+length") do
            total = 0
            n.times { |i| total += i.to_s.length }
            total
          end
          x.report("optimized: digit math") do
            total = 0
            n.times { |i| total += (Math.log10(i + 1).to_i + 1) }
            total
          end
        end
        puts "  结论: 用数学计算代替 to_s 减少中间对象分配"
        puts

        # --- 9. GC 控制测量 ---
        puts "--- 9. GC 控制对测量的影响 ---"
        data = Array.new(50_000) { rand(100) }

        GC.disable
        time_no_gc = Benchmark.measure { data.select(&:even?).map { |i| i * 2 } }
        GC.enable
        time_with_gc = Benchmark.measure { data.select(&:even?).map { |i| i * 2 } }

        puts "  禁用 GC: #{time_no_gc.real.round(4)}s"
        puts "  启用 GC: #{time_with_gc.real.round(4)}s"
        puts "  GC 对性能的影响取决于对象分配量"
        puts

        # --- 10. 预分配 vs 动态增长 ---
        puts "--- 10. 数组预分配 ---"
        n = 50_000
        Benchmark.bm(14) do |x|
          x.report("push dynamic") { arr = []; n.times { |i| arr << i }; arr }
          x.report("pre-allocated") { Array.new(n) { |i| i } }
        end
        puts "  预分配减少动态扩容"
        puts

        # --- 11. benchmark-ips 高精度测量 ---
        benchmark_ips_demo

        # --- 12. 内存分析器 ---
        memory_profiler_demo

        # --- 13. ObjectSpace 深度分析 ---
        objectspace_deep_analysis

        # --- 14. GC 调优 ---
        gc_tuning_examples

        puts "=== 性能优化演示完成 ==="
      end

      def self.benchmark_ips_demo
        puts "--- Benchmark.ips — 高精度迭代/秒测量 ---"
        puts

        puts "  比较: 字符串拼接方式 (iterations per second)"
        Benchmark.ips do |x|
          x.report("+=") { (1..1000).to_a.reduce("") { |s, i| s + i.to_s } }
          x.report("<<") { (1..1000).to_a.reduce(String.new) { |s, i| s << i.to_s } }
          x.report("join") { (1..1000).map(&:to_s).join }
          x.compare!
        end
        puts

        puts "  比较: Hash 查找方式"
        small_hash = Hash[(1..100).map { |i| [i, "val_#{i}"] }]
        array = (1..100).to_a

        Benchmark.ips do |x|
          x.report("Hash[]") { small_hash[50] }
          x.report("Array#find") { array.find { |i| i == 50 } }
          x.compare!
        end
        puts
      end

      def self.memory_profiler_demo
        puts "--- MemoryProfiler — 内存分配追踪 ---"
        puts

        report = MemoryProfiler.report do
          1000.times do |i|
            "hello_#{i}_world".split("_").map(&:upcase).join("-")
          end
        end

        report.pretty_print(scale_bytes: true, normalize_paths: true)
        puts

        total_allocated = report.total_allocated_memsize
        puts "  总分配大小: #{(total_allocated / 1024.0).round(2)} KB"
        puts
      end

      def self.objectspace_deep_analysis
        puts "--- ObjectSpace — 深度对象分析 ---"
        puts

        puts "  各类对象数量 Top 15:"
        counts = {}
        ObjectSpace.each_object { |obj|
          klass = obj.class rescue Object
          counts[klass.name || "<anonymous>"] ||= 0
          counts[klass.name || "<anonymous>"] += 1
        }

        sorted = counts.sort_by { |_, v| -v }.take(15)
        sorted.each do |name, count|
          puts "    #{name.ljust(30)} #{count}"
        end
        puts

        puts "  Symbol 总数: #{Symbol.all_symbols.size}"
        GC.start
        puts "  GC 后存活对象: #{ObjectSpace.count_objects[:TOTAL]}"
        puts
      end

      def self.gc_tuning_examples
        puts "--- GC.configure — 调优示例 ---"
        puts

        params = GC::OPTS.select { |opt| opt.to_s.include?("max") || opt.to_s.include?("min") }
        puts "  GC 配置参数:"
        params.each do |opt|
          begin
            val = GC.const_get(opt)
            puts "    #{opt.to_s.ljust(35)} => #{val}"
          rescue NameError
            nil
          end
        end
        puts

        gc_before = GC.stat
        puts "  调优前: heap_live_slots=#{gc_before[:heap_live_slots]}, heap_free_slots=#{gc_before[:heap_free_slots]}"

        GC.disable
        100_000.times { Array.new(10) }
        gc_during = GC.stat
        puts "  禁用 GC 分配后: heap_live_slots=#{gc_during[:heap_live_slots]}, heap_free_slots=#{gc_during[:heap_free_slots]}"

        GC.enable
        GC.start
        gc_after = GC.stat
        puts "  启用 GC 后:   heap_live_slots=#{gc_after[:heap_live_slots]}, heap_free_slots=#{gc_after[:heap_free_slots]}"
        puts
        puts "  结论: 合理调整 GC 参数可减少不必要的回收停顿"
        puts
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "performance", "性能优化", Hello::Advance::PerformanceSample)
