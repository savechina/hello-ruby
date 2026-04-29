# 符号（Symbol）

## 开篇故事

Symbol 是 Ruby 独有的类型。它看起来像字符串，但本质上是"内部化的字符串"——每个唯一的符号名只有一个对象实例，无论在哪里使用。这个设计让符号成为哈希键、方法名、状态标识的最佳选择。

## 本章适合谁

如果你在 Ruby 代码中反复看到 `:name` 或 `:status`，想知道为什么不是字符串 `"name"`，本章会给你完整的答案。

## 你会学到什么

1. 符号的 object_id 唯一性
2. 字符串 vs 符号的区别
3. 创建符号的多种方式
4. 符号作为哈希键
5. 新旧哈希语法对比
6. 内存影响与最佳实践

## 前置要求

- [变量与作用域](variables.md) — 基础概念
- [哈希](hashes.md) — 哈希基础

## 第一个例子

```ruby
# 运行: hello basic symbols

# 同一个符号的 object_id 永远相同
puts :foo.object_id  # 第1次: 4170742
puts :foo.object_id  # 第2次: 4170742
puts "同一个符号的 object_id 永远相同: #{:foo.object_id == :foo.object_id}"
# → true
```

**为什么这很重要**：每次 `:foo` 都指向同一个对象。而字符串 `"hello"` 每次都是新对象。

```ruby
s1 = "hello"
s2 = "hello"
puts "字符串 object_id (s1): #{s1.object_id}"  # 80
puts "字符串 object_id (s2): #{s2.object_id}"  # 80（但不同）
puts "同样内容的字符串 object_id 不同: #{s1.object_id == s2.object_id}"
# → false（每个 "hello" 都是新对象）
```

## 创建符号的方式

```ruby
# 方式1: 冒号前缀（最常见）
method_name = :length
# 方式2: 字符串转符号
dynamic = "user".to_sym

# 方式3: 动态创建（允许非标准命名）
key = "access"
dynamic_symbol = :"#{key}_token"  # :access_token

# 方式4: %i[] 批量创建
%w[foo bar baz].each { |sym| puts "  #{sym.inspect} (#{sym.class})" }
# → :foo (Symbol), :bar (Symbol), :baz (Symbol)
```

## 相等性比较

```ruby
str = "foo"
sym = :foo

puts ":foo == :foo (符号): #{:foo == :foo}"           # true
puts '"foo" == "foo" (字符串): #{"foo" == "foo"}'            # true
puts ':foo == "foo" (跨类型 ==): #{sym == str}'      # true（符号 == 字符串）
puts ':foo.eql?(:foo): #{:foo.eql?(:foo)}'           # true
puts ':foo.eql?("foo"): #{:foo.eql?(str)}'      # false（eql? 比类型）
puts ':foo.equal?(:foo): # {:foo.equal?(:foo)}'  # true（同一对象）
```

| 比较方式 | 含义 |
|---------|------|
| `==` | 内容相等（可跨类型） |
| `eql?` | 内容 + 类型相等 |
| `equal?` | 同一内存地址 |

## 符号作为哈希键

这是符号最主要的用途。

```ruby
user = { name: "Alice", age: 30, role: "admin" }

puts user[:name]           # "Alice"
puts user.fetch(:age)      # 30
puts user.fetch(:email, "N/A")  # "N/A"
puts user.key?(:role)      # true
puts user.key?(:missing)   # false
```

**符号键 vs 字符串键**（它们不互通！）

```ruby
mixed = { :name => "Alice", "name" => "Bob" }
puts mixed[:name]    # "Alice"（符号键）
puts mixed["name"]   # "Bob"（字符串键）
```

## 新旧哈希语法

```ruby
# 旧式（火箭语法）—— 仍然有效
old_style = { :name => "Alice", :age => 30 }

# 新式（JSON 风格）—— 推荐
new_style = { name: "Alice", age: 30 }

puts "两者等价: #{old_style == new_style}"  # true
```

新式语法更简洁，是 Ruby 1.9+ 的惯例。

## freeze vs Symbol

```ruby
frozen_str = "immutable".freeze
symbol = :immutable

puts "frozen_str.object_id: #{frozen_str.object_id}"
puts ":immutable.object_id: #{symbol.object_id}"
puts "frozen_str.frozen?: #{frozen_str.frozen?}"
puts ":immutable.frozen?: #{symbol.frozen?}"
```

**区别**：冻结字符串不能修改，但每次都是新对象。符号天然冻结且全局唯一。

## Symbol.all_symbols 与内存

```ruby
count_before = Symbol.all_symbols.size
puts "当前符号总数: #{count_before}"

100.times do |i|
  :"dynamic_#{i}"
end

count_after = Symbol.all_symbols.size
puts "增加 100 个动态符号后总数: #{count_after}"
puts "增长: #{count_after - count_before}"
```

**警告**：Symbol 不会被垃圾回收（Ruby 3.2 之前）。大量动态创建 Symbol 会导致内存泄漏。

Ruby 3.2+ 增加了符号垃圾回收，但最佳实践仍然是：只在已知键名时使用 Symbol。运行时接收的外部输入应使用 String。

## 使用建议

```
使用 Symbol: 哈希键、方法名、枚举值
  :user_status     ✅ 哈希键（惯例）
  :each            ✅ 方法名引用（&:each）
  :red             ✅ 枚举值

使用 String: 外部输入、用户数据、动态内容
  params[:name]    ✅ 获取值（符号键）
  params.fetch("name") ✅ Web 框架中常见
```

**经验法则**：内部标识符用 Symbol，外部数据用 String。

## 常见错误

### 错误 1：动态创建 Symbol 导致内存泄漏

```ruby
# ❌ 不要用用户输入创建符号
user_input = params[:search]
:"dynamic_#{user_input}"  # 每次搜索创建一个 Symbol，内存增长
```

**修复**：用字符串代替。

### 错误 2：符号键和字符串键混用

```ruby
# 前端传来字符串键
data = { "name" => "Alice", "email" => "alice@example.com" }

# ❌ 用符号键取不到
puts data[:name]  # nil

# ✅ 用字符串键
puts data["name"]  # "Alice"

# ✅ 或者标准化
data.transform_keys(&:to_sym)
```

### 错误 3：过度使用 Symbol

```ruby
# ❌ 把长文本当 Symbol
:"这是一段很长的用户输入文本"  # 永远不会被 GC 回收
```

**修复**：短标识符用 Symbol，长文本用 String。

## 动手练习

### 练习 1：标准化哈希键

```ruby
# 写一个符号键和字符串键统一为符号键
mixed = { "name" => "Alice", age: 30, "email" => "alice@example.com" }
# → { name: "Alice", age: 30, email: "alice@example.com" }
```

<details>
<summary>参考答案</summary>

```ruby
mixed.transform_keys(&:to_sym)
```

</details>

### 练习 2：对比 Symbol vs Frozen String

```ruby
# 证明 Symbol 和 frozen string 不是同一对象
s = "hello".freeze
sym = :hello
puts s.object_id == sym.object_id  # → false
```

<details>
<summary>参考答案</summary>

```ruby
s = "hello".freeze
sym = :hello
puts s.object_id == sym.object_id  # false
```

</details>

## 故障排查 (FAQ)

### Q: Ruby 3.2 之后 Symbol 还会内存泄漏吗？

**A**: Ruby 3.2 新增了 Symbol 垃圾回收（只在内存压力时回收）。但动态创建 Symbol 仍然可能占用内存，最佳实践仍然是：已知标识符用 Symbol，运行时输入用 String。

### Q: 哈希键用 Symbol 还是 String 效率高？

**A**: Symbol 略快（因为 object_id 比较即可），但 Ruby 的哈希查找已相当优化。两者的性能差异在绝大多数场景可以忽略，应优先考虑代码可读性。

## 小结

**核心要点**：

1. **Symbol object_id 全局唯一**：`:name` 不管用多少次都是同一个对象
2. **String 每次都是新对象**：`"name"` 每次 new 都有不同 object_id
3. **符号键是哈希惯例**：`{ name: "Alice" }`
4. **新式哈希语法更简洁**：`{ name: ... }` 替代 `{ :name => ... }`
5. **内部标识符用 Symbol，外部数据用 String**：经验法则
6. **避免动态创建 Symbol**：防止内存泄漏

**术语**：

- **Symbol（符号）**：全局唯一的内部字符串
- **Object ID（对象 ID）**：Ruby 中每个对象的唯一标识
- **Interning（内部化）**：相同内容的对象只存一份
- **Frozen（冻结）**：不可变的对象
- **Symbol GC**：符号垃圾回收

## 继续学习

- **上一章**: [数字与数值运算](numbers.md)
- **下一章**: [正则表达式](regex.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic symbols` 查看完整示例代码.
