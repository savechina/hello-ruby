# typed: true
# frozen_string_literal: true

require "json"

module Hello
  module Awesome
    class HanamiDemo
      def self.run
        puts "=== Hanami — 干净架构的现代 Ruby 框架 ==="
        puts

        repo = TaskRepository.new

        puts "1. 创建实体 (Entity)"
        task = Task.new(title: "Design API", status: "in_progress", priority: "high")
        puts "  实体: #{task.title} [#{task.status}] priority=#{task.priority}"
        puts "  pending? → #{task.pending?}"
        puts "  important? → #{task.important?}"
        puts

        puts "2. 保存到 Repository (Data Mapper 模式)"
        saved = repo.create(task)
        puts "  返回: id=#{saved.id}, title=#{saved.title}"
        puts

        repo.create(Task.new(title: "Write Tests", status: "pending", priority: "medium"))
        repo.create(Task.new(title: "Deploy App", status: "done", priority: "low"))
        repo.create(Task.new(title: "Review PR", status: "in_progress", priority: "high"))

        puts "3. 列出所有任务 (按优先级排序)"
        all = repo.list
        all.each { |t| puts "  [##{t.id}] #{t.title.ljust(20)} status=#{t.status.ljust(12)} priority=#{t.priority}" }
        puts

        puts "4. 过滤：查找高优先级任务"
        urgent = repo.find_by_priority("high")
        urgent.each { |t| puts "  #{t.title} (#{t.status})" }
        puts

        puts "5. 更新实体"
        updated = repo.update(all[0].id, status: "done")
        puts "  #{updated.title} → status=done"
        puts

        puts "6. 参数验证 (dry-validation 风格)"
        valid_params = { title: "New Feature", status: "pending", priority: "high" }
        result = validate_params(valid_params)
        puts "  有效参数: #{result[:valid]} → #{result[:errors]}"

        invalid_params = { title: "", status: "unknown" }
        result2 = validate_params(invalid_params)
        puts "  无效参数: #{result2[:valid]} → #{result2[:errors]}"
        puts

        puts "7. View 层 — 数据格式化"
        view = TaskIndexView.new(repo)
        puts "  JSON: #{view.render_json}"
        puts "  摘要: #{view.render_summary}"
        puts

        puts "--- 架构对比 ---"
        puts "  维度       | Rails MVC        | Hanami 干净架构"
        puts "  控制器     | Fat Controllers  | Thin Actions"
        puts "  模型       | Active Record    | Data Mapper (Repository)"
        puts "  数据传输   | AR objects        | Entity (纯 Ruby)"
        puts "  验证       | Model callbacks   | dry-validation"
        puts "  依赖注入   | 全局常量          | dry-system 容器"
      end

      def self.validate_params(params)
        errors = []
        errors << "title 不能为空" if params[:title].to_s.strip.empty?
        errors << "status 必须是 pending/in_progress/done" unless %w[pending in_progress done].include?(params[:status])

        { valid: errors.empty?, errors: errors }
      end
    end

    class Task
      attr_reader :id, :title, :status, :priority, :created_at

      def initialize(title:, status: "pending", priority: "low", id: nil, created_at: nil)
        @id = id
        @title = title
        @status = status
        @priority = priority
        @created_at = created_at || Time.now
      end

      def pending?
        @status == "pending"
      end

      def important?
        @priority == "high"
      end
    end

    class TaskRepository
      def initialize
        @tasks = []
        @next_id = 1
      end

      def list
        @tasks.dup
      end

      def create(task)
        new_task = Task.new(
          title: task.title,
          status: task.status,
          priority: task.priority,
          id: @next_id,
          created_at: task.created_at
        )
        @next_id += 1
        @tasks << new_task
        new_task
      end

      def update(id, params)
        task = @tasks.find { |t| t.id == id }
        return nil unless task
        new_task = Task.new(
          title: params[:title] || task.title,
          status: params[:status] || task.status,
          priority: params[:priority] || task.priority,
          id: task.id,
          created_at: task.created_at
        )
        @tasks[@tasks.index(task)] = new_task
        new_task
      end

      def find_by_priority(priority)
        @tasks.select { |t| t.priority == priority }
      end

      def find(id)
        @tasks.find { |t| t.id == id }
      end
    end

    class TaskIndexView
      def initialize(repo)
        @repo = repo
      end

      def render_json
        @repo.list.map { |t| { title: t.title, status: t.status, priority: t.priority } }.to_json
      end

      def render_summary
        tasks = @repo.list
        "#{tasks.length} 个任务: #{tasks.count { |t| t.status == 'done' }} 完成, #{tasks.count { |t| t.status == 'pending' }} 待处理"
      end
    end
  end
end

Hello::TopicRegistry.register("awesome", "hanami", "Hanami 干净架构", Hello::Awesome::HanamiDemo)
