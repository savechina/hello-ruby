# typed: true
# frozen_string_literal: true

require "json"

module Hello
  module Advance
    # Enumerable 深度探索 — 自定义 Enumerable, lazy, chunk_while, group_by
    class EnumerableSample
      def self.run
        puts "=== Enumerable 深度探索 ==="
        puts

        # --- 1. 自定义 Enumerable ---
        puts "--- 1. 自定义 Enumerable 类 ---"
        scores = ScoreCollection.new([85, 92, 78, 96, 88, 73, 91])

        puts "  成绩数据: #{scores.to_a.inspect}"
        puts "  平均值: #{scores.average}"
        puts "  最高分: #{scores.max_score}"
        puts "  通过率(≥60): #{scores.pass_rate}"
        puts "  分数段分布: #{scores.distribution}"
        puts "  所有 ≥ 90? #{scores.all? { |s| s >= 90 }}"
        puts "  存在 ≥ 90? #{scores.any? { |s| s >= 90 }}"
        puts

        # --- 2. lazy 延迟求值 ---
        puts "--- 2. 惰性序列 ---"

        # Fibonacci 无限序列的惰性访问
        counter = Counter.new
        even_fibs = []
        counter.each.lazy.select { |n| n > 100 && n.even? }.take(5).each do |val|
          even_fibs << val
        end
        puts "  Fibonacci > 100 的前 5 个偶数: #{even_fibs.inspect}"
        puts "  实际计算了 #{counter.counted} 项（而非全部）"

        # 大数据集 lazy 链式操作
        large_range = (1..1_000_000)
        lazy_result = large_range.lazy.select(&:even?).map { |n| n * 3 }.take(5).force
        puts "  1..1000000 的 前5个偶数×3(lazy): #{lazy_result.inspect}"

        eager_result = (1..1_000_000).select(&:even?).map { |n| n * 3 }[0, 5]
        puts "  1..1000000 的 前5个偶数×3(eager): #{eager_result.inspect}"
        puts "  lazy 只对需要的元素求值，eager 会先处理全部 100 万条"
        puts

        # --- 3. chunk_while ---
        puts "--- 3. 连续分组（chunk_while） ---"
        numbers = [1, 2, 3, 5, 6, 8, 10, 11, 12, 15]
        consecutive = numbers.chunk_while { |a, b| b == a + 1 }.to_a
        puts "  数据: #{numbers.inspect}"
        puts "  chunk_while 连续分组: #{consecutive.inspect}"

        # 按奇偶分组
        parity = [1, 3, 5, 2, 4, 7, 9, 11].chunk_while { |a, b| (a.odd? && b.odd?) || (a.even? && b.even?) }.to_a
        puts "  奇偶分组: #{parity.inspect}"

        # 按大小写分组
        chars = %w[a b c A B c d A].chunk_while { |a, b| a == a.downcase && b == b.downcase || a == a.upcase && b == b.upcase }.to_a
        puts "  大小写分组: #{chars.inspect}"
        puts

        # --- 4. slice_before / slice_after ---
        puts "--- 4. 分割序列 ---"
        lines = ["# Ch1", "Content1", "Content2", "# Ch2", "Content3", "# Ch3", "Content4", "Content5"]
        chapters = lines.slice_before(/^#/).to_a
        puts "  输入: #{lines.inspect}"
        puts "  slice_before 按 # 分割:"
        chapters.each_with_index do |chapter, i|
          puts "    章节#{i + 1}: #{chapter.inspect}"
        end
        puts

        # --- 5. group_by + tally ---
        puts "--- 5. group_by 与 tally ---"
        words = %w[apple banana cherry apple date banana apple elderberry]
        grouped = words.group_by(&:length)
        puts "  按长度分组: #{grouped.transform_values(&:length).to_h.inspect}"
        counts = words.tally
        puts "  tally 统计: #{counts.inspect}"
        puts "  最高频: #{counts.max_by { |_, c| c }.first} (#{counts.max_by { |_, c| c }.last}次)"
        puts

        # --- 6. 高级枚举模式 ---
        puts "--- 6. 高级枚举方法 ---"

        # each_cons
        pairs = (1..6).each_cons(2).to_a
        puts "  each_cons(2) on 1..6: #{pairs.inspect}"

        # each_slice
        chunks = (1..10).each_slice(3).to_a
        puts "  each_slice(3) on 1..10: #{chunks.inspect}"

        # each_with_index + map
        indexed = %w[a b c].each_with_index.map { |v, i| "#{v}:#{i}" }
        puts "  each_with_index.map: #{indexed.inspect}"

        # partition
        evens, odds = (1..10).partition(&:even?)
        puts "  partition(even?): 偶=#{evens.inspect}, 奇=#{odds.inspect}"

        # minmax_by
        people = [{ name: "Alice", score: 88 }, { name: "Bob", score: 95 }, { name: "Carol", score: 72 }]
        min_person, max_person = people.minmax_by { |p| p[:score] }
        puts "  minmax_by(score): 最低=#{min_person[:name]}(#{min_person[:score]}), 最高=#{max_person[:name]}(#{max_person[:score]})"

        # detect
        found = (1..100).detect { |n| n % 7 == 0 && n % 5 == 0 }
        puts "  detect(同时被7和5整除): first = #{found}"

        # grep / grep_v
        emails = %w[user@example.com admin@test.org invalid not@domain root@localhost]
        valid = emails.grep(/@.*\./)
        invalid = emails.grep_v(/@.*\./)
        puts "  grep(有效邮箱): #{valid.inspect}"
        puts "  grep_v(无效邮箱): #{invalid.inspect}"

        # zip
        names = %w[Alice Bob Carol]
        ages = [30, 25, 35]
        paired = names.zip(ages)
        puts "  zip(名字+年龄): #{paired.inspect}"
        hash_from_zip = names.zip(ages).to_h
        puts "  zip.to_h: #{hash_from_zip.inspect}"

        puts
        puts "=== Enumerable 演示完成 ==="
      end
    end

    # 自定义 Enumerable 集合
    class ScoreCollection
      include Enumerable

      def initialize(scores)
        @scores = scores
      end

      def each(&block)
        @scores.each(&block)
      end

      def average
        return 0 if @scores.empty?
        reduce(0, :+).fdiv(count).round(1)
      end

      def max_score
        max
      end

      def pass_rate
        return "0.0%" if @scores.empty?
        passing = count { |s| s >= 60 }
        "#{(passing.fdiv(count) * 100).round(1)}%"
      end

      def distribution
        groups = group_by do |s|
          case s
          when 90..100 then "A"
          when 80..89 then "B"
          when 70..79 then "C"
          when 60..69 then "D"
          else "F"
          end
        end
        groups.transform_values(&:length).sort.to_h
      end
    end

    # 计数器：生成 Fibonacci 数列
    class Counter
      attr_reader :counted

      def initialize
        @counted = 0
      end

      def each(&block)
        return to_enum unless block_given?
        a = 0
        b = 1
        loop do
          @counted += 1
          block.call(a)
          a, b = b, a + b
        end
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "enumerable", "Enumerable 深度探索", Hello::Advance::EnumerableSample)
