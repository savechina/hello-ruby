# Hanami — 干净架构的现代 Ruby 框架

> Hanami 是 Ruby 世界中 Rails 最有力的竞争者。如果你认为 Rails 的"魔法"让代码变得难以追踪，Hanami 提供了另一种思路：干净架构、领域驱动设计、明确的依赖关系。它不是一个更小的 Rails，而是一个完全不同的哲学。

Rails 在 2004 年重新定义了 Web 开发，但近二十年后，许多开发者开始感到疲惫。ORM 隐含了 SQL 查询的行为，控制器混入了视图逻辑，全局状态让测试变得困难。Hanami 2.x 的回应是：拆分层，让每个部分只做一件事。

## 为什么选择 Hanami？

- **比 Rails 快 3 倍**：启动时间不到 1 秒，请求延迟更低，内存占用更少
- **干净架构**：Actions、Views、Repositories、Entities 严格分离，不存在"胖模型"
- **领域驱动设计**：Entities 是纯 Ruby 对象，不包含 ORM 行为，数据库访问通过 Repositories 完成
- **原生 DI**：深度集成 dry-system，依赖注入是一等公民
- **类型安全**：与 dry-validation 配合，参数验证不再是事后补充

选择 Hanami 的场景：你正在构建一个中长期项目，团队规模在 3 人以上，需要清晰的代码结构和可测试性。选择 Rails 的场景：你需要在一周内搭出 MVP，或者团队中很多人已经熟悉 Rails 约定。

## 项目结构

Hanami 生成的项目结构与 Rails 类似，但每个目录的职责更加明确：

```
my_app/
├── config/
│   ├── settings.rb            # 应用设置
│   └── locales/               # 国际化
├── lib/
│   ├── my_app/
│   │   └── settings.rb        # 自定义设置类
│   └── tasks/                 # Rake 任务
├── apps/
│   └── web/                   # Web 层（可以多个 app）
│       ├── controllers/       # Actions：处理 HTTP 请求
│       │   ├── home/
│       │   │   └── index.rb
│       │   └── posts/
│       │       ├── create.rb
│       │       ├── index.rb
│       │       └── show.rb
│       ├── views/             # Views：渲染数据（不含业务逻辑）
│       │   ├── home/
│       │   │   └── index.rb
│       │   └── posts/
│       │       ├── index.rb
│       │       └── show.rb
│       ├── templates/         # ERB 模板
│       │   ├── home/
│       │   │   └── index.html.erb
│       │   └── posts/
│       │       ├── index.html.erb
│       │       └── show.html.erb
│       └── routes.rb          # 路由定义
├── config/
│   └── routes.rb              # 全局路由
├── db/
│   └── migrations/            # 数据库迁移
├── lib/
│   └── my_app/
│       ├── entities/          # Entities：纯 Ruby 领域对象
│       │   └── post.rb
│       └── repositories/      # Repositories：数据访问层
│           └── post_repository.rb
├── config.ru
├── Gemfile
└── config.ru
```

关键区别：

- **Controllers 和 Views 在不同目录**。Rails 的 `app/views/posts/show.html.erb` 在 Hanami 中拆分为 `apps/web/views/posts/show.rb`（数据准备）和 `apps/web/templates/posts/show.html.erb`（HTML 渲染）
- **Entities 不在 app/models**。领域对象是纯 Ruby 对象，通过 Repositories 持久化
- **每个 app 独立**。你可以在同一个项目中运行 `web`（HTML）和 `api`（JSON）两个独立应用

## Actions（控制器）

Hanami 的 controller 叫 Action，每个 action 是一个独立的类。这种方式让每个 HTTP 端点的行为一目了然。

```ruby
# typed: true
# frozen_string_literal: true

module Web
  module Controllers
    module Posts
      class Index
        include Web::Action

        expose :posts

        def call(params)
          @posts = repositories.posts.all
        end
      end
    end
  end
end
```

每个 action 类只做一件事：接收请求参数，调用仓库层获取数据，通过 `expose` 暴露给 View。没有实例变量泄漏，没有隐含的全局状态。

带参数验证的 action：

```ruby
# typed: true
# frozen_string_literal: true

module Web
  module Controllers
    module Posts
      class Create
        include Web::Action
        include Web::ApiOnly  # 如果是 API，返回 JSON

        params do
          required(:title).filled(:string)
          required(:body).filled(:string)
          optional(:status).value(included_in?: %w[draft published archived])
        end

        def call(params)
          if params.valid?
            post = repositories.posts.create(params.to_h)
            self.status = 201
            self.body = post.to_json
          else
            self.status = 422
            self.body = { errors: params.errors }.to_json
          end
        end
      end
    end
  end
end
```

参数验证通过 `params` DSL 声明，Hanami 使用 dry-validation 在后台生成验证逻辑。无效参数自动返回结构化错误，不需要手动检查。

## 路由系统

Hanami 的路由定义在 `apps/web/routes.rb` 中，语法与 Rails 类似但更简洁：

```ruby
# apps/web/routes.rb
get "/", to: "home#index"
resources :posts, only: [:index, :show, :create, :update, :destroy]
get "/posts/:id/edit", to: "posts#edit"
```

支持命名空间和版本控制：

```ruby
namespace :admin do
  resources :users
  resources :posts
end

scope path: "api/v1", as: "api_v1" do
  resources :posts, only: [:index, :show]
end
```

## Repositories（数据访问层）

这是 Hanami 与 Rails 最本质的区别。Rails 的 ActiveRecord 把查询和数据操作混在同一个对象里。Hanami 拆成了两半：Entity 是纯数据，Repository 负责所有数据库操作。

```ruby
# lib/my_app/entities/post.rb
# typed: true
# frozen_string_literal: true

module My
  module Entities
    class Post < Hanami::Entity
      attribute :id,          Types::Int
      attribute :title,       Types::String
      attribute :body,        Types::String
      attribute :status,      Types::String
      attribute :created_at,  Types::Time
      attribute :updated_at,  Types::Time
    end
  end
end
```

Entity 只是数据容器，没有任何查询方法。查询通过 Repository 完成：

```ruby
# lib/my_app/repositories/post_repository.rb
# typed: true
# frozen_string_literal: true

module My
  module Repositories
    class PostRepository
      include Hanami::Repository

      def published
        posts.where(status: "published").order(:created_at)
      end

      def find_by_slug(slug)
        posts.where(slug: slug).map_to(My::Entities::Post).one
      end

      def create_with_tags(post_attrs, tag_ids)
        # 事务内创建文章和标签关联
        transaction do
          post = posts.create(post_attrs)
          tag_ids.each do |tag_id|
            post_tags.create(post_id: post.id, tag_id: tag_id)
          end
          post
        end
      end

      private

      def posts
        relation(:posts)
      end

      def post_tags
        association_repo(:post_tags)
      end
    end
  end
end
```

Repository 使用 Sequel 作为底层 ORM，支持复杂的关联查询和事务操作。关联关系通过 `associations` 在 relation 层声明：

```ruby
# db/migrations/20240101000000_create_posts.rb
# typed: true
# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :posts do
      primary_key :id
      column :title, String, null: false
      column :body, Text, null: false
      column :slug, String, null: false, unique: true
      column :status, String, null: false, default: "draft"
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
```

## Views（视图层）

Hanami 的 View 层不包含业务逻辑，只负责数据格式化和模板渲染：

```ruby
# apps/web/views/posts/index.rb
# typed: true
# frozen_string_literal: true

module Web
  module Views
    module Posts
      class Index
        include Web::View

        # 格式化日期
        def formatted_date(date)
          date.strftime("%Y年%m月%d日")
        end

        # 生成文章摘要
        def summary(post, max_length: 100)
          text = post.body.to_s
          if text.length > max_length
            "#{text[0...max_length]}..."
          else
            text
          end
        end
      end
    end
  end
end
```

对应的 ERB 模板只处理 HTML：

```erb
<%# apps/web/templates/posts/index.html.erb %>
<h1>文章列表</h1>

<ul>
<% @posts.each do |post| %>
  <li>
    <h2><a href="<%= url(:post, id: post.id) %>"><%= post.title %></a></h2>
    <p class="date"><%= formatted_date(post.created_at) %></p>
    <p class="summary"><%= summary(post) %></p>
  </li>
<% end %>
</ul>
```

## 依赖注入（Dry-System 集成）

Hanami 在底层使用 dry-system 管理所有依赖。这意味你可以明确控制每个对象如何创建、如何注入：

```ruby
# config/settings.rb
# typed: true
# frozen_string_literal: true

module My
  class Settings < Hanami::Settings
    setting :database_url, constructor: Types::String
    setting :redis_url, constructor: Types::String, default: "redis://localhost:6379"
    setting :secret_key_base, constructor: Types::String
    setting :cache_store, constructor: Types::Symbol, default: :memory
  end
end
```

在 action 中注入自定义服务：

```ruby
# apps/web/controllers/posts/ publish.rb
# typed: true
# frozen_string_literal: true

module Web
  module Controllers
    module Posts
      class Publish
        include Web::Action
        inject "services.publish_notifier"

        params do
          required(:id).filled(:integer)
        end

        def call(params)
          post = repositories.posts.find(params[:id])
          post.update(status: "published")
          services.publish_notifier.call(post)
          redirect_to url(:post, id: post.id)
        end
      end
    end
  end
end
```

服务组件通过 dry-system 自动注册：

```ruby
# lib/my_app/services/publish_notifier.rb
# typed: true
# frozen_string_literal: true

module My
  module Services
    class PublishNotifier
      def call(post)
        # 发布通知逻辑
        puts "通知订阅者：新文章 #{post.title}"
      end
    end
  end
end
```

> 如果你对 dry-system 还不熟悉，建议先阅读 [依赖注入进阶](../advance/dry-system.md) 章节。

## 完整 CRUD 示例

下面是用 Hanami 构建一个完整博客 CRUD 的最简配置：

**1. 定义路由**

```ruby
# apps/web/routes.rb
get "/", to: "home#index"
resources :posts, only: [:index, :show, :new, :create, :edit, :update, :destroy]
```

**2. Action 层**

```ruby
# apps/web/controllers/posts/index.rb
module Web
  module Controllers
    module Posts
      class Index
        include Web::Action
        expose :posts

        def call(params)
          @posts = repositories.posts.published
        end
      end
    end
  end
end
```

```ruby
# apps/web/controllers/posts/create.rb
module Web
  module Controllers
    module Posts
      class Create
        include Web::Action

        params do
          required(:title).filled(:string)
          required(:body).filled(:string)
          optional(:status).value(included_in?: %w[draft published])
        end

        def call(params)
          if params.valid?
            post = repositories.posts.create(params.to_h)
            redirect_to url(:post, id: post.id)
          else
            @post = params.to_h
            halt 422
          end
        end
      end
    end
  end
end
```

**3. View 层**

```ruby
# apps/web/views/posts/show.rb
module Web
  module Views
    module Posts
      class Show
        include Web::View
      end
    end
  end
end
```

**4. 模板**

```erb
<%# apps/web/templates/posts/show.html.erb %>
<article>
  <h1><%= post.title %></h1>
  <time><%= post.created_at.strftime("%Y-%m-%d") %></time>
  <div class="body"><%= post.body %></div>
  <p>Status: <%= post.status %></p>
</article>

<p>
  <a href="<%= url(:edit_post, id: post.id) %>">编辑</a> |
  <form action="<%= url(:post, id: post.id) %>" method="post" style="display:inline">
    <input type="hidden" name="_method" value="delete">
    <button type="submit">删除</button>
  </form>
</p>
```

## 性能对比

以下是社区基准测试的典型数据（单请求响应时间，越低越好）：

| 框架     | 启动时间 | 简单请求 | 数据库查询 | 内存占用 |
|----------|----------|----------|------------|----------|
| Rails 7  | ~2.5s    | ~45ms    | ~120ms     | ~180MB   |
| Hanami 2 | ~0.4s    | ~15ms    | ~40ms      | ~65MB    |
| Sinatra  | ~0.2s    | ~8ms     | ~35ms      | ~30MB    |

Hanami 在启动速度和内存上比 Rails 有显著优势，同时保持了接近 Rails 的开发体验。Sinatra 更快更轻，但没有 Hanami 的结构化架构。

## 何时选择 Hanami

选择 Hanami 的情况：
- 项目生命周期超过 6 个月
- 团队 3 人以上，需要明确的代码组织规则
- 领域模型复杂，需要 DDD 模式
- 对性能有要求，尤其是容器化部署场景（快速启动很关键）

选择 Rails 的情况：
- 项目需要在 1-2 周内上线
- 团队中大多数成员熟悉 Rails
- 需要大量现成的 gem 生态（后台管理、支付集成等）
- 快速验证创业想法

## 本章要点

- Hanami 是 Rails 的替代方案，采用干净架构和领域驱动设计
- Actions、Views、Repositories、Entities 四层严格分离
- Entities 是纯 Ruby 对象，不含 ORM 行为
- Repositories 通过 Sequel 访问数据库，支持复杂查询和事务
- 每个 Action 是独立的类，参数验证通过 dry-validation 声明
- 底层使用 dry-system 实现依赖注入
- 性能约为 Rails 的 3 倍，适合中长期项目和容器化部署

## 继续学习

- Hanami 官方指南: [hanamirb.org](https://hanamirb.org)
- dry-system 文档: [dry-rb.org/gems/dry-system](https://dry-rb.org/gems/dry-system)
- Sequel ORM: [sequel.jeremyevans.net](https://sequel.jeremyevans.net)
- 项目中的 DI 基础: [依赖注入](../advance/dry-system.md)
- 轻量替代方案: [Sinatra](sinatra.md)

> 💡 **提示**：Hanami 的学习曲线比 Rails 更陡，因为你需要理解 Repository 模式和干系统。但一旦跨过这个门槛，你会得到一个更容易测试、更容易重构的项目结构。
