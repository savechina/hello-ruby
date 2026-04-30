# typed: true
# frozen_string_literal: true

require "parallel"

module Hello
  module Advance
    # 并行计算 — parallel gem, GVL 限制, CPU vs I/O 绑定
    class ParallelSample
      class << self
        def run
          puts "=== 并行计算 — parallel gem, GVL 限制, CPU vs I/O 绑定 ==="
          puts

          parallel_map_processes
          puts
          parallel_map_threads
          puts
          gvl_limitations_demo
          puts
          benchmark_comparison
          puts
          error_propagation
          puts

          puts "=== 并行计算演示完成 ==="
        end

        def parallel_map_processes
          puts "--- 1. in_processes (CPU 密集型) ---"
          numbers = (1..20_000).to_a

          result = Parallel.map(numbers, in_processes: 4) do |n|
            prime_count = (2..n).count { |i| n % i == 0 ? false : true }
            prime_count
          end

          puts "  使用 4 个进程并行处理 #{numbers.size} 个数字"
          puts "  前 10 个结果: #{result[0..9].inspect}"
          puts "  进程数: #{Parallel.physical_processor_count}"
        end

        def parallel_map_threads
          puts "--- 2. in_threads (I/O 密集型) ---"
          urls = 10.times.map { |i| "https://httpbin.org/delay/#{i % 3}" }

          results = Parallel.map(urls, in_threads: 5) do |url|
            start = Time.now
            begin
              Net::HTTP.get(URI(url))
              elapsed = Time.now - start
              "OK (#{elapsed.round(2)}s)"
            rescue StandardError => e
              "ERR: #{e.class} (#{(Time.now - start).round(2)}s)"
            end
          end

          ok_count = results.count { |r| r.start_with?("OK") }
          puts "  使用 5 个线程并发请求 #{urls.size} 个 URL"
          puts "  成功 #{ok_count}/#{urls.size}"
        end

        def gvl_limitations_demo
          puts "--- 3. Ruby GVL 限制说明 ---"
          puts "  GVL (Global VM Lock) 是 Ruby 3.x 的全局锁机制:"
          puts "  - 同一时刻只有一个 Thread 执行 Ruby 字节码"
          puts "  - I/O 操作、系统调用会释放 GVL，所以线程适合 I/O 密集型"
          puts "  - CPU 密集型任务使用 in_processes 绕过 GVL 限制"
          puts "  - Ractor (Ruby 3.0+) 提供真正的并行执行"
          puts
          puts "  GVL 实验:"

          cpu_start = Time.now
          cpu_threads = 4.times.map do
            Thread.new { 10_000_000.times { Math.sqrt(rand) } }
          end
          cpu_threads.each(&:join)
          cpu_elapsed = Time.now - cpu_start

          io_start = Time.now
          io_threads = 4.times.map do
            Thread.new { sleep(0.5) }
          end
          io_threads.each(&:join)
          io_elapsed = Time.now - io_start

          puts "  CPU 密集型 4 线程: #{cpu_elapsed.round(3)}s (受 GVL 限制)"
          puts "  I/O (sleep) 4 线程:  #{io_elapsed.round(3)}s (几乎并行)"
          puts "  比例: #{(cpu_elapsed / [io_elapsed, 0.001].max).round(1)}x (越大说明 GVL 影响越大)"
        end

        def benchmark_comparison
          puts "--- 4. 顺序 vs 线程 vs 进程 对比 ---"
          data = (1..50).to_a

          heavy_cpu = ->(n) { (1..n).count { |i| (2..Math.sqrt(i).to_i).none? { |j| i % j == 0 } } }

          seq_start = Time.now
          seq_result = data.map { |n| heavy_cpu.call(n) }
          seq_elapsed = Time.now - seq_start

          thread_start = Time.now
          thread_result = Parallel.map(data, in_threads: 4) { |n| heavy_cpu.call(n) }
          thread_elapsed = Time.now - thread_start

          process_start = Time.now
          process_result = Parallel.map(data, in_processes: 4) { |n| heavy_cpu.call(n) }
          process_elapsed = Time.now - process_start

          puts "  数据量: #{data.size}"
          puts "  顺序执行:   #{seq_elapsed.round(3)}s"
          puts "  线程 (4):   #{thread_elapsed.round(3)}s (#{(seq_elapsed / [thread_elapsed, 0.001].max).round(1)}x)"
          puts "  进程 (4):   #{process_elapsed.round(3)}s (#{(seq_elapsed / [process_elapsed, 0.001].max).round(1)}x)"
          puts "  结果一致: #{seq_result == thread_result && thread_result == process_result}"
        end

        def error_propagation
          puts "--- 5. 异常传播 — parallel 的错误处理 ---"

          good_data = [1, 2, 3, 4, 5]
          bad_data = [1, 2, "boom", 4, 5]

          begin
            Parallel.map(good_data, in_processes: 2) { |n| n * 2 }
            puts "  正常数据: 成功处理"
          rescue Parallel::UndumpableException => e
            puts "  正常数据: 意外 - #{e.message}"
          end

          begin
            Parallel.map(bad_data, in_processes: 2) do |n|
              raise ArgumentError, "bad value: #{n}" if n.is_a?(String)
              n * 2
            end
            puts "  异常数据: 未捕获 (不应该到这里)"
          rescue Parallel::UndumpableException => e
            puts "  异常数据: 捕获到 UndumpableException - #{e.message}"
          rescue StandardError => e
            puts "  异常数据: 捕获到 #{e.class} - #{e.message}"
          end

          result_with_keep_going = Parallel.map(bad_data, in_processes: 2, keep_going: true) do |n|
            raise ArgumentError, "bad value: #{n}" if n.is_a?(String)
            n * 2
          rescue StandardError
            nil
          end
          puts "  keep_going: #{result_with_keep_going.inspect} (nil 表示失败元素)"
        end
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "parallel", "并行计算", Hello::Advance::ParallelSample)
