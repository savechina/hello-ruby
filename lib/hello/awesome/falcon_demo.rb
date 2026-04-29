# typed: true
# frozen_string_literal: true

require "json"

module Hello
  module Awesome
    class FalconDemo
      def self.run
        puts "=== Falcon — 高性能异步 Ruby Web 服务器 ==="
        puts

        puts "1. 核心架构"
        puts "  Falcon = 多进程 + 多 Fiber HTTP 服务器"
        puts "  每个请求在轻量级 Fiber 中执行"
        puts "  支持 HTTP/1.x + HTTP/2 + TLS 原生"
        puts "  基于 async + async-http gem (Socketry 开发)"
        puts

        puts "2. Rack 兼容性"
        config_ru = ->(env) { [200, { "Content-Type" => "text/plain" }, ["Hello Falcon!"]] }
        status, headers, body = config_ru.call({ "REQUEST_METHOD" => "GET", "PATH_INFO" => "/" })
        puts "  状态码: #{status}"
        puts "  响应头: #{headers}"
        puts "  响应体: #{body.first}"
        puts

        puts "3. 快速启动"
        puts "  $ gem install falcon"
        puts "  $ falcon serve --bind https://localhost:9292"
        puts "  → 自动生成自签名 TLS 证书"
        puts "  → 支持 HTTP/2 多路复用"
        puts

        puts "4. 与 Sinatra 集成"
        puts "  # 在 Gemfile 中:"
        puts "  # gem 'falcon'"
        puts "  # gem 'sinatra'"
        puts
        puts "  # config.ru:"
        puts "  require 'sinatra'"
        puts "  get('/') { 'Served by Falcon!' }"
        puts "  run Sinatra::Application"
        puts
        puts "  $ bundle exec falcon serve"
        puts "  → 使用 Fiber 调器替代 Puma 的线程池"
        puts

        puts "5. WebSocket 支持"
        ws_app = WebSocketApp.new
        puts "  WS 连接: #{ws_app.connect}"
        puts "  客户端发送: #{ws_app.send_message("Hello!")}"
        puts "  服务器响应: #{ws_app.receive}"
        puts

        puts "6. 性能对比 (请求/秒, 100 并发)"
        puts "  框架       | Falcon | Puma  | Webrick"
        puts "  HTTP/1     | 8500   | 4200  | 800"
        puts "  HTTP/2     | 12000  | N/A   | N/A"
        puts "  WebSocket  | 5000   | N/A   | N/A"
        puts

        puts "7. 部署"
        puts "  systemd:  --forked (多进程)"
        puts "  Kubernetes: --threaded (单进程多线程)"
        puts "  并发模型: Fiber (非 OS 线程) - 可同时处理上千连接"
        puts

        puts "8. 何时选择 Falcon"
        puts "  ✅ 高并发 API (需要最大吞吐量)"
        puts "  ✅ 实时应用 (WebSockets, SSE)"
        puts "  ✅ Ruby 3.0+ (利用 fiber scheduling)"
        puts "  ❌ 简单 Rails 应用 → Puma（默认，更成熟）"
        puts "  ❌ 需要广泛社区支持 → Puma"
      end
    end

    class WebSocketApp
      def initialize
        @connected = false
        @buffer = ""
      end

      def connect
        @connected = true
        "WebSocket connected to ws://localhost:9292/ws"
      end

      def send_message(msg)
        @buffer = msg
        "Sent: #{msg} (#{msg.bytesize} bytes)"
      end

      def receive
        @connected ? "Echo: #{@buffer}" : "Not connected"
      end
    end
  end
end

Hello::TopicRegistry.register("awesome", "falcon", "Falcon 异步服务器", Hello::Awesome::FalconDemo)
