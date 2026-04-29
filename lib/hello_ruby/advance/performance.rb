# typed: true
# frozen_string_literal: true

require "benchmark"
require "objspace"

module Hello
  module Advance
    module Performance
      # --- 字符串优化：拼接 vs array.join ---
      def self.string_concat_demo
        puts "--- 字符串拼接性能对比 ---"

        n = 10_000
        Benchmark.bm(18) do |x|
          # 方式1: += 拼接（每次创建新字符串）
          x.report("+= concat") do
            s = ""
            n.times { |i| s += "line#{i} " }
          end

          # 方式2: Array#join（预缓冲，一次性 joined）
          x.report("array.join") do
            arr = Array.new(n) { |i| "line#{i}" }
            arr.join(" ")
          end

          # 方式3: << 追加（修改原字符串，减少分配）
          x.report("<< append") do
            s = String.new(capacity: n * 7)
            n.times { |i| s << "line#{i} " }
          end

          # 方式4: 插值在循环中
          x.report("interpolation") do
            s = ""
            n.times { |i| s += "line#{i} " }
          end
        end
        puts "  结论: << append 和 array.join 远优于 += 拼接"
      end

      # --- map/map! / each/each_with_object 性能对比 ---
      def self.enumerable_performance_demo
        puts "--- Enumerable 方法性能对比 ---"

        n = 100_000
        data = Array.new(n) { rand(1000) }

        Benchmark.bm(22) do |x|
          # map 创建新数组
          x.report("map (new array)") do
            data.map { |i| i * 2 }
          end

          # map! 原地修改
          x.report("map! (in-place)") do
            data.dup.map! { |i| i * 2 }
          end

          # each_with_object 构建 hash
          x.report("each_with_object") do
            data.each_with_object({}) { |i, h| h[i] = i * 2 }
          end

          # 预分配 hash 的 each
          x.report("each + hash assign") do
            h = {}
            data.each { |i| h[i] = i * 2 }
          end
        end
        puts "  结论: 原地修改(map!)减少分配；构建容器时 each_with_object 语义更清晰"
      end

      # --- 对象分配分析 ---
      def self.object_allocation_demo
        puts "--- 对象分配与优化 ---"

        # 方式1: 每次循环创建新字符串
        count_before1 = ObjectSpace.count_objects[:T_STRING]
        10_000.times { |i| "object_#{i}".upcase }
        count_after1 = ObjectSpace.count_objects[:T_STRING]
        puts "  循环创建字符串: 新增 ~#{count_after1 - count_before1} 个 T_STRING"

        # 方式2: 预分配并复用缓冲区
        buffer = String.new
        count_before2 = ObjectSpace.count_objects[:T_STRING]
        10_000.times do |i|
          buffer.clear
          buffer << "object_#{i}"
          buffer.upcase
        end
        count_after2 = ObjectSpace.count_objects[:T_STRING]
        puts "  复用 buffer:    新增 ~#{count_after2 - count_before2} 个 T_STRING"

        # Array 预分配 vs 动态增长
        puts
        n = 50_000
        Benchmark.bm(14) do |x|
          x.report("push dynamic") do
            arr = []
            n.times { |i| arr << i }
          end

          x.report("pre-allocated") do
            arr = Array.new(n) { |i| i }
          end
        end
        puts "  结论: 预分配减少动态扩容带来的内存重新分配"
      end

      # --- GC.stat 垃圾回收统计 ---
      def self.gc_statistics_demo
        puts "--- GC 统计信息 ---"

        gc_stats = GC.stat
        puts "  GC 运行次数: #{gc_stats[:count]}"
        total_time = gc_stats[:total_time]
        puts "  GC 总耗时（秒）: #{total_time ? total_time.round(4) : "N/A (未启用 GC 测量)"}"
        puts "  活跃对象数: #{gc_stats[:heap_live_slots]}"
        puts "  空闲对象数: #{gc_stats[:heap_free_slots]}"
        puts "  新分配对象数: #{gc_stats[:heap_allocated_slots]}"
        puts "  旧对象数: #{gc_stats[:heap_allocated_oldpages]}"
        puts

        # 触发 GC 并观察变化
        before_count = GC.count
        GC.start
        after_count = GC.count
        puts "  GC.start 前后运行次数: #{before_count} -> #{after_count}"

        # 分配大量对象后观察
        count_before_allocate = GC.count
        100_000.times { Object.new }
        count_after_allocate = GC.count
        puts "  分配10万个对象后GC次数变化: #{count_before_allocate} -> #{count_after_allocate}"
        puts "  （Ruby 会自动触发 GC，无需手动调用）"
      end

      # --- ObjectSpace.count_objects ---
      def self.object_space_demo
        puts "--- ObjectSpace 对象统计 ---"

        objects = ObjectSpace.count_objects
        puts "  总对象数: #{objects[:TOTAL]}"
        puts "  T_OBJECT: #{objects[:T_OBJECT]}（普通 Ruby 对象）"
        puts "  T_ARRAY:  #{objects[:T_ARRAY]}（数组）"
        puts "  T_HASH:   #{objects[:T_HASH]}（哈希）"
        puts "  T_STRING: #{objects[:T_STRING]}（字符串）"
        puts "  T_SYMBOL: #{objects[:T_SYMBOL]}（符号）"
        puts "  T_DATA:   #{objects[:T_DATA]}（C 扩展对象）"
        puts "  T_MODULE: #{objects[:T_MODULE]}（模块/类）"
      end

      # --- 字符串冻结（frozen strings）内存优化 ---
      def self.string_freezing_demo
        puts "--- 字符串冻结 vs 非冻结内存对比 ---"

        # 未冻结：每次创建新对象
        unfrozen_ids = 100.times.map { "frozen_test".dup }.uniq(&:object_id)
        puts "  未冻结（dup）:    #{unfrozen_ids.length} 个独立对象"

        # 冻结：相同的字面量共享内存
        frozen_ids = 100.times.map { :frozen_test.to_s }.uniq(&:object_id)
        puts "  Symbol.to_s:      #{frozen_ids.length} 个独立对象"

        # frozen_string_literal: true 已冻结的字面量
        str1 = "hello_ruby"
        str2 = "hello_ruby"
        puts
        puts "  frozen_string_literal=true 时:"
        puts "    'hello_ruby'.object_id: #{str1.object_id}"
        puts "    'hello_ruby'.object_id: #{str2.object_id}"
        puts "    相同? #{str1.object_id == str2.object_id ? '是（内存共享）' : '否'}"
        puts
        puts "  手动冻结示例:"
        s1 = "manual_freeze".freeze
        s2 = "manual_freeze".freeze
        puts "    'manual_freeze'.freeze.object_id: #{s1.object_id}"
        puts "    'manual_freeze'.freeze.object_id: #{s2.object_id}"
        puts "    相同? #{s1.object_id == s2.object_id ? '是' : '否'}"
        puts "  结论: freeze 减少重复字符串的内存占用"
      end

      # --- 惰性 vs  eagerly 求值 ---
      def self.lazy_vs_eager_demo
        puts "--- 惰性（lazy）vs 立即（eager）求值 ---"

        n = 1_000_000

        # 立即求值：中间产生完整数组
        Benchmark.bm(22) do |x|
          x.report("eager chain") do
            (1..n).map { |i| i * 2 }.select(&:even?).take(10)
          end

          x.report("lazy chain") do
            (1..n).lazy.map { |i| i * 2 }.select(&:even?).take(10).force
          end
        end

        puts
        puts "  立即：map 先处理全部 100 万条 → select → take(10)"
        puts "  惰性：逐元素流过 map → select → 取到 10 个后停止"
        puts "  结论: 处理大规模/无限数据时，lazy 大幅减少不必要的计算"

        # 展示惰性效果
        count = 0
        result = (1..Float::INFINITY).lazy.map { |i| count += 1; i * 2 }
          .select(&:even?)
          .take(5)
          .force
        puts "  惰性调用实际处理了 #{count} 个元素就停止了"
      end

      # --- Benchmark.bmbm 交叉比较 ---
      def self.benchmark_comparison_demo
        puts "--- Benchmark.bmbm 交叉比较（rehearsal） ---"

        n = 50_000

        # bmbm 会先做 rehearse（排练），再做真实测量
        # 消除 JIT/缓存启动效应
        Benchmark.bmbm(16) do |x|
          x.report("sort") { Array.new(n) { rand(n + 1) }.sort }
          x.report("sort!") { a = Array.new(n) { rand(n + 1) }; a.sort! }
          x.report("max")   { Array.new(n) { rand(n + 1) }.max }
          x.report("reduce") { Array.new(n) { rand(n + 1) }.reduce(0, :+) }
        end

        puts "  bmbm vs bm: bmbm 先做一轮排练预热，消除首次运行偏差"
      end

      # --- 热路径优化：减少对象分配 ---
      def self.hot_path_optimization_demo
        puts "--- 热路径性能优化 ---"

        n = 200_000

        Benchmark.bm(24) do |x|
          # 反模式：每次创建中间对象
          x.report("naive: create intermediate") do
            total = 0
            n.times do |i|
              str = i.to_s
              total += str.length
            end
            total
          end

          # 优化1：避免 to_s 调用（直接用整数操作）
          x.report("optimized: integer math") do
            total = 0
            n.times do |i|
              total += (Math.log10(i + 1).to_i + 1)
            end
            total
          end

          # 反模式：创建中间数组
          x.report("naive: intermediate array") do
            Array.new(n) { |i| i }.sum
          end

          # 优化2：直接求和
          x.report("optimized: direct sum") do
            total = 0
            n.times { |i| total += i }
            total
          end
        end
        puts "  结论: 减少中间对象分配能显著提升热路径性能"
      end

      # --- Benchmark.ips 模式（IPS = iterations per second） ---
      def self.ips_pattern_demo
        puts "--- Benchmark.ips 模式（每秒迭代次数） ---"
        puts "  注: benchmark-ips 需作为 gem 引入，此处展示代码模式"
        puts
        puts "  使用方式（需 add 'benchmark-ips' 到 Gemfile）:"
        puts "    require 'benchmark/ips'"
        puts
        puts "    Benchmark.ips do |x|"
        puts "      x.report('plus')   { sum = 0; 10_000.times { |i| sum += i } }"
        puts "      x.report('reduce') { (0...10_000).reduce(:+) }"
        puts
        puts "      x.compare!"  # 输出比较结果
        puts "    end"
        puts
        puts "  输出示例:"
        puts "    plus:    1250.3 i/s"
        puts "    reduce:  890.1 i/s"
        puts "    - plus is 1.40x faster than reduce"
        puts
        puts "  benchmark-ips 优势:"
        puts "    1. 自动 warmup（预热 JIT）"
        puts "    2. 自适应采样（统计显著性）"
        puts "    3. 可读的输出格式"
        puts "    4. compare! 自动对比所有报告"

        # 模拟展示
        puts
        puts "  stdlib Benchmark 也能实现类似效果:"
        n = 50_000
        Benchmark.bm(12) do |x|
          x.report("plus") do
            sum = 0
            n.times { |i| sum += i }
          end
          x.report("reduce") do
            (0...n).reduce(:+)
          end
        end
      end

      # --- GC 控制用于精确测量 ---
      def self.gc_control_demo
        puts "--- GC 控制用于精确测量 ---"

        n = 50_000
        data = Array.new(n) { rand(100) }

        # 禁用 GC 后测量（减少干扰）
        GC.disable
        time_without_gc = Benchmark.measure do
          data.select(&:even?).map { |i| i * 2 }
        end
        GC.enable

        # 启用 GC 测量
        time_with_gc = Benchmark.measure do
          data.select(&:even?).map { |i| i * 2 }
        end

        puts "  禁用 GC: #{time_without_gc.real.round(4)}s"
        puts "  启用 GC: #{time_with_gc.real.round(4)}s"
        puts "  注意: GC.disable 仅供特定测量场景，生产代码中慎用"
      end

      def self.run
        puts "=== Ruby 性能优化 ==="
        puts
        string_concat_demo
        puts
        enumerable_performance_demo
        puts
        object_allocation_demo
        puts
        gc_statistics_demo
        puts
        object_space_demo
        puts
        string_freezing_demo
        puts
        lazy_vs_eager_demo
        puts
        benchmark_comparison_demo
        puts
        hot_path_optimization_demo
        puts
        ips_pattern_demo
        puts
        gc_control_demo
        puts
        puts "=== 性能优化演示完成 ==="
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "performance", "性能优化", Hello::Advance::Performance)
