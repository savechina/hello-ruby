# typed: true
# frozen_string_literal: true

module Hello
  module Awesome
    # Grape REST API 框架 — 类 Sinatra 的 API DSL
    # 演示 API 版本化、参数校验、响应格式化、异常处理
    module GrapeDemo
      def self.run
        puts "=== Grape REST API ==="
        puts

        # --- 1. API 基类 ---
        puts "--- API 基类：继承 Grape::API ---"
        example_code = <<~RUBY
          require "grape"
          require "grape-entity"
          require "json"

          class API < Grape::API
            # 挂载子 API
            mount V1::Base
            mount V2::Base
          end
        RUBY
        puts "  #{example_code.strip}"
        puts "  → Grape::API 是 Rack 应用，可通过 Rack::Builder 挂载"
        puts

        # --- 2. 版本化（V1 / V2） ---
        puts "--- 版本化：命名空间 + 路径前缀 ---"
        example_code2 = <<~RUBY
          module V1
            class Base < Grape::API
              prefix "api"
              format :json

              # GET  /api/users     → V1 接口
              # GET  /api/tweets    → V1 接口

              resource :users do
                desc "Get all users"
                get do
                  User.all.as_json
                end

                desc "Get a single user"
                params do
                  requires :id, type: Integer, desc: "User ID"
                end
                route_param :id do
                  get do
                    User.find(params[:id])
                  end
                end
              end
            end
          end

          module V2
            class Base < Grape::API
              prefix "api"

              # GET  /api/v2/users  → V2 接口
              namespace :users do
                desc "Get all users (V2 with pagination)"
                params do
                  optional :page, type: Integer, default: 1
                  optional :per_page, type: Integer, default: 20
                end
                get do
                  users = User
                    .page(params[:page])
                    .per(params[:per_page])
                  { users:, total: User.count, page: params[:page] }
                end
              end
            end
          end
        RUBY
        puts "  #{example_code2.strip}"
        puts "  → resource 和 namespace 创建嵌套路径；version 可选（路径或 header 版本化）"
        puts

        # --- 3. 参数校验 ---
        puts "--- 参数校验：params DSL ---"
        example_code3 = <<~RUBY
          post "/tweets" do
            params do
              # 必需参数
              requires :status, type: String, length: { minimum: 1, maximum: 280 }

              # 可选参数，带默认值
              optional :lang, type: String, values: %w[en zh ja], default: "en"

              # 必需参数组（至少一个）
              requires :media, type: Hash do
                optional :image_url, type: String
                optional :video_url, type: String
              end
              at_least_one_of :media

              # 自定义校验
              optional :scheduled_at do |value|
                Time.parse(value) rescue nil
              end
            end

            # 通过校验后 params 才可用
            Tweet.create!(params.slice(:status, :lang))

            { tweet: { id: 42, status: params[:status], lang: params[:lang] } }
          end
        RUBY
        puts "  #{example_code3.strip}"
        puts "  → params 块定义校验规则，失败时自动返回 400 错误"
        puts

        # --- 4. 响应格式化 ---
        puts "--- 响应格式化：grape-entity ---"
        example_code4 = <<~RUBY
          # app/entities/user_entity.rb
          class UserEntity < Grape::Entity
            # 暴露字段
            expose :id, :username, :email

            # 暴露带别名
            expose :first_name, as: :firstName
            expose :last_name, as: :lastName

            # 暴露计算字段
            expose :full_name do |user, options|
              "#{user.first_name} #{user.last_name}"
            end

            # 条件暴露
            expose :api_key, if: { role: :admin }

            # 嵌套暴露
            expose :profile, using: ProfileEntity

            # 自定义格式化
            expose :created_at, format_with: :iso_timestamp
          end

          # 使用实体格式化响应
          get "/users/:id" do
            user = User.find(params[:id])
            present user, with: UserEntity
          end
        RUBY
        puts "  #{example_code4.strip}"
        puts "  → grape-entity 声明响应格式，支持条件暴露和嵌套"
        puts

        # --- 5. 异常处理 ---
        puts "--- 异常处理：rescue_from ---"
        example_code5 = <<~RUBY
          class API < Grape::API
            format :json

            # 捕获 ActiveRecord::RecordNotFound
            rescue_from :all do |e|
              # :all 捕获所有异常
              error!({ error: e.message, backtrace: e.backtrace.first(5) }, 500)
            end

            rescue_from ActiveRecord::RecordInvalid do |e|
              error!({ error: e.message, details: e.record.errors }, 422)
            end

            rescue_from ActiveRecord::RecordNotFound do |e|
              error!({ error: "Not Found" }, 404)
            end

            rescue_from Grape::Exceptions::ValidationErrors do |e|
              error!({ error: "Validation Failed", messages: e.message }, 400)
            end
          end
        RUBY
        puts "  #{example_code5.strip}"
        puts "  → rescue_from 按类型匹配异常，error! 返回标准化错误响应"
        puts

        # --- 6. 中间件 ---
        puts "--- 中间件：认证 / rate limiting ---"
        example_code6 = <<~RUBY
          module V1
            class Base < Grape::API
              # HTTP Basic 认证
              http_basic do |username, password|
                username == ENV["API_USER"] && password == ENV["API_PASS"]
              end

              # 自定义 Header 认证
              helpers do
                def current_user
                  token = env["HTTP_AUTHORIZATION"]&.split(" ")&.last
                  return unless token

                  payload = JWT.decode(token, ENV["SECRET_KEY"]).first
                  User.find(payload["user_id"])
                end
              end

              # Rate Limiting
              before do
                limit = 100
                key   = "rate:#{env["HTTP_X_FORWARDED_FOR"]}"
                count = redis.incr(key)
                redis.expire(key, 3600)

                error!("Rate Limit Exceeded", 429) if count > limit
              end
            end
          end
        RUBY
        puts "  #{example_code6.strip}"
        puts "  → http_basic / helpers / before 实现认证和限流"
        puts

        # --- 7. 模拟输出 ---
        puts "--- 模拟请求 / 响应 ---"
        puts "  GET  /api/users          → V1: [{\"id\":1,\"username\":\"alice\"}]"
        puts "  GET  /api/v2/users?per_page=5 → V2: {\"users\":[...],\"total\":120,\"page\":1}"
        puts "  POST /api/tweets         → 201: {\"tweet\":{\"id\":42,\"status\":\"Hello!\",\"lang\":\"en\"}}"
        puts "  GET  /api/users/999      → 404: {\"error\":\"Not Found\"}"
        puts "  POST /api/tweets (bad)   → 400: {\"error\":\"Validation Failed\",\"messages\":\"...\"}"
        puts
        puts "  Grape 特点:"
        puts "  - 专为 API 设计，DSL 类似 Sinatra 但更结构化"
        puts "  - 内置版本化支持（路径 / header / 参数）"
        puts "  - 参数校验 DSL 完整（requires / optional / at_least_one_of）"
        puts "  - grape-entity 统一响应格式"
        puts "  - 兼容 Sinatra 中间件和 Rack 生态"
      end
    end
  end
end

Hello::TopicRegistry.register("awesome", "grape_demo", "Grape REST API 版本化与校验", Hello::Awesome::GrapeDemo)
