# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 块、Proc、Lambda
    # 涵盖 &block、Proc.new、lambda 及其差异
    module BlocksProcs
      def self.run
        puts "=== 块、Proc、Lambda ==="
        puts

        # --- 1. 块（Block）— 最核心的 Ruby 特性 ---
        puts "块 — 方法通过 yield 隐式调用:"
        [1, 2, 3].each { |n| print "#{n * 10} " }
        puts
        puts

        # 块也可以显式捕获为 Proc
        explicit_capture = ->(&block) {
          puts "显式捕获的 block.class = #{block.class}"
          block.call(42)
        }
        result = explicit_capture.call { |x| "收到: #{x}" }
        puts "  返回值: #{result}"
        puts

        # --- 2. Proc — 一等公民的块 ---
        puts "Proc:"
        my_proc = Proc.new { |x| x * 2 }
        puts "  Proc.new { |x| x * 2 }.call(5) = #{my_proc.call(5)}"

        # Proc.new vs [] 调用
        # Proc 支持 .(), .call, .yield, [] 四种调用方式
        puts "  my_proc[10] = #{my_proc[10]}"
        puts "  my_proc.(15) = #{my_proc.(15)}"
        puts

        # --- 3. Lambda — 更严格的 Proc ---
        puts "Lambda:"
        my_lambda = ->(x) { x * 2 }
        # 或等价写法：lambda { |x| x * 2 }
        puts "  ->(x) { x * 2 }.call(5) = #{my_lambda.call(5)}"
        puts "  lambda.class = #{my_lambda.class}"
        puts

        # --- 4. Proc vs Lambda 的核心差异 ---

        # 差异一：arity（参数检查）
        puts "差异 1 — arity（参数检查）:"
        # Lambda 严格检查参数数量
        strict_lambda = ->(a, b) { a + b }
        puts "  lambda(a, b) 正确调用: #{strict_lambda.call(1, 2)}"
        begin
          strict_lambda.call(1)  # 抛出 ArgumentError
        rescue ArgumentError => e
          puts "  lambda(1) → ArgumentError: #{e.message}"
        end

        # Proc.new 对多余参数忽略，缺失参数填 nil
        loose_proc = Proc.new { |a, b| "a=#{a.inspect}, b=#{b.inspect}" }
        puts "  Proc.new(1, 2, 3) → #{loose_proc.call(1, 2, 3)}"
        puts "  Proc.new(1) → #{loose_proc.call(1)}"
        puts

        # 差异二：return 行为
        puts "差异 2 — return 行为:"

        proc_return_demo = -> do
          p = Proc.new { return "Proc.new 的 return 直接返回外部函数！" }
          p.call
          "这行不会执行"
        end
        puts "  Proc.new return: #{proc_return_demo.call}"

        lambda_return_demo = -> do
          l = lambda { return "仅从 lambda 返回" }
          result = l.call
          "lambda 返回了: '#{result}'，继续执行"
        end
        puts "  lambda return: #{lambda_return_demo.call}"
        puts

        # --- 5. 实用模式：将块作为回调 ---
        puts "实用模式 — 回调:"

        # 模拟一个带回调的方法
        retry_with_callback = ->(retries: 3, &on_attempt) {
          retries.times do |i|
            puts "  尝试 #{i + 1}/#{retries}..."
            on_attempt.call(i + 1)
          end
        }

        retry_with_callback.call { |i| puts "    执行 #{i}" }

        # 链式 Proc 组合
        compose = ->(f, g) { ->(x) { f.call(g.call(x)) } }
        add_one = ->(x) { x + 1 }
        times_two = ->(x) { x * 2 }
        add_then_double = compose.call(times_two, add_one)
        puts
        puts "函数组合 (times_two ∘ add_one)(5) = #{add_then_double.call(5)}"

        # Proc → Symbol 转换
        puts "Proc → Symbol 转换:"
        puts "  %w[hello world].map(&:upcase) = #{%w[hello world].map(&:upcase).inspect}"
        puts "    :upcase 被 .to_proc 自动转换"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "blocks_procs", "块、Proc、Lambda", Hello::Basic::BlocksProcs)
