# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    class TemperatureReadings
      include Enumerable

      def initialize(locations)
        @data = locations
      end

      def each(&block)
        @data.each(&block)
      end

      def average
        sum = map { |_, t| t }.reduce(0, :+)
        sum / count
      end

      def hottest
        max_by { |_, t| t }
      end

      def coldest
        min_by { |_, t| t }
      end
    end

    module Enumerable
      def self.run
        puts "=== Enumerable 深度探索 ==="
        puts

        # --- 1. 自定义 Enumerable 类 ---
        puts "--- 实现自定义 Enumerable ---"
        readings = TemperatureReadings.new([
          ["北京", 28], ["上海", 32], ["广州", 35],
          ["哈尔滨", 18], ["成都", 26], ["武汉", 33]
        ])

        puts "  城市气温:"
        readings.each { |city, temp| puts "    #{city}: #{temp}°C" }
        puts "  平均气温: #{readings.average}°C"
        puts "  最热: #{readings.hottest[0]} (#{readings.hottest[1]}°C)"
        puts "  最冷: #{readings.coldest[0]} (#{readings.coldest[1]}°C)"
        puts
        puts "  所有 Enumerable 方法:"
        puts "    select(>30): #{readings.select { |_, t| t > 30 }.map(&:first).join(", ")}"
        puts "    count: #{readings.count}"
        puts "    any?(>40): #{readings.any? { |_, t| t > 40 }}"
        puts

        # --- 2. lazy 延迟求值 ---
        puts "--- lazy（惰性序列） ---"

        fib = Enumerator.new do |yielder|
          a = 0
          b = 1
          loop do
            yielder << a
            a, b = b, a + b
          end
        end

        first_three_even = fib.lazy.select { |n| n > 100 && n.even? }.take(3).force
        puts "  斐波那契 > 100 的前3个偶数: #{first_three_even.inspect}"
        puts "  lazy 允许操作无限序列——take(3) 后停止计算"

        large_range = (1..1_000_000)
        result = large_range.lazy.select(&:even?).map { |n| n * 3 }.take(5).force
        puts "  lazy 大数组: 前5个偶数×3 = #{result.inspect}"
        puts

        # --- 3. minmax_by ---
        puts "--- minmax_by ---"
        words = %w[apple banana cherry date elderberry fig grape]
        minmax = words.minmax_by { |s| s.length }
        puts "  最短最长词: #{minmax.inspect}"

        num_minmax = [15, 3, 42, 7, 28, 1].minmax_by { |n| Math.sqrt(n) }
        puts "  平方根最小最大: #{num_minmax.inspect}"
        puts

        # --- 4. chunk_while ---
        puts "--- chunk_while ---"
        numbers = [1, 2, 3, 5, 6, 8, 10, 11, 12]
        consecutive_groups = numbers.chunk_while { |a, b| b == a + 1 }.to_a
        puts "  #{numbers.inspect}.chunk_while(b==a+1) = #{consecutive_groups.inspect}"

        parity_groups = [1, 3, 5, 2, 4, 7, 9, 11].chunk_while { |a, b| (a.odd? && b.odd?) || (a.even? && b.even?) }.to_a
        puts "  奇偶分组: #{parity_groups.inspect}"
        puts

        # --- 5. slice_after ---
        puts "--- slice_after ---"
        mixed = ["# 标题", "内容1", "内容2", "# 章节", "内容3", "# 结束"]
        sections = mixed.slice_after(/^#/).to_a
        puts "  按 # 开头分割:"
        sections.each_with_index { |section, i| puts "    段#{i}: #{section.inspect}" }
        puts

        # --- 6. grep_v ---
        puts "--- grep_v（反向匹配） ---"
        words2 = %w[hello world ruby programming rust c golang python]
        longer_than_5 = words2.grep_v(/^. {0,5}$/)
        puts "  长度>5的单词: #{longer_than_5.join(", ")}"

        emails = %w[user@example.com admin@test.org not_an_email root@localhost]
        invalid = emails.grep_v(/@.*\./)
        puts "  无效邮件地址: #{invalid.join(", ")}"
        puts

        # --- 7. 核心方法清单 ---
        puts "--- Enumerable 提供的核心方法 ---"
        methods = [
          "所有", "any?", "count", "detect/find", "drop/drop_while",
          "each_cons", "each_slice", "each_with_index", "find_index",
          "first", "flat_map/collect", "group_by", "include?",
          "inject/reduce", "max/min", "max_by/min_by", "minmax",
          "none?", "one?", "partition", "select/filter",
          "sort/sort_by", "take/take_while", "tally",
          "to_h", "zip"
        ]
        puts "  共 #{methods.length} 个核心方法"
        puts "  #{methods.join(", ")}"
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "enumerable", "Enumerable 深度探索", Hello::Advance::Enumerable)
