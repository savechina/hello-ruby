# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 变量类型与作用域
    module Variables
      class << self
        # 类变量演示计数器
        attr_reader :counter_count

        def reset_counter
          @@count = 0
        end

        def increment_counter
          @@count ||= 0
          @@count += 1
        end
      end

      def self.run
        puts "=== 变量类型与作用域 ==="
        puts

        # 1. 局部变量（小写字母或下划线开头）
        greeting = "你好，Ruby！"
        count = 42

        puts "局部变量 - greeting: #{greeting}"
        puts "  count: #{count}"
        puts

        # 2. 实例变量（@ 开头）
        # 作用域：当前对象实例
        obj = Object.new
        class << obj
          attr_accessor :name
        end
        obj.name = "实例对象"
        puts "实例变量 - obj.name: #{obj.name}"
        puts

        # 3. 类变量（@@ 开头）
        # 作用域：当前类及其所有子类（共享！）
        reset_counter
        increment_counter
        increment_counter
        increment_counter
        puts "类变量 - 创建了 #{@@count || 0} 次调用计数器"
        puts

        # 4. 全局变量（$ 开头）
        $global_config = { version: "0.1.0", debug: false }
        puts "全局变量 - $global_config: #{$global_config}"
        puts

        # Ruby 是动态类型语言，变量类型随赋值改变
        x = 10
        puts "动态类型 - x 初始为 Integer: #{x.class}"
        x = "现在是字符串"
        puts "动态类型 - x 变为 String: #{x.class}"

        # 常量以大写字母开头
        # 重新赋值会给出警告，不会报错
        max_retries = 3
        puts "常量示例 - MAX_RETRIES: #{max_retries}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "variables", "变量类型与作用域", Hello::Basic::Variables)
