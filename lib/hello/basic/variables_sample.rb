# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 变量绑定与可变性 — 实际运行的代码示例
    module VariablesSample
      GREETING_CONST = "Hello"

      def self.run
        puts "=== 变量绑定与可变性 ==="
        puts

        # 1. 局部变量绑定
        name = "Ruby"
        version = 3.4
        greeting = "Hello, #{name}!"
        puts "1. 变量绑定:"
        puts "   name = #{name.inspect}"
        puts "   version = #{version}"
        puts "   greeting = #{greeting.inspect}"
        puts

        # 2. 对象引用共享 — 修改会影响所有引用
        original = "hello".dup
        alias_ref = original
        alias_ref << " world"
        puts "2. 引用共享:"
        puts "   original after mutate: #{original.inspect}"
        puts "   alias_ref after mutate: #{alias_ref.inspect}"
        puts "   Same object? #{original.object_id == alias_ref.object_id}"
        puts

        # 3. 重新绑定（创建新对象，不影响原引用）
        a = "first"
        b = a
        a = "second"
        puts "3. Rebinding:"
        puts "   a rebind: #{a.inspect}"
        puts "   b unaffected: #{b.inspect}"
        puts "   Same object? #{a.object_id != b.object_id}"
        puts

        # 4. 常量 — 可修改内容但不能重新赋值
        puts "4. 常量:"
        puts "   GREETING_CONST = #{GREETING_CONST.inspect}"
        puts "   Mutable? #{GREETING_CONST.respond_to?(:<<)}"
        puts "   但重新赋值会警告（不报错）"
        puts

        # 5. 变量 shadowing — 同名变量覆盖外层作用域
        x = 10
        result = begin
          x = 20
          x * 2
        end
        puts "5. 变量 Shadowing:"
        puts "   外层: x = 10"
        puts "   内层: x = 20 → result = #{result}"
        puts "   外层 x 仍是: #{x}"
        puts

        # 6. 平行赋值（交换）
        left = "left"
        right = "right"
        left, right = right, left
        puts "6. 平行赋值（交换）:"
        puts "   交换后: left=#{left.inspect}, right=#{right.inspect}"
        puts

        # 7. 动态类型 — 变量类型随赋值变化
        dynamic = 42
        puts "7. 动态类型:"
        puts "   dynamic = 42 → class: #{dynamic.class}"
        dynamic = "now a string"
        puts "   dynamic = 'now a string' → class: #{dynamic.class}"
        dynamic = [1, 2, 3]
        puts "   dynamic = [1,2,3] → class: #{dynamic.class}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "variables", "变量绑定与可变性", Hello::Basic::VariablesSample)
