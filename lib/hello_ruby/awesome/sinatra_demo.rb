# typed: true
# frozen_string_literal: true

module Hello
  module Awesome
    # Sinatra REST API 模式 — 轻量级 DSL 风格的 Web 框架
    # 演示路由定义、参数处理、请求体解析、JSON 响应
    module SinatraDemo
      def self.run
        puts "=== Sinatra REST API ==="
        puts

        # --- 1. 基本路由 ---
        puts "--- 路由定义：HTTP Method 映射 ---"
        example_code = <<~RUBY
          require "sinatra"
          require "json"

          # GET — 查询资源
          get "/articles" do
            content_type :json
            Article.all.to_json
          end

          # GET with 路径参数
          get "/articles/:id" do
            article = Article.find(params["id"])
            if article
              content_type :json
              article.to_json
            else
              status 404
              { error: "Article not found" }.to_json
            end
          end

          # POST — 创建资源
          post "/articles" do
            data = JSON.parse(request.body.read)
            article = Article.create(title: data["title"], body: data["body"])
            status 201
            content_type :json
            article.to_json
          end

          # PUT — 更新资源
          put "/articles/:id" do
            data = JSON.parse(request.body.read)
            article = Article.find(params["id"])
            article.update(data.slice("title", "body"))
            content_type :json
            article.to_json
          end

          # DELETE — 删除资源
          delete "/articles/:id" do
            Article.find(params["id"])&.destroy
            status 204
          end
        RUBY
        puts "  #{example_code.strip}"
        puts "  → Sinatra 用 DSL 将 HTTP 方法与路径绑定，params 自动解析路径和查询参数"
        puts

        # --- 2. 参数处理 ---
        puts "--- 参数处理：params / request.body ---"
        example_code2 = <<~RUBY
          post "/search" do
            # params 自动合并路径参数 + 查询字符串 + form 数据
            query = params["q"]
            page  = params["page"].to_i
            per   = params["per_page"].to_i

            # JSON 请求体需要手动解析
            body = JSON.parse(request.body.read)
            filters = body["filters"]

            results = Article.search(query, filters:)
            { results:, page:, total: results.count }.to_json
          end
        RUBY
        puts "  #{example_code2.strip}"
        puts "  → params 是万能哈希；JSON body 需 request.body.read + JSON.parse"
        puts

        # --- 3. 请求/响应控制 ---
        puts "--- 请求/响应控制：status / headers / content_type ---"
        example_code3 = <<~RUBY
          get "/api/data" do
            # 设置状态码
            status 200

            # 设置响应头
            headers "X-API-Version" => "1.0", "Cache-Control" => "no-cache"

            # 设置内容类型
            content_type :json

            # 重定向
            # redirect "/new-location", 301

            { data: [1, 2, 3] }.to_json
          end
        RUBY
        puts "  #{example_code3.strip}"
        puts "  → status() / headers() / content_type() 控制 HTTP 响应元信息"
        puts

        # --- 4. 错误处理 ---
        puts "--- 错误处理：not_found / error 块 ---"
        example_code4 = <<~RUBY
          not_found do
            content_type :json
            status 404
            { error: "Not Found", path: request.path_info }.to_json
          end

          error do
            content_type :json
            status 500
            { error: "Internal Server Error", message: env["sinatra.error"].message }.to_json
          end
        RUBY
        puts "  #{example_code4.strip}"
        puts "  → 全局错误处理，统一 JSON 响应格式"
        puts

        # --- 5. Sinatra 特点 ---
        puts "--- Sinatra 与 Rails 对比 ---"
        puts "  特点:"
        puts "  - 单个文件即可运行，无需项目骨架"
        puts "  - DSL 极简，一个方法调用就是一个路由"
        puts "  - 适合微服务、API 代理、简单工具"
        puts "  - 兼容 Rack 中间件生态"
        puts "  - 缺点：没有内置 MVC、ORM、任务队列"
        puts

        # --- 6. 模拟示例输出 ---
        puts "--- 模拟请求 / 响应 ---"
        puts "  GET  /articles       → 200 [{\"id\":1,\"title\":\"Hello\"}]"
        puts "  GET  /articles/1     → 200 {\"id\":1,\"title\":\"Hello\",\"body\":\"...\"}"
        puts "  POST /articles       → 201 {\"id\":2,\"title\":\"New\"}"
        puts "  PUT  /articles/1     → 200 {\"id\":1,\"title\":\"Updated\"}"
        puts "  DELETE /articles/1   → 204 (no body)"
        puts "  GET  /articles/999   → 404 {\"error\":\"Article not found\"}"
      end
    end
  end
end

Hello::TopicRegistry.register("awesome", "sinatra_demo", "Sinatra REST API 模式", Hello::Awesome::SinatraDemo)
