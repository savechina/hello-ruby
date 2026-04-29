# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # 错误处理模式
    # Result monad、dry-monads、Safe Navigation（&.）、异常层级
    module ErrorHandling
      def self.run
        puts "=== 错误处理模式 ==="
        puts

        # --- 1. Safe Navigation Operator (&.) ---
        puts "--- Safe Navigation（&.） ---"
        user = { profile: { address: { city: "上海" } } }
        puts "  user[:profile][:address][:city] = #{user[:profile][:address][:city]}"
        # 传统方式可能抛 NoMethodError（nil 调用方法）
        # Safe Navigation &. 在 nil 时返回 nil 而非抛异常
        broken = nil
        # broken&.upcase 返回 nil
        puts "  broken&.upcase = #{broken&.upcase.inspect}（不抛异常）"

        # 实际示例
        config = { database: nil }
        # config[:database]&.fetch(:host) 安全访问
        puts "  config[:database]&.fetch(:host) = #{config.dig(:database, :host).inspect}"
        puts

        # --- 2. Result Monad 模式 ---
        puts "--- Result Monad（函数式错误处理）---"
        # Ruby 异常机制是命令式的，函数式编程中常用 Result 模式
        # dry-monads 提供这个模式；这里用纯 Ruby 模拟

        success = ->(value) { { success: true, value: value } }
        failure = ->(error) { { success: false, error: error } }

        bind = ->(result, &handler) {
          return result unless result[:success]
          handler.call(result[:value])
        }

        # 模拟可能失败的操作
        parse_int = ->(str) {
          begin
            success.call(Integer(str))
          rescue ArgumentError => e
            failure.call(e.message)
          end
        }

        double = ->(n) { success.call(n * 2) }

        good_result = bind.call(parse_int.call("42"), &double)
        puts "  parse_int('42') → double → #{good_result}"

        bad_result = bind.call(parse_int.call("not_a_number"), &double)
        puts "  parse_int('not_a_number') → double → #{bad_result}"
        puts

        # --- 3. 异常层级树 ---
        puts "--- 异常层级 ---"
        puts "  Exception"
        puts "  ├── StandardError (rescue 默认捕获)"
        puts "  │   ├── ArgumentError"
        puts "  │   ├── KeyError"
        puts "  │   ├── NoMethodError"
        puts "  │   ├── NameError"
        puts "  │   ├── TypeError"
        puts "  │   ├── RuntimeError"
        puts "  │   ├── FrozenError"
        puts "  │   └── ... (大多数异常)"
        puts "  ├── SignalException"
        puts "  ├── SystemExit"
        puts "  └── Interrupt（Ctrl+C）"
        puts
        puts "  ⚠️  永远不要 rescue Exception → 会捕获 SystemExit 等"
        puts "  ✅  只 rescue StandardError 或其子类"
        puts

        # --- 4. at_exit 与 ensure ---
        puts "--- 清理模式 ---"
        # ensure 保证执行
        resource_demo = -> {
          puts "  获取资源..."
          begin
            raise "处理失败"
          rescue
            puts "  捕获异常"
          ensure
            puts "  ensure: 释放资源（无论是否异常）"
          end
        }
        resource_demo.call
        puts

        # --- 5. 实用模式 — 装饰器式错误处理 ---
        puts "--- 装饰器式错误处理 ---"
        # 用于包装可能失败的外部调用
        safe_call = ->(description, &block) {
          begin
            result = block.call
            puts "  ✓ #{description}: 成功"
            result
          rescue => e
            puts "  ✗ #{description}: #{e.class} — #{e.message}"
            nil
          end
        }

        # 模拟外部 API 调用
        fetch_api = ->(url) {
          if url.include?("error")
            raise "连接超时"
          end
          "{data: from #{url}}"
        }

        safe_call.call("请求 /api/users") { fetch_api.call("/api/users") }
        safe_call.call("请求 /api/error") { fetch_api.call("/api/error") }
        safe_call.call("计算 1/0") { 1 / 0 }
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "error_handling", "错误处理模式", Hello::Advance::ErrorHandling)
