# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 方法定义 — 实际运行的代码示例
    module MethodsSample
      # 基本方法定义（方法返回值是最后一个表达式）
      def self.greet(name)
        "Hello, #{name}!"
      end

      # 默认参数
      def self.greet_default(name = "World")
        "Hi, #{name}!"
      end

      # 关键字参数
      def self.build_url(host:, port:, path: "/")
        "#{host}:#{port}#{path}"
      end

      # 可变参数
      def self.collect(*args)
        "收到 #{args.length} 个参数: #{args.inspect}"
      end

      # 关键字可变参数
      def self.collect_options(**kwargs)
        "选项: #{kwargs.inspect}"
      end

      # Block 参数
      def self.repeat(n, &block)
        n.times.map { |i| block.call(i) }
      end

      # yield 隐式 block
      def self.with_resource(name)
        puts "  [setup] 准备资源: #{name}"
        result = yield
        puts "  [cleanup] 释放资源: #{name}"
        result
      end

      def self.run
        puts "=== 方法定义 ==="
        puts

        # 1. 基本方法
        result = greet("Ruby")
        puts "1. 基本方法: greet('Ruby') => #{result}"
        puts

        # 2. 默认参数
        default_result = greet_default()
        override_result = greet_default("Alice")
        puts "2. 默认参数:"
        puts "   greet_default() => #{default_result}"
        puts "   greet_default('Alice') => #{override_result}"
        puts

        # 3. 关键字参数
        url1 = build_url(host: "localhost", port: 8080)
        url2 = build_url(host: "localhost", port: 3000, path: "/api/v1")
        puts "3. 关键字参数:"
        puts "   build_url(host:, port:) => #{url1}"
        puts "   build_url with path => #{url2}"
        puts

        # 4. *args 可变参数
        args_msg = collect(1, 2, 3, 4)
        puts "4. *args: #{args_msg}"
        first, *rest = [1, 2, 3, 4, 5]
        puts "   解构: first=#{first}, rest=#{rest.inspect}"
        puts

        # 5. **kwargs
        opts_msg = collect_options(color: "red", size: "large", active: true)
        puts "5. **kwargs: #{opts_msg}"
        puts

        # 6. 显式 block 参数
        results = repeat(3) { |i| "iteration #{i}" }
        puts "6. 显式 block (&block):"
        results.each { |r| puts "   #{r}" }
        puts

        # 7. yield 隐式 block
        computed = with_resource("database") { 42 * 2 }
        puts "7. yield 隐式 block:"
        puts "   方法返回值: #{computed}"
        puts

        # 8. Lambda vs Method
        add_l = ->(a, b) { a + b }
        mult_l = ->(a, b) { a * b }
        puts "8. Lambda 调用:"
        puts "   add.call(3, 4) => #{add_l.call(3, 4)}"
        puts "   mult.(5, 6) => #{mult_l.(5, 6)}"
        puts "   add[10, 20] => #{add_l[10, 20]}"
        puts

        # 9. Proc.new vs lambda — return 行为
        outer_proc = -> do
          p = Proc.new { return "从 Proc.new 直接跳出外层" }
          p.call
          "不会执行"
        end
        puts "9. Proc.new vs lambda return:"
        puts "   Proc.new: #{outer_proc.call}"

        outer_lambda = -> do
          l = lambda { return "仅从 lambda 返回" }
          ret = l.call
          "lambda 后继续: #{ret}"
        end
        puts "   lambda: #{outer_lambda.call}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "methods", "方法定义与调用", Hello::Basic::MethodsSample)
