# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 异常处理 — 实际运行的代码示例
    module ExceptionsSample
      # 自定义异常
      class DivisionError < StandardError; end

      def self.divide(a, b)
        a / b
      rescue ZeroDivisionError => e
        raise DivisionError, "Cannot divide by zero: #{e.message}"
      end

      def self.run
        puts "=== 异常处理 ==="
        puts

        # 1. 基本 rescue
        puts "1. 基本 rescue:"
        begin
          10 / 0
        rescue ZeroDivisionError => e
          puts "   Caught: #{e.class} — #{e.message}"
        end
        puts

        # 2. 自定义异常
        puts "2. 自定义异常:"
        begin
          divide(10, 0)
        rescue DivisionError => e
          puts "   Caught: #{e.class} — #{e.message}"
        end
        puts

        # 3. ensure
        puts "3. ensure:"
        resource = begin
          begin
            raise "Something went wrong"
          ensure
            puts "   ensure: resource cleanup happens"
          end
        rescue
          "rescued"
        end
        puts "   Final result: #{resource}"
        puts

        # 4. rescue 修饰符
        puts "4. rescue modifier:"
        value = undefined_variable rescue "default value"
        puts "   undefined_variable rescue 'default': #{value}"

        safe = Integer("not_a_number") rescue 0
        puts "   Integer('not_a_number') rescue 0: #{safe}"
        puts

        # 5. retry
        puts "5. retry:"
        attempts = 0
        max_attempts = 3
        begin
          attempts += 1
          puts "   Attempt #{attempts}/#{max_attempts}"
          raise "Simulated failure" unless attempts >= max_attempts
          puts "   Success!"
        rescue
          retry if attempts < max_attempts
        end
        puts

        # 6. else 块
        puts "6. else block:"
        begin
          puts "   Normal execution"
        rescue
          puts "   This won't run"
        else
          puts "   else: no exception occurred"
        ensure
          puts "   ensure: always runs"
        end
        puts

        # 7. 异常层级
        puts "7. Exception hierarchy:"
        [StandardError, NoMethodError, ArgumentError, RuntimeError,
         TypeError, KeyError, FrozenError].each do |klass|
          parent = klass.ancestors[1]
          puts "   #{klass.name.split("::").last} < #{parent.name.split("::").last}"
        end
        puts

        # 8. begin..end 代码块返回值
        result = begin
          42
        rescue
          0
        end
        puts "8. begin..end returns value:"
        puts "   begin 42 rescue 0 end => #{result}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "exceptions", "异常处理", Hello::Basic::ExceptionsSample)
