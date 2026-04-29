# 模块与混入

## 开篇故事

Ruby 只有单继承，但现实中的对象往往有多种角色。一个人可以"会唱歌"也会"会画画"——这些能力不是继承关系，而是可组合的特征。Ruby 用模块（Module）来解决这个问题：模块就像工具箱，可以混入（mixin）到任何类里。

## 本章适合谁

如果你需要实现代码复用而非继承关系（比如日志功能、序列化功能、权限检查），模块就是你的工具。

## 你会学到什么

1. include — 模块方法成为实例方法
2. extend — 模块方法成为类方法
3. prepend — 在方法链中前置拦截
4. module_function — 模块本身作为命名空间调用
5. 自定义 Enumerable 类

## 前置要求

- [类与对象](classes.md) — 类基础

## 第一个例子

```ruby
# 运行: hello basic modules

module Loggable
  def log(msg)
    puts "[LOG] #{self.class.name}: #{msg}"
  end
end

class Service
  include Loggable

  def do_work
    log("doing something")
  end
end

Service.new.do_work
# 输出: [LOG] Service: doing something
```

**为什么这比继承好**：一个类可以同时 include 多个模块，但只能继承一个父类。模块是组合优于继承的 Ruby 式体现。

## include — 模块方法成为实例方法

```ruby
module Loggable
  def log(msg)
    puts "[LOG] #{self.class.name}: #{msg}"
  end
end

class Service
  include Loggable

  def do_work
    log("doing something")
  end
end
```

`include` 把模块的方法变成类的**实例方法**。一个类可以 include 多个模块：

```ruby
class Report
  include Loggable
  include Serializable
  extend Timestamped

  def generate
    log("generating report")
  end
end
```

## extend — 模块方法成为类方法

```ruby
module Serializable
  def to_json_like
    "{instance_variables: #{instance_variables.map(&:to_s)}}"
  end
end

class Config
  extend Serializable
end

Config.instance_variable_set(:@foo, "bar")
puts Config.to_json_like
# → {instance_variables: ["@foo"]}
```

**记忆区别**：`include` 给实例提供方法，`extend` 给类提供方法。

## prepend — 方法拦截

```ruby
module Timestamped
  attr_accessor :created_at
end

class Task
  prepend Timestamped

  def initialize
    @created_at = "original"
  end
  attr_accessor :created_at
end

task = Task.new
task.created_at = "2024-01-01"
puts task.created_at  # "2024-01-01"
```

`prepend` 把模块插在方法查找链的最前面。如果模块和类有同名方法，模块的方法先执行，可以调用 `super` 继续调用类的方法。

```ruby
module Logging
  def do_something
    puts "before"
    super  # 调用类的方法
    puts "after"
  end
end

class Worker
  prepend Logging

  def do_something
    puts "working..."
  end
end

Worker.new.do_something
# 输出:
# before
# working...
# after
```

## module_function — 模块作为命名空间

```ruby
module Greetings
  module_function

  def hello
    "Hello from module_function"
  end

  def goodbye
    "Goodbye from module_function"
  end
end

puts Greetings.hello    # "Hello from module_function"
puts Greetings.goodbye  # "Goodbye from module_function"
```

`module_function` 做两件事：
1. 把模块的方法变成可以直接调用的类方法
2. 生成私有实例方法副本，可以被 include 使用

**适用场景**：工具类方法（如 JSON.parse、File.read），不需要实例化即可调用。

## include Enumerable

Ruby 的 `Enumerable` 模块提供了 `map`、`select`、`find`、`each` 等 50+ 个方法。你只需实现 `each`，即可获得所有方法：

```ruby
class UserList
  include Enumerable

  def initialize(data)
    @data = data
  end

  def each(&block)
    @data.each(&block)
  end
end

users = UserList.new(["alice@email.com", "BOB@EMAIL.COM"])

# 实现了 each 后，map、find 等全都有
puts users.map(&:upcase).inspect
# → ["ALICE@EMAIL.COM", "BOB@EMAIL.COM"]

puts users.find { |s| s.include?("@") }
# → "alice@email.com"
```

**为什么这很强大**：你定义一次 `each`，就免费获得 `all?`、`any?`、`count`、`group_by`、`max`、`min` 等几十个方法。

## 常见错误

### 错误 1：include vs extend 混淆

```ruby
module StringUtils
  def capitalize_words(str)
    str.split.map(&:capitalize).join(" ")
  end
end

class TextProcessor
  include StringUtils  # ❌ 想用类方法调用，却用了 include
end

# TextProcessor.capitalize_words("hello")  # ❌ NoMethodError
# ✅ 应该用 extend
```

### 错误 2：模块方法中的 self 困惑

```ruby
module Logger
  def log(msg)
    puts "[LOG] #{self.class.name}: #{msg}"
    # self 指向 include 这个模块的实例
  end
end
```

`self` 在 `log` 方法中指向调用它的对象，而非模块本身。这保证了日志输出正确的类名。

## 动手练习

### 练习 1：设计 Mixin

```ruby
# 创建可复用的模块
# 1. Auditable 模块：添加 created_at, updated_at, audit_log
# 2. 让 Order 类和 User 类 include 它
```

<details>
<summary>参考答案</summary>

```ruby
module Auditable
  attr_accessor :created_at, :updated_at

  def self.included(base)
    base.class_eval do
      before_save :update_timestamp
    end
  end

  def audit_log
    puts "记录于 #{Time.now}"
  end

  private

  def update_timestamp
    @updated_at = Time.now
  end
end

class Order
  include Auditable
end
```

</details>

### 练习 2：扩展 Enumerable

```ruby
# 创建一个 RangeList 类
# 包含 [1..5, 10..15] 这样的范围列表
# include Enumerable 使其支持 map, select 等
```

<details>
<summary>参考答案</summary>

```ruby
class RangeList
  include Enumerable

  def initialize(*ranges)
    @ranges = ranges
  end

  def each(&block)
    @ranges.each { |range| range.each(&block) }
  end
end

rl = RangeList.new(1..3, 10..12)
rl.select(&:even?)  # [2, 10, 12]
```

</details>

## 故障排查 (FAQ)

### Q: include vs extend vs prepend 怎么选？

**A**:
- **include**：需要模块方法作为实例方法（最常见）
- **extend**：需要模块方法作为类方法
- **prepend**：需要拦截/包装原有方法

### Q: 模块可以继承吗？

**A**: 不可以直接用 `<`。但模块可以 `include` 其他模块，实现模块级别的组合。

### Q: module_function 和 extend self 区别？

**A**: 两者效果类似。`module_function` 更正式，`extend self` 更简洁（一行搞定）。小模块用 extend self，需要 include 和直接调用两用的用 module_function。

## 小结

**核心要点**：

1. **include → 实例方法**：给对象添加行为
2. **extend → 类方法**：给类添加功能
3. **prepend → 方法拦截**：在方法链最前面插入
4. **module_function → 直接调用**：工具方法模式
5. **include Enumerable → 免费获得 50+ 方法**：只需实现 `each`
6. **模块 = 可组合的特征**：弥补单继承的限制

**术语**：

- **Module（模块）**：无实例化的方法集合
- **Mixin（混入）**：将模块方法注入类的机制
- **Enumerable**：提供集合遍历功能的模块
- **Method Lookup Path（方法查找路径）**：Ruby 查找方法定义的顺序
- **Ancestor Chain（祖先链）**：包含父类和 include 的模块

## 继续学习

- **上一章**: [类与对象](classes.md)
- **下一章**: [块与 Proc](blocks-procs.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic modules` 查看完整示例代码。
