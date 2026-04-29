# 块与 Proc

## 开篇故事

块（Block）是 Ruby 的灵魂。没有块，Ruby 就只是一门普通的面向对象语言；有了块，Ruby 变成了一门优雅的函数式混合语言。Rails 的路由配置、RSpec 的测试描述、ActiveRecord 的链式查询——都建立在块的基础上。理解块，才能真正理解 Ruby。

## 本章适合谁

如果你想写出地道的 Ruby 代码，理解 Ruby 生态中最常见的设计模式，本章不可跳过。

## 你会学到什么

1. Block 的基本用法和 yield 机制
2. Proc — 将块变为对象
3. Lambda — 更严格的 Proc
4. Proc.new vs Lambda 的核心差异
5. 回调与函数组合模式
6. Symbol#to_proc 速记法

## 前置要求

- [方法定义与调用](methods.md) — 参数基础

## 第一个例子

```ruby
# 运行: hello basic blocks-procs

# 块是最核心的 Ruby 特性
[1, 2, 3].each { |n| print "#{n * 10} " }
# 输出: 10 20 30
```

**为什么这很 Ruby**：`each` 方法本身不知道你要对每个元素做什么。你把逻辑写成 `{ |n| ... }` 传给 `each`，`each` 负责遍历，块负责处理。这是经典的策略模式。

## Block — 方法的隐式伙伴

Block 不是参数，是方法的隐式搭档。方法通过 `yield` 调用块：

```ruby
def repeat(n)
  n.times do |i|
    yield(i)  # 调用传入的块
  end
end

repeat(3) { |i| puts "第 #{i + 1} 次" }
# 输出:
# 第 1 次
# 第 2 次
# 第 3 次
```

**yield 的开销极低**：隐式 yield 比显式 `&block` 快。如果只需要调用块一次或几次，用 yield。

## Proc — 一等公民的块

Proc 让块变成可以存储、传递的对象：

```ruby
my_proc = Proc.new { |x| x * 2 }

# Proc 支持 .(), .call, .yield, [] 四种调用方式
puts my_proc.call(5)   # 10
puts my_proc[10]       # 20
puts my_proc.(15)      # 30
```

**什么时候需要 Proc**：

1. 需要把块存储到变量中
2. 需要把块作为参数传给另一个方法
3. 需要块作为方法的返回值

## Lambda — 更严格的 Proc

```ruby
my_lambda = ->(x) { x * 2 }
# 等价于: lambda { |x| x * 2 }

puts my_lambda.call(5)   # 10
puts my_lambda.class      # Proc
```

Lambda 和 Proc 都是 Proc 类的实例，但行为有差异。

## Proc.new vs Lambda 的核心差异

### 差异 1：参数检查（Arity）

```ruby
# Lambda 严格检查
strict = ->(a, b) { a + b }
strict.call(1, 2)   # ✅ 3
strict.call(1)      # ❌ ArgumentError

# Proc.new 宽松
loose = Proc.new { |a, b| "a=#{a.inspect}, b=#{b.inspect}" }
loose.call(1, 2, 3) # "a=1, b=2"（多余参数忽略）
loose.call(1)       # "a=1, b=nil"（缺失填 nil）
```

### 差异 2：return 行为

```ruby
# Proc.new — return 跳出整个外部方法
outer = -> do
  p = Proc.new { return "Proc.new 的 return 直接跳出！" }
  p.call
  "这行不会执行"
end
# 输出: "Proc.new 的 return 直接跳出！"

# Lambda — return 只从 lambda 返回
outer2 = -> do
  l = lambda { return "仅从 lambda 返回" }
  result = l.call
  "lambda 继续运行: #{result}"
end
# 输出: "lambda 继续运行: 仅从 lambda 返回"
```

**记忆口诀**：Proc.new 是"跳楼逃生"，lambda 是"关门退出"。

## 回调模式

```ruby
retry_with_callback = ->(retries: 3, &on_attempt) {
  retries.times do |i|
    puts "尝试 #{i + 1}/#{retries}..."
    on_attempt.call(i + 1)
  end
}

retry_with_callback.call { |i| puts "  执行 #{i}" }
# 输出:
# 尝试 1/3...
#   执行 1
# 尝试 2/3...
#   执行 2
# 尝试 3/3...
#   执行 3
```

## 函数组合

```ruby
compose = ->(f, g) { ->(x) { f.call(g.call(x)) } }

add_one = ->(x) { x + 1 }
times_two = ->(x) { x * 2 }

add_then_double = compose.call(times_two, add_one)
puts add_then_double.call(5)
# → 12（5+1=6, 6*2=12）
```

## Symbol#to_proc 速记法

```ruby
%w[hello world].map(&:upcase)
# → ["HELLO", "WORLD"]

# :upcase 被自动调用 .to_proc 转为 Proc
# 等价于 %w[hello world].map { |s| s.upcase }
```

## 常见错误

### 错误 1：{} 和 do...end 的优先级

```ruby
# {} 优先级高于 do...end
# 以下两条不同：
arr.map { |x| x * 2 }.select(&:even?)  # 正确
arr.map do |x| x * 2 end.select(&:even?)  # ❌ 语法错误
```

**惯例**：单行块用 `{}`，多行块用 `do...end`。

### 错误 2：用 Proc.new 意外 return

```ruby
def process
  items.each do |item|
    Proc.new { return "退出" }.call  # 直接退出整个方法
  end
end
```

**修复**：大多数情况下用 lambda。

### 错误 3：块变量泄漏

```ruby
[1, 2, 3].each { |n| temp = n * 2 }
puts temp  # 在 Ruby 2.0+ 中不会泄漏
```

块变量作用域仅限于块内部（Ruby 2.0+）。Ruby 1.9 之前块变量会泄漏到外层。

## 动手练习

### 练习 1：实现 retry_with_callback

```ruby
# 写一个 retry 方法：
# retry(3) { 可能失败的代码块 }
# 如果块抛异常，重试，最多 3 次
```

<details>
<summary>参考答案</summary>

```ruby
def retry(max_times = 3)
  max_times.times do |attempt|
    begin
      return yield  # 成功则直接返回
    rescue => e
      puts "第 #{attempt + 1} 次失败: #{e.message}"
      raise if attempt == max_times - 1  # 最后一次失败则抛出
    end
  end
end

retry(3) { 
  # 模拟可能失败的代码
  rand > 0.5 ? "成功" : raise("失败")
}
```

</details>

### 练习 2：currying

```ruby
# Currying：把多参数函数转换为单参数函数的嵌套
# add = ->(a, b) { a + b }
# add_five = add.curry.(5)
# add_five.(3)  # → 8
```

<details>
<summary>参考答案</summary>

```ruby
add = ->(a, b) { a + b }
add_five = add.curry.(5)
puts add_five.(3)  # 8
```

</details>

## 故障排查 (FAQ)

### Q: yield 和 &block 什么时候用？

**A**: 
- **yield**：只需要调用一次或几次，性能好
- **&block**：需要存储、传递、延迟调用

### Q: Lambda 和 Proc.new 到底用哪个？

**A**: 默认用 lambda。它的行为更可预测——参数检查和局部 return 符合直觉。Proc.new 的特殊行为只在少数场景需要（如 DSL 中需要 return 跳出外部方法）。

### Q: 块和闭包是一回事吗？

**A**: Ruby 的块都是闭包。它们捕获定义时的上下文（外部变量），在调用时仍可访问。

## 小结

**核心要点**：

1. **Block 是 Ruby 的灵魂**：yield 调用，方法不需要显式声明
2. **Proc 让块变成对象**：可存储、传递、延迟调用
3. **Lambda 是严格的 Proc**：参数检查、局部 return
4. **Proc.new return 跳出外部方法**——小心使用
5. **Symbol#to_proc 是惯用速记**：`:upcase` 自动转 `{ |x| x.upcase }`
6. **块天然关闭**：捕获定义时的变量环境
7. **回调模式是 Ruby 的 API 设计精髓**：API 框架的基石

**术语**：

- **Block（块）**：方法隐式传递的代码段
- **Proc**：块的对象化
- **Lambda**：严格的 Proc（参数检查、局部 return）
- **Closure（闭包）**：捕获定义时上下文的代码块
- **Yield（产出）**：方法内部调用传入的块
- **Currying（柯里化）**：多参数函数转为单参数函数链
- **Arity（元数）**：方法需要的参数数量
- **to_proc**：转为 Proc 对象的协议

## 继续学习

- **上一章**: [模块与混入](modules.md)
- **下一章**: [文件 I/O](file-io.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic blocks-procs` 查看完整示例代码。
