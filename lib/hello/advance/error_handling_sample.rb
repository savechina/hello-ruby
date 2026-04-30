# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # 错误处理模式 — Result monad, safe navigation, exception chains
    class ErrorHandlingSample
      def self.run
        puts "=== 错误处理模式 ==="
        puts

        # --- 1. Safe Navigation ---
        puts "--- 1. Safe Navigation (&.) ---"
        config = { database: { host: "localhost", port: 5432 }, cache: nil }

        puts "  存在路径: config.dig(:database, :host) = #{config.dig(:database, :host).inspect}"
        puts "  不存在路径: config.dig(:cache, :ttl) = #{config.dig(:cache, :ttl).inspect}"

        nil_value = nil
        puts "  nil&.upcase = #{nil_value&.upcase.inspect} (不抛异常)"
        puts "  nil&.[](0) = #{nil_value&.[](0).inspect} (不抛异常)"
        safe_len = config[:nonexistent]&.length || 0
        puts "  config[:nonexistent]&.length || 0 = #{safe_len}"
        puts

        # --- 2. Result Monads ---
        puts "--- 2. Result Monad（函数式错误处理） ---"
        parser = ResultParser.new

        success_parse = parser.parse_int("42")
        puts "  parse_int('42') = #{success_parse.inspect}"
        double_result = success_parse.bind { |n| parser.double(n) }
        puts "  >> double = #{double_result.inspect}"

        failure_parse = parser.parse_int("not_a_number")
        puts "  parse_int('not_a_number') = #{failure_parse.inspect}"
        failure_chain = failure_parse.bind { |n| parser.double(n) }
        puts "  >> double (chain 中断) = #{failure_chain.inspect}"

        # 链式管道：parse → validate → format
        pipeline_result = parser.parse_int("100")
          .bind { |n| parser.validate_range(n, 0, 200) }
          .bind { |n| Success.new("validated: #{n}") }
        puts "  管道(pipeline): parse_int(100) → validate_range(0,200) → #{pipeline_result.value.inspect}"

        pipeline_fail = parser.parse_int("300")
          .bind { |n| parser.validate_range(n, 0, 200) }
          .bind { |n| Success.new("validated: #{n}") }
        puts "  管道(fail): parse_int(300) → validate_range(0,200) → #{pipeline_fail.error.inspect}"
        puts

        # --- 3. 异常层级 ---
        puts "--- 3. 异常层级与捕获策略 ---"
        errors = ErrorSimulator.new
        puts "  标准异常层级遍历:"
        %w[arg key type runtime frozen].each do |err_type|
          result = errors.try_error(err_type)
          puts "    #{err_type}: rescued? #{result[:rescued]}, message: #{result[:message]}"
        end

        rescue_count = errors.count_rescuable
        puts "  StandardError 可捕获的子类数: #{rescue_count}"
        puts

        # --- 4. 资源清理 ---
        puts "--- 4. 资源清理（ensure/at_exit） ---"
        cleaner = ResourceCleaner.new

        normal_result = cleaner.with_resource("normal") do
          "processing"
        end
        puts "  正常执行: #{normal_result}"
        puts "    资源已清理: #{cleaner.last_cleaned}"

        error_result = cleaner.with_resource("failing") do
          raise "processing error"
        rescue StandardError => e
          "recovered from: #{e.message}"
        end
        puts "  异常恢复: #{error_result}"
        puts "    资源已清理: #{cleaner.last_cleaned}"
        puts

        # --- 5. 装饰器式错误处理 ---
        puts "--- 5. 安全调用模式 ---"
        api_client = APIClient.new

        api_client.safe_call("GET /users") do
          { status: 200, data: [{ id: 1 }] }
        end
        api_client.safe_call("GET /users/999") do
          raise "404 Not Found"
        end
        api_client.safe_call("POST /users") do
          { status: 201, data: { id: 2 } }
        end
        api_client.safe_call("GET /error") do
          raise "Connection timeout"
        end

        stats = api_client.stats
        puts "  总调用: #{stats[:total]}, 成功: #{stats[:success]}, 失败: #{stats[:failed]}"
        puts

        puts "=== 错误处理演示完成 ==="
      end
    end

    # Result Monad 实现
    class Result
      def bind; self; end
      def value; nil; end
      def error; nil; end
    end

    class Success < Result
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def bind(&block)
        block.call(@value)
      end

      def inspect
        "Success(#{@value.inspect})"
      end
    end

    class Failure < Result
      attr_reader :error

      def initialize(error)
        @error = error
      end

      def bind; self; end

      def inspect
        "Failure(#{@error.inspect})"
      end
    end

    module ResultMixin
      def Success(value)
        Hello::Advance::Success.new(value)
      end

      def Failure(error)
        Hello::Advance::Failure.new(error)
      end
    end

    class ResultParser
      include ResultMixin

      def parse_int(str)
        begin
          Success(Integer(str))
        rescue ArgumentError => e
          Failure("invalid integer: #{str} (#{e.message})")
        end
      end

      def double(n)
        Success(n * 2)
      end

      def validate_range(n, min, max)
        if n >= min && n <= max
          Success(n)
        else
          Failure("value #{n} not in range [#{min}, #{max}]")
        end
      end
    end

    class ErrorSimulator
      STANDARD_ERRORS = {
        "arg" => -> { raise ArgumentError, "wrong number of arguments" },
        "key" => -> { { a: 1 }.fetch(:missing) },
        "type" => -> { "string" + 1 },
        "runtime" => -> { raise "runtime error!" },
        "frozen" => -> { "frozen".freeze << "!" }
      }

      def try_error(type)
        action = STANDARD_ERRORS[type]
        return { rescued: false, message: "unknown" } unless action
        action.call
        { rescued: false, message: "no error" }
      rescue StandardError => e
        { rescued: true, message: e.message }
      end

      def count_rescuable
        # 统计 common StandardError subtypes
        [
          ArgumentError, KeyError, TypeError, RuntimeError,
          FrozenError, NoMethodError, NameError, IndexError,
          ZeroDivisionError, FloatDomainError, SystemCallError
        ].count { |c| c < StandardError }
      end
    end

    class ResourceCleaner
      attr_reader :last_cleaned

      def initialize
        @last_cleaned = nil
      end

      def with_resource(name, &block)
        puts "    [resource] 获取资源: #{name}"
        begin
          block.call
        ensure
          @last_cleaned = name
          puts "    [ensure] 释放资源: #{name}"
        end
      end
    end

    class APIClient
      def initialize
        @stats = { total: 0, success: 0, failed: 0 }
      end

      def stats
        @stats.dup
      end

      def safe_call(description)
        @stats[:total] += 1
        result = yield
        @stats[:success] += 1
        puts "  ✓ #{description}: #{result.inspect}"
        result
      rescue StandardError => e
        @stats[:failed] += 1
        puts "  ✗ #{description}: #{e.class} — #{e.message}"
        nil
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "error_handling", "错误处理模式", Hello::Advance::ErrorHandlingSample)
