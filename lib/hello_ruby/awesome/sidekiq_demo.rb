# typed: true
# frozen_string_literal: true

module Hello
  module Awesome
    # Sidekiq 异步任务模式 — Redis 驱动的背景任务队列
    # 演示 worker 定义、retry 策略、唯一性（idempotency）、队列策略
    module SidekiqDemo
      def self.run
        puts "=== Sidekiq Worker Pattern ==="
        puts

        # --- 1. 基本 Worker ---
        puts "--- Worker 基本结构 ---"
        example_code = <<~RUBY
          require "sidekiq"
          require "sidekiq/job"

          # Sidekiq Worker 只需要 include Sidekiq::Job
          class SendWelcomeEmailWorker
            include Sidekiq::Job

            # Sidekiq 配置选项
            sidekiq_options(
              queue: "mailers",          # 队列名称
              retry: 3,                  # 失败重试次数
              backtrace: 10,             # 保留错误堆栈行数
              lock: Sidekiq::Lock::UntilExecuted  # 分布式锁
            )

            # perform 方法：参数必须是 JSON 可序列化的类型
            # ✅ 字符串、整数、哈希、数组
            # ❌ User Active Record 对象（传递 ID）
            def perform(user_id)
              user = User.find(user_id)  # 在 worker 中查数据库
              Mailer.welcome(user).deliver_later
            end
          end

          # 入队调用
          SendWelcomeEmailWorker.perform_async(user.id)
          # 或传入未来时间（延迟执行）
          SendWelcomeEmailWorker.perform_in(5.minutes, user.id)
          SendWelcomeEmailWorker.perform_at(2.hours.from_now, user.id)
        RUBY
        puts "  #{example_code.strip}"
        puts "  → include Sidekiq::Job，perform 是唯一实例方法"
        puts "  → 参数必须 JSON 可序列化！传递 ID 而非对象"
        puts

        # --- 2. Retry 重试策略 ---
        puts "--- Retry 重试策略 ---"
        example_code2 = <<~RUBY
          class ProcessPaymentWorker
            include Sidekiq::Job

            # retry: true  → 默认 25 次重试（指数退避）
            # retry: false → 不重试，立即丢弃
            # retry: 3     → 最多重试 3 次
            sidekiq_options retry: 5

            # 自定义重试延迟（指数退避公式）
            # 第 N 次重试：min(30 * N^4, 86400) 秒后执行
            # 1min, ~4min, ~17min, ~51min, ~2h, ... 最长 24h

            def perform(payment_id)
              payment = Payment.find(payment_id)
              payment.process!
              # ↑ 如果 raise 异常 → 自动重新入队（Retry Queue）
            end
          end

          # 手动触发重试
          class RetryPaymentWorker
            include Sidekiq::Job

            def perform(payment_id, max_retries: 3)
              payment = Payment.find(payment_id)
              begin
                payment.charge!
              rescue GatewayTimeoutError
                raise unless Sidekiq::Worker.jobs["attempts"].to_i < max_retries
              end
            end
          end
        RUBY
        puts "  #{example_code2.strip}"
        puts "  → Retry Queue 自动管理重试，指数退避防止雪崩"
        puts

        # --- 3. 幂等性（Idempotency） ---
        puts "--- 幂等性：防止重复执行 ---"
        example_code3 = <<~RUBY
          # 幂等 key 模式：用 Redis 记录已处理的消息
          class ProcessOrderWorker
            include Sidekiq::Job

            sidekiq_options queue: "orders", retry: 3

            def perform(order_id, idempotency_key)
              # 幂等性检查：同一 key 只执行一次
              lock_key = "order_processed:#{order_id}:#{idempotency_key}"
              already_done = redis { |c| c.set(lock_key, "1", nx: true, ex: 86400) }

              return if already_done.nil?  # 已处理，跳过

              order = Order.find(order_id)
              # 使用 optimistic locking 防止并发
              Order.transaction do
                order.reload.lock!
                order.process!
                order.save!
              end
            end
          end

          # 调用方式：每次请求附带唯一 key
          idempotency_key = SecureRandom.uuid
          ProcessOrderWorker.perform_async(order.id, idempotency_key)

          # 或在 HTTP 客户端中实现：
          # headers["Idempotency-Key"] = SecureRandom.uuid
        RUBY
        puts "  #{example_code3.strip}"
        puts "  → 幂等 key + Redis NX 保证同一操作只执行一次"
        puts "  → 即使 Sidekiq 重试，也不会造成双重处理"
        puts

        # --- 4. 队列策略 ---
        puts "--- 队列策略：多队列与优先级 ---"
        example_code4 = <<~RUBY
          # 队列优先级（启动时通过命令行指定）
          # sidekiq -q critical -q default -q low
          #
          # critical：支付、认证等实时任务
          # default：通知、邮件、日志
          # low：报表生成、数据清理

          class ProcessPaymentWorker
            include Sidekiq::Job
            sidekiq_options queue: "critical"  # 最高优先级
          end

          class SendNotificationWorker
            include Sidekiq::Job
            sidekiq_options queue: "default"
          end

          class GenerateReportWorker
            include Sidekiq::Job
            sidekiq_options queue: "low"
          end

          # 动态队列
          class ImportDataWorker
            include Sidekiq::Job

            def perform(file_path, dynamic_queue)
              # 根据文件大小选择队列
              queue = File.size(file_path) > 10_000_000 ? "bulk" : "default"
              # ...
            end
          end
        RUBY
        puts "  #{example_code4.strip}"
        puts "  → 多队列保证关键任务优先执行"
        puts

        # --- 5. Middleware 中间件 ---
        puts "--- Middleware 中间件模式 ---"
        example_code5 = <<~RUBY
          # 自定义 Sidekiq 中间件
          class LoggingMiddleware
            include Sidekiq::ServerMiddleware

            def call(worker_class, job, queue)
              logger = job["logger"]&.constantize || Logger.new(STDOUT)
              logger.info("Starting job: #{worker_class} | Queue: #{queue}")
              start = Time.now

              yield  # 执行 perform

              duration = Time.now - start
              logger.info("Completed job: #{worker_class} in #{duration.round(3)}s")
            end
          end

          # 注册中间件
          Sidekiq.configure_server do |config|
            config.server_middleware do |chain|
              chain.add LoggingMiddleware
            end
          end
        RUBY
        puts "  #{example_code5.strip}"
        puts "  → middleware 链包围 perform 执行，实现日志、监控、追踪"
        puts

        # --- 6. 模拟输出 ---
        puts "--- 模拟 Sidekiq 执行流程 ---"
        puts "  1. perform_async(order_id, idem_key)"
        puts "     → Redis LPUSH queues:orders {\"class\":\"ProcessOrder\",\"args\":[42,\"abc\"]}"
        puts "  2. Sidekiq poll → Redis RPOP"
        puts "     → 取出 job → 反序列化 → 调用 worker.perform(42, \"abc\")"
        puts "  3. perform 成功 → Redis DEL worker:busy → 完成"
        puts "  4. perform raise → retry_count++ → Redis ZADD retries → 延迟重试"
        puts
        puts "  Sidekiq 特点:"
        puts "  - 基于 Redis 的轻量级任务队列（无 Rails 依赖）"
        puts "  - 多线程并发执行（每个 worker 一个线程）"
        puts "  - UI Dashboard：查看队列状态、重试、Dead jobs"
        puts "  - 幂等性：由开发者实现（Redis 锁 + 唯一 key）"
        puts "  - 可观测：middleware 实现追踪、日志、监控集成"
      end
    end
  end
end

Hello::TopicRegistry.register("awesome", "sidekiq_demo", "Sidekiq 异步任务与幂等性", Hello::Awesome::SidekiqDemo)
