# Grape — Ruby REST API 专用微框架

> Grape 是 Ruby 世界里专门为 REST API 设计的微框架。它的目标和 Python 的 FastAPI 一样：让你用最少的代码写出规范的 RESTful API，自动处理参数验证、版本控制、错误格式化和文档生成。如果 Sinatra 是 Ruby 的 Flask，那 Grape 就是 Ruby 的 FastAPI。

 Sinatra 能做 API，但它是一个通用 Web 框架，做 API 时很多事需要手动处理。Grape 从一开始就只为 API 而生：内置版本管理、自动 JSON 序列化、参数验证、Swagger 文档生成。它的 DSL 围绕 REST 资源设计，写出来的代码天然符合 REST 规范。

## 为什么选择 Grape？

- **API First 设计**：所有 API 围绕 `resource` 分组，天然符合 REST 规范
- **版本管理内置**：`version` DSL 一行搞定 v1/v2 并行
- **参数验证声明式**：`requires` / `optional` 声明参数规则，自动校验并返回 422
- **错误格式统一**：`rescue_from` 统一捕获异常，返回结构化 JSON 错误
- **Swagger 文档自动生成**：集成 `grape-swagger` 后，访问 `/swagger.json` 即可得到完整的 OpenAPI 文档
- **可独立运行，也可嵌入 Sinatra/Rails**：作为 Rack 应用挂载到任何 Ruby Web 框架中

## 安装依赖

```ruby
# Gemfile
gem "grape"
gem "grape-swagger"        # 自动生成 Swagger 文档
gem "grape-swagger-entity" # 实体文档支持（可选）
gem "puma"                 # 生产服务器
gem "sequel"               # ORM
gem "sqlite3"              # 数据库驱动
```

```bash
bundle install
```

## API 类结构

Grape 的核心是继承 `Grape::API` 的类。每个 API 模块是一个独立的 Rack 应用：

```ruby
# typed: true
# frozen_string_literal: true

require "grape"

class API < Grape::API
  prefix "api"
  format :json
  content_type :json, "application/json"

  rescue_from :all do |e|
    error!(
      {
        error: e.class.name,
        message: e.message
      },
      500
    )
  end

  mount API::V1::Root
end
```

几个关键点：
- `prefix "api"` 给所有路由加 `/api` 前缀
- `format :json` 让 Grape 自动处理 JSON 请求和响应
- `rescue_from :all` 捕获所有未处理的异常，返回结构化错误

## 版本管理

Grape 的版本管理是它区别于其他 API 框架的核心特性。你可以并行运行多个 API 版本：

```ruby
# lib/api/v1/root.rb
# typed: true
# frozen_string_literal: true

require_relative "users"
require_relative "posts"

module API
  module V1
    class Root < Grape::API
      version "v1", using: :path

      mount API::V1::Users
      mount API::V1::Posts

      get "/health" do
        {
          status: "ok",
          version: "v1",
          timestamp: Time.now.iso8601
        }
      end
    end
  end
end
```

```ruby
# lib/api/v2/root.rb
module API
  module V2
    class Root < Grape::API
      version "v2", using: :path

      mount API::V2::Users
      mount API::V2::Posts

      get "health" do
        {
          status: "ok",
          version: "v2",
          timestamp: Time.now.iso8601
        }
      end
    end
  end
end
```

在根 API 中挂载两个版本：

```ruby
class API < Grape::API
  prefix "api"
  format :json

  mount API::V1::Root
  mount API::V2::Root
end
```

访问路径：
- `GET /api/v1/health`
- `GET /api/v2/health`

Grape 也支持其他版本方式：`using: :header`（通过 `Accept` 头）、`using: :param`（通过 `?v=1` 参数）。

## 参数验证

Grape 的参数验证 DSL 是最常用的功能之一。它比 Sinatra 中手动解析请求体优雅得多：

```ruby
# lib/api/v1/users.rb
module API
  module V1
    class Users < Grape::API
      resource :users do
        # GET /api/v1/users?page=1&per_page=20
        params do
          optional :page, type: Integer, default: 1, range: 1..100
          optional :per_page, type: Integer, default: 20, range: 1..100
          optional :status, type: String, values: %w[active inactive banned]
        end
        get do
          users = User.all
          users = users.where(status: params[:status]) if params[:status]
          {
            users: users.paginate(page: params[:page], per_page: params[:per_page]),
            total: users.count
          }
        end

        # POST /api/v1/users
        params do
          requires :name, type: String, length: 2..50
          requires :email, type: String, format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
          optional :age, type: Integer, range: 0..150
          optional :role, type: String, values: %w[user admin moderator], default: "user"
        end
        post do
          user = User.create!(
            name: params[:name],
            email: params[:email],
            age: params[:age],
            role: params[:role]
          )
          status 201
          present user, with: API::V1::Entities::User
        end

        # PUT /api/v1/users/:id
        params do
          requires :id, type: String
          optional :name, type: String, length: 2..50
          optional :email, type: String, format: EMAIL_REGEX
          mutually_exclusive :name, :email, allow_blank: true
        end
        put ":id" do
          user = User.find(params[:id])
          user.update!(params.to_hash)
          present user, with: API::V1::Entities::User
        end

        # DELETE /api/v1/users/:id
        delete ":id" do
          user = User.find(params[:id])
          user.destroy
          status 204
        end
      end
    end
  end
end
```

验证 DSL 的关键功能：
- `requires` vs `optional`：声明必填或可选参数
- `type`：自动类型转换，字符串 `"123"` 转为 Integer `123`
- `range` / `values`：范围限制和枚举约束
- `format`：正则表达式验证，比如邮箱
- `mutually_exclusive`：参数互斥，比如不能同时传 `name` 和 `email` 更新
- `group` / `as`：参数分组，配合 `as: :update` 复用同一组验证逻辑

## RESTful 路由

Grape 围绕 `resource :name` 组织路由，这和 Rails 的 `resources` 思维一致：

```ruby
resource :posts do
  # GET /api/v1/posts
  get do
    present Post.all, with: API::V1::Entities::Post
  end

  # GET /api/v1/posts/:id
  route_param :id do
    get do
      present Post.find(params[:id]), with: API::V1::Entities::Post
    end

    # GET /api/v1/posts/:id/comments
    resource :comments do
      get do
        present Comment.where(post_id: params[:id]),
                with: API::V1::Entities::Comment
      end

      params do
        requires :body, type: String, length: 1..1000
      end
      post do
        comment = Comment.create!(
          post_id: params[:id],
          body: params[:body]
        )
        status 201
        present comment, with: API::V1::Entities::Comment
      end
    end
  end
end
```

嵌套资源通过 `route_param` 和嵌套 `resource` 实现。参数通过 `params[:id]` 自动从 URL 路径中提取。

## 响应格式化

Grape 支持多种格式，并可通过 HTTP `Accept` 头自动协商：

```ruby
class API < Grape::API
  format :json            # 默认 JSON
  content_type :xml, "application/xml"
  content_type :yaml, "text/yaml"

  # 也可以针对特定端点指定格式
  get "/data", produces: [:json, :xml] do
    { name: "hello", items: [1, 2, 3] }
  end
end
```

客户端控制响应格式：
```bash
# 默认 JSON
$ curl http://localhost:9292/api/data

# 要求 XML
$ curl -H "Accept: application/xml" http://localhost:9292/api/data
```

使用 Entity 构建结构化响应：

```ruby
# lib/api/v1/entities/user.rb
module API
  module V1
    module Entities
      class User < Grape::Entity
        expose :id, :name, :email, :role
        expose :created_at, format: :iso8601

        expose :avatar_url do |user, options|
          "https://cdn.example.com/avatars/#{user.id}.jpg"
        end

        # 嵌套关联
        expose :latest_post, using: API::V1::Entities::Post, if: -> (*) {
          object.respond_to?(:latest_post) && object.latest_post
        }
      end
    end
  end
end
```

Entity 的作用是把数据库模型转为 API 需要的 JSON 结构，避免直接暴露数据库字段。在 action 中通过 `present object, with: Entity` 自动序列化。

## 错误处理

Grape 的错误处理通过 `rescue_from` 实现，可以按异常类型精确捕获：

```ruby
class API < Grape::API
  prefix "api"
  format :json

  # 捕获特定异常
  rescue_from Grape::Exceptions::ValidationErrors do |e|
    error!({
      error: "validation_error",
      messages: e.errors
    }, 422)
  end

  rescue_from Sequel::NotFound do
    error!({
      error: "not_found",
      message: "资源不存在"
    }, 404)
  end

  rescue_from Sequel::UniqueConstraintViolation do |e|
    error!({
      error: "duplicate",
      message: "记录已存在"
    }, 409)
  end

  # 兜底捕获所有异常
  rescue_from :all do |e|
    error!({
      error: "internal_error",
      message: "服务器内部错误"
    }, 500)
  end

  get "/users/:id" do
    user = User.find(params[:id])  # Sequel::NotFound 会被自动捕获
    present user, with: API::V1::Entities::User
  end
end
```

错误响应的格式统一为：
```json
{
  "error": "validation_error",
  "messages": {
    "email": ["is invalid"]
  }
}
```

自定义错误处理函数：

```ruby
helpers do
  def authenticate!
    token = request.env["HTTP_AUTHORIZATION"]&.split(" ")&.last
    unless token
      error!({ error: "unauthorized", message: "需要认证" }, 401)
    end
    @current_user = User.find_by(auth_token: token)
    error!({ error: "unauthorized", message: "无效的认证令牌" }, 401) unless @current_user
  end

  def require_admin!
    error!({ error: "forbidden", message: "需要管理员权限" }, 403) unless @current_user&.admin?
  end
end

# 在资源中使用 before 过滤器
resource :admin do
  before { authenticate!; require_admin! }

  get "/stats" do
    {
      users: User.count,
      posts: Post.count,
      comments: Comment.count
    }
  end
end
```

## Swagger / OpenAPI 文档

`grape-swagger` 为你的 API 自动生成 Swagger UI，这是 Grape 最强大的功能之一：

```ruby
require "grape-swagger"

class API < Grape::API
  prefix "api"
  format :json

  # ... 你的 API 定义

  add_swagger_documentation(
    mount_path: "swagger",
    api_version: "v1",
    hide_documentation_path: true,
    info: {
      title: "My API",
      version: "v1",
      description: "用户和文章管理 API"
    },
    security_definitions: {
      api_key: {
        type: "apiKey",
        name: "Authorization",
        in: "header"
      }
    }
  )
end
```

访问 `http://localhost:9292/api/swagger` 即可看到交互式文档。

更精细的端点文档：

```ruby
desc "获取用户列表", {
  detail: "支持分页和状态筛选",
  success: API::V1::Entities::User,
  is_array: true
}
params do
  optional :page, type: Integer, default: 1, desc: "页码"
  optional :per_page, type: Integer, default: 20, desc: "每页数量"
  optional :status, type: String, values: %w[active inactive], desc: "用户状态"
end
get do
  present User.all, with: API::V1::Entities::User
end

desc "创建新用户", {
  detail: "需要 name 和 email，age 可选",
  success: API::V1::Entities::User,
  failure: [
    [422, "验证失败", API::V1::Entities::Error],
    [409, "重复记录", API::V1::Entities::Error]
  ]
}
params do
  requires :name, type: String, length: 2..50, desc: "用户名"
  requires :email, type: String, desc: "邮箱地址"
  optional :age, type: Integer, range: 0..150, desc: "年龄"
end
post do
  # ...
end
```

生成的 Swagger 文档包含端点描述、参数说明、返回类型、错误码，可以直接用于前端联调和客户端代码生成。

## 与 Rack 集成

Grape 应用是完整的 Rack 应用，可以独立运行，也可以嵌入其他框架：

**独立运行**：

```ruby
# config.ru
require_relative "./lib/api"

run API
```

```bash
$ bundle exec rackup config.ru
# Puma 启动在 http://localhost:9292
```

**嵌入 Rails**：

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount API => "/api"
end
```

**嵌入 Sinatra**：

```ruby
require "sinatra/base"
require_relative "./lib/api"

class MainApp < Sinatra::Base
  mount API => "/api"

  get "/" do
    "Hello from Sinatra!"
  end
end
```

这种灵活性让 Grape 可以作为 Rails 应用中的 API 模块存在，同时保留 REST API 专用 DSL 的优势。

## 完整示例结构

```
my_api/
├── config.ru                 # Rack 入口
├── Gemfile
├── lib/
│   └── api.rb                # 根 API 类，挂载所有版本
│   ├── api/
│   │   ├── v1/
│   │   │   ├── root.rb       # V1 入口
│   │   │   ├── users.rb      # 用户资源
│   │   │   ├── posts.rb      # 文章资源
│   │   │   └── entities/
│   │   │       ├── user.rb   # 用户响应格式
│   │   │       └── post.rb   # 文章响应格式
│   │   └── v2/
│   │       ├── root.rb       # V2 入口
│   │       └── users.rb      # V2 用户 API（可能有新字段）
│   ├── models/
│   │   ├── user.rb
│   │   └── post.rb
│   └── db.rb                 # 数据库连接
```

## 本章要点

- Grape 是 Ruby 专用的 REST API 微框架，围绕 `resource` 组织路由
- `version` DSL 支持 v1/v2 多版本并行，通过路径、Header 或参数切换
- `requires` / `optional` 声明参数验证规则，自动返回结构化错误
- Entity 层负责将数据库对象序列化为 JSON，控制 API 响应格式
- `rescue_from` 按异常类型统一处理错误，避免重复的 `begin/rescue`
- `add_swagger_documentation` 自动生成 OpenAPI/Swagger 文档
- 可以作为独立 Rack 应用运行，也可以嵌入 Rails/Sinatra
- 适合需要规范 REST API、版本管理和自动文档的后端服务

## 继续学习

- Grape 官方文档: [ruby-grape.github.io/grape](https://ruby-grape.github.io/grape)
- grape-swagger 文档: [ruby-grape.github.io/grape-swagger](https://ruby-grape.github.io/grape-swagger)
- Grape::Entity: [ruby-grape.github.io/entity](https://ruby-grape.github.io/entity)
- Sinatra 基础: [Sinatra 微服务框架](sinatra.md)
- 现代 Web 框架: [Hanami — 干净架构](hanami.md)

> 💡 **提示**：Grape 的哲学是"API 应该像 API 一样被设计"。它不是为了替代 Sinatra 或 Rails 而生，而是补足了它们在 API 场景下的不足：版本管理、参数验证、自动文档。如果你的项目需要对外提供 REST API，Grape 是比 Sinatra 更专业的选择。
