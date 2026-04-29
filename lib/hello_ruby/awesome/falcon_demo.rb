# typed: true
# frozen_string_literal: true

module Hello
  module Awesome
    # Falcon async web server 模式 — 基于 Async 框架的异步 HTTP 服务器
    # 演示 Rack app、异步处理器、Fiber 调度、HTTP/2、WebSocket 升级
    module FalconDemo
      def self.run
        puts "=== Falcon Async Web Server ==="
        puts

        puts "Falcon 是什么？"
        puts "  Falcon 是一个基于 async 框架的现代 Ruby web 服务器。"
        puts "  它利用 Fiber 实现协程式并发，在单线程中处理大量并发连接。"
        puts "  兼容 Rack 接口，可直接运行 Rack/Rails/Sinatra 应用。"
        puts

        # --- 1. 基本 Rack App ---
        puts "--- Rack App：Falcon 兼容标准 Rack 接口 ---"
        example_code = <<~RUBY
          # config.ru — 标准 Rack 配置文件
          require "falcon"

          # Rack 应用：接受 env 哈希，返回 [status, headers, body]
          app = proc do |env|
            request = Rack::Request.new(env)

            [
              200,
              { "Content-Type" => "text/html" },
              ["<h1>Hello from Falcon at #{request.url}</h1>"]
            ]
          end

          # 运行
          # falcon run --bind https://localhost:9292
          # Falcon 自动绑定 rackup 中的 app
        RUBY
        puts "  #{example_code.strip}"
        puts "  → 标准 Rack app 接口：[status, headers, body]"
        puts

        # --- 2. 异步 Handler ---
        puts "--- 异步处理：async 协程 + Fiber ---"
        example_code2 = <<~RUBY
          require "falcon"
          require "async"
          require "async/http/endpoint"
          require "net/http"
          require "json"

          # 异步 Rack app
          class AsyncApp
            def call(env)
              async do
                request = Async::HTTP::Request.wrap(env)

                # 模拟异步 I/O（如外部 API 调用）
                external_data = await fetch_external_data

                # 模拟数据库查询（异步数据库驱动）
                records = await query_database

                [
                  200,
                  { "Content-Type" => "application/json" },
                  [JSON.generate({ data: external_data, records: records })]
                ]
              end
            end

            private

            def fetch_external_data
              # 异步 HTTP 请求，不阻塞事件循环
              Async do |task|
                endpoint = Async::HTTP::Endpoint.parse("https://api.example.com")
                endpoint.get("/data")
              end
            end

            def query_database
              Async do |task|
                # 异步数据库查询
                # await db.execute("SELECT * FROM users")
                [{ id: 1, name: "Alice" }, { id: 2, name: "Bob" }]
              end
            end
          end
        RUBY
        puts "  #{example_code2.strip}"
        puts "  → async { ... } 创建 Fiber，await 暂停执行直到 I/O 完成"
        puts "  → Fiber 切换成本极低，单事件循环可处理数万并发"
        puts

        # --- 3. Fiber Scheduler ---
        puts "--- Fiber Scheduler 事件调度器 ---"
        example_code3 = <<~RUBY
          require "async"

          # Fiber 调度器自动替换 Ruby 标准库的阻塞 I/O
          # 让 Socket、IO、wait 等标准库变为异步非阻塞

          # 手动启用 Fiber Scheduler（Ruby 3.0+）
          Async do
            # 在此 block 中，所有标准 I/O 变为异步
            socket = TCPSocket.new("example.com", 80)
            socket.write("GET / HTTP/1.1\\r\\nHost: example.com\\r\\n\\r\\n")
            response = socket.read
            # ↑ 不会阻塞线程，Fiber Scheduler 自动 yield

            # 多个并发任务
            tasks = 5.times.map do |i|
              Async do
                # 每个 Async block 是一个独立的 Fiber
                sleep 0.1  # 异步 sleep，不阻塞
                puts "Task #{i} completed"
              end
            end

            # 等待所有任务完成
            tasks.map(&:wait)
          end

          # Falcon 内部自动使用 Fiber Scheduler
          # 你写的普通 Ruby 代码（Socket、IO）在 Falcon 中自动异步化
        RUBY
        puts "  #{example_code3.strip}"
        puts "  → Fiber Scheduler 让阻塞式代码自动变为异步，无需改写"
        puts

        # --- 4. HTTP/2 支持 ---
        puts "--- HTTP/2 支持 ---"
        example_code4 = <<~RUBY
          # Falcon 内置 HTTP/2 和 HTTP/3 支持
          # 自动使用 ALPN 协议协商

          # 命令行启用
          # $ falcon run --bind https://0.0.0.0:9292
          #
          # 自动启用 TLS + HTTP/2（无需额外配置）
          #
          # HTTP/2 特性：
          # - 多路复用：单连接并发多个请求（无队头阻塞）
          # - 头部压缩：HPACK 算法减少开销
          # - 服务器推送：Server Push 主动发送资源
          #
          # 测试 HTTP/2
          # $ curl --http2 -v https://localhost:9292
          # 应看到：
          #   ALPN, offering h2
          #   SSL connection using TLS 1.3
          #   HTTP/2 200

          # 编程方式配置
          require "async/http/endpoint"

          endpoint = Async::HTTP::Endpoint.parse("https://localhost:9292")
          # endpoint.protocol 自动选择 :http2, :http11

          # 强制 HTTP/2
          endpoint2 = Async::HTTP::Endpoint.parse("https://localhost:9292", protocol: :h2)
        RUBY
        puts "  #{example_code4.strip}"
        puts "  → HTTP/2 默认启用，零配置"
        puts

        # --- 5. WebSocket 升级 ---
        puts "--- WebSocket 升级模式 ---"
        example_code5 = <<~RUBY
          require "falcon"
          require "async/http/endpoint"
          require "falcon/websocket"

          class WebSocketApp
            def call(env)
              # 检测 WebSocket 升级
              if Falcon::WebSocket.websocket?(env)
                # 升级为 WebSocket 连接
                return Falcon::WebSocket.open(env, method: :on_connect)
              end

              # 普通 HTTP 响应
              [200, { "Content-Type" => "text/html" }, ["Hello!"]]
            end

            def on_connect(connection)
              puts "WebSocket connected: #{connection.object_id}"

              # WebSocket 消息循环
              loop do
                message = connection.read
                break if message.nil?  # 连接关闭

                case message
                when "ping"
                  connection.write("pong")

                when /^echo (.+)$/
                  connection.write("echo: #{$1}")

                else
                  connection.write("received: #{message}")
                end
              end

              puts "WebSocket disconnected: #{connection.object_id}"
            end
          end

          # 客户端连接
          # const ws = new WebSocket('ws://localhost:9292')
          # ws.send('ping')        → "pong"
          # ws.send('echo hello')  → "echo: hello"
        RUBY
        puts "  #{example_code5.strip}"
        puts "  → WebSocket 升级：检测 -> open -> 消息循环 -> 关闭"
        puts

        # --- 6. Falcon 运行模型 ---
        puts "--- Falcon 运行模型 ---"
        puts "  架构："
        puts "  ┌──────────────────────────────────┐"
        puts "  │  Falcon Server (main Fiber)       │"
        puts "  │  ┌────────────────────────────┐   │"
        puts "  │  │  Fiber Scheduler            │   │"
        puts "  │  │  ┌──────┐ ┌──────┐ ┌──────┐│   │"
        puts "  │  │  │Fiber1│ │Fiber2│ │FiberN││   │"
        puts "  │  │  └──────┘ └──────┘ └──────┘│   │"
        puts "  │  │  (并发 HTTP 请求处理)       │   │"
        puts "  │  └────────────────────────────┘   │"
        puts "  └──────────────────────────────────┘"
        puts
        puts "  与 Puma 对比："
        puts "  ┌──────────┬────────────────┬────────────────────┐"
        puts "  │ 特性     │ Puma           │ Falcon             │"
        puts "  ├──────────┼────────────────┼────────────────────┤"
        puts "  │ 并发模型 │ 线程池          │ Fiber（协程）       │"
        puts "  │ 内存占用 │ 每个线程 ~1MB   │ 每个 Fiber ~16KB   │"
        puts "  │ HTTP/2   │ 支持            │ 原生支持            │"
        puts "  │ HTTP/3   │ ❌              │ ✅ (通过 async-nng)│"
        puts "  │ WebSocket│ 支持            │ 原生支持            │"
        puts "  │ 生态     │ 成熟（Rails 默认）│ 新兴但快速          │"
        puts "  └──────────┴────────────────┴────────────────────┘"
        puts
        puts "  模拟请求处理："
        puts "  → Client 连接 → Fiber Scheduler 分配 Fiber → 处理请求 → 发送响应 → Fiber 回收"
        puts "  → 并发 10,000 连接：Puma 需要 1000 线程，Falcon 需要 1 个线程 + 10,000 Fibers"
      end
    end
  end
end

Hello::TopicRegistry.register("awesome", "falcon_demo", "Falcon 异步 Web 服务器模式", Hello::Awesome::FalconDemo)
