# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 方法定义与调用
    module Methods
      def self.run
        puts "=== 方法定义与调用 ==="
        puts

        # 1. 基本方法（lambda）
        greet = ->(name) { "Hello, #{name}!" }
        puts greet.call("Ruby")
        puts

        # 2. 默认参数值
        greet_default = ->(name = "World") { "Hi, #{name}!" }
        puts "默认参数: #{greet_default.call}"
        puts "覆盖默认: #{greet_default.call("Alice")}"
        puts

        # 3. 关键字参数
        create_url = ->(host:, port:, path: "/") { "#{host}:#{port}#{path}" }
        puts "关键字参数: #{create_url.call(host: "localhost", port: 8080)}"
        puts "带 path: #{create_url.call(host: "localhost", port: 3000, path: "/api/v1")}"
        puts

        # 4. Splat (*args) — 捕获剩余位置参数为数组
        collect_args = ->(*args) { "收到 #{args.length} 个参数: #{args.inspect}" }
        puts collect_args.call(1, 2, 3, 4)
        # Splat 解构
        first, *rest = [1, 2, 3, 4, 5]
        puts "解构 - first: #{first}, rest: #{rest.inspect}"
        puts

        # 5. Double Splat (**kwargs) — 捕获剩余关键字参数为哈希
        collect_kwargs = ->(**kwargs) { "选项: #{kwargs.inspect}" }
        puts collect_kwargs.call(color: "red", size: "large", active: true)
        puts

        # 6. &block — 捕获传入的块为 Proc
        repeater = ->(n, &block) { n.times { |i| puts "  第 #{i + 1} 次: #{block.call(i)}" } }
        puts "block 参数:"
        repeater.call(3) { |i| "迭代 #{i}" }
        puts

        # 7. Proc.new vs lambda（return 行为差异）
        puts "Proc.new vs lambda (return 行为):"
        outer = -> {
          p = Proc.new { return "从 Proc.new 跳出 lambda" }
          p.call
          "这段不会执行"
        }
        puts "  #{outer.call}"

        outer2 = -> {
          l = lambda { return "仅从 lambda 返回" }
          result = l.call
          "lambda 之后还在这里: #{result}"
        }
        puts "  #{outer2.call}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "methods", "方法定义与调用", Hello::Basic::Methods)
