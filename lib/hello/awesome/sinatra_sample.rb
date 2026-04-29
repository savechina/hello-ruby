# typed: true
# frozen_string_literal: true

require "json"
require "uri"

module Hello
  module Awesome
    # Sinatra — 轻量级 REST 微框架
    # 不依赖 sinatra gem，演示核心路由+请求+响应模式
    class SinatraDemo
      def self.run
        puts "=== Sinatra — 轻量级 REST 微框架 ==="
        puts

        # 1. 内存数据存储（模拟数据库）
        store = MemoryTaskStore.new

        puts "1. 创建任务 (POST /api/tasks)"
        new_task = store.create(title: "Build REST API", status: "pending")
        puts "  返回: #{new_task.to_json}"
        puts

        store.create(title: "Write Tests", status: "pending")
        store.create(title: "Deploy to Docker", status: "done")
        puts "2. 列出所有任务 (GET /api/tasks)"
        all_tasks = store.list
        puts "  返回: #{all_tasks.to_json}"
        puts

        puts "3. 获取单个任务 (GET /api/tasks/1)"
        task = store.find(1)
        puts "  返回: #{task.to_json}"
        puts

        puts "4. 更新任务 (PUT /api/tasks/1)"
        updated = store.update(1, status: "done")
        puts "  返回: #{updated.to_json}"
        puts

        puts "5. 删除任务 (DELETE /api/tasks/2)"
        deleted = store.delete(2)
        puts "  返回: #{deleted[:status]} (#{deleted[:message]})"
        puts

        puts "6. 查找不存在的任务 (GET /api/tasks/99)"
        result = store.find(99)
        puts "  返回: #{JSON.generate(result)}"
        puts

        # 7. 演示 Sinatra 风格的路由 DSL
        puts "7. 路由 DSL 演示（模拟 Sinatra 路由定义）"
        TaskApp.new.routes.each do |route|
          puts "  #{route[:method].to_s.upcase.ljust(7)} #{route[:path].ljust(25)} → #{route[:action]}"
        end
      end
    end

    # 模拟数据库存储层
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

    # 模拟 Sinatra 应用的路由定义
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

Hello::TopicRegistry.register("awesome", "sinatra", "Sinatra 微框架", Hello::Awesome::SinatraDemo)
