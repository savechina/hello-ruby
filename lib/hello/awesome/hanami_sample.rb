# typed: true
# frozen_string_literal: true

require "hanami"
require "dry-validation"
require "dry-struct"
require_relative "../topic_registry"

module Hello
  module Awesome
    # Types module for dry-struct
    module Types
      include Dry.Types
    end
    # HanamiSample — 演示 Hanami 2.0+ 架构
    # Hanami 2.0+ 是模块化框架，组件可独立使用
    class HanamiSample
      def self.run
        puts "=== Hanami — 干净架构的现代 Ruby 框架 ==="
        puts

        puts "1. Hanami 2.0+ 架构特点"
        puts "  - 模块化: 每个组件可独立使用（Entity、Repository、Action）"
        puts "  - 切片架构: 使用 Slice 组织代码（类似 Rails Engine）"
        puts "  - 依赖注入: 通过 Provider 系统管理依赖"
        puts "  - 零猴子补丁: 不修改核心类（与 Rails 不同）"
        puts

        puts "2. 实体定义（使用 dry-struct，Hanami 推荐）"
        task = Task.new(id: 1, title: "Design API", status: "in_progress", priority: "high")
        puts "  实体: #{task.title} [#{task.status}] priority=#{task.priority}"
        puts

        puts "3. 仓库模式（Repository 概念）"
        repo = TaskRepository.new
        repo.create(title: "Design API", status: "in_progress", priority: "high")
        repo.create(title: "Write Tests", status: "pending", priority: "medium")
        repo.create(title: "Deploy App", status: "done", priority: "low")

        all = repo.all
        puts "  所有任务:"
        all.each { |t| puts "    [##{t.id}] #{t.title.ljust(20)} status=#{t.status.ljust(12)} priority=#{t.priority}" }
        puts

        puts "4. 参数验证（dry-validation 集成）"
        valid_params = { title: "New Feature", status: "pending", priority: "high" }
        contract = Class.new(Dry::Validation::Contract) do
          params do
            required(:title).value(:string)
            required(:status).value(:string)
            required(:priority).value(:string)
          end
        end.new
        result = contract.call(valid_params)
        puts "  参数: #{valid_params}"
        puts "  验证结果: #{result.success? ? '✅ 通过' : '❌ 失败'}"
        puts

        puts "5. Hanami Slice 示例（应用组织）"
        puts "  # 创建切片（类似微服务模块）"
        puts "  class MyApp < Hanami::Slice"
        puts "    # 自动加载 lib/ 目录"
        puts "    # 配置 routes、providers、repositories"
        puts "  end"
        puts

        puts "--- Hanami 核心特性 ---"
        puts "  干净架构: Entity → Repository → Action → View"
        puts "  依赖注入: Provider 系统（类似 dry-system）"
        puts "  中间件: Rack 兼容的中间件栈"
        puts "  命令行: `hanami new`、`hanami generate` 等"
        puts "  dry-rb 集成: dry-validation、dry-types、dry-struct"
        puts ""
        puts "  ⚠️ 注意: 完整 Hanami 应用需要 `hanami new` 初始化"
        puts "  本示例展示核心概念，实际开发请使用完整应用结构"
      end
    end

    # Task — 使用 dry-struct 作为实体（Hanami 推荐方式）
    class Task < Dry::Struct
      attribute :id, Types::Integer.optional
      attribute :title, Types::Strict::String
      attribute :status, Types::Strict::String
      attribute :priority, Types::Strict::String
    end

    # TaskRepository — 模拟 Hanami Repository 模式
    # 真实 Hanami 应用: class TaskRepository < Hanami::Repository
    class TaskRepository
      def initialize
        @tasks = []
        @next_id = 1
      end

      def create(attrs)
        task = Task.new(attrs.merge(id: @next_id))
        @tasks << task
        @next_id += 1
        task
      end

      def all
        @tasks
      end

      def by_status(status)
        @tasks.select { |t| t.status == status }
      end

      def by_priority(priority)
        @tasks.select { |t| t.priority == priority }
      end
    end

    # 参数验证（使用 dry-validation）
    def self.validate_params(params)
      contract = Class.new(Dry::Validation::Contract) do
        params do
          required(:title).value(:string)
          required(:status).value(:string)
          required(:priority).value(:string)
        end
      end.new

      contract.call(params)
    end
  end
end

Hello::TopicRegistry.register("awesome", "hanami", "Hanami 现代框架", Hello::Awesome::HanamiSample)
