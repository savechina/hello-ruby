# 线程与协程

上一章介绍了三种并发原语的基础用法。这一章深入到每个原语的内部机制，包括 GVL 的工作原理、Thread 生命周期管理、Fiber 的协作式调度、Ractor 的消息传递模型，以及它们组合使用的实际模式。理解这些底层细节是写出正确并发程序的前提。

运行 `hello advance threads_fibers` 可以查看完整演示代码。

## GVL：全局虚拟机锁的深度解析

GVL（Global VM Lock，之前叫 GIL）是 Ruby 并发模型的最核心约束。它保证同一时刻只有一个线程在执行 Ruby 字节码，保护 Ruby 的内存管理机制不被并发破坏。

GVL 的影响取决于任务类型。CPU 密集型任务（如计算斐波那契数列、处理大数组排序）会被 GVL 序列化，多线程无法加速。I/O 密集型任务（如等待网络响应、读取文件、查询数据库）不会受到 GVL 限制，因为 I/O 操作期间 GVL 会被释放，其他线程可以继续运行。

验证这个差异：

```ruby
def fib(n)
  return n if n < 2
  fib(n - 1) + fib(n - 2)
end

# CPU 密集 — 双线程不会更快
[:single, :multi].each do |mode|
  start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  if mode == :single
    fib(35)
  else
    threads = 2.times.map { Thread.new { fib(35) } }
    threads.each(&:join)
  end
  elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
  puts "#{mode}: #{(elapsed * 1000).round(1)}ms"
end
# single: ~270ms,  multi: ~280ms（几乎相同，GVL 限制）

# I/O 密集 — 双线程确实更快
[:single, :multi].each do |mode|
  start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  if mode == :single
    2.times { sleep(0.1) }
  else
    threads = 2.times.map { Thread.new { sleep(0.1) } }
    threads.each(&:join)
  end
  elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
  puts "#{mode}: #{(elapsed * 1000).round(1)}ms"
end
# single: ~200ms,  multi: ~100ms（并行执行，GVL 被释放）
```

Ruby 3.0 之后的版本中，I/O 操作和 GVL 的关系更加精细。大部分 I/O 系统调用都会释放 GVL，但某些 C 扩展可能不会。如果你在代码中发现多线程 I/O 仍然很慢，可以检查一下是否有 C 扩展没有正确释放 GVL。

## Thread 生命周期

Thread 从创建到结束经历多个状态。理解这些状态对调试并发问题至关重要：

```ruby
Thread.new do
  # 线程创建后进入运行状态
  sleep(0.5)
  # 休眠时状态为 sleep
  # 返回 "done" 后状态变为 false（终止）
  "done"
end
```

Thread 的状态通过 `Thread#status` 查询：

- `"run"` — 线程正在运行
- `"sleep"` — 线程休眠或等待 I/O
- `"aborting"` — 线程正在被终止
- `false` — 线程正常终止
- `nil` — 线程因异常终止

`Thread#value` 等待线程完成并返回 block 的最后一个表达式的值。它等价于 `join` + 获取返回值：

```ruby
t = Thread.new { "线程返回值" }
puts t.status    # "run"（线程可能还在运行）
result = t.value # 阻塞等待完成并获取返回值
puts t.status    # false（已终止）
puts result      # "线程返回值"
```

`Thread#join` 的超时参数允许你等一段时间就放弃：

```ruby
slow = Thread.new { sleep(10) }
joined = slow.join(0.1)  # 最多等 0.1 秒

if joined
  puts "线程在超时前完成"
else
  puts "超时！线程仍在运行"
  slow.kill   # 终止慢线程
  slow.join   # 等待终止完成
end
```

`Thread#raise` 向另一个线程注入异常。用于中断执行中的线程：

```ruby
worker = Thread.new do
  begin
    sleep(10)
  rescue Interrupt => e
    puts "线程收到中断: #{e.message}"
    "已清理"
  end
end

sleep(0.05)
worker.raise(Interrupt.new("强制中断"))
result = worker.join&.value
puts result  # "已清理"
```

线程局部变量是 Thread 内部的一个哈希空间，每个线程独立：

```ruby
Thread.current[:request_id] = "request-42"
Thread.current[:user] = "alice"

Thread.new do
  Thread.current[:request_id] = "other"
  puts Thread.current[:request_id]  # "other"
end.join

puts Thread.current[:request_id]  # "request-42"（不受影响）
```

Web 框架广泛使用线程局部变量传递请求上下文，比如当前用户ID、请求追踪ID、事务ID 等。

## Thread-Safe Queue

`Queue` 是 Ruby 标准库中线程安全的数据结构。多个线程可以同时 push 和 pop，保证不会丢失数据：

```ruby
queue = Queue.new

# 生产者
producer = Thread.new do
  5.times do |i|
    item = "item-#{i}"
    queue.push(item)
    puts "生产者 → push #{item}"
    sleep(0.02)
  end
  queue.push(:stop)  # 停止信号
end

# 消费者
consumer = Thread.new do
  results = []
  loop do
    item = queue.pop  # 阻塞直到有数据
    break if item == :stop
    results << item
    puts "消费者 ← pop #{item}"
  end
  results
end

producer.join
puts consumer.value  # ["item-0", "item-1", "item-2", "item-3", "item-4"]
```

这是经典的生产者-消费者模式。`push` 向队列添加数据，`pop` 从队列取出数据（先进先出）。如果队列为空，`pop` 会阻塞直到有数据可用。`Queue.num_waiting` 可以查看当前有多少线程在等待数据。

SizedQueue 是 Queue 的变体，有最大容量限制。当队列满时 push 会阻塞：

```ruby
queue = SizedQueue.new(3)  # 最多 3 个元素
queue.push(1)
queue.push(2)
queue.push(3)
# queue.push(4)  # 阻塞！队列已满，等消费者取出元素
```

`SizedQueue` 适合控制生产者速度，防止生产者比消费者快太多导致内存溢出。

## Mutex：保护共享状态

当多个线程读写同一个变量时，竞态条件会导致数据不一致。Mutex 通过临界区保护解决这个问题：

```ruby
# 没有保护 — 竞态条件
counter = { value: 0 }
10.times.map do
  Thread.new do
    1000.times do
      # 读 → 加 1 → 写：三步操作非原子性
      temp = counter[:value]
      counter[:value] = temp + 1  # 可能被其他线程的写覆盖
    end
  end
end.each(&:join)
puts counter[:value]  # 通常小于 10000，数据丢失

# 有保护 — 无竞态
counter = { value: 0 }
mutex = Mutex.new
10.times.map do
  Thread.new do
    1000.times do
      mutex.synchronize do  # 临界区：同时只有一个线程执行
        temp = counter[:value]
        counter[:value] = temp + 1
      end
    end
  end
end.each(&:join)
puts counter[:value]  # 正好 10000
```

Mutex 的使用规则：

- 每次读写共享状态都要在 `synchronize` 块中
- 不要在临界区内执行长时间操作（I/O、sleep）
- 死锁的典型场景：线程 A 持有锁 X 要获取锁 Y，线程 B 持有锁 Y 要获取锁 X

## Fiber：协作式并发详解

Fiber 是用户态协程，不能自动抢占。通过 `Fiber#resume` 恢复执行，`Fiber.yield` 交出控制权。这种协作式设计让 Fiber 极其轻量：

```ruby
fiber = Fiber.new do
  puts "[Fiber] 开始"
  Fiber.yield 1       # 暂停，返回值 1
  puts "[Fiber] 恢复后继续"
  Fiber.yield 2       # 暂停，返回值 2
  puts "[Fiber] 最后一次"
  3                    # 终止，返回值 3
end

puts fiber.resume     # "[Fiber] 开始" → 1
puts fiber.resume     # "[Fiber] 恢复后继续" → 2
puts fiber.resume     # "[Fiber] 最后一次" → 3
puts fiber.alive?     # false
```

Fiber 最常见的实际用途是生成器。`Enumerator` 底层就是 Fiber：

```ruby
# 无限偶数生成器
evens = Enumerator.new do |yielder|
  i = 0
  loop do
    i += 2
    yielder.yield i
  end
end

puts evens.first(5).inspect  # [2, 4, 6, 8, 10]
```

Fiber 还可以实现协作式数据管道，将数据依次通过多个处理阶段：

```ruby
# 阶段1：生成数据
source = Fiber.new do
  [1, 2, 3, 4, 5].each { |n| Fiber.yield n }
end

# 阶段2：处理数据
values = []
loop do
  val = source.resume
  values << val * 2
  break unless source.alive?
end

puts values.inspect  # [2, 4, 6, 8, 10]
```

Ruby 3.0 后的 Fiber 调度器（Fiber Scheduler）允许你替换默认的 I/O 调度行为，实现类似 async gem 的协作式 I/O。这是现代 Ruby 并发编程的另一个重要方向。

## Ractor：消息传递模型

Ractor 通过 `send` 和 `receive` 交换消息。消息在传递时会做可分享性检查：不可分享的对象（被多个 Ractor 共享的可变对象）会被拒绝：

```ruby
echo = Ractor.new do
  msg = Ractor.receive  # 阻塞等待消息
  "收到: #{msg}"
end

echo.send("Hello!")
puts echo.take  # "收到: Hello!"
```

多 Ractor 协作模式：

```ruby
# 3 个 Ractor 分别处理不同数据范围
datasets = [(1..100), (101..200), (201..300)]
workers = datasets.map { |range| Ractor.new(range) { |r| r.sum } }
results = workers.map(&:take)  # [5050, 15100, 30150]
puts results.sum               # 50300
```

Ractor 的限制很严格。你不能在 Ractor 之间共享可变对象。如果你确实需要在 Ractor 之间共享数据，可以使用 `Ractor.make_shareable` 标记对象为不可变，或者用 `Ractor::Queue` 通过消息传递。

## 本章要点

- **GVL** 序列化 Ruby 字节码执行，I/O 操作会释放 GVL 允许并发
- **Thread.status** 返回 "run"、"sleep"、"aborting"、false 或 nil
- **Thread#value** 等待完成并获取返回值，**Thread#join(timeout)** 支持超时
- **Thread#raise** 向目标线程注入异常，**Thread.current[]** 存取线程局部变量
- **Queue** 线程安全的生产者-消费者通道，**SizedQueue** 限制队列容量
- **Mutex** 保护临界区，**synchronize** 保证原子执行
- **Fiber.yield/resume** 实现协作式调度，`Enumerator` 底层是 Fiber
- **Ractor** 通过 `send/receive/take` 做消息传递，不可分享对象会被拒绝
- 运行 `hello advance threads_fibers` 查看完整线程与协程演示
