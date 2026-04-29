# Sinatra — 轻量级 REST 微服务框架

> Sinatra 是 Ruby 世界最著名的微框架。它相当于 Python 的 Flask/FastAPI——用最少的代码快速搭建 RESTful API。与 Rails 的"大而全"不同，Sinatra 只提供路由和请求/响应处理，让你从零开始组装自己的技术栈。

## 为什么选择 Sinatra？

- **极简主义**：一个文件、几行代码就能启动 HTTP 服务
- **灵活性**：不强制任何架构约定，你可以自由组合 ORM、模板引擎等
- **微服务友好**：轻量级，适合构建独立的小服务
- **易于理解**：没有 Rails 那样的魔法层，请求到响应的流程一目了然

## 第一个 Sinatra 应用

```ruby
require "sinatra"

get "/" do
  "Hello, Sinatra!"
end

get "/hello/:name" do
  "你好，#{params['name']}！"
end

post "/api/users" do
  request.body.rewind
  data = JSON.parse(request.body.read)
  content_type :json
  { user: data }.to_json
end
```

运行方式：

```bash
$ bundle exec ruby app.rb
# 默认启动 http://localhost:4567
```

## 路由系统

Sinatra 的路由非常直观，支持所有 HTTP 方法：

```ruby
# GET 请求
get "/users" do
  # 列出所有用户
end

# POST 请求
post "/users" do
  # 创建用户
end

# PUT 请求
put "/users/:id" do
  # 更新用户
end

# DELETE 请求
delete "/users/:id" do
  # 删除用户
end

# 带参数的路由
get "/posts/:year/:month/:slug" do
  year  = params['year']
  month = params['month']
  slug  = params['slug']
end

# 正则表达式路由
get %r{/items/([\w]+)} do
  capture_groups[0]  # 访问正则匹配的第一个分组
end

# 带条件的路由
get "/api/v2/data", provides: :json do
  { version: "v2" }.to_json
end
```

## 请求处理

```ruby
# 获取请求信息
get "/request-info" do
  request_method = request.request_method
  path           = request.path_info
  ip             = request.ip
  user_agent     = request.user_agent
  
  "Method: #{request_method}, Path: #{path}, IP: #{ip}"
end

# 处理 JSON 请求体
post "/api/data" do
  content_type :json
  request.body.rewind
  payload = JSON.parse(request.body.read)
  { status: "ok", received: payload }.to_json
end

# 重定向
get "/old-page" do
  redirect "/new-page"
end

# 停止执行
get "/forbidden" do
  halt 403, "你没有访问权限"
end
```

## 过滤器（Before/After）

```ruby
# 请求前执行
before do
  content_type :json
  @start_time = Time.now
end

# 指定路径的过滤器
before "/api/*" do
  authenticate! unless request.path == "/api/health"
end

# 请求后执行
after do
  elapsed = Time.now - @start_time
  logger.info "请求耗时: #{elapsed}ms"
end
```

## 完整示例：REST API

```ruby
require "sinatra"
require "json"

class App < Sinatra::Base
  set :bind, "0.0.0.0"
  set :port, 4567

  # 内存数据库（实际项目用 Sequel/ActiveRecord）
  @tasks = [
    { id: 1, title: "Learning Ruby", status: "in_progress" },
    { id: 2, title: "Building API",   status: "pending" }
  ]
  @next_id = 3

  # 列出所有任务
  get "/api/tasks" do
    { tasks: @tasks }.to_json
  end

  # 获取单个任务
  get "/api/tasks/:id" do
    task = @tasks.find { |t| t["id"] == params["id"].to_i }
    halt 404, { error: "Task not found" }.to_json unless task
    task.to_json
  end

  # 创建任务
  post "/api/tasks" do
    request.body.rewind
    body = JSON.parse(request.body.read)
    new_task = {
      "id" => (@next_id += 1),
      "title" => body["title"],
      "status" => "pending"
    }
    @tasks << new_task
    status 201
    new_task.to_json
  end

  # 更新任务
  put "/api/tasks/:id" do
    task = @tasks.find { |t| t["id"] == params["id"].to_i }
    halt 404, { error: "Task not found" }.to_json unless task
    request.body.rewind
    body = JSON.parse(request.body.read)
    task["title"] = body["title"] if body["title"]
    task["status"] = body["status"] if body["status"]
    task.to_json
  end

  # 删除任务
  delete "/api/tasks/:id" do
    task = @tasks.find { |t| t["id"] == params["id"].to_i }
    halt 404, { error: "Task not found" }.to_json unless task
    @tasks.delete(task)
    status 204
    ""
  end

  # 健康检查
  get "/health" do
    { status: "ok", version: "1.0.0" }.to_json
  end
end

App.run!
```

测试 API：

```bash
# 列出任务
$ curl http://localhost:4567/api/tasks

# 创建任务
$ curl -X POST http://localhost:4567/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "New Task"}'
```

## 部署

Sinatra 应用可通过多种方式部署：

- **Puma**：推荐的生产服务器，支持多线程
  ```ruby
  # config.ru
  require_relative "./app"
  run App
  ```
  ```bash
  $ bundle exec puma -p 3000
  ```

- **Passenger**：Nginx 集成的部署方案
- **Docker**：轻量级容器化部署，非常适合微服务

## 与 FastAPI 对比

| 特性           | Sinatra (Ruby)         | FastAPI (Python)        |
| -------------- | ---------------------- | ----------------------- |
| 路由定义       | DSL get/post/put/delete| 装饰器 @app.get/post    |
| 请求参数       | params['name']         | 函数参数 + Pydantic     |
| JSON 响应      | 手动 .to_json           | 自动序列化              |
| OpenAPI 文档  | 需要 rswag gem         | 自动生成                |
| 异步支持       | 需要 async-sinatra     | 原生 async/await        |
| 启动速度       | ~1s                    | ~0.5s                   |

## 本章要点

- Sinatra 是 Ruby 微服务的首选，相当于 Python Flask/FastAPI
- 路由系统直观，支持所有 HTTP 方法和参数模式
- Before/After 过滤器实现中间件模式
- 生产环境使用 Puma 作为服务器
- 适合：小型服务、API 后端、原型快速验证
- 不适合：需要完整 ORM、模板、邮件等功能的复杂 Web 应用 → 选择 Rails 或 Hanami

## 继续学习

- API 微框架: [Grape — REST API 专用](../advance/grape.md)
- 现代 Web 框架: [Hanami — 干净架构](../advance/hanami.md)
- 异步服务: [Falcon + Async Rack](../advance/falcon.md)

> 💡 **提示**：Sinatra 的核心理念是"少即是多"。当你发现自己在 Sinatra 中手写越来越多的基础设施（数据库连接池、模板引擎、邮件发送），可能就是升级到 Rails 或 Hanami 的时候了。
