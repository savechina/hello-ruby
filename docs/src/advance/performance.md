# 性能优化

当你的 Ruby 程序运行缓慢时，你会本能地想去优化代码。但优化的前提是测量。没有数据支撑的优化往往是盲目的，甚至会让性能更差。这一章教你用 Ruby 标准库中的工具测量性能、分析内存分配、理解 GC 行为，然后给出经过验证的优化策略。

性能优化不是早期就应该做的事。先让代码正确运行，再用工具找到真正的瓶颈，最后才针对性地优化。提前优化往往是浪费精力。

运行 `hello advance performance` 可以查看完整演示代码。

## Benchmark 基础

Ruby 标准库中的 Benchmark 模块提供三个方法：`Benchmark.measure`、`Benchmark.bm`、`Benchmark.bmbm`：

```ruby
require "benchmark"

# 简单的单次测量
time = Benchmark.measure do
  1_000_000.times { "hello" }
end
puts time  # 输出 user, system, total, real 时间

# 对比多个方案（带标签对齐）
n = 50_000
Benchmark.bm(16) do |x|
  x.report("sort")  { Array.new(n) { rand(n + 1) }.sort }
  x.report("sort!") { a = Array.new(n) { rand(n + 1) }; a.sort! }
  x.report("max")   { Array.new(n) { rand(n + 1) }.max }
end
```

`Benchmark.measure` 返回一个 `Tms` 对象，包含字段：`u`（用户态 CPU 时间）、`s`（系统态 CPU 时间）、`r`（实际墙钟时间）。`r` 是最重要的，因为它反映了真实的等待时间。

`Benchmark.bm` 在多个方案间做对比。参数 `16` 是标签列的宽度。输出按行对齐，方便对比。

`Benchmark.bmbm` 在做真实测量前先执行一轮 rehearse（排练），消除首次运行的 JIT 预热和缓存效应。这是最精确的对比方式：

```ruby
Benchmark.bmbm(16) do |x|
  x.report("plus")   { sum = 0; 10_000.times { |i| sum += i } }
  x.report("reduce") { (0...10_000).reduce(:+) }
end
```

bmbm 输出两组数据，下面是正式的对比结果，排除了首次运行的偏差。

## 字符串拼接优化

字符串操作是最常见的性能瓶颈之一。Ruby 中有多种拼接方式：

```ruby
n = 10_000
Benchmark.bm(18) do |x|
  # 方式1：+= 每次创建新字符串（最慢）
  x.report("+= concat") do
    s = ""
    n.times { |i| s += "line#{i} " }
  end

  # 方式2：Array#join 预缓冲后一次性连接
  x.report("array.join") do
    arr = Array.new(n) { |i| "line#{i}" }
    arr.join(" ")
  end

  # 方式3：<< 追加到原字符串（最快之一）
  x.report("<< append") do
    s = String.new(capacity: n * 7)
    n.times { |i| s << "line#{i} " }
  end
end
```

结果规律很明确。`+=` 最差，因为每次拼接都创建新字符串，旧字符串需要 GC 回收。`Array#join` 和 `<<` 都远优于 `+=`。`String.new(capacity:)` 预分配缓冲区能进一步减少内存分配。

实际建议：少量字符串拼接用 `+`，中等量用 `<<`，大量或循环中用 `Array#join`。

## Enumerable 性能对比

不同的 Enumerable 方法在性能上有差异：

```ruby
n = 100_000
data = Array.new(n) { rand(1000) }

Benchmark.bm(22) do |x|
  # 创建新数组
  x.report("map (new array)") { data.map { |i| i * 2 } }

  # 原地修改
  x.report("map! (in-place)") { data.dup.map! { |i| i * 2 } }

  # 构建 hash
  x.report("each_with_object") { data.each_with_object({}) { |i, h| h[i] = i * 2 } }

  x.report("each + hash assign") { h = {}; data.each { |i| h[i] = i * 2 } }
end
```

`map!` 比 `map` 快，因为不创建新数组。`each_with_object` 和 `each + hash assign` 速度接近，但前者语义更清晰。

## 对象分配分析

`ObjectSpace.count_objects` 可以统计当前堆中各类型对象的数量。结合 `GC.stat` 可以分析 GC 行为：

```ruby
require "objspace"

# 统计创建对象的数量
count_before = ObjectSpace.count_objects[:T_STRING]
10_000.times { |i| "object_#{i}".upcase }
count_after = ObjectSpace.count_objects[:T_STRING]
puts "循环创建字符串: 新增 ~#{count_after - count_before} 个 T_STRING"

# 复用 buffer 减少分配
buffer = String.new
count_before = ObjectSpace.count_objects[:T_STRING]
10_000.times do |i|
  buffer.clear
  buffer << "object_#{i}"
  buffer.upcase
end
count_after = ObjectSpace.count_objects[:T_STRING]
puts "复用 buffer:    新增 ~#{count_after - count_before} 个 T_STRING"
```

复用一个 buffer 字符串，比每次创建新的字符串减少大量 T_STRING 分配。对于热点路径上的代码，这种优化效果显著。

## GC 统计

`GC.stat` 返回垃圾回收的详细统计：

```ruby
stats = GC.stat
puts "GC 运行次数: #{stats[:count]}"
puts "GC 总耗时: #{stats[:total_time].round(4)}s"
puts "活跃对象数: #{stats[:heap_live_slots]}"
puts "空闲对象数: #{stats[:heap_free_slots]}"
puts "新分配对象数: #{stats[:heap_allocated_slots]}"
```

监控这些指标可以帮助判断性能瓶颈是否是 GC 压力过大。如果 `total_time` 占比很大，说明 GC 频繁运行，可能需要减少对象分配。

## 字符串冻结优化

Ruby 3.0 默认启用了 `frozen_string_literal: true`。冻结的字符串字面量在内存中只有一份拷贝，相同内容共享同一对象：

```ruby
# frozen_string_literal: true

s1 = "hello_ruby"
s2 = "hello_ruby"
puts s1.object_id == s2.object_id  # true，共享内存

手动冻结也一样:
s3 = "manual_freeze".freeze
s4 = "manual_freeze".freeze
puts s3.object_id == s4.object_id  # true
```

冻结字符串减少内存占用，也避免了不必要的 dup 操作。这是 Ruby 3.x 最重要的内存优化之一。

## 惰性 vs 立即求值

当处理大数据集时，惰性的 `lazy` 可以大幅减少计算量：

```ruby
n = 1_000_000

Benchmark.bm(22) do |x|
  # 立即求值
  x.report("eager chain") do
    (1..n).map { |i| i * 2 }.select(&:even?).take(10)
  end

  # 惰性求值
  x.report("lazy chain") do
    (1..n).lazy.map { |i| i * 2 }.select(&:even?).take(10).force
  end
end
```

立即求值的链路是：map 处理全部 100 万个元素 → select 过滤 → take 取 10 个。惰性求值的链路是：逐元素流过 map → select → take，取够 10 个后整个链路的计算全部停止。

处理大规模或无限数据时，`lazy` 带来的性能提升不是线性的，而是数量级的。

## Array 预分配

动态扩容的数组在每次容量不足时都要重新分配内存并复制数据。预分配可以避免这个开销：

```ruby
n = 50_000
Benchmark.bm(14) do |x|
  x.report("push dynamic") { arr = []; n.times { |i| arr << i } }
  x.report("pre-allocated") { arr = Array.new(n) { |i| i } }
end
```

预分配在数据量大于 10 万条时效果明显。数据量小时差异不大，可以优先考虑代码可读性而非性能。

## map vs map!

`map` 创建新数组，`map!` 原地修改。两者的性能差异在于内存分配：

```ruby
data = Array.new(100_000) { rand(1000) }

# map: 分配新数组 + 遍历
result = data.map { |i| i * 2 }  # 原始 data 不变

# map!: 原地修改，不分配新数组
data.map! { |i| i * 2 }          # data 被修改
```

如果不需要保留原始数组，用 `map!` 减少内存分配。如果需要保留原始数据，用 `map`。这是一个安全性和性能之间的权衡。

## 热路径优化原则

性能优化的黄金法则是：先测量，再优化。盲目猜测瓶颈位置往往猜错。以下是经过验证的通用优化策略：

1. **减少中间对象分配**。每次 `map`、`select` 都创建新数组。用 `map!`、`lazy`、原地操作减少分配。
2. **字符串用 `<<` 或 `join`**。不要用 `+=`。大字符串用 `String.new(capacity:)` 预分配。
3. **数组预分配**。已知大小时用 `Array.new(n)` 而非空的 `<<`。
4. **用 `lazy` 处理大数据集**。当最终结果远小于数据集时，惰性求值减少大量不必要的计算。
5. **冻结字符串**。`frozen_string_literal: true` 是默认推荐，共享内存减少分配。
6. **用 `reduce(:+)` 求和**。比手动循环和 `each` 构建中间结果更快。

优化之前始终用 `Benchmark.bmbm` 测量，确保优化确实带来了提升。

## 本章要点

- **Benchmark.measure** 测量单次执行时间，**bm** 对比多个方案，**bmbm** 带排练预热
- **ObjectSpace.count_objects** 按类型统计堆内对象数，分析内存分配
- **GC.stat** 提供 GC 运行次数、总耗时、活跃/空闲对象数
- **字符串拼接**：`<<` 和 `Array#join` 远优于 `+=`
- **惰性求值 lazy** 处理大数据集时只需计算到结果满足即可停止
- **字符串冻结** 共享相同内容的内存，减少重复对象
- **数组预分配** `Array.new(n)` 减少动态扩容的内存重新分配
- **map! 原地修改** 比 map 创建新数组少一次内存分配
- 优化原则：先测量找到瓶颈，再针对性优化，最后再测量验证效果
- 运行 `hello advance performance` 查看完整性能测量和对比演示
