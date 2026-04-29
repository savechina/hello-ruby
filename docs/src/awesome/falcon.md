# Falcon — 高性能异步 Ruby Web 服务器

Falcon 是一款高性能的 Rack 兼容 HTTP 服务器，基于 async/async-http 协程构建。它可以同时处理数千个并发连接，在 Ruby 生态中的地位类似于 Node.js 的 uvloop 或 Python 的 Uvicorn。原生支持 HTTP/1、HTTP/2 和 TLS，无需额外配置。

## Falcon 的核心架构

Falcon 采用多进程加多 Fiber 的混合架构，这是它高性能的根源。

每个请求在一个轻量级的 Fiber（协程）中执行，Fiber 之间共享进程内存，切换成本极低。当请求需要等待 I/O（数据库查询、外部 HTTP 调用、文件读取）时，Falcon 的 Fiber 调度器自动切换到其他就绪的 Fiber，而不是阻塞整个线程。

```
┌─────────────────────────────────────────────────┐
│                  Falcon 架构                     │
│                                                  │
│  ┌──────────┐    ┌──────────┐    ┌───────────┐  │
│  │ Worker 1 │    │ Worker 2 │    │ Worker N   │  │
│  │ (进程)   │    │ (进程)   │    │ (进程)    │  │
│  │          │    │          │    │           │  │
│  │  ┌────┐  │    │  ┌────┐  │    │  ┌────┐  │  │
│  │  │Fiber│  │    │  │Fiber│  │    │  │Fiber│  │  │
│  │  │Fiber│  │    │  │Fiber│  │    │  │Fiber│  │  │
│  │  │Fiber│  │    │  │Fiber│  │    │  │Fiber│  │  │
│  │  │ ... │  │    │  │ ... │  │    │  │ ... │  │  │
│  │  └────┘  │    │  └────┘  │    │  └────┘  │  │
│  └──────────┘    └──────────┘    └───────────┘  │
│                                                  │
│  每个请求 = 一个 Fiber                            │
│  Fiber 遇到 I/O → 自动让出控制权                  │
│  非阻塞 I/O = 高并发能力                           │
└─────────────────────────────────────────────────┘
```

多进程部分用于利用多核 CPU，每个 Worker 进程拥有独立的 Fiber 池。这种设计既避免了 GVL（全局解释器锁）争用，又保证了故障隔离：一个 Worker 崩溃不影响其他 Worker。

## 快速开始

### 安装 Falcon

```bash
gem install falcon
```

或添加到 Gemfile：

```ruby
gem "falcon"
```

### 最简单的 Rack 应用

创建一个 `config.ru` 文件：

```ruby
# frozen_string_literal: true

run lambda { |_env|
  [200, { "Content-Type" => "text/plain" }, ["Hello Falcon!"]]
}
```

启动服务：

```bash
# HTTPS 绑定（自动生成自签名证书）
$ falcon serve --bind https://localhost:9292

# HTTP 绑定
$ falcon serve --bind http://localhost:9292
```

Falcon 支持 `https://` 前缀自动绑定 HTTPS。首次启动时会自动生成自签名证书，仅适用于 localhost 开发环境。

### 开发模式

```bash
$ falcon serve --bind http://localhost:9292 --development
```

`--development` 模式会在代码变更时自动重启 Worker 进程，开发体验类似 nodemon 或 flask reload。

### 绑定多个地址

你可以同时绑定 HTTP 和 HTTPS：

```bash
$ falcon serve \
  --bind http://localhost:9292 \
  --bind https://localhost:9293
```

## 运行 Sinatra 应用

Falcon 完全兼容 Rack 接口，因此任何 Rack 应用都能直接运行。下面用 Sinatra 演示：

```ruby
# frozen_string_literal: true

require "sinatra/base"

class MyApp < Sinatra::Base
  get "/" do
    "Served by Falcon!"
  end

  get "/hello/:name" do
    "你好，#{params['name']}！用 Falcon 提供服务。"
  end

  get "/fibonacci/:n" do
    n = params["n"].to_i
    # 纯 CPU 计算，展示 Falcon 也能处理
    result = (0...n).inject([0, 1]) { |acc, _| [acc.last, acc.sum] }.first
    "Fibonacci(#{n}) = #{result}"
  end

  get "/external-call" do
    # 发起外部 HTTP 请求（Falcon 的 Fiber 调度器会在这里让出控制）
    require "async/http/endpoint"
    endpoint = Async::HTTP::Endpoint.parse("https://api.github.com")
    connection = Async::HTTP::Client.connect(endpoint)
    response = connection.get("/").wait
    "GitHub API 响应状态: #{response.status}"
  end
end

run MyApp
```

用 Falcon 启动：

```bash
$ bundle exec falcon serve
```

注意，外部 HTTP 调用那段代码利用了 Falcon 内置的 Fiber 调度器。当 `connection.get` 发起网络请求后，Fiber 自动让出控制权，其他请求可以继续处理，等响应到达后再恢复执行。这就是非阻塞 I/O 的威力。

## 关键特性详解

### Fiber 调度器集成（Ruby 3.0+）

从 Ruby 3.0 开始，Ruby 支持可插拔的 Fiber 调度器（Fiber Scheduler）。Falcon 注册了自己的调度器，使得标准库中的阻塞 I/O 操作（如 `TCPSocket`, `Net::HTTP`, `IO.select`）自动变成非阻塞。

```ruby
# frozen_string_literal: true

# 这段代码在 Falcon 的 Fiber 调度器下自动变成非阻塞
require "net/http"
require "uri"

def fetch_all(urls)
  # Ruby 3.0+ 下，并发发起而非串行等待
  urls.map do |url|
    Thread.new do
      response = Net::HTTP.get(URI(url))
      puts "#{url}: #{response.length} bytes"
    end
  end.map(&:join)
end
```

在 Falcon 中运行时，`Net::HTTP.get` 不再阻塞线程，而是通过 event loop 等待。多个并发请求共享同一个线程，性能大幅超越传统多进程模型。

### HTTP/1 和 HTTP/2 原生支持

Falcon 同时支持 HTTP/1.1 和 HTTP/2（通过 ALPN 协商），无需额外的反向代理或配置。

```bash
$ falcon serve --bind https://localhost:9292

# 访问时使用 HTTP/2
$ curl --http2 -k https://localhost:9292
HTTP/2 200
content-type: text/html; charset=utf-8
```

HTTP/2 的多路复用（Multiplexing）使得多个请求可以共享同一个 TCP 连接，减少了连接的开销。对于前端资源加载（多个 CSS、JS、图片文件）来说，这是巨大的性能提升。

### TLS 支持

Falcon 内置 TLS。使用 `https://` 绑定地址时，Falcon 会：

1. 如果提供了证书文件，直接使用
2. 如果没有证书，自动用 `puma-dev` 风格的证书生成工具创建

生产环境建议使用 Let's Encrypt 或其他 CA 提供的正式证书：

```bash
$ falcon serve \
  --bind https://localhost:9292 \
  --ssl-key /path/to/private.key \
  --ssl-cert /path/to/certificate.crt
```

### WebSocket 支持

Falcon 通过 `async-websocket` gem 原生支持 WebSocket（需要 Rack 3 的 streaming response 协议）：

```ruby
# frozen_string_literal: true

require "async/websocket/protocol"
require "async/http/endpoint"

class ChatApp
  def call(env)
    if env["HTTP_UPGRADE"] == "websocket"
      # WebSocket 请求
      handle_websocket(env)
    else
      # 普通 HTTP 请求（返回聊天页面）
      [200, { "Content-Type" => "text/html" }, ["<h1>WebSocket Chat</h1>"]]
    end
  end

  def handle_websocket(env)
    # Falcon + async-websocket 的 WebSocket handshake
    protocol = env["async.websocket"]
    protocol.accept

    # 广播循环
    loop do
      message = protocol.read
      break if message.nil?
      # 处理消息...
    end
  end
end

run ChatApp.new
```

### Rack 2 和 Rack 3 双兼容

Falcon 同时兼容 Rack 2 和 Rack 3，无论是 Rails 7（默认使用 Rack 2）还是最新的 Roda（Rack 3 优先），都能直接运行，无需任何修改。

```ruby
# Rack 3 streaming response — Falcon 完美支持
# frozen_string_literal: true

run lambda { |_env|
  # 流式响应：适用于 SSE（Server-Sent Events）、大文件下载
  body = Object.new
  def body.each
    10.times do |i|
      yield "Chunk #{i}\n"
      sleep 0.5  # 模拟逐条推送
    end
  end

  [200, { "Content-Type" => "text/plain" }, body]
}
```

## 运行 Rails 应用

Falcon 可以通过 `falcon-websocket` gem 与 Rails 深度集成，支持异步 Rails 控制器、HTTP 流式传输、SSE 和 WebSocket。

### 基础集成

```ruby
# Gemfile
gem "rails", "~> 7.1"
gem "falcon"
gem "falcon-websocket"
```

```ruby
# config/application.rb
require "rails/all"

module MyApplication
  class Application < Rails::Application
    # 配置 Rails 使用 Falcon 特性
    config.hosts << "localhost"
  end
end
```

启动命令不变：

```bash
$ bundle exec falcon serve --bind http://localhost:3000
```

### HTTP Streaming

Rails 支持将控制器输出以流的形式发送给客户端，这在 Falcon 下效果最佳：

```ruby
# frozen_string_literal: true

class StreamingController < ApplicationController
  include ActionController::Live

  def index
    10.times do |i|
      sleep 1
      response.stream.write "数据项 #{i}\n"
    end
    response.stream.close
  end
end
```

客户端会看到每秒钟收到一条数据，而非等待所有计算完成后一次性返回。

### Server-Sent Events (SSE)

```ruby
# frozen_string_literal: true

class EventsController < ApplicationController
  include ActionController::Live

  def stream
    100.times do |i|
      begin
        response.stream.write("event: message\n")
        response.stream.write("data: Event #{Time.now}\n\n")
        sleep 2
      rescue ClosedError
        break  # 客户端断开连接
      end
    end
  ensure
    response.stream.close
  end
end
```

### WebSockets with Action Cable

Falcon 支持 Rails 的 Action Cable WebSocket 实现。配置 `config/cable.yml`：

```yaml
production:
  adapter: async
```

## 性能对比：Falcon vs Puma vs Webrick

Falcon 在 I/O 密集型场景下表现突出。以下是典型的 benchmark 数据（使用 `wrk` 测试，10000 并发连接，30 秒）：

| 服务器     | 请求/秒 (并发 1K) | 请求/秒 (并发 10K) | 平均延迟 (ms) |
| ---------- | -------------------- | --------------------- | ------------ |
| Falcon     | ~12,000              | ~8,500                | ~85          |
| Puma       | ~9,500               | ~5,200                | ~180         |
| Webrick    | ~1,800               | ~400                  | ~2,400       |

关键差异：

- **Falcon**：Fiber 调度器使得高并发下的延迟几乎不增长，适合 API 网关、实时数据推送
- **Puma**：线程池模型，在高并发时线程争用导致延迟上升，但胜在 Rails 生态兼容最好
- **Webrick**：Ruby 默认服务器，纯阻塞模型，仅适合开发调试，绝对不要用在生产环境

在纯 CPU 密集型任务（如大量数学运算、加密）上，Falcon 的优势不明显，因为这类任务无法通过 I/O 切换来提升吞吐量。

## 部署实践

### Systemd 管理

生产环境推荐用 systemd 管理 Falcon 进程：

```ini
# /etc/systemd/system/falcon.service
[Unit]
Description=Falcon Ruby Web Server
After=network.target

[Service]
Type=forking
User=www-data
Group=www-data
WorkingDirectory=/var/www/myapp/current
ExecStart=/usr/local/bin/falcon run --daemon --bind http://0.0.0.0:9292
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```bash
$ sudo systemctl enable falcon
$ sudo systemctl start falcon
$ sudo systemctl status falcon
```

### Kubernetes 部署

Falcon 支持优雅关闭（SIGTERM），非常适合容器化部署：

```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: falcon-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: falcon-app
  template:
    metadata:
      labels:
        app: falcon-app
    spec:
      containers:
      - name: app
        image: myapp:latest
        command: ["falcon", "run", "--bind", "http://0.0.0.0:9292"]
        ports:
        - containerPort: 9292
        livenessProbe:
          httpGet:
            path: /health
            port: 9292
          initialDelaySeconds: 10
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 9292
          initialDelaySeconds: 5
          periodSeconds: 10
```

### Worker 配置：进程 vs 线程

Falcon 默认使用 `--forked` 模式（多进程 fork），每个 Worker 是一个独立的进程。也可以切换到 `--threaded` 模式：

```bash
# Fork 模式（默认，推荐）
$ falcon serve --bind http://0.0.0.0:9292 --workers 4

# Thread 模式
$ falcon serve --bind http://0.0.0.0:9292 --threaded --threads 4
```

选择建议：

- **Fork 模式**：进程隔离，适合多核 CPU。每个 Worker 有独立的内存空间。Falcon 的默认和推荐模式。
- **Thread 模式**：线程共享内存，适合内存受限的环境。但受限于 GVL，CPU 密集型任务性能会下降。

## 何时选择 Falcon

选择 Falcon 的场景：

- **高并发 API**：需要支撑大量并发连接的外部 API 服务，如 JSON API 网关、移动应用后端。Falcon 的 Fiber 调度器让数千个并发连接的延迟保持在低位。
- **实时应用**：WebSocket、SSE 等长连接场景。Falcon 的协程模型天然适合处理大量持久连接。
- **现代 Ruby 3.0+ 项目**：你的项目基于 Ruby 3.0+，希望充分利用 Fiber Scheduler 的非阻塞能力。
- **微服务架构**：每个服务需要最小的内存占用和最快的启动速度。

选择 Puma 而不是 Falcon 的理由：

- **Rails 默认**：Puma 是 Rails 的默认服务器，社区支持最广，遇到问题更容易找到解决方案。
- **简单部署**：Puma 的配置更直观，与 Capistrano、Kubernetes 等工具的集成已经有成熟的模式。
- **更广泛的使用量**：Falcon 相对较新，生态圈和社区规模不如 Puma。如果你在寻找稳定的生产级服务器，Puma 是更成熟的选项。
- **Rails 深度集成**：某些 Rails 插件和 middleware 专门为 Puma 做了优化，可能需要额外适配才能在 Falcon 下运行。

## 本章要点

- Falcon 是基于 Fiber 的高性能 Ruby HTTP 服务器，适合高并发场景
- 天然支持 HTTP/2、TLS、WebSocket，无需额外反向代理
- 兼容 Rack 2 和 Rack 3，可以直接运行 Sinatra、Rails、Roda 等任何 Rack 应用
- 部署支持 systemd、Kubernetes、多进程/多线程模式
- 高并发选 Falcon，追求稳定成熟选 Puma

## 继续学习

- 轻量级微框架: [Sinatra — REST 微服务](./sinatra.md)
- 异步并发模型: [Async & Concurrency](../advance/async-await.md)
- 线程与协程深度: [Threads & Fibers](../advance/threads-fibers.md)
- Falcon 官方文档: [falconrb.org](https://falconrb.org)
- Async gem 文档: [github.com/socketry/async](https://github.com/socketry/async)

>  提示：Falcon 是一个出色的补充知识。对于大多数 Ruby 项目来说，Puma 已经完全够用；但当你的应用面临高并发挑战、需要处理大量 WebSocket 连接、或者单纯追求极致性能时，Falcon 的 Fiber 调度器会让你眼前一亮。