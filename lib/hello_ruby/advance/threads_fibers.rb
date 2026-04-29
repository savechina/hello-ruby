# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # 线程与协程 — GVL、Thread、Fiber、Ractor、Queue、Mutex
    #
    # Ruby 的并发原语各有适用场景：
    # - GVL（全局虚拟机锁）：限制 CPU 密集型线程并行，I/O 密集型可并行
    # - Thread：操作系统线程，适合 I/O 密集型任务
    # - Fiber：轻量级协程，用户态协作式调度
    # - Ractor（Ruby 3.0+）：真正的并行执行，无共享内存模型
    module ThreadsFibers
      def self.run
        puts "=== 线程与协程 ==="
        puts

        # --- 1. GVL（全局虚拟机锁）概述 ---
        puts "--- GVL（Global VM Lock / 全局虚拟机锁）---"
        puts "  Ruby 的 GVL 保证同一时刻只有一个线程执行 Ruby 字节码"
        puts "  - CPU 密集型任务：多线程 NOT 并行（受 GVL 限制）"
        puts "  - I/O 密集型任务：多线程 可以并行（I/O 操作会释放 GVL）"
        puts
        puts "  验证 GVL 行为："
        # CPU 密集型 — 多线程不会更快（GVL 限制）
        cpu_times = {}
        [:single, :multi].each do |mode|
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          if mode == :single
            fib(35)
          else
            threads = 2.times.map do
              Thread.new { fib(35) }
            end
            threads.each(&:join)
          end
          cpu_times[mode] = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
          puts "    #{mode} 耗时: #{(cpu_times[mode] * 1000).round(1)}ms"
        end
        puts "  → 双线程计算 Fibonacci 不更快（GVL 锁住了 CPU 计算）"
        puts

        # --- 2. Thread 基础 ---
        puts "--- Thread 基础 ---"
        puts "  Thread.new — 创建新线程"
        puts "  Thread#join — 等待线程完成"
        puts "  Thread#value — 等待并获取 block 返回值"
        puts "  Thread#status / Thread#alive? — 线程状态"
        puts

        # 2a. Thread.new + join + value
        puts "  示例：Thread.new + Thread#value"
        t = Thread.new { "线程返回值" }
        puts "    t.status: #{t.status}（运行中）"
        result = t.value  # 等价于 join + 获取 block 返回值
        puts "    t.value: #{result}"
        puts "    t.status: #{t.status}（已终止）"
        puts

        # 2b. Thread 状态
        puts "  Thread 状态："
        status_thread = Thread.new { sleep(0.5) }
        puts "    运行中: status Thread#status = #{status_thread.status.inspect}"
        status_thread.join
        puts "    完成后:   status Thread#status = #{status_thread.status.inspect}"
        # Thread#alive? 等同于 status != false/nil
        puts "    Thread#alive? 表示线程是否仍在执行"
        puts

        # 2c. Thread#raise 和 join with timeout
        puts "  Thread#raise — 向线程注入异常"
        interrupted = Thread.new do
          begin
            sleep(10)
          rescue Interrupt => e
            puts "    线程收到异常: #{e.class} — #{e.message}"
            "rescued"
          end
        end
        sleep(0.05)  # 等线程开始
        interrupted.raise(Interrupt.new("强制中断"))
        result = interrupted.join&.value  # join 然后取值
        puts "    处理结果: #{result}"
        puts

        puts "  Thread#join with timeout — 等待线程（带超时）"
        slow = Thread.new { sleep(10) }
        joined = slow.join(0.1)  # 最多等 0.1 秒
        if joined
          puts "    线程在超时前完成"
        else
          puts "    超时！线程仍在运行"
          slow.kill  # 终止慢线程
          slow.join
          puts "    线程已终止"
        end
        puts

        # 2d. 线程局部变量
        puts "--- 线程局部变量 ---"
        Thread.current[:request_id] = "request-42"
        Thread.current[:user] = "alice"

        other = Thread.new do
          # 每个线程有独立的 Thread.current 命名空间
          Thread.current[:request_id] = "other-request"
          puts "    子线程 Thread.current[:request_id] = #{Thread.current[:request_id]}"
        end
        other.join
        puts "    主线程 Thread.current[:request_id] = #{Thread.current[:request_id]}"
        puts "    主线程 Thread.current[:user] = #{Thread.current[:user]}"
        puts "  → 线程局部变量互不干扰"
        puts

        # --- 3. Thread-Safe Queue ---
        puts "--- Thread-Safe Queue ---"
        queue = Queue.new

        # 生产者线程
        producer = Thread.new do
          5.times do |i|
            item = "item-#{i}"
            queue.push(item)
            puts "  生产者 → push #{item}"
            sleep(0.02)
          end
          queue.push(:stop)  # 停止信号
        end

        # 消费者线程
        consumer = Thread.new do
          results = []
          loop do
            item = queue.pop  # 阻塞直到有数据
            break if item == :stop
            results << item
            puts "  消费者 ← pop #{item}"
          end
          results
        end

        producer.join
        consumer_results = consumer.value
        puts "  消费者收到: #{consumer_results.inspect}"
        puts "  Queue#num_waiting: #{queue.num_waiting}（等待的消费者数）"
        puts

        # --- 4. Mutex — 保护共享状态 ---
        puts "--- Mutex（互斥锁）---"

        # 4a. 没有 Mutex — 竞态条件
        puts "  场景：无保护的共享计数器（竞态条件）"
        counter_naked = { value: 0 }
        mutex_none = Mutex.new  # 仅用于 synchronized 输出

        threads_naked = 10.times.map do
          Thread.new do
            1000.times do
              # 不安全的操作：读取 → 加 1 → 写回
              temp = counter_naked[:value]
              counter_naked[:value] = temp + 1
            end
          end
        end
        threads_naked.each(&:join)
        puts "    预期: 10_000, 实际: #{counter_naked[:value]}（通常小于预期）"
        puts "    → 多个线程同时读取旧值，导致更新丢失"
        puts

        # 4b. 有 Mutex — 无竞态
        puts "  场景：Mutex 保护的共享计数器"
        counter_safe = { value: 0 }
        mutex_safe = Mutex.new

        threads_safe = 10.times.map do
          Thread.new do
            1000.times do
              mutex_safe.synchronize do
                temp = counter_safe[:value]
                counter_safe[:value] = temp + 1
              end
            end
          end
        end
        threads_safe.each(&:join)
        puts "    预期: 10_000, 实际: #{counter_safe[:value]}（正确）"
        puts "    → Mutex#synchronize 保证临界区原子执行"
        puts

        # --- 5. Fiber — 协作式并发 ---
        puts "--- Fiber（协作式协程）---"
        puts "  Fiber 是用户态协程，不能自动抢占调度"
        puts "  通过 Fiber#resume 和 Fiber.yield 主动转让控制权"
        puts

        # 5a. 基本 Fiber 使用
        puts "  示例：Fiber.resume / Fiber.yield"
        fiber = Fiber.new do
          puts "    [Fiber] 开始执行"
          Fiber.yield 1
          puts "    [Fiber] 恢复后继续"
          Fiber.yield 2
          puts "    [Fiber] 最后一次 yield"
          3  # 最终返回值
        end
        puts "    第1次 resume → #{fiber.resume}"
        puts "    第2次 resume → #{fiber.resume}"
        puts "    第3次 resume → #{fiber.resume}"
        puts "    Fiber 已完成: alive? = #{fiber.alive?}"
        puts

        # 5b. Fiber 作为生成器
        puts "  模式：Fiber 生成器"
        # Ruby 内置的 Enumerator 底层就是用 Fiber 实现的
        numbers = Enumerator.new do |yielder|
          i = 0
          loop do
            i += 1
            yielder.yield i * 2
          end
        end
        puts "    前 5 个偶数: #{numbers.first(5).inspect}"
        puts

        # 5c. Fiber 实现协作式 pipeline
        puts "  模式：协程管道（Pipeline）"
        # 将数据通过多个 Fiber 管道处理
        source_fiber = Fiber.new do
          [1, 2, 3, 4, 5].each { |n| Fiber.yield n }
        end

        # 手动实现一个简单的管道
        values = []
        loop do
          val = source_fiber.resume
          values << val
          break unless source_fiber.alive?  # 最后一次 resume 返回 block 值则跳出
        end
        puts "    管道输出: #{values.first(5).inspect}"
        puts

        # --- 6. Ractor — Ruby 3+  actor 模型 ---
        puts "--- Ractor（真正并行，无共享内存）---"
        puts "  Ractor 禁止共享可变状态，只能通过消息传递通信"
        puts

        if RUBY_VERSION >= "3.0"
          begin
            # 6a. 基本 Ractor
            puts "  示例：Ractor 计算（CPU 密集型真正并行）"
            ractor = Ractor.new do
              # Ractor 内部执行纯计算，不受 GVL 限制
              sum = (1..5_000_000).sum
              sum
            end
            # Ractor#take — 获取 Ractor 返回值（阻塞直到完成）
            result = ractor.take
            puts "    (1..5_000_000).sum = #{result}"
            puts

            # 6b. Ractor 消息传递
            puts "  示例：Ractor 消息传递"
            echo = Ractor.new do
              msg = Ractor.receive  # 接收消息
              "收到: #{msg}"
            end
            echo.send("Hello, Ractor!")
            response = echo.take
            puts "    #{response}"
            puts

            # 6c. 多 Ractor 并行
            puts "  示例：多 Ractor 并行处理"
            data_sets = [(1..100), (101..200), (201..300)]
            ractors = data_sets.map { |range| Ractor.new(range) { |r| r.sum } }
            results = ractors.map(&:take)
            puts "    3 个 Ractor 分别计算: #{results.inspect}"
            puts "    总计: #{results.sum}"
          rescue Ractor::Error => e
            puts "  （Ractor 在当前环境受限: #{e.message}）"
          end
        else
          puts "  Ractor 需要 Ruby 3.0+（当前 #{RUBY_VERSION}）"
        end
        puts

        # --- 7. 选择指南 ---
        puts "--- 并发原语选择指南 ---"
        puts "  ┌─────────┬────────────┬──────────────────────────┐"
        puts "  │ 原语    │ 适用场景   │ 特点                     │"
        puts "  ├─────────┼────────────┼──────────────────────────┤"
        puts "  │ Thread  │ I/O 密集型 │ 受 GVL 限制，I/O 时可并行│"
        puts "  │ Fiber   │ 协作式调度 │ 手动控制，轻量、低成本   │"
        puts "  │ Ractor  │ CPU 密集型 │ 真正并行，无共享内存     │"
        puts "  └─────────┴────────────┴──────────────────────────┘"
        puts
        puts "  Thread 适用：HTTP 请求、数据库查询、文件读写"
        puts "  Fiber 适用：生成器、协同 pipeline、轻量状态机"
        puts "  Ractor 适用：大规模数据处理、独立计算任务"
        puts
        puts "=== 线程与协程演示完成 ==="
      end

      # 辅助方法：Fibonacci（用于 GVL 演示）
      def self.fib(n)
        return n if n < 2
        fib(n - 1) + fib(n - 2)
      end
      private_class_method :fib
    end
  end
end

Hello::TopicRegistry.register("advance", "threads_fibers", "线程与协程", Hello::Advance::ThreadsFibers)
