# typed: true
# frozen_string_literal: true

require "json"

module Hello
  module Awesome
    class SidekiqDemo
      def self.run
        puts "=== Sidekiq + Redis — 生产级后台任务处理 ==="
        puts

        puts "1. Worker 定义"
        worker = EmailWorker.new
        puts "  类: EmailWorker"
        puts "  队列: #{worker.queue}"
        puts "  最大重试次数: #{worker.max_retries}"
        puts

        puts "2. 入队任务 (perform_async)"
        job_id = worker.enqueue(user_id: 123, template: "welcome")
        puts "  入队: JID=#{job_id}"
        puts

        puts "3. 执行任务 — 成功"
        result = worker.perform(user_id: 42, template: "welcome")
        puts "  结果: #{result}"
        puts

        puts "4. 执行任务 — 幂等性 (重复执行)"
        result2 = worker.perform(user_id: 42, template: "welcome")
        puts "  结果: #{result2}"
        puts

        puts "5. 执行任务 — 失败并重试"
        result3 = worker.perform(user_id: 999, template: "reset_password")
        puts "  结果: #{result3}"
        puts

        puts "6. 队列策略"
        puts "  critical → 用户可见任务 (邮件、支付、Webhook)"
        puts "  default  → 正常任务 (通知、同步)"
        puts "  low      → 重型非紧急任务 (报表、ETL)"
        puts

        puts "7. 重试配置"
        puts "  默认: 25 次重试，跨越约 21 天 (指数退避)"
        puts "  自定义:"
        puts "    retry_in ->(executions) { [30, 60, 120, 300, 600][executions - 1] || 10000 }"
        puts

        puts "8. at-least-once 语义"
        puts "  Sidekiq 保证任务至少执行一次，非 exactly-once"
        puts "  → 必须设计为幂等 (idempotent)"
        puts "  → guard 模式: return if already_processed?"
      end
    end

    class EmailWorker
      attr_reader :queue, :max_retries

      def initialize
        @queue = "critical"
        @max_retries = 3
        @sent_emails = {}
        @job_counter = 0
      end

      def enqueue(params)
        @job_counter += 1
        jid = "sidekiq-#{@job_counter}"
        puts "  [Redis] 写入队列: #{jid} → #{params}"
        jid
      end

      def perform(params)
        user_id = params[:user_id]
        template = params[:template]

        # 幂等性检查 — guard 模式防止重复处理
        key = "#{user_id}:#{template}"
        if @sent_emails[key]
          return "Skipped: #{template} email already sent to user #{user_id} (idempotency guard)"
        end

        # 模拟数据库查找
        user = find_user(user_id)
        return "Failed: User #{user_id} not found — will retry" if user.nil?

        # 发送件
        @sent_emails[key] = true
        "Sent #{template} email to #{user[:name]} (user_id=#{user_id})"
      end

      private

      def find_user(user_id)
        # 模拟数据库查询
        users = {
          42 => { name: "Alice", email: "alice@example.com" },
          123 => { name: "Bob", email: "bob@example.com" }
        }
        users[user_id]
      end
    end
  end
end

Hello::TopicRegistry.register("awesome", "sidekiq", "Sidekiq 后台任务", Hello::Awesome::SidekiqDemo)
