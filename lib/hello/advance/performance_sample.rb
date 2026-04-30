# typed: true
# frozen_string_literal: true

require "benchmark"
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
        puts "=== 性能优化演示完成 ==="
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "performance", "性能优化", Hello::Advance::PerformanceSample)
