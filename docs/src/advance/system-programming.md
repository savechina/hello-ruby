# 系统编程 (System Programming)

## 概述

Ruby 提供了丰富的系统级编程能力，包括进程管理、信号处理、管道通信和进程信息查询。这些能力对于构建 DevOps 工具、后台任务处理器和基础设施自动化脚本至关重要。本章节将介绍 Process.spawn、IO.popen、Signal.trap 以及 sys-proctable gem 的实际应用场景。

核心要点：
- **进程创建**：Process.spawn 创建子进程，非阻塞执行
- **管道通信**：IO.popen 双向管道，捕获命令输出
- **信号处理**：Signal.trap 捕获 SIGINT/SIGTERM，优雅退出
- **进程信息**：Sys::ProcTable 查询系统进程状态
- **环境管理**：ENV 访问和修改进程环境变量

## 示例

### 示例 1：进程创建与等待

```ruby
# 创建子进程执行命令
pid = Process.spawn('sleep 5 && echo "Done"')
puts "子进程 PID: #{pid}"

# 非阻塞：继续其他工作
puts "父进程继续执行..."

# 等待子进程完成
Process.wait(pid)
puts "子进程已退出"
```

### 示例 2：信号处理与优雅退出

```ruby
# 捕获 Ctrl+C (SIGINT)
Signal.trap('INT') do
  puts "\n收到中断信号，正在清理..."
  cleanup_resources
  exit(0)
end

# 捕获终止信号 (SIGTERM)
Signal.trap('TERM') do
  puts "收到终止信号，正在关闭..."
  graceful_shutdown
  exit(0)
end

# 主循环
loop { sleep 1 }
```

### 示例 3：进程信息查询

```ruby
require 'sys/proctable'

# 查询当前进程
current = Sys::ProcTable.ps.find { |p| p.pid == Process.pid }
puts "进程名: #{current.comm}"
puts "内存使用: #{current.rss} KB"
puts "CPU 时间: #{current.time}"

# 查询所有 Ruby 进程
ruby_processes = Sys::ProcTable.ps.select { |p| p.comm.include?('ruby') }
puts "Ruby 进程数: #{ruby_processes.size}"
```

## 知识检查

1. Process.spawn 与 system 命令有什么区别？何时使用 spawn？
2. 信号处理中 SIGINT 和 SIGTERM 有什么不同？为什么需要优雅退出？
3. Sys::ProcTable.ps 返回哪些进程属性？如何筛选特定进程？

## 参考资源

- [Ruby Process 文档](https://ruby-doc.org/core/Process.html)
- [sys-proctable gem](https://github.com/djberg96/sys-proctable)
- [Unix Signals 详解](https://man7.org/linux/man-pages/man7/signal.7.html)