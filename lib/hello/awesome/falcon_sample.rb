# typed: true
# frozen_string_literal: true

require "falcon"
require "rack/test"
require_relative "../topic_registry"

module Hello
  module Awesome
    # FalconSample — 演示 Falcon 异步 HTTP 服务器
    # Falcon 基于 Async gem，使用 Fiber 实现非阻塞 I/O
    class FalconSample
      def self.run
        puts "=== Falcon — 高性能异步 Ruby Web 服务器 ==="
        puts

        # 使用 Rack::Test 测试 Falcon 兼容的 Rack 应用
        client = Rack::Test::Session.new(Rack::MockSession.new(build_rack_app))

        puts "1. Falcon 架构特点"
        puts "  - 基于 Async gem + Fiber 实现异步 I/O"
        puts "  - 每个请求在轻量级 Fiber 中执行"
        puts "  - 支持 HTTP/1.x + HTTP/2 + TLS 原生"
        puts "  - 多进程 + 事件驱动（类似 EventMachine）"
        puts

        puts "2. Rack 兼容应用（可被 Falcon 服务）"
        client.get "/"
        puts "  响应: #{client.last_response.body}"
        puts "  状态码: #{client.last_response.status}"
        puts

        puts "3. JSON API 端点"
        client.get "/api/status"
        puts "  响应: #{client.last_response.body}"
        puts "  状态码: #{client.last_response.status}"
        puts

        puts "4. 路由参数示例"
        client.get "/users/42"
        puts "  响应: #{client.last_response.body}"
        puts "  状态码: #{client.last_response.status}"
        puts

        puts "5. 异步行为演示（Fiber 非阻塞）"
        puts "  Falcon 使用 Async gem 实现真正的非阻塞 I/O"
        puts "  以下代码展示了 Async 块的使用："
        puts
        demo_async_behavior
        puts

        puts "6. Falcon 服务器配置（生产环境）"
        puts "  # config.ru"
        puts "  require 'falcon'"
        puts "  app = proc { |env| [200, { 'Content-Type' => 'text/plain' }, ['Hello from Falcon!']] }"
        puts "  run Falcon::Server.new(app)"
        puts
        puts "  $ falcon serve --bind http://localhost:9292"
        puts "  → 自动使用所有 CPU 核心（多进程）"
        puts "  → 每个请求在独立 Fiber 中处理"
        puts

        puts "--- Falcon 核心特性 ---"
        puts "  异步 I/O: Async gem + Fiber（非线程/进程）"
        puts "  HTTP/2: 原生支持多路复用（一个 TCP 连接多请求）"
        puts "  TLS: 自动生成自签名证书（开发环境）"
        puts "  与 Sinatra 集成: 直接 serve Sinatra::Base 应用"
        puts "  WebSocket: 基于 Async::WebSocket 支持"
      end

      # 构建一个简单的 Rack 应用（兼容 Falcon）
      def self.build_rack_app
        lambda do |env|
          req = Rack::Request.new(env)

          case req.path
          when "/"
            [200, { "Content-Type" => "text/plain" }, ["Hello from Falcon-compatible Rack app!"]]
          when "/api/status"
            [200, { "Content-Type" => "application/json" }, [{ status: "ok", server: "Falcon" }.to_json]]
          when %r{^/users/(\d+)$}
            user_id = Regexp.last_match(1)
            [200, { "Content-Type" => "application/json" }, [{ id: user_id, name: "User #{user_id}" }.to_json]]
          else
            [404, { "Content-Type" => "application/json" }, [{ error: "Not found" }.to_json]]
          end
        end
      end

      # 演示 Async gem 的异步行为（Falcon 的核心）
      def self.demo_async_behavior
        puts "  Async 块启动："
        puts "  Async do"
        puts "    puts \"Start #{Time.now}\""
        puts "    await Async { sleep 1; puts \"Task 1 done #{Time.now}\" }"
        puts "    await Async { sleep 1; puts \"Task 2 done #{Time.now}\" }"
        puts "    puts \"End #{Time.now}\""
        puts "  end"
        puts
        puts "  执行结果（并发执行，总耗时 ~1s 而非 2s）:"
        puts "  Start -> Task 1 & Task 2 并发 -> End"

        # 实际执行演示
        start = Time.now
        Async do
          task1 = Async do
            sleep 0.5
            puts "    [Fiber] Task 1 completed (concurrent)"
          end

          task2 = Async do
            sleep 0.5
            puts "    [Fiber] Task 2 completed (concurrent)"
          end

          task1.wait
          task2.wait
        end

        elapsed = (Time.now - start).round(2)
        puts "    实际耗时: #{elapsed}s（证明非阻塞）"
      end
    end
  end
end

Hello::TopicRegistry.register("awesome", "falcon", "Falcon 异步服务器", Hello::Awesome::FalconSample)
