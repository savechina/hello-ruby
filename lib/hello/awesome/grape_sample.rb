# typed: true
# frozen_string_literal: true

require "grape"
require "rack/test"

require_relative "../topic_registry"

module Hello
  module Awesome
    # TaskAPI — Grape REST API 示例
    # 继承 Grape::API，使用内置路由、参数验证、错误处理
    class TaskAPI < Grape::API
      # 共享任务存储（类级别），API 路由块中可访问
      class << self
        def api_tasks
          @api_tasks ||= [
            { id: 1, title: "Setup Grape", status: "done", priority: 1 },
            { id: 2, title: "Add Validation", status: "in_progress", priority: 2 }
          ]
        end

        def reset_tasks
          @api_tasks = nil
        end
      end

      # API 基础路径前缀
      prefix :api
      # 版本管理：URL 路径中包含版本号
      version "v1", using: :path
      # 响应格式
      format :json

      # 未定义路由 — 返回 404
      rescue_from do
        error!({ error: "Route not found" }, 404)
      end

      resource :tasks do
        # GET /api/v1/tasks — 列出所有任务
        get do
          TaskAPI.api_tasks
        end

        # GET /api/v1/tasks/:id — 获取单个任务
        get ":id" do
          task = TaskAPI.api_tasks.find { |t| t[:id] == params[:id].to_i }
          return error!({ error: "Task not found" }, 404) unless task

          task
        end

        # POST /api/v1/tasks — 创建新任务（带参数验证）
        params do
          requires :title, type: String, desc: "任务标题"
          optional :priority, type: Integer, values: 1..5, desc: "优先级 1-5"
        end
        post do
          task = {
            id: (TaskAPI.api_tasks.map { |t| t[:id] }.max || 0) + 1,
            title: params[:title],
            status: "pending",
            priority: params[:priority] || 1
          }
          TaskAPI.api_tasks << task
          task
        end

        # PUT /api/v1/tasks/:id — 更新任务
        params do
          requires :id, type: Integer, desc: "任务 ID"
          optional :status, type: String, values: %w[pending in_progress done], desc: "任务状态"
          optional :title, type: String, desc: "任务标题"
        end
        put ":id" do
          task = TaskAPI.api_tasks.find { |t| t[:id] == params[:id].to_i }
          return error!({ error: "Task not found" }, 404) unless task

          task[:status] = params[:status] if params[:status]
          task[:title] = params[:title] if params[:title]
          task
        end

        # DELETE /api/v1/tasks/:id — 删除任务
        delete ":id" do
          task_index = TaskAPI.api_tasks.index { |t| t[:id] == params[:id].to_i }
          return error!({ error: "Task not found" }, 404) unless task_index

          TaskAPI.api_tasks.delete_at(task_index)
          { message: "Task #{params[:id]} deleted" }
        end
      end
    end

    # GrapeSample — 演示 Grape API 实际运作方式
    # 使用 Rack::Test（真实 HTTP 请求模拟）测试 Grape API
    class GrapeSample
      def self.run
        puts "=== Grape — Ruby REST API 专用微框架 ==="
        puts

        # 重置任务数据保证演示一致性
        TaskAPI.reset_tasks

        # Rack::Test 会话 — 直接对 Grape API 发起请求（无需启动服务器）
        client = Rack::Test::Session.new(Rack::MockSession.new(TaskAPI))

        puts "1. API 配置"
        puts "  prefix: api, format: json, version: v1 (path)"
        puts

        puts "2. 列出任务 (GET /api/v1/tasks)"
        client.get "/api/v1/tasks"
        puts "  状态: #{client.last_response.status}"
        puts "  返回: #{client.last_response.body}"
        puts

        puts "3. 获取单个任务 (GET /api/v1/tasks/1)"
        client.get "/api/v1/tasks/1"
        puts "  状态: #{client.last_response.status}"
        puts "  返回: #{client.last_response.body}"
        puts

        puts "4. 创建任务 (POST /api/v1/tasks)"
        client.post "/api/v1/tasks", { title: "Build API", priority: 3 }.to_json, "CONTENT_TYPE" => "application/json"
        puts "  状态: #{client.last_response.status}"
        puts "  返回: #{client.last_response.body}"
        puts

        puts "5. 创建任务 — 参数验证失败"
        client.post "/api/v1/tasks", {}.to_json, "CONTENT_TYPE" => "application/json"
        puts "  状态: #{client.last_response.status}"
        puts "  返回: #{client.last_response.body}"
        puts

        puts "6. 更新任务 (PUT /api/v1/tasks/1)"
        client.put "/api/v1/tasks/1", { status: "done" }.to_json, "CONTENT_TYPE" => "application/json"
        puts "  状态: #{client.last_response.status}"
        puts "  返回: #{client.last_response.body}"
        puts

        puts "7. 删除任务 (DELETE /api/v1/tasks/2)"
        client.delete "/api/v1/tasks/2"
        puts "  状态: #{client.last_response.status}"
        puts "  返回: #{client.last_response.body}"
        puts

        puts "8. 路由不存在 (GET /api/v1/unknown)"
        client.get "/api/v1/unknown"
        puts "  状态: #{client.last_response.status}"
        puts "  返回: #{client.last_response.body}"
        puts

        puts "9. Grape 路由列表（API 自省）"
        TaskAPI.routes.each do |route|
          puts "  #{route.request_method.to_s.upcase.ljust(7)} #{route.path}"
        end
        puts

        puts "--- Grape 核心特性 ---"
        puts "  参数验证: requires/optional, type, values, mutually_exclusive"
        puts "  版本管理: path/header/param 方式，支持 v1/v2 并行"
        puts "  响应格式: :json/:xml/:txt 内容协商"
        puts "  错误处理: error! / rescue_from 自定义错误响应"
        puts "  文档生成: grape-swagger → OpenAPI/Swagger JSON"
      end
    end
  end
end

Hello::TopicRegistry.register("awesome", "grape", "Grape REST API", Hello::Awesome::GrapeSample)
