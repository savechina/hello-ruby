# typed: true
# frozen_string_literal: true

require "sys/proctable"

module Hello
  module Advance
    # 系统编程 — Process, IO, Signal, ENV, Sys::ProcTable
    class SystemProgrammingSample
      def self.run
        puts "=== 系统编程 ==="
        puts

        process_spawn_demo
        puts

        io_popen_demo
        puts

        signal_handling
        puts

        process_info_collection
        puts

        environment_management
        puts

        puts "=== 系统编程演示完成 ==="
      end

      def self.process_spawn_demo
        puts "--- 1. 进程生成 (Process.spawn) ---"

        pid = Process.spawn("echo 'Hello from child process!'")
        puts "  子进程 PID: #{pid}"

        _, status = Process.wait2(pid)
        puts "  子进程退出状态: #{status.exitstatus}"
        puts "  子进程正常结束? #{status.success?}"
        puts
        puts "  Process.spawn vs system:"
        puts "  - spawn: 立即返回 PID, 非阻塞"
        puts "  - system: 阻塞等待, 返回 true/false"
        puts "  - exec: 替换当前进程, 不返回"
      end

      def self.io_popen_demo
        puts "--- 2. 管道 IO (IO.popen) ---"

        puts "  读取命令输出:"
        IO.popen("ls -la /tmp") do |io|
          lines = io.readlines.take(5)
          lines.each { |line| puts "    #{line.chomp}" }
          puts "    ... (仅显示前 5 行)"
        end
        puts

        puts "  写入并读取管道:"
        io = IO.popen("ruby -e 'puts STDIN.read.upcase'", "r+")
        io.write("hello from pipe\n")
        io.close_write
        result = io.read.chomp
        io.close
        puts "  输入: 'hello from pipe'"
        puts "  输出: '#{result}'"
        puts
        puts "  IO.popen 允许与子进程双向通信"
      end

      def self.signal_handling
        puts "--- 3. 信号处理 (Signal.trap) ---"

        original_handler = Signal.trap("USR1") do
          puts "  [USR1 信号已捕获!]"
        end

        puts "  已注册 USR1 信号处理器"
        puts "  当前进程 PID: #{Process.pid}"
        puts "  发送 USR1 信号到自身..."
        Process.kill("USR1", Process.pid)
        sleep(0.1)

        Signal.trap("USR1", original_handler)
        puts "  已恢复原始信号处理器"
        puts
        puts "  常用信号:"
        puts "  - INT (Ctrl+C): 中断"
        puts "  - TERM: 终止请求"
        puts "  - KILL: 强制终止(不可捕获)"
        puts "  - USR1/USR2: 用户自定义"
      end

      def self.process_info_collection
        puts "--- 4. 进程信息收集 (Sys::ProcTable) ---"

        current_pid = Process.pid
        puts "  当前进程 PID: #{current_pid}"

        begin
          procs = Sys::ProcTable.ps
          proc = procs.find { |p| p.pid == current_pid }
          if proc
            puts "  进程名: #{proc.name}"
            puts "  父进程 PID: #{proc.ppid}"
            puts "  进程组 ID: #{proc.pgid}"
            puts "  会话 ID: #{proc.sid}" if proc.respond_to?(:sid)
            puts "  虚拟内存 (KB): #{proc.vsize}" if proc.respond_to?(:vsize)
            puts "  常驻内存 (KB): #{proc.rss}" if proc.respond_to?(:rss)
          else
            puts "  未找到当前进程信息"
          end
        rescue => e
          puts "  进程信息: #{e.message}"
          puts "  (某些平台可能需要额外权限)"
        end

        puts
        puts "  Sys::ProcTable 可枚举所有系统进程"
        puts "  适用场景: 进程监控, 资源审计, 僵尸进程检测"
      end

      def self.environment_management
        puts "--- 5. 环境变量管理 (ENV) ---"

        puts "  读取环境变量:"
        puts "  PATH 前 50 字符: #{ENV['PATH'][0...50]}..."
        puts "  HOME: #{ENV['HOME']}"
        puts "  SHELL: #{ENV['SHELL']}"
        puts

        puts "  设置环境变量:"
        ENV["HELLO_RUBY_DEMO"] = "system_programming"
        puts "  HELLO_RUBY_DEMO = '#{ENV['HELLO_RUBY_DEMO']}'"
        puts

        puts "  遍历所有环境变量 (前 5 个):"
        ENV.to_h.take(5).each do |key, value|
          puts "  #{key}=#{value[0...30]}..."
        end
        puts "  总计: #{ENV.size} 个环境变量"
        puts

        ENV.delete("HELLO_RUBY_DEMO")
        puts "  已清理 HELLO_RUBY_DEMO"
        puts
        puts "  提示: 使用 dotenv gem 管理 .env 文件"
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "system_programming", "系统编程", Hello::Advance::SystemProgrammingSample)
