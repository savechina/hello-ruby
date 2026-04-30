# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 数组操作 — 实际运行的代码示例
    module ArraysSample
      def self.run
        puts "=== 数组操作 ==="
        puts

        # 1. 数组创建
        fruits = ["apple", "banana", "cherry"]
        numbers = Array(1..5)
        words = %w[foo bar baz qux]
        mixed = [1, "two", 3.0, true]
        puts "1. 数组创建:"
        puts "   fruits: #{fruits.inspect}"
        puts "   numbers (1..5): #{numbers.inspect}"
        puts "   words (%w): #{words.inspect}"
        puts "   mixed: #{mixed.inspect}"
        puts

        # 2. 索引与切片
        puts "2. 索引与切片:"
        puts "   fruits[0]: #{fruits[0]}"
        puts "   fruits[-1]: #{fruits[-1]}"
        puts "   fruits[1, 2]: #{fruits[1, 2].inspect}"
        puts "   fruits.first(2): #{fruits.first(2).inspect}"
        puts "   fruits.last: #{fruits.last}"
        puts

        # 3. 添加与移除
        arr = [1, 2, 3]
        arr << 4
        arr.push(5)
        arr.unshift(0)
        puts "3. 添加后: #{arr.inspect}"
        popped = arr.pop
        shifted = arr.shift
        puts "   pop => #{popped}, shift => #{shifted}"
        puts "   结果: #{arr.inspect}"
        puts

        # 4. map — 转换
        squared = numbers.map { |n| n**2 }
        upper_fruits = fruits.map(&:upcase)
        puts "4. map:"
        puts "   map { |n| n**2 }: #{squared.inspect}"
        puts "   map(&:upcase): #{upper_fruits.inspect}"
        puts

        # 5. select / reject — 过滤
        evens = numbers.select(&:even?)
        odds = numbers.reject(&:even?)
        long_fruits = fruits.select { |f| f.length > 5 }
        puts "5. select / reject:"
        puts "   select(&:even?): #{evens.inspect}"
        puts "   reject(&:even?): #{odds.inspect}"
        puts "   fruits longer than 5 chars: #{long_fruits.inspect}"
        puts

        # 6. reduce — 聚合
        sum = numbers.reduce(0, :+)
        product = numbers.reduce(1, :*)
        concat = fruits.reduce("[]") { |acc, f| "#{acc}#{f}" }
        puts "6. reduce:"
        puts "   reduce(0, :+): #{sum}"
        puts "   reduce(1, :*): #{product}"
        puts "   reduce concat: #{concat}"
        puts

        # 7. flatten 展平
        nested = [[1, 2], [3, [4, 5]]]
        puts "7. flatten:"
        puts "   nested.flatten: #{nested.flatten.inspect}"
        puts "   nested.flatten(1): #{nested.flatten(1).inspect}"
        puts

        # 8. uniq & compact
        with_nils = [1, nil, 2, nil, 3, nil]
        duplicates = [1, 2, 2, 3, 3, 3]
        puts "8. compact & uniq:"
        puts "   compact: #{with_nils.compact.inspect}"
        puts "   uniq:    #{duplicates.uniq.inspect}"
        puts "   uniq.sort: #{duplicates.uniq.sort.inspect}"
        puts

        # 9. each_with_index 遍历
        puts "9. each_with_index:"
        colors = %w[red green blue]
        colors.each_with_index do |color, index|
          puts "   [#{index}] = #{color}"
        end
        puts

        # 10. zip — 配对
        ids = [1, 2, 3]
        names_z = %w[Alice Bob Charlie]
        paired = ids.zip(names_z)
        puts "10. zip:"
        puts "   ids:    #{ids.inspect}"
        puts "   names:  #{names_z.inspect}"
        puts "   zipped: #{paired.inspect}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "arrays", "数组操作", Hello::Basic::ArraysSample)
