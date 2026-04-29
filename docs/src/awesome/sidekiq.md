# Sidekiq + Redis — 生产级后台任务处理

> 在 Ruby 生态中，Sidekiq 是后台任务处理的事实标准。从初创公司到 GitHub、Shopify、Airbnb，全球数万个生产环境依赖 Sidekiq 处理邮件、报表、数据同步等异步工作。

## 为什么需要后台任务？

在 Web 应用中，并非所有工作都应在请求-响应周期内完成。以下场景必须异步处理：

| 场景 | 为什么异步 | 延迟容忍 |
|------|-----------|---------|
| 发送注册邮件 | SMTP 慢（2-5s），用户体验差 | 秒级 |
| 生成月度报表 | 可能耗时数分钟 | 分钟级 |
| 调用第三方支付 API | 网络不确定性 | 秒级 |
| 数据处理/ETL | CPU 密集型，长时间运行 | 分钟/小时 |
| 图片/视频缩略图 | CPU 密集型 | 分钟级 |
| Webhook 回调 | 第三方服务可能宕机 | 分钟级 + 重试 |

不使用后台任务的应用，用户会在每次操作中等待这些缓慢的外部操作完成。使用后台任务后，请求立即返回，繁重工作在后台由独立的 Worker 进程处理。

## Sidekiq 架构

Sidekiq 采用 **Redis 作为消息中间件**、**多线程 Worker** 的消费模型：

```
┌─────────────┐         ┌─────────────┐
│  Web/Redis  │ ─push─► │  Redis List │
│  应用服务器  │         │  (Job Queue)│
└─────────────┘         └──────┬──────┘
                               │
                      ┌────────▼────────┐
                      │   Sidekiq       │
                      │   Worker        │
                      │  (多线程)        │
                      │  默认 25 线程    │
                      └─────────────────┘
```

**核心组件**：

- **Client（客户端）**：Web 应用将 Job 序列化后推入 Redis 队列
- **Redis Queue**：作为持久化消息队列，保证 Job 不丢失
- **Server（Worker）**：Sidekiq 进程从 Redis 拉取 Job，在独立线程中执行
- **Retry Set**：失败 Job 进入重试队列，按指数退避策略重新入队
- **Dead Set**：超过重试上限的 Job 进入"死亡"状态，需要人工介入

## 安装与配置

安装 Sidekiq gem：

```ruby
# Gemfile
gem "sidekiq", "~> 7.0"  # 需要 Redis 6+ 和 Ruby 2.7+
```

```bash
bundle add sidekiq
```

配置 Sidekiq 连接（在生产环境中通常使用环境变量的 Redis URL）：

```ruby
# config/sidekiq.rb
# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/0" },
    network_timeout: 5,
    pool_size: Sidekiq.default_configuration.concurrency + 2
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/0" }
  }
end
```

> 📌 **注意**：连接池大小应等于 Worker 并发数 + 缓冲。默认并发 25，连接池 25-27 是常见配置。

## 编写第一个 Worker

Sidekiq Worker 需要 `include Sidekiq::Job` 并实现 `perform` 方法：

```ruby
# frozen_string_literal: true

require "sidekiq"

module Hello
  module Awesome
    # 邮件发送 Worker
    class SendWelcomeEmailWorker
      include Sidekiq::Job

      sidekiq_options(
        queue: "default",
        retry: 3,
        backtrace: 5
      )

      # 这个方法是 Worker 的核心入口
      # 参数必须是 JSON 可序列化的类型
      def perform(user_id)
        user = User.find(user_id)
        # 发送邮件的逻辑
        Mailer.welcome(user.email).deliver_now
        Rails.logger.info "欢迎邮件已发送到 #{user.email}"
      end
    end
  end
end
```

**调用 Worker**：

```ruby
# 入队——立即返回，Job 被推入 Redis
Hello::Awesome::SendWelcomeEmailWorker.perform_async(current_user.id)

# 延迟执行——5 分钟后入队
Hello::Awesome::SendWelcomeEmailWorker.perform_in(5.minutes, current_user.id)

# 指定时间入队
Hello::Awesome::SendWelcomeEmailWorker.perform_at(Time.tomorrow.noon, current_user.id)
```

## 参数序列化规则

这是 Sidekiq 最容易踩坑的地方：**Worker 的参数必须是 JSON 可序列化的基本类型**。

```ruby
# ✅ 正确——只传 ID
class ProcessReportWorker
  include Sidekiq::Job

  def perform(report_id, user_id)
    report = Report.find(report_id)
    user = User.find(user_id)
    report.generate_for(user)
  end
end

ProcessReportWorker.perform_async(report.id, user.id)

# ❌ 错误——传递了 ActiveRecord 对象
# Sidekiq 尝试序列化 User 实例时会失败或产生过期数据
class BadWorker
  include Sidekiq::Job

  def perform(user, report)  # 两个 ActiveRecord 对象 ❌
    report.generate_for(user)
  end
end

BadWorker.perform_async(user, report)  # 危险！
```

**为什么不能传对象？**

1. Sidekiq 通过 JSON 序列化参数到 Redis，ActiveRecord 对象无法直接 JSON 序列化
2. 从入队到执行有时间差，对象状态可能已过期
3. Worker 运行在独立进程，无法共享 Active Record 实例的内存状态

**唯一可接受的参数类型**：`String`、`Integer`、`Float`、`Boolean`、`Array`（嵌套基本类型）、`Hash`（字符串或符号键）。

## 幂等性设计

Sidekiq 保证 **at-least-once（至少执行一次）** 投递语义。在网络异常、Worker 崩溃等情况下，同一个 Job 可能被重复执行。你的 Worker 必须设计为幂等的。

```ruby
# ❌ 非幂等——多次执行导致重复扣款
class ChargeCustomerWorker
  include Sidekiq::Job

  def perform(order_id)
    order = Order.find(order_id)
    # 如果这个 Job 被重新执行，会重复扣款！
    PaymentGateway.charge(order.amount, order.payment_token)
    order.update!(status: "paid")
  end
end

# ✅ 幂等——使用状态检查防止重复执行
class ChargeCustomerWorker
  include Sidekiq::Job

  def perform(order_id)
    order = Order.find(order_id)

    # 幂等守卫：已支付的订单直接返回
    return if order.paid?

    PaymentGateway.charge(order.amount, order.payment_token)

    # 乐观锁：确保只有第一个成功的请求更新状态
    order.update!(status: "paid")
  end
end
```

**幂等性模式**：

1. **状态检查**：执行前检查目标对象的业务状态
2. **幂等键**：在 Redis/Set 中维护已处理的 Job 指纹
3. **数据库约束**：利用唯一索引保证数据层面的一致性
4. **事务**：将业务操作放在数据库事务中，利用事务的原子性

```ruby
# 使用 Redis Set 的幂等键模式
class IdempotentImportWorker
  include Sidekiq::Job

  def perform(import_id)
    idempotency_key = "import:processed:#{import_id}"

    # Redis SET NX：只有第一次能成功设置
    added = RedisClient.set(idempotency_key, "1", nx: true, ex: 86_400)

    unless added
      Rails.logger.info "Job #{import_id} 已处理过，跳过"
      return
    end

    # 执行实际导入逻辑
    Import.find(import_id).process!
  end
end
```

## 重试策略

Sidekiq 默认对失败 Job 进行 **25 次重试**，采用指数退避算法，覆盖约 **21 天** 的周期。这意味着一个 Job 在最坏情况下会在第 21 天做最后一次尝试。

```ruby
class ImportCsvWorker
  include Sidekiq::Job

  # 自定义重试次数
  sidekiq_options retry: 5

  # 自定义重试间隔
  sidekiq_options retry_in: lambda { |count|
    # 前 3 次快速重试，之后指数退避
    count <= 3 ? (count * 0.5) : (count**4).to_i
  }

  def perform(csv_url)
    # 调用第三方 API 下载 CSV
    response = HTTParty.get(csv_url)
    raise "Download failed: #{response.code}" unless response.success?

    # 解析并导入数据
    CsvParser.import(response.body)
  rescue StandardError => e
    # 记录日志后 re-raise，让 Sidekiq 处理重试
    Rails.logger.error "CSV 导入失败: #{e.message}"
    raise
  end
end
```

**重试间隔计算公式**（Sidekiq 默认）：

```
retry_in = (attempt ** 4) + 15 秒随机抖动
```

前几次重试间隔大约为：5s、31s、96s、271s、670s ... 直到最后一次（第 25 次）约在 21 天后。

**不重试的错误**：某些错误不应该重试（如数据校验失败、权限不足）：

```ruby
class ValidateAndProcessWorker
  include Sidekiq::Job

  # 业务校验错误不应该重试
  sidekiq_options discard_on ArgumentError
  sidekiq_options discard_on ActiveModel::ValidationError

  # 网络/基础设施错误使用自定义重试
  sidekiq_options retry_in: ->(count) { count * 5 }

  def perform(payload)
    record = validate!(payload)   # 校验失败 → ArgumentError → 不重试
    process!(record)              # 内部错误 → 标准重试
  end
end
```

## 队列策略与优先级

Sidekiq 支持多队列，不同队列对应不同的业务优先级。Worker 处理队列的顺序决定了高优先级任务的响应速度。

```ruby
# 关键任务的 Worker
class PaymentNotificationWorker
  include Sidekiq::Job
  sidekiq_options queue: "critical"

  def perform(transaction_id)
    transaction = Transaction.find(transaction_id)
    Pusher.notify(:payments, :completed, { id: transaction.id })
  end
end

# 普通任务的 Worker
class SendDigestEmailWorker
  include Sidekiq::Job
  sidekiq_options queue: "default"

  def perform(user_id)
    user = User.find(user_id)
    Mailer.digest(user).deliver_now
  end
end

# 低优先级任务
class GenerateAnalyticsReportWorker
  include Sidekiq::Job
  sidekiq_options queue: "low"

  def perform(organization_id)
    org = Organization.find(organization_id)
    AnalyticsReport.generate_for(org)
  end
end
```

启动 Sidekiq 时指定队列优先级：

```bash
bundle exec sidekiq -q critical -q default -q low

# 队列权重：critical 每次拿 3 个 Job，default 拿 2 个，low 拿 1 个
bundle exec sidekiq -q critical,3 -q default,2 -q low
```

队列策略原则：
- **critical**：支付、登录通知、安全事件——直接影响用户操作
- **default**：邮件发送、数据处理——用户关心但不是阻塞性的
- **low**：统计报表、日志归档、缓存预热——可以晚处理

## 监控与 Sidekiq Web UI

Sidekiq 提供内置的 Web 界面，可以查看队列状态、重试队列、死亡队列和统计数据。

```ruby
# config/routes.rb（Rails 项目）
require "sidekiq/web"

Rails.application.routes.draw do
  authenticate :admin_user do
    mount Sidekiq::Web => "/sidekiq"
  end
end

# Sinatra 项目
require "sidekiq/web"

class App < Sinatra::Base
  use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USER"] && password == ENV["SIDEKIQ_PASSWORD"]
  end

  mount Sidekiq::Web => "/sidekiq"
end
```

> 🔒 **安全警告**：Sidekiq Web 界面包含 Job 管理功能（删除、重试 Job），必须添加认证保护，**绝不直接暴露到外网**。

Sidekiq Web UI 提供：

- **队列概览**：各队列当前积压的 Job 数量
- **重试页面**：查看和手动重试失败的 Job
- **Dead 页面**：超过重试上限的 Job，需要人工处理
- **Busy 页面**：当前正在执行的 Job
- **调度器页面**：待执行的 `perform_in` / `perform_at` Job
- **统计信息**：今日/总计的成功、失败 Job 数

**生产监控集成**：

```ruby
# 通过 sidekiq API 获取统计信息
stats = Sidekiq::Stats.new
puts "排队中: #{stats.enqueued}"
puts "重试中: #{stats.retries}"
puts "已死亡: #{stats.dead}"
puts "今天成功: #{stats.processed_successes}"
puts "今天失败: #{stats.failed}"

# Workers 进程健康检查
Sidekiq.redis do |conn|
  workers = conn.smembers("processes")
  workers.each do |worker_key|
    info = conn.hgetall(worker_key)
    puts "Worker: #{info['busy']} busy threads, #{info['quiet'] || 'active'}"
  end
end
```

与外部监控系统集成（Prometheus、Datadog、New Relic 等）：

```ruby
# config/initializers/sidekiq_metrics.rb
require "prometheus/client"

Sidekiq.configure_server do |config|
  registry = Prometheus::Client.registry

  config.server_middleware do |chain|
    chain.add ::Sidekiq::PrometheusMiddleware
  end
end

class Sidekiq::PrometheusMiddleware
  def call(worker_class, job, queue, redis_pool)
    yield
  rescue StandardError => e
    # 推送失败指标到 Prometheus
    registry.counter(:sidekiq_job_failures).increment(labels: { job: worker_class.name })
    raise
  end
end
```

## 生产环境最佳实践

### 1. 保持 Job 小而快

```ruby
# ❌ 不好——一个 Job 做所有事，耗时长
class ProcessOrderWorker
  include Sidekiq::Job

  def perform(order_id)
    order = Order.find(order_id)

    # 1. 计算价格（可能调用数据库）
    order.calculate_totals

    # 2. 扣减库存（可能需要外部 API）
    InventoryService.decrement(order.items)

    # 3. 发送邮件（SMTP 很慢）
    Mailer.order_confirm(order).deliver_now

    # 4. 生成 PDF（CPU 密集型）
    PdfGenerator.create(order)

    # 5. 更新分析数据
    Analytics.track_order(order)

    # 6. 发送 Webhook（网络调用）
    WebhookDelivery.send(order.webhook_url, order.to_json)

    order.update!(status: "processed")
  end
end

# ✅ 好——拆分多个小 Job
class ProcessOrderWorker
  include Sidekiq::Job
  sidekiq_options queue: "critical"

  def perform(order_id)
    order = Order.find(order_id)
    order.calculate_totals
    InventoryService.decrement(order.items)
    order.update!(status: "processed")

    # 触发后续异步任务
    SendOrderConfirmationWorker.perform_async(order_id)
    GenerateOrderPdfWorker.perform_async(order_id)
    TrackOrderAnalyticsWorker.perform_async(order_id)
  end
end

class SendOrderConfirmationWorker
  include Sidekiq::Job
  sidekiq_options queue: "default"

  def perform(order_id)
    order = Order.find(order_id)
    Mailer.order_confirm(order).deliver_now
  end
end
```

**经验法则**：单个 Job 的执行时间应控制在 **10 秒以内**。超出时考虑拆分、检查点（checkpointing）或使用专用任务调度。

### 2. 长时间任务的检查点模式

```ruby
class ProcessBatchReportWorker
  include Sidekiq::Job
  sidekiq_options retry: 5

  def perform(report_id, checkpoint = nil)
    report = Report.find(report_id)

    # 从上次的检查点继续处理
    items = report.items
    items = items.where("id > ?", checkpoint) if checkpoint

    # 每次处理 100 条
    batch = items.limit(100)
    batch.each(&:process)

    # 还有剩余？重新入队并记录检查点
    if batch.count == 100
      last_processed = batch.maximum("id")
      ProcessBatchReportWorker.perform_async(report_id, last_processed)
    else
      report.update!(status: "completed")
    end
  end
end
```

检查点模式的优势：
- 每个 Job 实例快速完成（处理 100 条，约 2-3 秒）
- Worker 崩溃后，仅丢失当前批次的进度
- 天然并行化——检查点可以分配到不同的 Worker

### 3. 连接池配置

Worker 进程内多个线程共享数据库连接池和 Redis 连接池：

```ruby
# 数据库连接池（database.yml）
production:
  adapter: postgresql
  pool: 30  # >= Sidekiq concurrency (25) + 缓冲

# Redis 连接池已在 sidekiq.rb 中配置
Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV["REDIS_URL"],
    pool_size: 30  # concurrency + 5
  }
end
```

**公式**：`连接池 = Sidekiq 并发数 + 缓冲（2-5）`。如果 Sidekiq 并发 25，Redis 连接池至少 27，数据库连接池也类似。

### 4. 硬超时与优雅关闭

Sidekiq 在收到 `TERM` 信号后，默认 **25 秒**（`timeout` 参数）等待正在执行的 Job 完成后再退出。这是优雅关闭（graceful shutdown）。

```bash
# Docker / systemd 部署时，确保使用 SIGTERM 而非 SIGKILL
# Sidekiq 收到 SIGTERM → 停止拉取新 Job → 等待当前 Job 完成 → 退出

# 自定义超时时间（默认 25s）
bundle exec sidekiq --timeout 30

# 在 Procfile/Dockerfile 中确保信号正确传递
exec bundle exec sidekiq -q critical,3 -q default -q low
```

如果 Worker 中的 Job 可能超过 25 秒，需要：
1. 增加 `--timeout` 值
2. 在 Worker 内部处理信号：

```ruby
class LongRunningWorker
  include Sidekiq::Job

  def perform(data_ids)
    @shutting_down = false
    trap(:TERM) { @shutting_down = true }

    data_ids.each do |id|
      break if @shutting_down  # 优雅退出当前 Job

      process_item(id)
    end
  end
end
```

### 5. Redis 持久化

Sidekiq 的可靠性依赖于 Redis 的持久化策略：

```bash
# Redis 配置（redis.conf）

# 推荐使用 AOF 模式
appendonly yes
appendfsync everysec  # 每秒刷盘，最多丢 1 秒数据

# 如果使用 RDB，确保足够频繁的快照
save 60 1000  # 60 秒内 1000 个 key 变化时保存
```

`appendfsync everysec` 是生产环境的推荐配置，在性能和数据安全性之间取得平衡。如果使用 `appendfsync always`，每次写入都刷盘，会显著降低 Redis 性能。

### 6. 日志规范

```ruby
class ProcessPaymentWorker
  include Sidekiq::Job

  def perform(payment_id)
    payment = Payment.find(payment_id)
    logger = Rails.logger.tagged("PaymentWorker", payment_id: payment_id)
    logger.info "开始处理支付"

    gateway = PaymentGateway.new(payment)
    result = gateway.charge

    if result.success?
      payment.update!(status: "charged")
      logger.info "支付成功, transaction_id: #{result.transaction_id}"
    else
      logger.error "支付失败: #{result.error}"
      raise StandardError, result.error
    end
  end
end
```

## 与 hello-ruby 项目集成

在 hello-ruby 的 Awesome 层级中，Sidekiq Worker 放在 `lib/hello/awesome/` 目录下：

```ruby
# lib/hello/awesome/send_welcome_email_worker.rb
# frozen_string_literal: true

module Hello
  module Awesome
    # 示例：欢迎邮件 Worker
    class SendWelcomeEmailWorker
      include Sidekiq::Job

      sidekiq_options(
        queue: "default",
        retry: 3,
        backtrace: true
      )

      def perform(user_name, user_email)
        # 实际项目中通过 DI 容器注入邮件服务
        mailer = Hello::System::Container["mailer_service"]
        mailer.send_welcome(user_name, user_email)
      end
    end
  end
end
```

```ruby
# lib/hello/awesome/import_data_worker.rb
# frozen_string_literal: true

module Hello
  module Awesome
    # 示例：数据导入 Worker（带检查点）
    class ImportDataWorker
      include Sidekiq::Job

      sidekiq_options(
        queue: "low",
        retry: 5,
        retry_in: ->(count) { count * 10 }
      )

      def perform(source_id, last_id = nil)
        source = DataSource.find(source_id)
      items = source.items.where("id > ?", last_id).limit(500)

      items.each do |item|
        item.transform_and_save!
      end

      if items.count == 500
        last_processed = items.maximum("id")
        ImportDataWorker.perform_async(source_id, last_processed)
      else
        source.update!(status: "imported")
      end
    end
  end
end
```

启动 Sidekiq Worker：

```bash
# 开发环境
bundle exec sidekiq -C config/sidekiq.yml

# sidekiq.yml 配置文件
---
:concurrency: 5
:queues:
  - [critical, 3]
  - [default, 2]
  - [low, 1]
```

## Sidekiq vs 替代方案

| 特性 | Sidekiq | Resque | Delayed Job | GoodJob |
|------|---------|--------|-------------|---------|
| 后端 | Redis | Redis | 数据库（PostgreSQL/MySQL） | PostgreSQL |
| 并发模型 | 多线程（单个进程内） | 多进程 | 多进程 | 多线程 |
| 内存占用 | 低（共享地址空间） | 高（每个 Worker 独立进程） | 中 | 低 |
| 吞吐量 | 高 | 中 | 低 | 中高 |
| 调度（定时任务） | 需要 sidekiq-cron gem | 需要 resque-scheduler | 不需要额外 gem | 内置（cron） |
| 重试策略 | 内置指数退避 | 需要额外配置 | 内置 | 内置 |
| Web 界面 | 官方内置 | 官方内置 | 无 | 需要额外 gem |
| 适用场景 | 高吞吐、Redis 环境 | 需要进程隔离的场景 | 不想引入 Redis | PostgreSQL 环境 |
| 维护者 | 独立开源 | GitHub | 独立开源 | 独立开源 |

**选型建议**：

- 已有 Redis？→ **Sidekiq**（Ruby 社区事实标准）
- 不想引入 Redis？→ **GoodJob**（PostgreSQL 原生）或 **Delayed Job**（任意数据库）
- 需要进程级隔离？→ **Resque**（每个 Worker 独立进程，一个 Worker 崩溃不影响其他）
- 需要更高级特性（调度、去重）？Sidekiq Pro（付费）或 **Sidekiq** + 扩展 gem

## 完整示例：邮件发送流水线

这是一个生产环境可用的邮件发送 Worker，集成了幂等性、重试、限流等模式：

```ruby
# frozen_string_literal: true

require "sidekiq"

module Hello
  module Awesome
    # 生产级邮件发送 Worker
    #
    # 特性：
    # - 幂等性（同一邮件不会重复发送）
    # - 指数退避重试
    # - SMTP 限流（防止触发第三方限制）
    # - 详细日志
    class MailingListWorker
      include Sidekiq::Job

      # 关键队列，高优先级
      sidekiq_options(
        queue: "critical",
        retry: 5,
        # 自定义重试间隔：10s, 30s, 90s, 270s, 810s (约 13.5 分钟)
        retry_in: ->(count) { 10 * (3**(count - 1)) },
        # SMTP 相关错误特殊处理
        dead: true  # 超过重试上限后进入 Dead Set
      )

      # 不对这几种错误进行重试（邮件地址或模板有问题，重试也不会成功）
      sidekiq_options discard_on Net::SMTPSyntaxError
      sidekiq_options discard_on InvalidEmailAddressError
      sidekiq_options discard_on TemplateNotFoundError

      def perform(email_id, template_id, user_id)
        # 幂等守卫：检查邮件是否已发送
        idempotency_key = "email:#{email_id}:#{user_id}"
        already_sent = RedisClient.set(idempotency_key, "1", nx: true, ex: 86_400)
        return unless already_sent

        email = Email.find(email_id)
        template = EmailTemplate.find(template_id)
        user = User.find(user_id)

        Rails.logger.info "发送邮件: user=#{user.id}, email=#{user.email}, template=#{template_id}"

        # 限流：每次发送前等待（防止触发 SMTP 速率限制）
        sleep_rate_limit

        # 渲染模板
        body = template.render(user: user)

        # 发送（Net::SMTP 错误会被 discard_on 拦截，不进入重试）
        Net::SMTP.start(ENV["SMTP_HOST"], ENV["SMTP_PORT"]) do |smtp|
          smtp.send_message(
            "From: #{email.from}\r\n" \
            "To: #{user.email}\r\n" \
            "Subject: #{email.subject}\r\n" \
            "Content-Type: text/html; charset=UTF-8\r\n\r\n" \
            "#{body}",
            email.from,
            user.email
          )
        end

        # 记录发送成功
        EmailLog.create!(
          email_id: email_id,
          user_id: user_id,
          status: "sent",
          sent_at: Time.current
        )

        Rails.logger.info "邮件发送成功: user=#{user.id}"

      rescue StandardError => e
        # 非 SMTP 语法错误（如网络超时）进入重试
        Rails.logger.error "邮件发送失败: user=#{user_id}, error=#{e.message}"
        raise  # 让 Sidekiq 处理重试
      end

      private

      def sleep_rate_limit
        # 根据环境配置发送频率
        rate = ENV.fetch("SMTP_RATE_LIMIT", 5).to_i
        sleep(1.0 / rate) if rate > 0
      end
    end
  end
end
```

## 本章要点

- Sidekiq 是 Ruby 后台任务处理的事实标准，使用 Redis 作为消息队列
- Worker 必须 `include Sidekiq::Job` 并实现 `perform` 方法
- **参数必须是 JSON 可序列化类型**（基本类型），不要传 ActiveRecord 对象
- Sidekiq 保证 **至少执行一次**（at-least-once），Worker 必须设计为幂等
- 默认重试 25 次、覆盖约 21 天，可通过 `sidekiq_options` 自定义
- 使用 `discard_on` 声明不重试的错误类型
- 多队列优先级策略（critical / default / low）保证关键任务优先执行
- 生产环境最佳实践：Job 小而快（< 10s）、长任务使用检查点、连接池合理配置、优雅关闭
- Sidekiq Web UI 提供队列监控、重试管理、死亡队列查看（**务必添加认证保护**）
- Redis 持久化推荐 AOF + `appendfsync everysec`（性能与安全性平衡）
- 已有 Redis 环境 → 首选 Sidekiq；PostgreSQL 原生需求 → GoodJob；不想引入 Redis → GoodJob / Delayed Job

## 继续学习

- Sidekiq 官方文档: [github.com/sidekiq/sidekiq](https://github.com/sidekiq/sidekiq)
- Sidekiq Wiki 最佳实践: [wiki · sidekiq/sidekiq](https://github.com/sidekiq/sidekiq/wiki)
- Sidekiq 超时与并发: [Sidekiq Concurrency Guide](https://github.com/sidekiq/sidekiq/wiki/Concurrency)
- Sidekiq Cron 定时任务: [sidekiq-cron](https://github.com/sidekiq-cron/sidekiq-cron)
- 消息队列对比: [Resque](https://github.com/resque/resque) / [GoodJob](https://github.com/bensalli/GoodJob) / [Delayed Job](https://github.com/collectiveidea/delayed_job)

> 💡 **提示**：Sidekiq 的核心理念是"可靠地做事"。通过 Redis 持久化、幂等 Worker 设计、合理的重试策略，你可以构建出即使在服务中断情况下也能恢复的异步任务系统。记住：Job 失败不是异常，是系统运行的一部分——让你的 Worker 能够从失败中恢复，而不是崩溃。
