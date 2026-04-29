# 异常处理

## 开篇故事

程序运行的过程就是不断出错和恢复的过程。文件找不到、网络超时、除数为零、格式不对——异常无处不在。Ruby 的异常处理不是用来掩盖错误的，而是让你在错误发生时优雅地恢复，或者把错误信息传递清楚。

## 本章适合谁

如果你想写出健壮的程序，能够妥善处理意外情况，而不是在遇到错误时直接崩溃，本章是必读内容。

## 你会学到什么

1. begin / rescue / ensure 结构
2. 捕获多种异常类型
3. retry — 重新执行
4. raise — 主动抛出异常
5. rescue 修饰符
6. else 块
7. 异常层级

## 前置要求

- [类与对象](classes.md) — 类继承概念

## 第一个例子

```ruby
# 运行: hello basic exceptions

begin
  10 / 0
rescue ZeroDivisionError => e
  puts "捕获: #{e.class} — #{e.message}"
end
# 输出: 捕获: ZeroDivisionError — divided by 0
```

**和 Java 的 try/catch 对比**：Ruby 的 `begin/rescue` 和 Java 的 `try/catch` 概念相似，但 Ruby 的 rescue 更简洁——不需要包裹整个方法，可以只包裹可能出错的行。

## begin / rescue / ensure

```ruby
result = begin
  raise "出错了！"
ensure
  puts "ensure 块执行（用于清理资源）"
end

puts "最终结果: #{result.inspect}"
# ensure 块不管有没有异常都会执行
```

## 捕获多种异常类型

```ruby
begin
  # 可能产生不同异常的代码
  Exceptions.divide(10, 0)
rescue Hello::ValidationError => e
  puts "自定义异常: #{e.message}"
rescue StandardError => e
  puts "其他错误: #{e.message}"
end
```

## ensure — 总是执行

```ruby
f = File.open("data.txt")
begin
  content = f.read
  process(content)
ensure
  f.close  # 不管有没有异常都会关闭文件
end
```

**更 Ruby 的写法**：用 `File.open` 的块模式，它内部有 ensure。

## rescue 修饰符（单行）

```ruby
value = undefined_variable rescue "变量不存在，用默认值"
safe = Integer("not_a_number") rescue 0
```

**何时使用**：处理简单、可预期的异常。不适用于需要详细错误信息的场景。

## retry — 重新执行

```ruby
attempts = 0
max_retries = 3

begin
  attempts += 1
  puts "第 #{attempts} 次尝试..."
  raise "模拟失败" unless attempts >= max_retries
  puts "成功！"
rescue
  retry if attempts < max_retries
end
```

**警告**：`retry` 会重新执行整个 `begin` 块。如果逻辑复杂，建议用循环代替。

## else 块

```ruby
begin
  puts "正常代码"
rescue
  puts "有异常"
else
  puts "else：没有异常，执行这里"
ensure
  puts "ensure：总是执行"
end
```

`else` 块在没有异常时执行，`rescue` 之后、`ensure` 之前。

## 主动抛出异常

```ruby
def divide(a, b)
  raise Hello::ValidationError, "除数不能为零" if b == 0
  a / b
end
```

## 异常层级

```
Exception
├── NoMemoryError
├── ScriptError
│   ├── SyntaxError
│   └── LoadError
├── SecurityError
├── SignalException
└── StandardError  ← rescue 默认捕获这里
    ├── ArgumentError
    ├── IOError
    ├── IndexError
    ├── KeyError
    ├── NoMethodError
    ├── RuntimeError
    ├── TypeError
    └── ZeroDivisionError
```

**关键理解**：`rescue` 默认捕获 `StandardError` 及其子类。如果不加类型，只捕获 `StandardError`。要捕获所有异常，用 `rescue Exception`（通常不推荐）。

## 常见错误

### 错误 1：bare rescue — 不带类型

```ruby
# ❌ 这会捕获 StandardError 及其所有子类，包括 SystemExit！
begin
  do_something
rescue
  puts "出错了"
end

# ✅ 明确指定异常类型
begin
  do_something
rescue StandardError => e
  puts "出错了: #{e.message}"
end
```

### 错误 2：忽略异常信息

```ruby
# ❌ 吞掉错误，调试时毫无头绪
begin
  do_something
rescue
  nil  # 错误被静默吃掉了
end

# ✅ 至少记录或传递
begin
  do_something
rescue => e
  logger.error "do_something failed: #{e.message}"
  raise  # 重新抛出
end
```

### 错误 3：用异常做流程控制

```ruby
# ❌ 异常不是用来做条件判断的
begin
  user = User.find(id)
rescue ActiveRecord::RecordNotFound
  user = nil
end

# ✅ 用条件判断
user = User.find_by(id: id)
```

## 动手练习

### 练习 1：安全解析

写一个 `safe_parse_int(str)` 方法，解析失败时返回 nil 而不是抛异常。

<details>
<summary>参考答案</summary>

```ruby
def safe_parse_int(str)
  Integer(str)
rescue ArgumentError, TypeError
  nil
end
```

</details>

### 练习 2：自定义异常

```ruby
class InsufficientFundsError < StandardError
  attr_reader :balance, :amount

  def initialize(balance, amount)
    @balance = balance
    @amount = amount
    super("余额 #{balance} 不足，需要 #{amount}")
  end
end

# 测试
begin
  balance = 100
  amount = 200
  raise InsufficientFundsError.new(balance, amount) if amount > balance
rescue InsufficientFundsError => e
  puts e.message
end
```

<details>
<summary>运行结果</summary>

```
余额 100 不足，需要 200
```

</details>

## 故障排查 (FAQ)

### Q: rescue 不指定异常类型时会捕获什么？

**A**: `StandardError` 及其子类。**不会**捕获 `SyntaxError`、`LoadError` 等。大多数运行时错误都是 `StandardError` 的子类。

### Q: `rescue => e` 和 `rescue StandardError => e` 一样吗？

**A**: 不完全一样。前者的默认类型取决于所在上下文（方法体内的默认类型）。在方法体内，`rescue => e` 等价于 `rescue StandardError => e`。

### Q: retry 和循环有什么区别？

**A**: `retry` 重新执行整个 begin 块，包括块内的所有初始化。循环只在循环体内部。如果逻辑简单，用循环；如果需要重新初始化，用 retry。

## 小结

**核心要点**：

1. **begin/rescue/ensure 是基础结构**：像 Java 的 try/catch/finally
2. **明确指定异常类型**：不要用 bare rescue
3. **ensure 总是执行**：用于清理资源
4. **rescue 修饰符用于简单场景**：`value = risky() rescue default`
5. **raise 主动抛出**：自定义异常类继承 `StandardError`
6. **rescue 默认捕获 StandardError**：不是 Exception
7. **异常不是流程控制工具**：能用条件判断时不要用异常

**术语**：

- **Exception（异常）**：程序运行时的错误事件
- **Catch（捕获）**：使用 rescue 处理异常
- **Raise（抛出）**：主动触发异常
- **Ensure（确保）**：无论是否有异常都执行的代码
- **Retry（重试）**：重新执行 begin 块
- **Bare Rescue（裸 rescue）**：不指定异常类型的 rescue

## 继续学习

- **上一章**: [文件 I/O](file-io.md)
- **下一章**: [数字与数值运算](numbers.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic exceptions` 查看完整示例代码。
