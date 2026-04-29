# Enumerable 深度探索

任何 Ruby 开发者都会频繁使用 `map`、`select`、`reduce`。大多数教程到此为止。但 Enumerable 的能力远不止这些基础方法。深入理解 Enumerable，你可以构建自定义集合类、实现惰性无限序列、用高级遍历方法替代手动循环。

Enumerable 是 Ruby 标准库中最被低估的模块之一。它只需要一个 `each` 方法就能提供超过 50 个集合操作方法。这一章带你挖掘 Enumerable 的全部潜力。

运行 `hello advance enumerable` 可以查看完整演示代码。

## 自定义 Enumerable 类

Enumerable 是一个 mixin 模块。只要你的类实现了 `each` 方法并 `include Enumerable`，就自动获得所有集合操作能力：

```ruby
class TemperatureReadings
  include Enumerable

  def initialize(locations)
    @data = locations
  end

  def each(&block)
    @data.each(&block)
  end

  # Enumerable 提供的能力：
  def average
    map { |_, temp| temp }.reduce(0, :+) / count
  end

  def hottest
    max_by { |_, temp| temp }
  end

  def coldest
    min_by { |_, temp| temp }
  end
end

readings = TemperatureReadings.new([
  ["北京", 28], ["上海", 32], ["广州", 35],
  ["哈尔滨", 18], ["成都", 26], ["武汉", 33]
])

puts "平均气温: #{readings.average}°C"       # 29
puts "最热: #{readings.hottest[0]}"           # 广州
puts "过热城市: #{readings.select { |_, t| t > 30 }.map(&:first).join(', ')}"
# 过热城市: 上海, 广州, 武汉
```

核心规则就是：实现 `each`，`include Enumerable`，获得一切。这个模式在 Ruby 中被称为"最小接口，最大能力"。

## 惰性求值与无限序列

普通的 `map`、`select` 会立即遍历整个集合并创建新数组。对于大型集合，这意味着大量的中间对象分配。`lazy` 方法改变了这种行为：它返回一个惰性 Enumerable，只在需要时才计算元素。

```ruby
# 无限斐波那契数列
fib = Enumerator.new do |yielder|
  a = 0
  b = 1
  loop do
    yielder << a
    a, b = b, a + b
  end
end

# 惰性操作：取 > 100 的前 3 个偶数
# 不会导致无限循环！take(3) 后停止计算
result = fib.lazy.select { |n| n > 100 && n.even? }.take(3).force
puts result.inspect  # [144, 987, 6765]
```

`force` 方法将惰性序列转为普通数组。在调用 `force` 之前，链路上的所有操作都不会实际执行。这是处理大数据集的标准做法。

惰性求值的另一个优势是性能：

```ruby
large_range = (1..1_000_000)

# 立即求值：map 先处理 100 万个元素，select 再过滤
result1 = large_range.map { |n| n * 3 }.select(&:even?).take(5)

# 惰性求值：逐元素流过 map → select → take，取够 5 个后停止
result2 = large_range.lazy.map { |n| n * 3 }.select(&:even?).take(5).force

puts result1 == result2  # true，结果相同
# 但惰性方式只处理了约 10 个元素，立即方式处理了 100 万个
```

当你处理的数据集远大于最终结果时，`lazy` 会带来数量级的性能提升。

## minmax_by：一次遍历获最值

`minmax_by` 在一次遍历中同时找出最小值和最大值。比分别调用 `min_by` 和 `max_by` 少遍历一次，对于大数据集能省一半的时间。

```ruby
words = %w[apple banana cherry date elderberry fig grape]
shortest, longest = words.minmax_by(&:length)
puts "最短: #{shortest}, 最长: #{longest}"
# 最短: fig, 最长: elderberry

# 按自定义规则比较
numbers = [15, 3, 42, 7, 28, 1]
min_max = numbers.minmax_by { |n| Math.sqrt(n) }
puts "平方根最小/最大: #{min_max}"  # [1, 42]
```

`minmax`（不带 `_by`）是按元素自身的默认比较。`minmax_by` 是按你提供的转换函数的结果比较。两者都在一次遍历中完成。

## chunk_while：按条件分组

`chunk_while` 根据相邻元素之间的关系将序列分段。这对于按自然断点分组数据非常有用。

```ruby
numbers = [1, 2, 3, 5, 6, 8, 10, 11, 12]
groups = numbers.chunk_while { |a, b| b == a + 1 }.to_a
puts groups.inspect
# [[1, 2, 3], [5, 6], [8], [10, 11, 12]]
# 把连续的数字分成一组

# 按奇偶分组
parity = [1, 3, 5, 2, 4, 7, 9, 11].chunk_while do |a, b|
  (a.odd? && b.odd?) || (a.even? && b.even?)
end.to_a
puts parity.inspect
# [[1, 3, 5], [2, 4], [7, 9, 11]]
```

`chunk_while` 接收一个条件块，当相邻两个元素满足条件时，它们属于同一组。这个模式在处理日志、时间序列、连续事件时非常常见。

## slice_after：按标记分割

`slice_after` 在匹配条件的元素之后将序列切开。常用于按标题分割文档、按分隔符分割日志等场景。

```ruby
mixed = ["# 标题", "内容1", "内容2", "# 章节", "内容3", "# 结束"]
sections = mixed.slice_after(/^#/).to_a

sections.each_with_index do |section, i|
  puts "段#{i}: #{section.inspect}"
end
# 段0: ["# 标题", "内容1", "内容2"]
# 段1: ["# 章节", "内容3"]
# 段2: ["# 结束"]
```

类似的还有 `slice_before`（在匹配之前切开）和 `slice_when`（条件变化时切开）。这三个方法覆盖了大多数基于标记的分组需求。

## grep_v：反向匹配

`grep_v` 是 `grep` 的反面，返回不匹配模式的元素。`grep` 用 `===` 运算符测试匹配，`grep_v` 取反。

```ruby
words = %w[hello world ruby programming rust c golang python]
long_words = words.grep_v(/^. {0,5}$/)
puts long_words.join(", ")
# ruby, programming, golang, python

emails = %w[user@example.com admin@test.org not_an_email root@localhost]
invalid = emails.grep_v(/@.*\./)
puts "无效邮件: #{invalid.join(', ')}"
# not_an_email
```

`grep` 和 `grep_v` 支持正则表达式、类、范围等任何实现了 `===` 的对象，比 `select { |x| x =~ pattern }` 更简洁。

## Enumerable 方法全景图

只要实现了 `each`，你就自动获得以下方法：

**过滤和筛选：** `select/filter`、`reject`、`grep`、`grep_v`、`take`、`take_while`、`drop`、`drop_while`、`first`、`compact`

**聚合和统计：** `reduce/inject`、`count`、`min/max/minmax`、`min_by/max_by/minmax_by`、`sum`

**分组和排序：** `sort/sort_by`、`group_by`、`chunk`、`chunk_while`、`slice_after`、`slice_before`、`slice_when`、`partition`

**遍历和操作：** `map/collect`、`flat_map/collect_concat`、`each_cons`、`each_slice`、`each_with_index`、`each_with_object`、`zip`

**查询：** `any?`、`all?`、`none?`、`one?`、`include?`、`find/detect`、`find_index`

**转换：** `to_a`、`to_h`、`tally`、`cycle`、`entries/to_enum`

**惰性：** `lazy`、`eager`

完整的 Enumerable 提供约 50 个方法。掌握它们意味着你不再需要手动编写大量的 `for` 循环和 `if` 条件。用声明式的方式描述"我要什么"，而不是"怎么得到"。

## 本章要点

- **include Enumerable** 只需实现 `each`，获得 50+ 集合方法
- **lazy** 实现惰性求值，可以安全操作无限序列
- **minmax_by** 一次遍历同时找到最小和最大值
- **chunk_while** 根据相邻元素关系分组
- **slice_after** 按标记将序列分段
- **grep/grep_v** 使用 `===` 进行正向/反向匹配
- **tally** 统计元素频次，**to_h** 将键值对转为 Hash
- Enumerable 将命令式循环转换为声明式表达式，代码更短、更安全
- 运行 `hello advance enumerable` 查看完整示例
