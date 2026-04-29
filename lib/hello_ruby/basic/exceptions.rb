# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 异常处理
    module Exceptions
      class << self
        def divide(a, b)
          a / b
        rescue ZeroDivisionError => e
          raise Hello::ValidationError, "除数不能为零: #{e.message}"
        end
      end

      def self.run
        puts "=== 异常处理 ==="
        puts

        # 1. 基本 rescue
        puts "基本 rescue:"
        begin
          10 / 0
        rescue ZeroDivisionError => e
          puts "  捕获: #{e.class} — #{e.message}"
        end
        puts

        # 2. 多类型 rescue
        puts "多类型 rescue:"
        begin
          Exceptions.divide(10, 0)
        rescue Hello::ValidationError => e
          puts "  自定义异常: #{e.class} — #{e.message}"
        end
        puts

        # 3. ensure — 无论是否异常都会执行
        puts "ensure 示例:"
        result = begin
          begin
            raise "出错了！"
          ensure
            puts "  ensure 块执行（通常用于清理资源）"
          end
        rescue
          "被 rescue 了"
        end
        puts "  最终结果: #{result}"
        puts

        # 4. rescue 修饰符（单行）
        puts "rescue 修饰符:"
        value = undefined_variable rescue "变量不存在，用默认值"
        puts "  undefined_variable rescue default → #{value}"

        safe = Integer("not_a_number") rescue 0
        puts "  Integer(\"not_a_number\") rescue 0 → #{safe}"
        puts

        # 5. retry — 重新执行 begin 块
        puts "retry（限次数重试）:"
        attempts = 0
        max_retries = 3
        begin
          attempts += 1
          puts "  第 #{attempts} 次尝试..."
          raise "模拟失败" unless attempts >= max_retries
          puts "  成功！"
        rescue
          retry if attempts < max_retries
        end
        puts

        # 6. else 块
        puts "else 块（无异常时执行）:"
        begin
          puts "  正常代码"
        rescue
          puts "  有异常"
        else
          puts "  else：没有异常，执行这里"
        ensure
          puts "  ensure：总是执行"
        end
        puts

        # 7. Ruby 异常层级
        puts "异常层级:"
        exceptions = [
          StandardError,
          NoMethodError,
          ArgumentError,
          RuntimeError,
          TypeError,
          KeyError,
          FrozenError,
          SystemStackError
        ]
        exceptions.each do |klass|
          ancestors = klass.ancestors.take(3)
          puts "  #{klass.name.split("::").last} < #{ancestors[1].name.split("::").last}"
        end
        puts
        puts "  注意：StandardError 是大多数异常的直接父类"
        puts "  rescue 默认捕获 StandardError 及其子类"
        puts "  如需捕获所有异常，使用 rescue Exception"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "exceptions", "异常处理", Hello::Basic::Exceptions)
