# typed: true
# frozen_string_literal: true

module Hello
  module Awesome
    # Hanami 2.x Clean Architecture 模式
    # 演示 actions / repositories / entities 分层、dry-validation 参数校验、DI inject 模式
    module HanamiDemo
      def self.run
        puts "=== Hanami 2.x Clean Architecture ==="
        puts

        # --- 1. Hanami 架构理念 ---
        puts "--- Clean Architecture 分层 ---"
        puts "  Hanami 采用洋葱架构（Onion Architecture）："
        puts "  ┌──────────────────────────────┐"
        puts "  │  Web Layer (actions, views)  │  ← 外部：HTTP 协议适配"
        puts "  ├──────────────────────────────┤"
        puts "  ├──────────────────────────────┤"
        puts "  │  App Layer   (use cases)     │  ← 中间：业务流程编排"
        puts "  ├──────────────────────────────┤"
        puts "  │  Persistent Layer (repos)    │  ← 内部：数据持久化"
        puts "  ├──────────────────────────────┤"
        puts "  │  Domain Layer  (entities)    │  ← 核心：业务规则和数据模型"
        puts "  └──────────────────────────────┘"
        puts

        # --- 2. Entity（实体） ---
        puts "--- Entity：领域实体（不可变值对象） ---"
        example_code = <<~RUBY
          # lib/entity/book.rb
          # 实体是纯数据对象，不可变，带类型校验
          class Book < Hanami::Entity
            attributes :id, :title, :author, :price, :created_at

            def discounted_price(discount_amount)
              # 实体方法：不依赖外部，纯领域逻辑
              price - discount_amount
            end

            def expensive?
              price > 50.0
            end
          end
        RUBY
        puts "  #{example_code.strip}"
        puts "  → Entity 是 Hanami::Entity 子类，只包含领域逻辑，无持久化方法"
        puts

        # --- 3. Repository（仓储） ---
        puts "--- Repository：数据访问层 ---"
        example_code2 = <<~RUBY
          # lib/repository/book_repository.rb
          class BookRepository < Hanami::Repository
            # 自定义查询方法，返回 Entity 或 Entity 数组
            def find_by_author(author_name)
              books.where(author: author_name).map(to: :book)
            end

            def expensive_books
              books.where { price > 50.0 }.map(to: :book)
            end

            def find_with_latest_review(book_id)
              # 多表关联查询 → 返回 Struct（不自动映射 Entity）
              books
                .join(:reviews, book_id: :id)
                .where(books__id: book_id)
                .order Sequel.desc(:reviews__created_at)
                .as(:book__id, :book__title, :review_body, :reviewer_name)
                .first
            end
          end
        RUBY
        puts "  #{example_code2.strip}"
        puts "  → Repository 只负责数据访问，返回 Entity 或 Struct"
        puts

        # --- 4. Action（动作） ---
        puts "--- Action：HTTP 请求处理器 ---"
        example_code3 = <<~RUBY
          # apps/web/actions/books/index.rb
          module Web
            module Actions
              module Books
                class Index < Web::Action
                  # 依赖注入：通过 config 注入 repository
                  expose :books, :page, :per_page

                  # 参数校验使用 dry-schema
                  params do
                    required(:page).value(:integer).filled(gte?: 1)
                    optional(:per_page).value(:integer).filled(gte?: 1, lte?: 100)
                  end

                  def handle(req, res)
                    page       = params[:page] || 1
                    per_page   = params[:per_page] || 20
                    offset     = (page - 1) * per_page
                    @books     = books_repo.list(offset, per_page)
                    @page      = page
                    @per_page  = per_page
                  end

                  private

                  def books_repo
                    # 通过 DI 获取 repository
                    @books_repo ||= container["repositories.book"]
                  end
                end
              end
            end
          end
        RUBY
        puts "  #{example_code3.strip}"
        puts "  → Action 是单一职责的请求处理器，params 校验在 params 块中完成"
        puts

        # --- 5. dry-validation 参数校验 ---
        puts "--- 参数校验：dry-validation DSL ---"
        example_code4 = <<~RUBY
          # Hanami 使用 dry-validation 进行参数校验
          params do
            # 必需的整数，最小值 1
            required(:page).value(:integer).filled(gte?: 1)

            # 可选的字符串，需匹配正则
            optional(:email).maybe(:string).format?(/@/)

            # 必需的字符串，非空且长度范围
            required(:name).value(:string, max_size?: 100).filled

            # 必需的哈希，嵌套校验
            required(:address).hash do
              required(:city).value(:string).filled
              required(:zip).value(:string).match?(/\\d{5}/)
            end

            # 自定义校验规则
            rule(:end_date).validate(:end_after_start) do
              unless values[:end_date] > values[:start_date]
                key(:end_date).failure("must be after start_date")
              end
            end
          end
        RUBY
        puts "  #{example_code4.strip}"
        puts "  → dry-validation 提供声明式、组合式的参数校验规则"
        puts

        # --- 6. DI 依赖注入 ---
        puts "--- DI 依赖注入：Hanami::Container ---"
        example_code5 = <<~RUBY
          # config/environment.rb
          module App
            class Application < Hanami::Application
              # 自动注册依赖
              config.auto_register = "lib"

              # 手动注册
              register("services.email_sender") do |container|
                EMail::Sender.new(api_key: container["settings"][:sendgrid_key])
              end
            end
          end

          # 在 Action 中使用注入的依赖
          class Create < Web::Action
            def handle(req, res)
              email_svc = container["services.email_sender"]
              email_svc.send_welcome(params[:email])
              res.redirect_to "/welcome"
            end
          end
        RUBY
        puts "  #{example_code5.strip}"
        puts "  → container 是延迟加载的 DI 容器，通过名称查找注册的服务"
        puts

        # --- 7. Hanami 项目结构 ---
        puts "--- Hanami 项目结构 ---"
        puts "  ├── apps/"
        puts "  │   ├── web/                    ← Web 应用（actions + views + templates）"
        puts "  │   └── api/                    ← API 应用（actions + JSON 响应）"
        puts "  ├── lib/"
        puts "  │   ├── entity/                 ← 领域实体"
        puts "  │   ├── repository/             ← 数据仓储"
        puts "  │   └── use_case/               ← 业务用例"
        puts "  ├── config/"
        puts "  │   ├── routes.rb               ← 全局路由"
        puts "  │   └── settings.rb             ← 应用配置"
        puts "  └── spec/                       ← 测试"
        puts

        # --- 8. 模拟路由和请求 ---
        puts "--- 模拟路由与请求 ---"
        puts "  GET  /books           → Books::Index  (lists all books)"
        puts "  GET  /books/:id       → Books::Show   (single book)"
        puts "  POST /books           → Books::Create (create new book)"
        puts "  PUT  /books/:id       → Books::Update (update book)"
        puts "  DELETE /books/:id     → Books::Destroy (delete book)"
        puts
        puts "  Hanami 特点:"
        puts "  - 分层清晰：Entity → Repository → UseCase → Action → View"
        puts "  - 依赖注入：通过 container 管理所有依赖"
        puts "  - 参数校验：dry-validation 提供完整校验规则"
        puts "  - 不可变：Entity 是不可变值对象"
        puts "  - 轻量：比 Rails 更轻，保留框架优势，去除魔法"
      end
    end
  end
end

Hello::TopicRegistry.register("awesome", "hanami_demo", "Hanami Clean Architecture 模式", Hello::Awesome::HanamiDemo)
