# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # 线程与 Fiber — GVL, Thread, Fiber, Queue, Mutex, Ractor
    class ThreadsFibersSample
      def self.run
        puts "=== 线程与协程 — GVL, Queue, Mutex, Ractor ==="
        puts

        # --- 1. Thread 基础 ---
        puts "--- 1. Thread 基础 ---"
        t = Thread.new { "Hello from thread" }
        puts "  创建线程: status=#{t.status}"
        result = t.value
        puts "  线程返回值: #{result}"
        puts "  线程结束状态: #{t.status}"

        # 线程状态追踪
        state_thread = Thread.new { sleep(0.3) }
        puts "  运行中线程: alive?=#{state_thread.alive?}, status=#{state_thread.status}"
        state_thread.join
        puts "  完成后线程: alive?=#{state_thread.alive?}, status=#{state_thread.status.inspect}"
        puts

        # --- 2. Queue 生产者/消费者 ---
        puts "--- 2. Queue 生产者/消费者 ---"
        queue = Queue.new
        consumed = []
        consumed_mutex = Mutex.new

        producer = Thread.new do
          5.times do |i|
            item = "item-#{i}"
            queue.push(item)
            puts "  [生产者] enqueue #{item}"
            sleep(0.02)
          end
          queue.push(:done)
          puts "  [生产者] 完成"
        end

        consumer = Thread.new do
          loop do
            item = queue.pop
            break if item == :done
            consumed_mutex.synchronize { consumed << item }
            puts "  [消费者] dequeue #{item}"
          end
          "Consumer done"
        end

        producer.join
        consumer_status = consumer.value
        puts "  #{consumer_status}"
        puts "  消费结果: #{consumed.inspect}"
        puts "  Queue 等待数: #{queue.num_waiting}"
        puts

        # --- 3. Mutex 共享状态保护 ---
        puts "--- 3. Mutex 共享状态保护 ---"

        # 无保护: 竞争条件
        counter_naked = SharedCounter.new
        threads_naked = 10.times.map do
          Thread.new { 1000.times { counter_naked.increment_naked } }
        end
        threads_naked.each(&:join)
        puts "  无保护并发: 预期 10000, 实际 #{counter_naked.value_naked} (丢失更新)"

        # 有保护: 正确结果
        counter_safe = SharedCounter.new
        threads_safe = 10.times.map do
          Thread.new { 1000.times { counter_safe.increment_safe } }
        end
        threads_safe.each(&:join)
        puts "  Mutex 保护: 预期 10000, 实际 #{counter_safe.value_safe} (正确)"
        puts

        # --- 4. Fiber 协程 ---
        puts "--- 4. Fiber 协作式协程 ---"
        fiber = Fiber.new do
          result1 = 10 * 5
          Fiber.yield(result1)
          result2 = 20 * 3
          Fiber.yield(result2)
          30 * 2
        end
        puts "  resume #1 → #{fiber.resume}"
        puts "  resume #2 → #{fiber.resume}"
        puts "  resume #3 → #{fiber.resume}"
        puts "  alive? → #{fiber.alive?}"

        # Fiber 生成器
        puts "  Fiber 生成器 (偶数序列):"
        even_gen = Fiber.new do
          n = 0
          loop do
            n += 2
            Fiber.yield(n)
          end
        end
        evens = 5.times.map { even_gen.resume }
        puts "    前5个: #{evens.inspect}"
        puts

        # --- 5. Fiber 管道 ---
        puts "--- 5. 协程管道 ---"
        # 数据逐个通过 filter → transform → collect
        transform_fiber = Fiber.new do
          input_data = [%w[apple banana cherry], %w[date elderberry]].flatten
          input_data.each do |word|
            result = word.upcase
            Fiber.yield(result)
          end
        end

        pipeline = []
        loop do
          val = transform_fiber.resume
          pipeline << val
          break unless transform_fiber.alive?
        end
        puts "  管道输入: 混合大小写单词数组"
        puts "  管道操作: upcase"
        puts "  管道输出: #{pipeline.inspect}"
        puts

        # --- 6. Ractor 真正并行 ---
        puts "--- 6. Ractor (Ruby 3+ 真正并行) ---"
        if RUBY_VERSION >= "3.0"
          begin
            # 素数计数：多分区
            ranges = [[2, 500], [501, 1000], [1001, 1500], [1501, 2000]]
            ractors = ranges.map { |min_val, max_val|
              Ractor.new(min_val, max_val) do |min_v, max_v|
                count = 0
                (min_v..max_v).each do |num|
                  is_prime = (2..Math.sqrt(num).to_i).none? { |i| num % i == 0 }
                  count += 1 if is_prime
                end
                count
              end
            }
            counts = ractors.map(&:take)
            total_primes = counts.sum
            puts "  4 个 Ractor 分区计算素数:"
            puts "    分区计数: #{counts.inspect}"
            puts "    素数总数: #{total_primes}"

            # Ractor 消息传递
            echo_ractor = Ractor.new do
              msg = Ractor.receive
              "Ack: #{msg} (by #{Ractor.current})"
            end
            echo_ractor.send("ping")
            ack = echo_ractor.take
            puts "    消息: ping → #{ack}"

            # Map-Reduce 模式
            data_chunks = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
            mapper_ractors = data_chunks.map { |chunk|
              Ractor.new(chunk) { |c| c.map { |x| x * 2 } }
            }
            mapped = mapper_ractors.map(&:take).flatten
            puts "    map-reduce [1..9]×2: #{mapped.inspect}"
            puts "    sum: #{mapped.sum}"
          rescue Ractor::Error => e
            puts "  Ractor 受限: #{e.message}"
          end
        else
          puts "  Ractor 需要 Ruby 3.0+（当前 #{RUBY_VERSION}）"
        end

        puts
        puts "=== 线程与协程演示完成 ==="
      end
    end

    class SharedCounter
      def initialize
        @value_naked = 0
        @value_safe = 0
        @mutex = Mutex.new
      end

      attr_reader :value_naked, :value_safe

      def increment_naked
        v = @value_naked
        @value_naked = v + 1
      end

      def increment_safe
        @mutex.synchronize do
          v = @value_safe
          @value_safe = v + 1
        end
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "threads_fibers", "线程与协程", Hello::Advance::ThreadsFibersSample)
