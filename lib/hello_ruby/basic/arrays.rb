# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 数组操作
    # 涵盖创建、索引、遍历、变换
    module Arrays
      def self.run
        puts "=== 数组操作 ==="
        puts

        # 创建数组
        fruits = ["apple", "banana", "cherry"]
        numbers = Array(1..5)
        # %w 和 %W（支持插值）
        words = %w[foo bar baz]
        puts "字面量: #{fruits.inspect}"
        puts "Array(range): #{numbers.inspect}"
        puts "%w[]: #{words.inspect}"
        puts

        # 索引（支持负数）
        puts "fruits[0]: #{fruits[0]}"
        puts "fruits[-1]: #{fruits[-1]}"     # 最后一个
        puts "fruits[1, 2]: #{fruits[1, 2].inspect}" # 切片
        puts "fruits.last: #{fruits.last}"
        puts "fruits.first(2): #{fruits.first(2).inspect}"
        puts

        # 添加 / 移除
        arr = [1, 2, 3]
        arr.push(4)       # 尾部添加
        arr << 5          # 推入（也支持链式）
        arr.unshift(0)    # 头部添加
        puts "push/<</unshift 后: #{arr.inspect}"
        popped = arr.pop  # 移除并返回尾部
        shifted = arr.shift # 移除并返回头部
        puts "pop => #{popped}, shift => #{shifted}"
        puts "结果: #{arr.inspect}"
        puts

        # map — 对每个元素应用变换
        squared = numbers.map { |n| n ** 2 }
        puts "map(n**2): #{squared.inspect}"
        # 简写 &: 语法
        upper = fruits.map(&:upcase)
        puts "map(&:upcase): #{upper.inspect}"
        puts

        # select / reject — 过滤
        evens = numbers.select(&:even?)
        puts "select(&:even?): #{evens.inspect}"
        odds = numbers.reject(&:even?)
        puts "reject(&:even?): #{odds.inspect}"
        puts

        # reduce / inject — 聚合
        sum = numbers.reduce(0) { |acc, n| acc + n }
        puts "reduce(sum): #{sum}"
        # 使用符号方法
        product = numbers.reduce(1, :*)
        puts "reduce(:*): #{product}"

        # flatten — 展平嵌套数组
        nested = [[1, 2], [3, [4, 5]]]
        puts "flat.flatten: #{nested.flatten.inspect}"
        puts "flat.flatten(1): #{nested.flatten(1).inspect}" # 只展平一层
        puts

        # compact — 移除 nil 元素
        with_nils = [1, nil, 2, nil, 3]
        puts "compact: #{with_nils.compact.inspect}"
        # uniq — 去重
        duplicates = [1, 2, 2, 3, 3, 3]
        puts "uniq: #{duplicates.uniq.inspect}"
        puts

        # each 遍历
        puts "each 遍历:"
        arr = [10, 20, 30]
        arr.each_with_index { |val, idx| puts "  [#{idx}] = #{val}" }
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "arrays", "数组操作", Hello::Basic::Arrays)
