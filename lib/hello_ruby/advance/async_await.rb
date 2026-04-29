# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # 并发模型 — Thread、Fiber、Ractor
    #
    # Ruby 提供三种并发原语：
    # - Thread：系统级线程，受 GVL（全局虚拟机锁）限制
    # - Fiber：轻量级协程，手动调度，适合 I/O 密集型
    # - Ractor（Ruby 3.0+）：真正并行，无共享数据模型
    #
    # 现代 Ruby 也常用 async gem 进行结构化并发
    module AsyncAwait
      def self.run
        puts "=== Ruby 并发模型 ==="
        puts

        # --- 1. Thread — 系统级线程 ---
        puts "--- Thread（系统级线程） ---"
        results = []
        mutex = Mutex.new

        threads = 3.times.map do |i|
          Thread.new do
            # 模拟耗时操作
            sleep(0.1)
            value = "Thread #{i} 完成，结果 #{i * 10}"
            # 用 Mutex 保护共享状态
            mutex.synchronize { results << value }
            value
          end
        end

        # 等待所有线程结束
        threads.each(&:join)
        results.each { |r| puts "  #{r}" }
        puts "  3 个线程全部完成 (耗时约 0.1 秒，因并发执行)"
        puts

        # 线程间通信 — Thread#[] 存取线程局部变量
        Thread.current[:thread_id] = "main"
        puts "  线程局部变量: Thread.current[:thread_id] = #{Thread.current[:thread_id]}"
        puts "  当前线程数: #{Thread.list.count}"
        puts

        # --- 2. Fiber — 轻量级协程 ---
        puts "--- Fiber（轻量级协程 / 协程）---"

        # 手动调度的 Fiber
        fiber = Fiber.new do
          Fiber.yield "第一步完成"
          puts "    （Fiber 内部恢复执行）"
          Fiber.yield "第二步完成"
          Fiber.yield "第三步完成"
        end

        puts "  Fiber.resume 第1次: #{fiber.resume}"
        puts "  Fiber.resume 第2次: #{fiber.resume}"
        puts "  Fiber.resume 第3次: #{fiber.resume}"
        puts "  Fiber.alive?: #{fiber.alive?}"  # 已完成
        puts

        # Fiber 的实际用途 — 生成器
        puts "  Fiber 生成器模式:"
        counter_fiber = Fiber.new do
          n = 0
          loop do
            n += 1
            Fiber.yield n
          end
        end
        5.times { puts "    next: #{counter_fiber.resume}" }
        puts

        # --- 3. Ractor（Ruby 3.0+）---
        puts "--- Ractor（真正并行，无共享内存）---"
        # Ractor 是 Ruby 3.0 引入的并行原语
        # 使用消息传递，禁止共享可变状态
        if RUBY_VERSION >= "3.0"
          begin
            ractor = Ractor.new do
              # Ractor 内部计算，无共享
              sum = (1..1_000_000).sum
              sum
            end
            result = ractor.take
            puts "  Ractor 计算 (1..1_000_000).sum = #{result}"
            puts "  Ractor.current: #{Ractor.current}"
          rescue Ractor::Error => e
            puts "  （Ractor 在当前环境可能受限: #{e.message}）"
          end
        else
          puts "  Ractor 需要 Ruby 3.0+（当前 #{RUBY_VERSION}）"
        end
        puts

        # --- 4. 结构化并发概念 ---
        puts "--- 结构化并发模式 ---"
        # Ruby 没有内建 async/await，但可通过模式实现
        # 思路：使用 Fiber + 事件循环

        puts "  结构化并发模式（模拟）:"

        # 模拟 async 任务
        task_results = {}
        tasks = {
          fetch_user: -> { sleep(0.05); "User{alice}" },
          fetch_posts: -> { sleep(0.03); "[Post1, Post2]" },
          fetch_comments: -> { sleep(0.02); "[C1, C2, C3]" }
        }

        # 并发执行所有任务
        thread_map = tasks.transform_values { |t| Thread.new { t.call } }

        puts "  并发执行 3 个模拟任务:"
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        tasks.each_key do |name|
          thread_map[name].join
          elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
          puts "    ✓ #{name} 完成 (#{(elapsed * 1000).round(1)}ms)"
        end
        puts "  总耗时: #{((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).round(1)}ms"
        puts "  （因并发执行，总耗时 ≈ 最慢任务耗时，而非三者之和）"
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "async_await", "并发模型：Thread/Fiber/Ractor", Hello::Advance::AsyncAwait)
