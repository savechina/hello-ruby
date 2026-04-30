# 并行计算 (Parallel Computing)

## 概述

Ruby 的并行计算需要理解 GVL（Global VM Lock）的限制：GVL 确保同一时刻只有一个线程执行 Ruby 代码。这意味着多线程无法真正并行执行 CPU 密集型任务，但 I/O 操作会释放 GVL。本章节将介绍 Parallel gem 的进程/线程模式、GVL 影响分析，以及如何选择正确的并行策略。

核心要点：
- **GVL 限制**：Ruby 线程无法并行执行 CPU 密集代码
- **进程并行**：in_processes 绑过 GVL，适合 CPU 任务
- **线程并行**：in_threads 适合 I/O 任务（HTTP、数据库）
- **性能对比**：基准测试验证最佳策略
- **错误传播**：Parallel::UndumpableException 包装异常

## 示例

### 示例 1：进程并行（CPU 密集型）

```ruby
require 'parallel'

# CPU 密集计算
data = (1..100).to_a

# 使用进程并行（绑过 GVL）
results = Parallel.map(data, in_processes: 4) do |n|
  # 每个进程独立 GVL，真正并行
  Math.sqrt(n) ** 2  # CPU 计算
end

puts results.sum  # => 约 5050
```

### 示例 2：线程并行（I/O 密集型）

```ruby
require 'parallel'
require 'net/http'

urls = ['https://api.example.com/users',
        'https://api.example.com/products',
        'https://api.example.com/orders']

# 线程并行（I/O 释放 GVL）
responses = Parallel.map(urls, in_threads: 4) do |url|
  Net::HTTP.get(URI(url))  # I/O 操作
end

puts "获取 #{responses.size} 个响应"
```

### 示例 3：性能基准对比

```ruby
require 'benchmark'
require 'parallel'

data = (1..1000).to_a

Benchmark.bm do |x|
  x.report('sequential') { data.map { |n| n ** 2 } }
  x.report('threads') { Parallel.map(data, in_threads: 4) { |n| n ** 2 } }
  x.report('processes') { Parallel.map(data, in_processes: 4) { |n| n ** 2 } }
end

# CPU 任务：processes 最快
# I/O 任务：threads 最快且内存低
```

## 知识检查

1. Ruby GVL 对多线程有什么限制？为什么 CPU 密集任务需要多进程？
2. I/O 操作如何与 GVL 交互？为什么线程适合 HTTP 请求？
3. 如何选择 in_processes vs in_threads？各自的开销是什么？

## 参考资源

- [Parallel gem](https://github.com/grosser/parallel)
- [Ruby GVL 详解](https://blog.saeloun.com/2026/03/11/ruby-concurrency-beyond-fibers)
- [Ruby Thread 文档](https://ruby-doc.org/core/Thread.html)