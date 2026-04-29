# 并发模型：Thread/Fiber/Ractor

在单线程程序中，代码按顺序一条条执行。这是最直观的模式，但也是最低效的。现实世界的应用需要同时做很多事：处理用户请求、读写文件、调用外部 API、处理后台任务。如果所有操作都排队等待，用户体验就会很差。

Ruby 提供了三种不同的并发原语来解决这个问题：Thread、Fiber 和 Ractor。它们各有适用场景，理解每种原语的特点和限制是写出高效 Ruby 程序的关键。

运行 `hello advance async_await` 可以查看完整演示代码。

## Thread：系统级线程

Ruby 的 Thread 是对操作系统线程的封装。每个 Thread 都有独立的调用栈和执行上下文，可以在不同 CPU 核心上并行执行。但 Ruby 有一个重要的限制：GVL（全局虚拟机锁）。GVL 保证同一时刻只有一个线程在执行 Ruby 字节码，这是为了保护 Ruby 内部数据结构不被并发修改。

这个限制意味着什么？CPU 密集型的计算不能通过多线程加速，因为 GVL 会 serialize 所有线程。但 I/O 操作会释放 GVL，多个线程可以同时等待网络响应或磁盘读写。所以 Thread 最适用的场景是 I/O 密集型任务。

```ruby
# 创建三个并发线程
results = []
mutex = Mutex.new

threads = 3.times.map do |i|
  Thread.new do
    sleep(0.1)  # 模拟 I/O 操作，会释放 GVL
    value = "Thread #{i} 完成，结果 #{i * 10}"
    mutex.synchronize { results << value }
    value
  end
end

# 等待所有线程结束
threads.each(&:join)
puts results
# 三个线程并发执行，总耗时约 0.1 秒
# 如果是顺序执行需要 0.3 秒
```

注意这里使用了 Mutex 来保护 `results` 数组。多个线程同时修改同一个对象会导致竞态条件，数据损坏。Mutex 的 `synchronize` 方法保证同一时刻只有一个线程能进入临界区。

线程之间还可以通过线程局部变量传递信息：

```ruby
Thread.current[:request_id] = "request-42"
puts Thread.current[:request_id]  # "request-42"
```

每个线程有独立的 `Thread.current` 命名空间，子线程不会继承父线程的局部变量。这在 Web 框架中很常见，用于在同一个请求的处理链路中传递上下文信息。

## Fiber：轻量级协程

Fiber 与 Thread 最大的区别在于调度方式。Thread 由操作系统调度，Fiber 由程序员手动调度。Fiber 是协作式的，只有当 Fiber 主动调用 `Fiber.yield` 交出控制权时，另一个 Fiber 才能运行。

这种手动调度的设计让 Fiber 非常轻量。创建 Fiber 几乎零成本，你可以在单个程序中使用数十万个 Fiber 而不会有性能问题。Fiber 适合的场景是协作式数据流处理：生成器、管道、状态机。

```ruby
fiber = Fiber.new do
  Fiber.yield "第一步完成"
  puts "  （Fiber 内部恢复执行）"
  Fiber.yield "第二步完成"
  Fiber.yield "第三步完成"
end

puts fiber.resume  # "第一步完成"
puts fiber.resume  # "第二步完成"
puts fiber.resume  # "第三步完成"
puts fiber.alive?  # false，已执行完毕
```

`Fiber.yield` 暂停当前 Fiber 并返回一个值，`Fiber.resume` 恢复执行。注意 Fiber 不是自动并行运行的。它只是让你把一个计算过程拆成多个阶段，在合适的时机手动推进。

Fiber 最常见的用途是生成器。Ruby 的 `Enumerator` 类底层就是用 Fiber 实现的：

```ruby
counter = Fiber.new do
  n = 0
  loop do
    n += 1
    Fiber.yield n
  end
end

5.times { puts counter.resume }
# 输出: 1, 2, 3, 4, 5
```

这个 Fiber 是一个无限递增的计数器。每次 `resume` 产生一个值并暂停，不会阻塞其他代码。如果你需要一个按需计算的序列，Fiber 生成器是最简洁的方式。

## Ractor：真正的并行

Thread 受 GVL 限制不能并行执行 CPU 密集型代码。Ractor 是 Ruby 3.0 引入的全新并发模型，专门解决这个问题。Ractor 之间不共享内存，每个 Ractor 有独立的 GVL，所以多个 Ractor 可以在不同 CPU 核心上真正并行运行。

通信方式决定了 Ractor 的安全边界。Ractor 之间只能通过消息传递交换数据，不能直接访问其他 Ractor 的内部状态。这个限制消除了所有竞态条件的可能。

```ruby
ractor = Ractor.new do
  # Ractor 内部不受 GVL 限制
  sum = (1..1_000_000).sum
  sum  # 返回值
end

result = ractor.take  # 阻塞等待结果
puts result  # 500000500000
```

如果需要多个 Ractor 并行处理不同数据集：

```ruby
data_sets = [(1..100), (101..200), (201..300)]
ractors = data_sets.map { |range| Ractor.new(range) { |r| r.sum } }
results = ractors.map(&:take)
puts results.sum  # 45150
```

Ractor 也可以使用消息传递模式：

```ruby
echo = Ractor.new do
  msg = Ractor.receive  # 阻塞接收消息
  "收到: #{msg}"
end

echo.send("Hello, Ractor!")
puts echo.take  # "收到: Hello, Ractor!"
```

注意 Ractor 的限制：共享可变对象不能在 Ractor 之间传递。如果你尝试传递一个在其他 Ractor 中被修改的对象，Ruby 会抛出 `Ractor::Error`。这是 Ruby 在语言层面保证并发安全的方式。

## 如何选择并发原语

| 场景 | 推荐 | 原因 |
|------|------|------|
| HTTP 请求、数据库查询、文件读写 | Thread | I/O 操作释放 GVL，多线程可并行 |
| 生成器、协作式管道、轻量状态机 | Fiber | 零成本创建，手动调度灵活 |
| 大数据处理、独立计算任务 | Ractor | 多 CPU 真正并行，无共享安全 |
| 复杂并发编排 | async gem | 结构化并发，更高级的抽象 |

如果你不确定该用哪种，可以从 Thread 开始。Thread 覆盖大多数常见场景，配合 Queue 和 Mutex 就能实现安全的线程通信。当你发现 Thread 的调度开销太大，或者需要创建大量"虚拟线程"时，再考虑 Fiber。当你确实需要利用多核 CPU 做 CPU 密集型计算时，Ractor 是最后的选择。

## 本章要点

- **Thread** 是系统级线程，受 GVL 限制，适合 I/O 密集型并行
- **Fiber** 是轻量级协程，手动调度，适合生成器和协作式数据流
- **Ractor** 是真正并行的 Actor 模型，无共享内存，适合 CPU 密集型并行
- **Mutex** 保护共享状态，**Queue** 实现线程安全通信
- 选择并发原语时要考虑任务类型：I/O 密集型用 Thread，CPU 密集型用 Ractor
- Ruby 没有内建的 async/await，但可以通过 Fiber + 事件循环模拟结构化并发
