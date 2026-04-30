# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 代码块与过程 — 实际运行的代码示例
    module BlocksProcsSample
      # retry 回调方法
      def self.retry_with_callback(retries: 3, &on_attempt)
        retry_count = retries.times.map { |i| on_attempt.call(i + 1) }
        "成功完成 #{retry_count.length} 次回调"
      end

      # yield 资源管理方法
      def self.with_logging(action)
        puts "  [before] start #{action}"
        result = yield
        puts "  [after]  end #{action}"
        result
      end

      def self.run
        puts "=== 代码块与过程 ==="
        puts

        # 1. Block — yield 隐式调用
        mult_result = [1, 2, 3].map { |n| n * 10 }
        puts "1. Block 通过 yield:"
        puts "   [1,2,3].map { |n| n*10 } => #{mult_result.inspect}"
        puts

        # 2. 显式 block 捕获为 Proc
        captured = ->(&block) {
          block.call(42)
        }
        capture_result = captured.call { |x| "received: #{x}" }
        puts "2. 显式捕获 (&block):"
        puts "   block.call(42) => #{capture_result}"
        puts

        # 3. Proc — 一等公民
        my_proc = Proc.new { |x| x * 2 }
        proc_call = my_proc.call(5)
        proc_bracket = my_proc[10]
        proc_dot = my_proc.(15)
        puts "3. Proc:"
        puts "   call(5): #{proc_call}"
        puts "   [10]: #{proc_bracket}"
        puts "   .(15): #{proc_dot}"
        puts

        # 4. Lambda
        my_lambda = ->(x) { x ** 2 }
        puts "4. Lambda:"
        puts "   ->(x) { x**2 }"
        puts "   call(5): #{my_lambda.call(5)}"
        puts "   .(7): #{my_lambda.(7)}"
        puts "   class: #{my_lambda.class}"
        puts "   lambda?: #{my_lambda.lambda?}"
        puts

        # 5. arity 差异
        strict_lambda = ->(a, b) { a + b }
        loose_proc = Proc.new { |a, b| "a=#{a.inspect}, b=#{b.inspect}" }
        puts "5. arity 差异:"
        puts "   lambda(1,2): #{strict_lambda.call(1, 2)}"
        begin
          strict_lambda.call(1)
        rescue ArgumentError => e
          puts "   lambda(1): ArgumentError"
        end
        puts "   Proc(1): #{loose_proc.call(1)}"
        puts "   Proc(1,2,3): #{loose_proc.call(1, 2, 3)}"
        puts

        # 6. return 行为差异
        proc_return = -> do
          p = Proc.new { return "Proc.new escapes outer!" }
          p.call
          "never reached"
        end
        puts "6. return 行为:"
        puts "   Proc.new: #{proc_return.call}"

        lambda_return = -> do
          l = lambda { return "lambda returns locally" }
          ret = l.call
          "continues after lambda: #{ret}"
        end
        puts "   lambda: #{lambda_return.call}"
        puts

        # 7. 回调模式
        callback = ->(retries: 3, &on_attempt) {
          retries.times.map { |i| "attempt #{i + 1}: #{on_attempt.call(i + 1)}" }
        }
        callback_results = callback.call { |i| i * 10 }
        puts "7. 回调模式:"
        callback_results.each { |r| puts "   #{r}" }
        puts

        # 8. 函数组合
        compose = ->(f, g) { ->(x) { f.call(g.call(x)) } }
        add_one = ->(x) { x + 1 }
        times_two = ->(x) { x * 2 }
        composed = compose.call(times_two, add_one)
        puts "8. 函数组合 (times Two ∘ addOne)(5):"
        puts "   composed.call(5) = #{composed.call(5)}"
        puts "   等价于 times_two(add_one(5)) = #{times_two.call(add_one.call(5))}"
        puts

        # 9. Proc → Symbol 转换 (&:to_proc)
        symbols = %w[hello world].map(&:upcase)
        puts "9. Proc→Symbol转换:"
        puts "   %w[hello world].map(&:upcase) = #{symbols.inspect}"
        puts

        # 10. yield 使用
        yield_result = with_logging("computation") { 42 * 2 }
        puts "10. yield 资源管理:"
        puts "   返回值: #{yield_result}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "blocks_procs", "代码块与过程", Hello::Basic::BlocksProcsSample)
