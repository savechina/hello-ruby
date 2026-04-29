# 元编程

元编程是关于"编写能编写代码的代码"的技术。在大多数语言中，类和方法一旦定义就固定不变。Ruby 不同，它在运行时仍然保留了完整的类型系统信息，你可以在程序执行过程中动态创建方法、修改类、甚至重建整个对象模型。这就是元编程的能力。

理解元编程是掌握 Ruby 的关键一步。Rails 的 `has_many`、`validates` 这些魔法方法全部基于元编程实现。学完这一章你会明白 Rails 背后没有黑魔法，只有 Ruby 在运行时动态操作对象模型。

运行 `hello advance metaprogramming` 可以查看完整演示代码。

## define_method：动态定义方法

Ruby 中 `def` 关键字不是唯一定义方法的方式。`define_method` 可以在运行时接受一个方法名和一个代码块，动态创建方法：

```ruby
klass = Class.new do
  %w[dog cat bird].each do |animal|
    define_method("#{animal}_sound") do
      case animal
      when "dog"  then "汪！"
      when "cat"  then "喵！"
      when "bird" then "叽！"
      end
    end
  end
end

instance = klass.new
puts instance.dog_sound   # "汪！"
puts instance.cat_sound   # "喵！"
puts instance.bird_sound  # "叽！"
```

注意代码块中捕获了外部变量 `animal`。这是因为 `define_method` 接受一个闭包，闭包可以访问定义时的词法环境。这个特性让动态方法可以根据不同的外部参数生成不同的行为。

`define_method` 创建的方法与 `def` 定义的方法完全等价，同样出现在 `instance.methods` 列表中，同样可以被 `super` 调用。区别只是定义时机不同：`def` 在解析代码时确定，`define_method` 在运行时创建。

## method_missing：方法拦截

当对象收到一个未定义的方法调用时，Ruby 默认会抛出 `NoMethodError`。`method_missing` 允许你拦截这个调用并自定义行为。这是一个强大的模式，很多 DSL 都基于它实现。

```ruby
class DynamicHash
  def initialize
    @data = {}
  end

  def method_missing(name, *args)
    name_str = name.to_s
    if name_str.end_with?("=")
      @data[name_str.chomp("=").to_sym] = args.first
    else
      @data[name.to_sym]
    end
  end

  def respond_to_missing?(name, include_private = false)
    true
  end
end

obj = DynamicHash.new
obj.name = "Alice"
obj.age = 30
puts obj.name  # "Alice"
puts obj.age   # 30
```

`method_missing` 接收方法名和参数，你可以在内部实现任意逻辑。这个例子中把 `obj.name = "Alice"` 翻译成 `@data[:name] = "Alice"`，把 `obj.name` 翻译成 `@data[:name]`。

有一个容易被忽略的细节：当你重写 `method_missing` 时，也应该重写 `respond_to_missing?`。否则 `obj.respond_to?(:name)` 会返回 `false`，即使 `obj.name` 能正常调用。Rails 的 `ActiveRecord` 就同时实现了这两个方法。

**警告**：`method_missing` 是双刃剑。用得好可以写出非常优雅的 DSL，用不好会隐藏 bug。如果你拼错了方法名却得到了一个看似合法的返回值，调试起来会非常痛苦。建议只在明确需要拦截的场景使用，并在方法内部做好参数校验。

## class_eval 和 instance_eval

这三者 (`class_eval`、`module_eval`、`instance_eval`) 的区别在于执行代码的上下文环境。

`class_eval` 和 `module_eval` 完全等价，都是在类/模块的上下文中执行代码块。在这个上下文中，`self` 指向类本身，可以定义实例方法：

```ruby
klass = Class.new { attr_reader :value }

klass.class_eval do
  define_method(:value_doubled) { value * 2 }
  def greet
    "Hello from class_eval!"
  end
end

instance = klass.new
instance.instance_variable_set(:@value, 21)
puts instance.value_doubled  # 42
puts instance.greet          # "Hello from class_eval!"
```

`instance_eval` 是在对象实例的上下文中执行代码。在这个上下文中，`self` 指向实例对象，可以定义单例方法：

```ruby
obj = Object.new
obj.instance_eval do
  @special = "仅属于这个对象"
  define_singleton_method(:special_method) { @special }
end

puts obj.special_method  # "仅属于这个对象"

other_obj = Object.new
puts other_obj.respond_to?(:special_method)  # false，方法只在这个对象上
```

选择哪个取决于你的需求：要修改类的定义用 `class_eval`，要给单个对象添加方法用 `instance_eval`，要执行类级别的宏（比如 Rails 的 `before_save`）用 `class_exec`。

## send 和 public_send：反射调用

`send` 允许你用符号或字符串调用对象的任意方法，包括私有方法。`public_send` 的行为相同，但只调用公开方法，调用私有方法会抛出 `NoMethodError`。

```ruby
text = "hello world"
puts text.send(:upcase)          # "HELLO WORLD"
puts text.send(:+, "!")          # "hello world!"
puts text.send(:split, " ").join("-")  # "hello-world"
```

什么时候会用到 `send`？最常见的是动态方法名。比如从配置或用户输入中获取方法名，再用 `send` 调用。但要注意 `public_send` 更安全，它不会意外触发私有方法。

## const_get：动态常量访问

`const_get` 允许你通过字符串或符号获取常量引用：

```ruby
StringClass = Object.const_get(:String)
puts StringClass.new("hello")  # "hello"

puts Math.const_get(:PI)       # 3.14159...
```

这在插件系统或工厂模式中很有用。你需要根据用户配置加载不同的类时，用 `const_get` 可以免去冗长的 `if/else` 分支。

## 开放类：随时修改已有类

Ruby 的类随时可以重新打开，添加新方法或修改已有方法：

```ruby
class String
  def shout
    upcase + "!"
  end
end

puts "hello".shout  # "HELLO!"
```

这个特性是 Ruby 元编程的基础，但也带来风险：如果你修改了核心类的方法，可能与其他库产生冲突。Rails 的 ActiveSupport 大量使用了这个特性，比如给 Integer 添加了 `2.days.ago` 这样的语法糖。使用开放类时要遵循两个原则：方法命名加前缀避免冲突、只添加不覆盖。

## 本章要点

- **define_method** 在运行时动态创建方法，接受闭包捕获外部变量
- **method_missing** 拦截未定义的方法调用，配合 `respond_to_missing?` 使用
- **class_eval** 在类上下文中执行代码，定义实例方法
- **instance_eval** 在对象上下文中执行代码，定义单例方法
- **send/public_send** 用符号动态调用方法，`public_send` 更安全
- **const_get** 通过名称获取常量引用，适合动态加载场景
- **开放类** 允许随时修改已有类，命名要谨慎避免冲突
- 元编程的终极目标不是炫技，而是写出更贴合业务语义的 API
- 运行 `hello advance metaprogramming` 查看完整示例
