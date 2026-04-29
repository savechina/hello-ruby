# 类与对象

## 开篇故事

面向对象编程的核心思想是：程序是由交互的对象组成的。对象有自己的数据（状态）和行为（方法）。在 Ruby 中，几乎所有东西都是对象——数字、字符串、甚至类本身。本章带你理解 Ruby 的类系统。

## 本章适合谁

如果你想用对象组织代码、设计可复用的组件、或理解 Rails 等框架中的模型系统，本章是必经之路。

## 你会学到什么

1. `initialize` 构造函数
2. `attr_reader` / `attr_writer` / `attr_accessor`
3. 类方法与实例方法
4. 继承与 `is_a?` 检查
5. 单例类概念

## 前置要求

- [方法定义与调用](methods.md) — 方法基础

## 第一个例子

```ruby
# 运行: hello basic classes

# 等价的类定义
class Person
  attr_reader :name, :age
  attr_accessor :email

  def initialize(name, age)
    @name = name
    @age = age
  end

  def greet
    "我叫 #{@name}，今年 #{@age} 岁。"
  end
end

person = Person.new("Alice", 30)
person.email = "alice@example.com"
puts person.greet  # 我叫 Alice，今年 30 岁。
```

**Ruby 的 `Person.new` 做了什么**：`new` 类方法先分配内存，然后调用 `initialize`。你通常只重写 `initialize`，而不是 `new`。

## initialize 构造函数

```ruby
class Person
  def initialize(name, age)
    @name = name    # 实例变量
    @age = age
  end
end

person = Person.new("Alice", 30)
```

`initialize` 是实例方法（私有），不能直接调用。它只在 `ClassName.new` 时被自动调用。

## attr_* 属性声明

Ruby 提供三个快捷方法来生成 getter/setter：

```ruby
class Person
  attr_reader :name, :age        # 只读：def name; @name; end
  attr_writer :email             # 只写：def email=(v); @email = v; end
  attr_accessor :phone           # 读写：两者都有
end

person = Person.new
person.phone = "138-1234-5678"   # writer
puts person.phone                # reader
```

| 宏 | 生成方法 | 用途 |
|---|----------|------|
| `attr_reader` | `def name; @name; end` | 只读属性 |
| `attr_writer` | `def name=(v); @name = v; end` | 只写属性 |
| `attr_accessor` | 两者都生成 | 读写属性 |

**为什么不推荐全用 attr_accessor**：只读属性更安全。让数据只能通过受控的方法修改，避免意外篡改。

## 类方法与实例方法

```ruby
class Counter
  @@count = 0  # 类变量

  # 类方法 — 用 def self.method_name
  def self.increment
    @@count += 1
  end

  def self.count
    @@count
  end

  # 实例方法 — 普通 def
  def initialize
    self.class.increment
  end
end

Counter.increment
Counter.increment
puts "计数器: #{Counter.count}"  # 2
```

**调用方式**：
- 类方法：`ClassName.method_name`
- 实例方法：`instance.method_name`

## self 关键字

`self` 指向当前对象：

```ruby
# 在类方法中，self = 类本身
class Foo
  def self.bar
    puts self  # Foo
  end
end

# 在实例方法中，self = 当前实例
class Foo
  def bar
    puts self  # #<Foo:0x0000...>
  end
end
```

**单例类**：每个 Ruby 对象都有一个隐藏的单例类，存放它独有的方法。

```ruby
obj = "hello"
class << obj
  def shouted
    upcase
  end
end
puts obj.shouted  # "HELLO"
# 另一个字符串没有这个方法
```

## 继承

```ruby
class Animal
  def speak
    "..."
  end
end

class Dog < Animal
  def speak
    "汪！"
  end
end

class Cat < Animal
  def speak
    "喵！"
  end
end

dog = Dog.new
cat = Cat.new
puts dog.speak  # 汪！
puts cat.speak  # 喵！
puts dog.is_a?(Animal)   # true
puts Dog < Animal        # true（Dog 继承自 Animal）
```

**Ruby 只有单继承**：一个类只能有一个直接父类。多行为通过模块（Mixin）实现。

## 常见错误

### 错误 1：在 initialize 中使用 return

```ruby
class Person
  def initialize(name)
    @name = name
    return "some value"  # ❌ initialize 的返回值被忽略
  end
end
```

`initialize` 的返回值总是被忽略，`new` 返回的是对象实例本身。

### 错误 2：类方法中用 self 却当成实例

```ruby
class Counter
  def self.increment
    @count = 10  # ❌ @count 是类实例变量，不是类变量
                 # 类实例变量存在 Counter 对象上
  end

  def self.count
    @count  # 可以访问
  end
end
```

### 错误 3：忘记 super

```ruby
class Dog < Animal
  def initialize(name)
    # @name = name  # ❌ 如果父类 initialize 做了其他事会被跳过
    super(name)    # ✅ 调用父类 initialize
  end
end
```

## 动手练习

### 练习 1：设计银行账户

```ruby
# 设计 Account 类：
# - 实例变量: owner (只读), balance (只写)
# - 类变量: @@total_accounts
# - 类方法: total_accounts
# - 实例方法: deposit(amount), withdraw(amount)
# - initialize(owner, initial_balance)
```

<details>
<summary>参考答案</summary>

```ruby
class Account
  @@total_accounts = 0

  attr_reader :owner
  attr_writer :balance

  def self.total_accounts
    @@total_accounts
  end

  def initialize(owner, initial_balance = 0)
    @owner = owner
    @balance = initial_balance
    @@total_accounts += 1
  end

  def deposit(amount)
    @balance += amount
  end

  def withdraw(amount)
    @balance -= amount
  end
end
```

</details>

### 练习 2：类继承链

```ruby
# 创建 Animal → Dog → ServiceDog 三层继承
# ServiceDog 添加 work 方法
```

<details>
<summary>参考答案</summary>

```ruby
class Animal
  def speak; "..."; end
end

class Dog < Animal
  def speak; "汪！"; end
end

class ServiceDog < Dog
  def speak; "汪！我是导盲犬。"; end
  def work; "正在引导主人..."; end
end
```

</details>

## 故障排查 (FAQ)

### Q: attr_accessor 和手动写 getter/setter 有什么区别？

**A**: 功能完全一样。`attr_accessor :name` 是语法糖，等价于：

```ruby
def name; @name; end
def name=(v); @name = v; end
```

如果 getter/setter 中有额外逻辑（如验证、转换），需要手动写方法。

### Q: 类变量 @@ 和类实例变量 @ 有什么区别？

**A**: `@@` 在继承链中共享；`@`（定义在 `class << self` 块内或 `def self.method` 中）是类对象自己的实例变量，不共享。推荐使用类实例变量。

### Q: Ruby 有构造函数重载吗？

**A**: 没有（方法名不支持重载）。解决方法：使用关键字参数、工厂方法 `Class.from_json(str)` 或默认参数。

## 小结

**核心要点**：

1. **initialize 是私有构造函数**：通过 `Class.new` 调用，返回值被忽略
2. **attr_reader/writer/accessor 是语法糖**：按需选择，保持封装性
3. **`def self.method` 定义类方法**：通过 `ClassName.method` 调用
4. **继承用 `<`**：单继承，多行为用模块
5. **self 指向当前上下文**：类方法中是类，实例方法中是对象
6. **`is_a?` 和 `<` 检查继承关系**：做类型判断时很有用

**术语**：

- **Class（类）**：对象的模板
- **Instance（实例）**：通过类创建的对象
- **Constructor（构造函数）**：`initialize` 方法
- **Accessor（访问器）**：读写内部状态的方法
- **Singleton Class（单例类）**：每个对象独有的匿名类

## 继续学习

- **上一章**: [方法定义与调用](methods.md)
- **下一章**: [模块与混入](modules.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic classes` 查看完整示例代码。
