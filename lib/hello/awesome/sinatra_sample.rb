# typed: true
# frozen_string_literal: true

require "json"
require "uri"
require "sequel"
require "sinatra/base"
require "rack/test"

module Hello
  module Awesome
    # Sinatra — 轻量级 REST 微框架
    # 生产级示例：RealTaskAPI 使用 Sinatra::Base + Sequel
    # 教学示例：MemoryTaskStore 模拟内部实现原理
    class SinatraSample
      def self.run
        puts "=== Sinatra — 轻量级 REST 微框架 ==="
        puts

        # ====== 1. 真实 Sinatra REST API（生产级用法）======
        puts "=== 1. 真实 Sinatra REST API（生产级用法） ==="
        puts
        sinatra_real_demo

        # ====== 2. 内存模拟（理解内部原理）======
        puts
        puts "=== 2. 内存模拟（理解内部原理） ==="
        puts "  以下演示 REST API 内部实现模式，帮助理解 Sinatra 路由如何工作"
        puts "  生产环境请使用 RealTaskAPI 模式"
        puts
        mock_demo
      end

      # 真实 Sinatra REST API - 生产级用法
      def self.sinatra_real_demo
        puts "  使用 Sinatra gem + Sequel + Rack::Test 实现真实 REST API"
        puts

        # 创建测试应用
        app = RealTaskAPI.new
        env = Rack::Test::Session.new(app)

        puts "  Sinatra 应用结构:"
        puts "    - 继承 Sinatra::Base（模块化风格）"
        puts "    - Sequel 数据库集成（线程安全连接池）"
        puts "    - before 过滤器设置 JSON 内容类型"
        puts "    - error 处理器捕获 JSON 解析错误"
        puts "    - Rack::Test 测试驱动（无需启动服务器）"
        puts

        # 测试 CRUD 操作
        puts "1. 创建任务 (POST /api/tasks)"
        env.post "/api/tasks", JSON.generate(title: "Build REST API", status: "pending"), "CONTENT_TYPE" => "application/json"
        puts "  返回: #{env.last_response.body}"
        puts "  状态: #{env.last_response.status}"
        puts

        env.post "/api/tasks", JSON.generate(title: "Write Tests", status: "pending"), "CONTENT_TYPE" => "application/json"
        env.post "/api/tasks", JSON.generate(title: "Deploy to Docker", status: "done"), "CONTENT_TYPE" => "application/json"

        puts "2. 列出所有任务 (GET /api/tasks)"
        env.get "/api/tasks"
        puts "  返回: #{env.last_response.body}"
        puts "  状态: #{env.last_response.status}"
        puts

        puts "3. 获取单个任务 (GET /api/tasks/1)"
        env.get "/api/tasks/1"
        puts "  返回: #{env.last_response.body}"
        puts "  状态: #{env.last_response.status}"
        puts

        puts "4. 更新任务 (PUT /api/tasks/1)"
        env.put "/api/tasks/1", JSON.generate(status: "done"), "CONTENT_TYPE" => "application/json"
        puts "  返回: #{env.last_response.body}"
        puts "  状态: #{env.last_response.status}"
        puts

        puts "5. 删除任务 (DELETE /api/tasks/2)"
        env.delete "/api/tasks/2"
        puts "  返回: #{env.last_response.body}"
        puts "  状态: #{env.last_response.status}"
        puts

        puts "6. 查找不存在的任务 (GET /api/tasks/99)"
        env.get "/api/tasks/99"
        puts "  返回: #{env.last_response.body}"
        puts "  状态: #{env.last_response.status}"
        puts

        puts "7. 错误处理演示 (POST 无效 JSON)"
        env.post "/api/tasks", "invalid json", "CONTENT_TYPE" => "application/json"
        puts "  返回: #{env.last_response.body}"
        puts "  状态: #{env.last_response.status}"
        puts

        puts "8. Sinatra 路由定义:"
        RealTaskAPI.routes.each do |method, route_list|
          route_list.each do |route_info|
            pattern = route_info[0].to_s
            puts "  #{method.to_s.upcase.ljust(7)} #{pattern}"
          end
        end
        puts

        puts "=== 真实 Sinatra REST API 演示完成 ==="
        puts

        puts "  启动服务器命令:"
        puts "    ruby -e 'require \"hello/awesome/sinatra_sample\"; Hello::Awesome::RealTaskAPI.run!'"
        puts
        puts "  或使用 config.ru:"
        puts "    rackup config.ru -p 4567"
      end

      # 内存模拟 - 教学示例
      def self.mock_demo
        store = MemoryTaskStore.new

        puts "1. 创建任务 (模拟 POST /api/tasks)"
        new_task = store.create(title: "Build REST API", status: "pending")
        puts "  返回: #{new_task.to_json}"
        puts

        store.create(title: "Write Tests", status: "pending")
        store.create(title: "Deploy to Docker", status: "done")
        puts "2. 列出所有任务 (模拟 GET /api/tasks)"
        all_tasks = store.list
        puts "  返回: #{all_tasks.to_json}"
        puts

        puts "3. 获取单个任务 (模拟 GET /api/tasks/1)"
        task = store.find(1)
        puts "  返回: #{task.to_json}"
        puts

        puts "4. 更新任务 (模拟 PUT /api/tasks/1)"
        updated = store.update(1, status: "done")
        puts "  返回: #{updated.to_json}"
        puts

        puts "5. 删除任务 (模拟 DELETE /api/tasks/2)"
        deleted = store.delete(2)
        puts "  返回: #{deleted[:status]} (#{deleted[:message]})"
        puts

        puts "6. 查找不存在的任务 (模拟 GET /api/tasks/99)"
        result = store.find(99)
        puts "  返回: #{JSON.generate(result)}"
        puts

        puts "7. 路由 DSL 演示（模拟 Sinatra 路由定义）"
        TaskApp.new.routes.each do |route|
          puts "  #{route[:method].to_s.upcase.ljust(7)} #{route[:path].ljust(25)} → #{route[:action]}"
        end
        puts

        puts "=== 内存模拟演示完成 ==="
      end
    end

    # ====== 真实 Sinatra REST API 应用（模块化风格）======
    # 生产级用法参考：继承 Sinatra::Base + Sequel 数据库
    class RealTaskAPI < Sinatra::Base
      # 配置
      set :bind, "0.0.0.0"
      set :port, 4567
      set :show_exceptions, false

      # Sequel 数据库（内存 SQLite）
      # 生产环境替换为: Sequel.connect(ENV['DATABASE_URL'])
      DB = Sequel.sqlite

      # 初始化数据库表
      DB.create_table? :tasks do
        primary_key :id
        String :title, null: false
        String :status, default: "pending"
        DateTime :created_at
      end

      # 前置过滤器：设置 JSON 内容类型
      before do
        content_type :json
      end

      # GET /api/tasks - 列出所有任务
      get "/api/tasks" do
        tasks = DB[:tasks].all
        JSON.generate(tasks)
      end

      # GET /api/tasks/:id - 获取单个任务
      get "/api/tasks/:id" do
        task = DB[:tasks].where(id: params[:id].to_i).first
        if task
          JSON.generate(task)
        else
          status 404
          JSON.generate(error: "Task not found")
        end
      end

      # POST /api/tasks - 创建任务
      post "/api/tasks" do
        data = JSON.parse(request.body.read)
        task_id = DB[:tasks].insert(
          title: data["title"],
          status: data["status"] || "pending",
          created_at: Time.now
        )
        task = DB[:tasks].where(id: task_id).first
        status 201
        JSON.generate(task)
      end

      # PUT /api/tasks/:id - 更新任务
      put "/api/tasks/:id" do
        data = JSON.parse(request.body.read)
        task = DB[:tasks].where(id: params[:id].to_i).first
        if task
          DB[:tasks].where(id: params[:id].to_i).update(data.slice("title", "status"))
          updated = DB[:tasks].where(id: params[:id].to_i).first
          JSON.generate(updated)
        else
          status 404
          JSON.generate(error: "Task not found")
        end
      end

      # DELETE /api/tasks/:id - 删除任务
      delete "/api/tasks/:id" do
        count = DB[:tasks].where(id: params[:id].to_i).delete
        if count > 0
          JSON.generate(status: "deleted", count: count)
        else
          status 404
          JSON.generate(error: "Task not found")
        end
      end

      # GET /health - 健康检查
      get "/health" do
        JSON.generate(status: "ok", version: "1.0.0")
      end

      # 错误处理
      error JSON::ParserError do
        status 400
        JSON.generate(error: "Invalid JSON")
      end

      error Sequel::Error do
        status 500
        JSON.generate(error: "Database error")
      end
    end

    # ====== 内存模拟存储层（教学示例）======
    # 用于理解 REST API 内部实现原理
    # 生产环境请使用 Sequel/ActiveRecord
    class MemoryTaskStore
      def initialize
        @tasks = []
        @next_id = 1
      end

      def create(params)
        task = {
          "id" => @next_id,
          "title" => params[:title],
          "status" => params[:status] || "pending",
          "created_at" => Time.now.to_s
        }
        @tasks << task
        @next_id += 1
        task
      end

      def list
        @tasks.dup
      end

      def find(id)
        task = @tasks.find { |t| t["id"] == id }
        return nil unless task
        task
      end

      def update(id, params)
        task = find(id)
        return nil unless task
        params.each { |k, v| task[k.to_s] = v }
        task
      end

      def delete(id)
        index = @tasks.index { |t| t["id"] == id }
        return { status: "not_found", message: "Task #{id} not found" } unless index
        @tasks.delete_at(index)
        { status: "deleted", message: "Task #{id} removed" }
      end
    end

    # ====== 模拟 Sinatra 路由 DSL（教学示例）======
    # 用于理解 Sinatra 路由如何定义和匹配
    class TaskApp
      def routes
        [
          { method: :get,    path: "/api/tasks",     action: "list_tasks" },
          { method: :get,    path: "/api/tasks/:id", action: "show_task" },
          { method: :post,   path: "/api/tasks",     action: "create_task" },
          { method: :put,    path: "/api/tasks/:id", action: "update_task" },
          { method: :delete, path: "/api/tasks/:id", action: "delete_task" }
        ]
      end
    end
  end
end

Hello::TopicRegistry.register("awesome", "sinatra", "Sinatra 微框架", Hello::Awesome::SinatraSample)