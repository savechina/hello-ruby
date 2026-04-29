# typed: true
# frozen_string_literal: true

require "json"

module Hello
  module Awesome
    class GrapeDemo
      def self.run
        puts "=== Grape — Ruby REST API 专用微框架 ==="
        puts

        api = TaskAPI.new

        puts "1. API 配置"
        puts "  prefix: #{api.prefix}, format: #{api.format}, version: #{api.version}"
        puts

        puts "2. 列出任务 (GET /api/v1/tasks)"
        result = api.handle_request(method: :get, path: "/api/v1/tasks")
        puts "  Status: #{result[:status]}"
        puts "  返回: #{result[:body].to_json}"
        puts

        puts "3. 获取单个任务 (GET /api/v1/tasks/1)"
        result = api.handle_request(method: :get, path: "/api/v1/tasks/1")
        puts "  Status: #{result[:status]}"
        puts "  返回: #{result[:body].to_json}"
        puts

        puts "4. 创建任务 (POST /api/v1/tasks)"
        result = api.handle_request(method: :post, path: "/api/v1/tasks", params: { title: "Build API", priority: 3 })
        puts "  Status: #{result[:status]}"
        puts "  返回: #{result[:body].to_json}"
        puts

        puts "5. 创建任务 — 参数验证失败"
        result = api.handle_request(method: :post, path: "/api/v1/tasks", params: { title: "" })
        puts "  Status: #{result[:status]}"
        puts "  返回: #{result[:body].to_json}"
        puts

        puts "6. 更新任务 (PUT /api/v1/tasks/1)"
        result = api.handle_request(method: :put, path: "/api/v1/tasks/1", params: { status: "done" })
        puts "  Status: #{result[:status]}"
        puts "  返回: #{result[:body].to_json}"
        puts

        puts "7. 删除任务 (DELETE /api/v1/tasks/2)"
        result = api.handle_request(method: :delete, path: "/api/v1/tasks/2")
        puts "  Status: #{result[:status]}"
        puts "  返回: #{result[:body].to_json}"
        puts

        puts "8. 路由不存在"
        result = api.handle_request(method: :get, path: "/api/v1/unknown")
        puts "  Status: #{result[:status]}"
        puts "  返回: #{result[:body].to_json}"
        puts

        puts "--- Grape 特性 ---"
        puts "  参数验证: requires/optional, type, values, mutually_exclusive"
        puts "  版本管理: path/header/param 方式，支持 v1/v2 并行"
        puts "  响应格式: :json/:xml/:txt 内容协商"
        puts "  错误处理: rescue_from 自定义错误响应"
        puts "  文档生成: grape-swagger → OpenAPI/Swagger JSON"
      end
    end

    class GrapeTask
      attr_accessor :id, :title, :status, :priority

      def initialize(id:, title:, status: "pending", priority: 1)
        @id = id
        @title = title
        @status = status
        @priority = priority
      end

      def to_hash
        { id: @id, title: @title, status: @status, priority: @priority }
      end
    end

    class TaskAPI
      attr_reader :prefix, :format, :version

      def initialize
        @prefix = "api"
        @format = :json
        @version = "v1"
        @tasks = [
          GrapeTask.new(id: 1, title: "Setup Grape", status: "done", priority: 1),
          GrapeTask.new(id: 2, title: "Add Validation", status: "in_progress", priority: 2)
        ]
        @next_id = 3
      end

      def handle_request(method:, path:, params: {})
        parsed = parse_route(path)
        return response(404, { error: "Route not found" }) unless parsed

        case parsed[:resource]
        when "tasks"
          if parsed[:id]
            handle_single_task(method, parsed, params)
          else
            handle_task_collection(method, params)
          end
        else
          response(404, { error: "Unknown resource" })
        end
      end

      private

      def parse_route(path)
        prefix_path = "/#{@prefix}/#{@version}/"
        return nil unless path.start_with?(prefix_path)
        rest = path[prefix_path.length..]
        parts = rest.split("/")
        { resource: parts[0], id: parts[1]&.to_i }
      end

      def handle_single_task(method, parsed, params)
        task = @tasks.find { |t| t.id == parsed[:id] }
        return response(404, { error: "Task not found" }) unless task

        case method
        when :get then response(200, task.to_hash)
        when :put
          task.status = params[:status] if params[:status]
          task.title = params[:title] if params[:title]
          response(200, task.to_hash)
        when :delete
          @tasks.delete(task)
          response(204, { message: "Task #{task.id} deleted" })
        else
          response(405, { error: "Method not allowed" })
        end
      end

      def handle_task_collection(method, params)
        case method
        when :get
          response(200, @tasks.map(&:to_hash))
        when :post
          errors = validate_create(params)
          return response(400, { error: "Validation failed", messages: errors }) unless errors.empty?

          task = GrapeTask.new(id: @next_id, title: params[:title], priority: params[:priority] || 1)
          @next_id += 1
          @tasks << task
          response(201, task.to_hash)
        else
          response(405, { error: "Method not allowed for collection" })
        end
      end

      def validate_create(params)
        errors = []
        errors << "title is required" if params[:title].to_s.strip.empty?
        errors << "priority must be 1-5" if params[:priority] && !(1..5).include?(params[:priority])
        errors
      end

      def response(status, body)
        { status: status, body: body }
      end
    end
  end
end

Hello::TopicRegistry.register("awesome", "grape", "Grape REST API", Hello::Awesome::GrapeDemo)
