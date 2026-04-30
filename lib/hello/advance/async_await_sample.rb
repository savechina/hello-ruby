# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # Async/Await 并发模式 — 使用 Thread/Fiber/Ractor 实现结构化并发
    class AsyncAwaitSample
      def self.run
        puts "=== 并发模型 — Thread/Fiber/Ractor ==="
        puts

        # --- 1. Task 抽象层：模拟 async/await ---
        puts "--- 1. Structured Concurrency（结构化并发） ---"
        scheduler = ConcurrentScheduler.new

        tasks = [
          TaskDef.new(name: "fetch_user", delay: 0.05) { sleep(0.05); { id: 1, name: "Alice" } },
          TaskDef.new(name: "fetch_posts", delay: 0.08) { sleep(0.08); [{ title: "Post 1" }, { title: "Post 2" }] },
          TaskDef.new(name: "fetch_comments", delay: 0.03) { sleep(0.03); [{ body: "Nice!" }] }
        ]

        results = scheduler.run_all(tasks)
        puts "  并发执行 #{tasks.length} 个任务:"
        results.each do |name, result|
          puts "    ✓ #{name} → #{result.inspect}"
        end
        puts "  并发耗时: #{(scheduler.elapsed_ms).round(1)}ms"
        puts "  (若串行执行 ≈ #{(tasks.sum { |t| t.delay * 1000 }).round(1)}ms)"
        puts

        # --- 2. Fiber 协程管道 ---
        puts "--- 2. Fiber Pipeline（协程管道） ---"
        pipeline = FiberPipeline.new

        pipeline.add_stage(:parse) { |line| line.strip.upcase }
        pipeline.add_stage(:filter) { |line| line.length > 5 }
        pipeline.add_stage(:number) { |line, idx| "[#{idx + 1}] #{line}" }

        input_lines = [%w[hello world ruby], %w[the], %w[advanced concurrent programming]].flatten
        output_lines = pipeline.execute(input_lines)
        puts "  输入: #{input_lines.inspect}"
        puts "  处理: strip → upcase → filter(len>5) → number"
        puts "  输出: #{output_lines.inspect}"
        puts

        # --- 3. Ractor 真正并行 ---
        puts "--- 3. Ractor（真正并行计算） ---"
        if RUBY_VERSION >= "3.0"
          begin
            # 素数筛：多 Ractor 并行分区计算
            ranges = [[2, 250], [251, 500], [501, 750], [751, 1_000]]
            ractors = ranges.map do |min_val, max_val|
              Ractor.new(min_val, max_val) do |min_v, max_v|
                primes = []
                (min_v..max_v).each do |num|
                  is_prime = num > 1 && (2..Math.sqrt(num).to_i).none? { |i| num % i == 0 }
                  primes << num if is_prime
                end
                primes
              end
            end
            prime_chunks = ractors.map(&:take)
            all_primes = prime_chunks.flatten.sort
            puts "  4 个 Ractor 并行计算 2..1000 的素数:"
            puts "    分区结果数: #{prime_chunks.map(&:length).inspect}"
            puts "    素数总数: #{all_primes.length}"
            puts "    前 10 个: #{all_primes.first(10).inspect}"
            puts "    最后 5 个: #{all_primes.last(5).inspect}"
            puts
            puts "  Ractor 消息传递模式:"
            echo_ractor = Ractor.new do
              msg = Ractor.receive
              "Echo: #{msg} (processed by #{Ractor.current})"
            end
            echo_ractor.send("Hello from main!")
            response = echo_ractor.take
            puts "    #{response}"
          rescue Ractor::Error => e
            puts "  Ractor 在当前环境受限: #{e.message}"
          end
        else
          puts "  Ractor 需要 Ruby 3.0+（当前 #{RUBY_VERSION}）"
        end

        puts
        puts "=== 并发模型演示完成 ==="
      end
    end

    # --- 并发原语：Task/调度器 ---
    class TaskDef
      attr_reader :name, :delay

      def initialize(name:, delay:, &block)
        @name = name
        @delay = delay
        @block = block
      end

      def execute
        @block.call
      end
    end

    class ConcurrentScheduler
      def initialize
        @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def elapsed_ms
        (Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start_time) * 1000
      end

      def run_all(tasks)
        threads = tasks.map do |task|
          Thread.new do
            [task.name, task.execute]
          end
        end
        threads.map(&:value)
      end
    end

    # --- Fiber 管道 ---
    class FiberPipeline
      def initialize
        @stages = []
      end

      def add_stage(_name, &transformer)
        @stages << transformer
      end

      def execute(input_items)
        input_items.each_with_index.filter_map do |item, idx|
          result = item
          skipped = false
          @stages.each do |stage|
            params = stage.parameters.map { |type, _| type }
            output = params.length >= 2 ? stage.call(result, idx) : stage.call(result)
            if output == false
              skipped = true
              break
            end
            result = output unless output == true
          end
          skipped ? nil : result
        end
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "async_await", "并发模型：Thread/Fiber/Ractor", Hello::Advance::AsyncAwaitSample)
