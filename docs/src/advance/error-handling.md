# 错误处理模式

程序总会出错。网络超时、文件不存在、用户输入无效、数据库连接断开。如何处理这些错误，决定了程序的健壮性和可维护性。Ruby 提供了多层错误处理机制，从最基础的 rescue/catch 到函数式的 Result monad，每种方式适合不同的场景。

理解错误處理不仅是学会 rescue 语法，更是学会在系统中建立清晰的错误边界。这一章从安全导航到 Result monad，带你掌握 Ruby 中所有主流的错误处理模式。

运行 `hello advance error_handling` 可以查看完整演示代码。

## Safe Navigation Operator（&.）

Ruby 3.0 正式支持的 `&.` 运算符是处理"可能为 nil"的最简洁方式。它会在左侧为 nil 时跳过方法调用并返回 nil，而不是抛出 `NoMethodError`。

```ruby
config = { database: { host: "localhost", port: 5432 } }

# 传统方式：需要嵌套判断
host = config[:database] && config[:database][:host]

# safe navigation：简洁且语义清晰
host = config[:database]&.[](:host)

# 更简洁的方式：Hash#dig
host = config.dig(:database, :host)  # "localhost"

# nil 时安全返回 nil
host = config.dig(:cache, :host)     # nil，不抛异常
```

`&.` 最适合的场景是遍历嵌套结构，而 `dig` 最适合 Hash 的深层查找。两者的共同点是：不会在中间某个层次为 nil 时崩溃。

但 `&.` 不是万能的。如果一个对象不应该为 nil，使用 `&.` 反而会隐藏 bug。正确的做法是让 `NoMethodError` 暴露出来，然后在修复 bug 后移除 `&.`。`&.` 只适用于那些"nil 是合法值"的场景。

## Result Monad（函数式错误处理）

Ruby 传统的错误处理用 `raise/rescue`，这是命令式的。函数式编程中常用 Result monad 模式，把错误当成正常返回值的一部分：

```ruby
# 简化版 Result monad（纯 Ruby 实现）
success = ->(value) { { success: true, value: value } }
failure = ->(error) { { success: false, error: error } }

bind = ->(result, &handler) {
  return result unless result[:success]
  handler.call(result[:value])
}

# 可能失败的操作
parse_int = ->(str) {
  begin
    success.call(Integer(str))
  rescue ArgumentError => e
    failure.call(e.message)
  end
}

double = ->(n) { success.call(n * 2) }

# 链式操作
good = bind.call(parse_int.call("42"), &double)
puts good  # { success: true, value: 84 }

bad = bind.call(parse_int.call("abc"), &double)
puts bad   # { success: false, error: "invalid value for Integer()" }
```

`bind` 是 Result monad 的核心操作。它在 success 时执行下一步，在 failure 时短路传递错误。这种模式避免了异常控制流，让错误处理变得可见且类型安全。

实际项目中建议使用 `dry-monads` gem，它提供了完整的 Maybe、Result、Either 等函数式数据结构：

```ruby
require "dry/monads"

class CreateUser
  extend Dry::Monads[:result, :validation]

  def call(params)
    validate(params).bind do |valid_params|
      save(valid_params)
    end
  end

  def validate(params)
    # 返回 Success(valid_params) 或 Failure(errors)
  end

  def save(params)
    # 返回 Success(user) 或 Failure(error)
  end
end
```

Result monad 的核心价值是把"可能失败"这件事显式地编码在类型系统中。调用方一眼就能看出这个函数可能失败，而不需要通读文档或源码才知道有哪些异常需要处理。

## 异常层级树

Ruby 的异常体系是一个严格的继承树。理解这个层级是正确处理异常的前提：

```
Exception
├── StandardError（rescue 默认捕获）
│   ├── ArgumentError
│   ├── KeyError
│   ├── NoMethodError
│   ├── NameError
│   ├── TypeError
│   ├── RuntimeError
│   ├── FrozenError
│   └── ...
├── SignalException
├── SystemExit
└── Interrupt（Ctrl+C）
```

规则很简单：永远不要 `rescue Exception`。这样做会捕获 `SystemExit`（`exit` 方法）和 `Interrupt`（Ctrl+C），导致你的程序无法通过正常方式退出。

```ruby
# 错误示范
begin
  do_something
rescue Exception => e   # 永远不要这样做
  log_error(e)
end

# 正确示范
begin
  do_something
rescue StandardError => e  # 或简写为 rescue => e
  log_error(e)
end

# 如果你确实需要处理特定异常
begin
  do_something
rescue ArgumentError, TypeError => e
  handle_specific(e)
rescue StandardError => e
  handle_general(e)
end
```

rescue 不加参数时默认捕获 `StandardError`。大多数情况下这就是你想要的。如果你需要更细粒度的控制，先列出具体异常类型，最后再兜一个 `StandardError`。

## 清理模式：ensure 和 at_exit

有些操作必须在异常发生时也要执行。文件句柄需要关闭、网络连接需要断开、临时文件需要删除。`ensure` 块保证无论是否异常都会执行：

```ruby
resource_demo = -> {
  puts "  获取资源..."
  begin
    raise "处理失败"
  rescue
    puts "  捕获异常"
  ensure
    puts "  ensure: 释放资源（无论是否异常）"
  end
}
```

`ensure` 在 rescue 之后执行。即使没有 rescue 块，ensure 也会在执行完 begin 块后运行。这使得它成为资源清理的理想位置。

`at_exit` 是另一种清理模式，在程序退出时执行：

```ruby
at_exit do
  puts "程序退出，清理临时文件"
  FileUtils.rm_rf(Dir.tmpdir + "/myapp_*")
end
```

## 装饰器式错误处理

对于需要统一处理多个外部调用的场景，可以编写一个通用的错误处理装饰器：

```ruby
safe_call = ->(description, &block) {
  begin
    result = block.call
    puts "  ✓ #{description}: 成功"
    result
  rescue => e
    puts "  ✗ #{description}: #{e.class} - #{e.message}"
    nil
  end
}

# 使用方式
safe_call.call("请求 /api/users") { fetch_api("/api/users") }
safe_call.call("请求 /api/error") { fetch_api("/api/error") }
safe_call.call("计算 1/0") { 1 / 0 }
```

这种模式在批量处理外部调用时非常有用。它统一了错误日志格式，避免了每个调用处重复写 begin/rescue 块。

## 自定义异常

当内置异常类型不足以表达你的业务语义时，可以定义自定义异常类。Ruby 3.4 支持用 `Ruby::Enum` 定义带有固定取值的异常类型：

```ruby
class PaymentError < StandardError
  attr_reader :code, :message

  def initialize(code, message)
    @code = code
    @message = message
    super(message)
  end
end

class InsufficientFundsError < PaymentError
  def initialize(amount, balance)
    super(:insufficient_funds, "余额 #{balance} 不足支付 #{amount}")
  end
end

class InvalidCardError < PaymentError
  def initialize(card_last4)
    super(:invalid_card, "卡片尾号 #{card_last4} 已过期")
  end
end

# 使用时精确捕获
begin
  process_payment(100)
rescue InsufficientFundsError => e
  puts "退款原因: #{e.message} (代码: #{e.code})"
rescue InvalidCardError => e
  puts "卡片问题: #{e.message}"
rescue PaymentError => e
  puts "支付失败: #{e.message}"
end
```

自定义异常继承 `StandardError` 而不是 `Exception`。这是一个重要约定。这样其他人在用 `rescue => e` 捕获错误时不会漏掉你的异常。

## 本章要点

- **`&.`（Safe Navigation）** 在 nil 时安全跳过方法调用，`dig` 适合嵌套 Hash 查找
- **Result monad** 把错误编码为返回值，避免异常控制流
- **异常层级**：只 rescue `StandardError` 或其子类，永远不要 rescue `Exception`
- **ensure** 保证资源释放，`at_exit` 在程序退出时执行清理
- **装饰器模式** 用统一的 begin/rescue 块处理多个外部调用
- **自定义异常** 继承 `StandardError`，提供业务语义化的错误信息
- 运行 `hello advance error_handling` 查看完整示例
