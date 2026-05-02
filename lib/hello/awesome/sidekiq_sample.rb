# typed: true
# frozen_string_literal: true

require "sidekiq"
require "redis"
require "json"
require_relative "../topic_registry"

module Hello
  module Awesome
    # EmailWorker — 真实 Sidekiq Worker 示例
    # 继承 Sidekiq::Worker，使用 Redis 作为任务队列
    class EmailWorker
      include Sidekiq::Worker

      sidekiq_options queue: "critical", retry: 5

      def perform(user_id, template)
        # 真实 Sidekiq worker 执行逻辑
        # 生产环境中会发送邮件
        "Email sent to user #{user_id} with template: #{template}"
      end
    end

    # ReportWorker — 另一个 Worker 示例（低优先级）
    class ReportWorker
      include Sidekiq::Worker

      sidekiq_options queue: "low", retry: 3

      def perform(report_type)
        "Report #{report_type} generated"
      end
    end

    # SidekiqSample — 演示 Sidekiq 真实用法
    class SidekiqSample
      def self.run
        puts "=== Sidekiq + Redis — 生产级后台任务处理 ==="
        puts

        puts "1. Worker 定义（继承 Sidekiq::Worker）"
        puts "  EmailWorker: queue=critical, retry=5"
        puts "  ReportWorker: queue=low, retry=3"
        puts

        puts "2. 入队任务（perform_async）"
        demonstrate_enqueue
        puts

        puts "3. 队列状态检查"
        demonstrate_queue_status
        puts

        puts "4. Sidekiq 架构"
        puts "  - Redis: 任务持久化 + 队列管理"
        puts "  - Worker 进程: 从 Redis 拉取并执行任务"
        puts "  - 重试机制: 指数退避（默认 25 次，跨越约 21 天）"
        puts "  - Web UI: sidekiq gem 自带监控界面"
        puts

        puts "5. 队列策略"
        puts "  critical → 用户可见任务（邮件、支付、Webhook）"
        puts "  default  → 正常任务（通知、同步）"
        puts "  low      → 重型非紧急任务（报表、ETL）"
        puts

        puts "--- Sidekiq 核心特性 ---"
        puts "  Redis 持久化: 服务器重启不丢失任务"
        puts "  优雅关闭: 完成当前任务后退出（SIGTSTP）"
        puts "  中间件: 可扩展的 middleware 链"
        puts "  并发控制: 每个进程可配置并发数"
        puts "  Web UI: 内置监控界面（sidekiq/web）"
      end

      # 演示任务入队（处理 Redis 连接异常）
      def self.demonstrate_enqueue
        workers = [
          { worker: EmailWorker, args: [123, "welcome"], desc: "欢迎邮件" },
          { worker: EmailWorker, args: [456, "reset_password"], desc: "密码重置" },
          { worker: ReportWorker, args: ["user_activity"], desc: "用户活跃度报表" }
        ]

        workers.each do |w|
          begin
            job_id = w[:worker].perform_async(*w[:args])
            puts "  ✅ #{w[:desc]}: JID=#{job_id || 'N/A (Redis not connected)'}"
          rescue RedisClient::CannotConnectError => e
            puts "  ⚠️  #{w[:desc]}: Redis 未连接（演示 API 调用）"
            puts "    #{w[:worker]}.perform_async(#{w[:args].join(', ')})"
          end
        end
      end

      # 演示队列状态检查
      def self.demonstrate_queue_status
        puts "  队列状态检查（需要 Redis 连接）:"
        puts "  Sidekiq.redis { |c| c.llen('queue:critical') } # critical 队列长度"
        puts "  Sidekiq.redis { |c| c.llen('queue:default') } # default 队列长度"
        puts
        puts "  ⚠️  Redis 未连接，跳过实际查询"
      end
  end
end

Hello::TopicRegistry.register("awesome", "sidekiq", "Sidekiq 后台任务", Hello::Awesome::SidekiqSample)
end
