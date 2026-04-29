# 变量与作用域

## 开篇故事

想象你在厨房做菜。每个调料罐都有自己的位置：有的放在手边（局部变量），有的贴在橱柜上（实例变量），有的放在仓库里所有厨师都能用（类变量），有的在整栋楼的公共柜子里（全局变量）。Ruby 的变量作用域就是这个道理——不同符号前缀决定变量在哪里可见。

## 本章适合谁

如果你是 Ruby 新手，本章是你学习的第一站。变量是所有编程语言的起点，理解作用域能让你避免很多隐蔽的 bug。

## 你会学到什么

1. 局部变量、实例变量、类变量、全局变量的区别
2. 常量命名约定与行为
3. Ruby 动态类型的含义
4. 五种变量前缀规则

## 前置要求

无。本章是零基础入门章节。

## 第一个例子

```ruby
# 运行: hello basic variables

# 局部变量 — 小写字母或下划线开头
greeting = "你好，Ruby！"
count = 42

puts "局部变量 - greeting: #{greeting}"
puts "  count: #{count}"
```

**输出**：

```
局部变量 - greeting: 你好，Ruby！
  count: 42
```

这段代码演示了 Ruby 最基础的赋值方式。变量不需要声明类型，赋值即创建。

## 五类变量

### 1. 局部变量

以小写字母或下划线开头。作用域是当前块（方法、循环、if 语句等）。

```ruby
def example
  local_var = "我只在当前方法内有效"
  puts local_var
end

# puts local_var  # ❌ 报错：变量未定义
```

**为什么要关心**：局部变量是 Ruby 中最常用的变量类型。把它们当作方法的私有数据，外部无法触碰。

### 2. 实例变量

以 `@` 开头。作用域是当前对象实例。

```ruby
obj = Object.new

# 为 obj 动态添加实例变量
class << obj
  attr_accessor :name
end

obj.name = "实例对象"
puts "实例变量 - obj.name: #{obj.name}"
```

**为什么要关心**：实例变量就是 OOP 里的"对象的属性"。每个对象实例拥有自己独立的实例变量副本。

```ruby
class User
  def initialize(name)
    @name = name  # 每个 User 实例有自己的 @name
  end
end

alice = User.new("Alice")
bob = User.new("Bob")

puts alice.instance_variable_get(:@name)  # "Alice"
puts bob.instance_variable_get(:@name)    # "Bob"
```

### 3. 类变量

以 `@@` 开头。作用域是当前类及其所有子类（共享同一个变量！）。

```ruby
class Counter
  @@count = 0

  def self.increment
    @@count += 1
  end

  def self.count
    @@count
  end
end

Counter.increment  # → 1
Counter.increment  # → 2
Counter.increment  # → 3
puts "计数器: #{Counter.count}"  # 3
```

**警告**：类变量在继承链中共享，子类修改会影响父类。大多数时候，使用类实例变量（`@count` 在单例类上）更安全。

```ruby
# 更安全的替代方案：类实例变量
class Counter
  class << self
    attr_accessor :count
  end

  @count = 0  # 类实例变量，不被子类共享

  def self.increment
    @count += 1
  end
end
```

### 4. 全局变量

以 `$` 开头。整个 Ruby 程序中任何地方都可以访问。

```ruby
$global_config = { version: "0.1.0", debug: false }

puts "全局变量: #{$global_config}"
```

**为什么要慎用**：全局变量会破坏封装。任何代码都可以修改它，调试时很难追踪 bug 来源。Ruby 社区惯例是尽量避免使用 `$` 变量。

**例外情况**：Ruby 内置的全局变量是安全的，比如：

- `$stdout` — 标准输出
- `$stderr` — 标准错误
- `$?` — 最近一次子进程退出状态
- `$~` — 最近一次正则匹配的 MatchData

### 5. 常量

以大写字母开头。重新赋值会给出警告而不是报错。

```ruby
MAX_RETRIES = 3

# 重新赋值会报警告，不会崩溃
# MAX_RETRIES = 5  # warning: already initialized constant
```

**为什么要关心**：常量并不是真正"不可变"。对于字符串和数组，内容仍然可以修改：

```ruby
API_URL = "https://api.example.com"
# API_URL << "/v2"  # ❌ frozen_string_literal 模式下会报错

PATHS = ["/app", "/lib"]
PATHS << "/bin"    # ✅ 数组内容可以修改（常量只保护变量绑定）
```

## Ruby 的动态类型

Ruby 是动态类型语言——变量类型随赋值而变，不需要显式声明。

```ruby
x = 10
puts "x 初始为 Integer: #{x.class}"     # Integer

x = "现在是字符串"
puts "x 变为 String: #{x.class}"        # String

x = [1, 2, 3]
puts "x 又变为 Array: #{x.class}"       # Array
```

**这和静态类型语言有什么区别**？

| 对比项 | Ruby（动态类型） | Java（静态类型） |
|--------|------------------|------------------|
| 声明类型 | 不需要 | 必须（`int x = 10;`） |
| 类型变化 | 可以随意变 | 编译报错 |
| 类型检查 | 运行时 | 编译时 |
| 灵活性 | 高 | 低 |
| 安全性 | 运行时才能发现类型错误 | 编译时发现大部分错误 |

## 作用域规则总结

| 变量类型 | 前缀 | 作用域 | 示例 |
|---------|------|--------|------|
| 局部变量 | 小写/下划线 | 当前代码块 | `count`, `user_name` |
| 实例变量 | `@` | 当前对象 | `@name`, `@age` |
| 类变量 | `@@` | 当前类及子类 | `@@count` |
| 全局变量 | `$` | 整个程序 | `$global_config` |
| 常量 | 大写 | 当前作用域及嵌套 | `MAX_RETRIES`, `API::URL` |

## 常见错误

### 错误 1：在方法内使用实例变量但忘记 @

```ruby
class User
  def set_name(name)
    name = name  # ❌ 这是一个局部变量赋值！
  end
end
```

**修复**：

```ruby
class User
  def set_name(name)
    @name = name  # ✅ 实例变量
  end
end
```

### 错误 2：滥用全局变量

```ruby
# ❌ 坏做法
$db = Database.connect
$cache = Cache.new
$logger = Logger.new

def process
  $db.query("SELECT ...")  # 难以测试，难以追踪
end
```

**更好的做法**：

```ruby
# ✅ 通过参数传递依赖
def process(db:)
  db.query("SELECT ...")
end
```

### 错误 3：类变量的继承陷阱

```ruby
class Parent
  @@value = "parent"

  def self.value
    @@value
  end
end

class Child < Parent
  @@value = "child"  # ❌ 同时修改了 Parent 的 @@value！
end

puts Parent.value  # 输出 "child"，不是预期的 "parent"
```

**修复**：使用类实例变量。

## 动手练习

### 练习 1：跟踪变量作用域

```ruby
# 说出每个变量属于哪种类型
@instance = "A"
@@class_var = "B"
$global = "C"
LOCAL = "D"
local_var = "E"
```

<details>
<summary>查看答案</summary>

- `@instance` — 实例变量
- `@@class_var` — 类变量
- `$global` — 全局变量
- `LOCAL` — 常量
- `local_var` — 局部变量

</details>

### 练习 2：动态类型体验

```ruby
value = 100
# 在不报错的前提下，让 value 依次变成 String、Array、Hash
# 每次打印它的 class
```

<details>
<summary>参考答案</summary>

```ruby
value = 100
puts value.class   # Integer

value = "文字"
puts value.class   # String

value = [1, 2, 3]
puts value.class   # Array

value = { key: "value" }
puts value.class   # Hash
```

</details>

## 故障排查 (FAQ)

### Q: 为什么 Ruby 不用声明变量类型？

**A**: Ruby 是动态类型语言，类型信息存储在对象上，不在变量上。变量只是一个指向对象的标签。这让代码更简洁，但在大型项目中建议配合 Sorbet 等类型检查工具。

### Q: 类变量和类实例变量有什么区别？

**A**: 类变量 `@@x` 在继承链中共享；类实例变量 `@x`（定义在类对象上）不共享。大多数情况下，类实例变量更安全、更可预测。

### Q: 常量真的不能改吗？

**A**: 变量绑定不能改（重新赋值为警告），但对象内容可以改。`ARR = [1]; ARR << 2` 可以执行，但 `ARR = [3]` 会报警告。加上 `.freeze` 可以冻结内容：`ARR = [1].freeze`。

## 小结

**核心要点**：

1. **五种前缀决定作用域**：小写字母/下划线（局部）、`@`（实例）、`@@`（类）、`$`（全局）、大写（常量）
2. **作用域越窄越安全**：优先使用局部变量，慎用全局变量
3. **动态类型 ≠ 无类型**：每个值都有类型（`class` 方法查看）
4. **常量只保护绑定不保护内容**：需要时使用 `.freeze`
5. **类变量会继承共享**：谨慎使用，优先考虑类实例变量

**术语**：

- **Scope（作用域）**：变量可见的代码区域
- **Dynamic Typing（动态类型）**：类型绑定到值而非变量
- **Binding（绑定）**：变量名指向内存对象的操作
- **Singleton Class（单例类）**：每个对象独有的匿名类

## 继续学习

- **下一章**: [字符串操作](strings.md)
- **相关**: [类与对象](classes.md) — 深入理解实例变量
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic variables` 查看完整示例代码。
