# 方法定义与调用

## 开篇故事

方法是代码的组织单元。一段重复的逻辑，把它放进方法里，起个名字，以后调名字就行了。Ruby 的方法特别灵活——支持默认参数、关键字参数、参数解构、块传递。本章不讲 `def` 语法（基础中的基础），而是深入 Ruby 方法的高级特性。

## 本章适合谁

如果你写 Ruby 代码时遇到过以下情况，本章适合你：

- "这个方法参数太多了，调用时容易搞混"
- "我想传未知数量的参数"
- "我想把一段代码逻辑当成参数传给方法"

## 你会学到什么

1. Lambda 作为方法对象
2. 默认参数值
3. 关键字参数
4. 参数解构（*args / **kwargs）
5. 块捕获（&block）
6. Proc.new vs lambda 的 return 行为差异

## 前置要求

- [控制流](control-flow.md) — 基础条件判断

## 第一个例子

```ruby
# 运行: hello basic methods

greet = ->(name) { "Hello, #{name}!" }
puts greet.call("Ruby")
# 输出: Hello, Ruby!
```

本章用 Lambda 来做演示。在 Ruby 中，lambda 是一种一等公民的方法对象，可以赋值给变量、作为参数传递、作为返回值返回。

## 默认参数值

```ruby
greet_default = ->(name = "World") { "Hi, #{name}!" }
puts greet_default.call         # "Hi, World!"
puts greet_default.call("Alice") # "Hi, Alice!"
```

**和 Python 的区别**：Ruby 的默认参数也是从左到右计算，和 Python 一样。

## 关键字参数

```ruby
create_url = ->(host:, port:, path: "/") { "#{host}:#{port}#{path}" }
puts create_url.call(host: "localhost", port: 8080)
# → "localhost:8080/"

puts create_url.call(host: "localhost", port: 3000, path: "/api/v1")
# → "localhost:3000/api/v1"
```

关键字参数的优势：**调用顺序无关紧要，且语义明确**：

```ruby
# 顺序无关
create_url.call(port: 8080, host: "localhost", path: "/")  # 一样

# 比位置参数更清晰
create_url.call("localhost", 8080, "/")  # 这三个参数是什么意思？
```

## 位置参数捕获 — Splat *

```ruby
# 捕获所有额外参数
collect_args = ->(*args) { "收到 #{args.length} 个参数: #{args.inspect}" }
puts collect_args.call(1, 2, 3, 4)
# → "收到 4 个参数: [1, 2, 3, 4]"

# Splat 解构赋值
first, *rest = [1, 2, 3, 4, 5]
puts "首元素: #{first}, 其余: #{rest.inspect}"
# → 首元素: 1, 其余: [2, 3, 4, 5]
```

## 关键字参数捕获 — Double Splat **

```ruby
collect_kwargs = ->(**kwargs) { "选项: #{kwargs.inspect}" }
puts collect_kwargs.call(color: "red", size: "large", active: true)
# → "选项: {:color=>\"red\", :size=>\"large\", :active=>true}"
```

## 块捕获 &block

```ruby
repeater = ->(n, &block) { n.times { |i| puts "  第 #{i + 1} 次: #{block.call(i)}" } }

repeater.call(3) { |i| "迭代 #{i}" }
# 输出:
#   第 1 次: 迭代 0
#   第 2 次: 迭代 1
#   第 3 次: 迭代 2
```

`&block` 将传入的匿名 block 转换为一个 Proc 对象，可以在方法内自由传递、存储、延迟调用。

## Proc.new vs lambda 的核心差异

这也是 Ruby 中经常混淆的问题。

### 差异 1：参数检查（Arity）

```ruby
# Lambda 严格检查参数数量
strict_lambda = ->(a, b) { a + b }
strict_lambda.call(1, 2)    # 3 ✅
strict_lambda.call(1)       # ❌ ArgumentError

# Proc.new 宽松处理
loose_proc = Proc.new { |a, b| "a=#{a.inspect}, b=#{b.inspect}" }
loose_proc.call(1, 2, 3)    # "a=1, b=2"（忽略多余参数）
loose_proc.call(1)          # "a=1, b=nil"（缺失参数填 nil）
```

### 差异 2：return 行为

```ruby
# Proc.new 的 return 跳出整个外部方法！
outer = -> do
  p = Proc.new { return "从 Proc.new 直接跳出外部方法！" }
  p.call
  "这行不会执行"    # ← 永远不会到这里
end
# 输出: "从 Proc.new 直接跳出外部方法！"

# Lambda 的 return 仅从 lambda 自身返回
outer2 = -> do
  l = lambda { return "仅从 lambda 返回" }
  result = l.call
  "lambda 返回了: '#{result}'，继续执行"  # ← 会到这里
end
# 输出: "lambda 返回了: '仅从 lambda 返回'，继续执行"
```

**记忆口诀**：`Proc.new` 的 return 是"跳楼逃生"，`lambda` 的 return 是"关门退出"。

## 常见错误

### 错误 1：关键字参数漏传必传参数

```ruby
create_url = ->(host:, port:) { "#{host}:#{port}" }
create_url.call(host: "localhost")  # ❌ missing keyword: :port
```

**修复**：给关键字参数设置默认值，或在调用时传全部必传的。

### 错误 2：混淆 * 和 **

```ruby
# ❌ 把哈希作为 *args 传入
def show(*args)
  puts args.inspect  # [{:color=>"red"}] — 哈希被当成数组元素
end
show(color: "red")

# ✅ 应该用 **kwargs
def show(**kwargs)
  puts kwargs.inspect # {:color=>"red"} — 直接解构为哈希
end
show(color: "red")
```

### 错误 3：用 Proc.new 时意外 return

```ruby
def process
  items.each do |item|
    Proc.new { return "提前退出" }.call  # ❌ 直接退出整个 process 方法
    puts "后处理"  # 永远不会执行
  end
  "正常结束"
end
```

**修复**：用 lambda 或 `next`。

## 动手练习

### 练习 1：通用日志方法

```ruby
# 写一个 log 方法：支持任意位置参数、关键字参数、块
# 调用示例：log("msg", level: :warn) { "extra info" }
```

<details>
<summary>参考答案</summary>

```ruby
def log(*args, **kwargs, &block)
  puts "Args: #{args.inspect}"
  puts "Keywords: #{kwargs.inspect}"
  puts "Block result: #{block.call if block}"
end

log("hello", level: :warn) { "extra" }
```

</details>

### 练习 2：参数解构

```ruby
# 用 * 解构赋值：从 [10, 20, 30, 40, 50] 提取首、尾、中间元素
```

<details>
<summary>参考答案</summary>

```ruby
first, *middle, last = [10, 20, 30, 40, 50]
# first=10, middle=[20, 30, 40], last=50
```

</details>

## 故障排查 (FAQ)

### Q: 什么时候用 lambda，什么时候用 Proc.new？

**A**: 
- **用 lambda**：需要严格参数检查、return 只退出自身（大多数场景）
- **用 Proc.new**：需要宽松的 arity、需要 return 跳出外部方法（少见）

### Q: `&block` 和 `yield` 有什么区别？

**A**: `yield` 隐式调用块（更快，但块不能存储）；`&block` 显式捕获为 Proc（可以存储、传递）。块只能被 yield 调用一次的方法用 yield；需要存储块的方法用 `&block`。

### Q: 关键字参数可以设置默认值吗？

**A**: 可以。`def method(key: "default")`。没有默认值的关键字参数是必传的。

## 小结

**核心要点**：

1. **默认参数简化调用**：常见场景有合理默认值
2. **关键字参数提高可读性**：参数多时强烈推荐
3. **`*args` 捕获位置参数**，`**kwargs` 捕获关键字参数
4. **`&block` 将块转为 Proc**：可存储、传递、延迟调用
5. **Proc.new 和 lambda 行为不同**：arity 检查和 return 语义是关键差异
6. **方法参数顺序**：位置参数 → splat → 关键字 → double splat → 块

**术语**：

- **Lambda**：严格模式的方法对象
- **Proc**：宽松的块对象
- **Arity（元数）**：方法所需的参数数量
- **Splat（*）**：打包/解包位置参数
- **Double Splat（**）**：打包/解包关键字参数
- **Block Capture（块捕获）**：`&block` 将匿名块转为 Proc

## 继续学习

- **上一章**: [控制流](control-flow.md)
- **下一章**: [类与对象](classes.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic methods` 查看完整示例代码。