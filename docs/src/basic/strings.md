# 字符串操作

## 开篇故事

字符串是程序世界里最普遍的存在。用户的输入、文件的文本、API 的响应——所有信息都以字符串的形式流动。Ruby 把字符串当成一等公民来对待，提供了一套丰富、直观的操作方式。

## 本章适合谁

如果你需要处理文本数据（几乎每个程序都需要），本章会教你 Ruby 字符串的常用操作和最佳实践。

## 你会学到什么

1. 双引号与单引号的区别
2. 字符串插值的强大能力
3. `%q`、`%Q`、`%[]` 百分号语法
4. 常用字符串方法链
5. `frozen_string_literal: true` 的影响
6. Heredoc 多行文本

## 前置要求

- [变量与作用域](variables.md) — 基础变量概念

## 第一个例子

```ruby
# 运行: hello basic strings

name = "Ruby"
version = 3.4
puts "#{name} 当前版本 #{version}"
# 输出: Ruby 当前版本 3.4
```

**为什么这很 Ruby**：不需要拼接符，不需要类型转换。`#{}` 插值自动调用 `to_s`，简洁、直观。

## 引号之争：双引号 vs 单引号

### 双引号（`""`）

- 支持插值 `#{}`
- 支持转义字符 `\n`、`\t`、`\\`

```ruby
text = "换行\n换行\t制表"
puts text
# 输出:
# 换行
# 换行    制表
```

### 单引号（`''`）

- 不支持插值
- 仅支持两个转义：`\\`（反斜杠）和 `\'`（单引号）
- 性能略好（不需要解析）

```ruby
literal = "Hello\nRuby"
puts literal  # 输出: Hello\nRuby（不解析 \n）
```

### `%q` 和 `%Q`

- `%q[]` 等价于单引号——不插值、不转义
- `%Q[]` 等价于双引号——支持插值和转义
- `%()` 也很常用
- 分隔符可以互换：`%q{}`、`%q<>`、`%q!!`

```ruby
# %q 等价于单引号
single_quoted = %q[Hello\nRuby]
puts "单引号行为: #{single_quoted}"

# %Q 或 %() 等价于双引号
interpolated2 = %(他说："我爱 #{name}")
puts "% 语法插值: #{interpolated2}"
```

**选择建议**：日常开发中使用双引号。当字符串包含大量引号时（如生成 HTML），可以用 `%Q()` 避免转义。

## 字符串插值

`#{}` 可以在双引号字符串中嵌入任意表达式：

```ruby
name = "Ruby"
version = 3.4

# 基本插值
puts "欢迎学习 #{name}"

# 表达式插值
puts "1 + 2 + 3 = #{1 + 2 + 3}"

# 方法调用
puts "大写: #{name.upcase}"

# 条件表达式
status = version >= 3.0 ? "最新" : "旧版"
puts "Ruby 版本 #{version} 是 #{status}"
```

**底层发生了什么**：Ruby 把 `#{}` 中的表达式转换为 `to_s` 结果，然后拼接到字符串中。

## 常用方法

Ruby 字符串提供了极其丰富的方法。

```ruby
text = "  Hello, Ruby World!  "

puts "strip: '#{text.strip}'"          # 去除首尾空白
puts "upcase: '#{text.strip.upcase}'"   # 大写
puts "downcase: '#{text.strip.downcase}'" # 小写
puts "swapcase: '#{text.strip.swapcase}'" # 大小写互换
puts "reverse: '#{text.strip.reverse}'" # 反转
puts "length: #{text.strip.length}"   # 长度
puts "include?('Ruby'): #{text.include?("Ruby")}"  # 包含
puts "start_with?('Hello'): #{text.strip.start_with?("Hello")}"  # 前缀
puts "end_with?('World!'): #{text.strip.end_with?("World!")}"   # 后缀
```

### 分割与连接

```ruby
csv = "apple,banana,cherry"
parts = csv.split(",")
puts "split: #{parts.inspect}"   # ["apple", "banana", "cherry"]

joined = parts.join(" - ")
puts "join: #{joined}"          # "apple - banana - cherry"

# 链式调用
chained = "hello world ruby".split.map(&:capitalize).join(" ")
puts "链式拆分→映射→连接: #{chained}"
```

### 替换：gsub 和 sub

```ruby
original = "Hello World"
global_replaced = original.gsub("o", "0")
puts "gsub(o→0): #{global_replaced}"    # "Hell0 W0rld"

single_replaced = original.sub("o", "0")
puts "sub(o→0): #{single_replaced}"    # "Hell0 World"

# 正则替换
redacted = "My email is user@example.com".gsub(/[\w.]+@[\w.]+/, "[已隐藏]")
puts "正则替换: #{redacted}"
```

`sub` 只替换第一个匹配，`gsub` 替换所有匹配。

## frozen_string_literal 的影响

在文件顶部添加以下注释：

```ruby
# frozen_string_literal: true
```

所有字符串字面量会变成冻结状态，不能修改：

```ruby
# frozen_string_literal: true

normal = "可以变"
# normal << "化"  # ❌ FrozenError

# 解决方案：.dup 创建可变副本
mutable = "动态修改".dup
mutable << "完毕"
puts "frozen 下 .dup 创建副本: #{mutable}"

# 显式冻结
frozen_string = "冻结了".freeze
# frozen_string << "！"  # ❌ FrozenError
```

**为什么要冻结字符串**：

1. **性能提升**：Ruby 可以复用相同的冻结字符串对象
2. **安全性**：防止意外修改共享字符串
3. **Ruby 3 趋势**：未来版本可能默认冻结所有字符串

## Heredoc 多行文本

用 `<<~` 创建缩进感知的多行字符串：

```ruby
sql = <<~SQL
  SELECT users.name, orders.total
  FROM users
  JOIN orders ON users.id = orders.user_id
  WHERE orders.total > 100
  ORDER BY orders.total DESC
SQL

puts sql
# 缩进自动调整，输出整洁的 SQL 语句
```

`<<~` 会自动去除公共前导空白，代码缩进和字符串内容缩进分离。

## 常见错误

### 错误 1：忘记 frozen_string_literal

```ruby
# ❌ 文件顶部缺少注释
text = "hello"
text << " world"  # 如果后来加了 frozen_string_literal 注释会崩
```

**修复**：始终在每行文件顶部加上 `# frozen_string_literal: true`

### 错误 2：用 + 拼接字符串

```ruby
# ❌ 可读性和性能都不好
result = "Hello, " + name + "! You are " + age.to_s + " years old."

# ✅ 用插值更清晰
result = "Hello, #{name}! You are #{age} years old."
```

### 错误 3：混淆 sub 和 gsub

```ruby
"aaa".sub("a", "b")   # → "baa"（只替换第一个）
"aaa".gsub("a", "b")  # → "bbb"（替换所有）
```

## 动手练习

### 练习 1：方法链

把 `"  hello   WORLD  "` 变成 `"World"`

<details>
<summary>参考答案</summary>

```ruby
"  hello   WORLD  ".strip.split.map(&:capitalize).join(" ").downcase.then(&:capitalize)
# 更简洁的方式：
"  hello   WORLD  ".strip.split(" ").map(&:capitalize).join(" ")
```

</details>

### 练习 2：统计单词

统计这个句子中每个单词出现的次数：`"the quick brown fox jumps over the lazy dog"`

<details>
<summary>参考答案</summary>

```ruby
sentence = "the quick brown fox jumps over the lazy dog"
words = sentence.split
counts = words.tally  # Ruby 2.7+
puts counts.inspect
# => {"the"=>2, "quick"=>1, "brown"=>1, ...}
```

</details>

## 故障排查 (FAQ)

### Q: 什么时候用单引号，什么时候用双引号？

**A**: 默认用双引号。字符串包含大量双引号时（如生成 HTML 属性），可以改用 `%Q()` 或 `%q()` 避免转义。

### Q: frozen_string_literal 会影响性能吗？

**A**: 会提升性能。冻结的字符串字面量在运行时只有一份拷贝，减少了内存分配和垃圾回收负担。

### Q: 怎么比较两个字符串是否相等？

**A**: 用 `==` 比较内容（区分大小写），`casecmp` 不区分大小写：

```ruby
"a" == "a"       # true
"a" == "A"       # false
"a".casecmp("A") # 0（相等）
```

## 小结

**核心要点**：

1. **双引号是默认选择**：支持插值和转义
2. **插值优于拼接**：`#{}` 比 `+` 更清晰、更高效
3. **方法链是 Ruby 风格**：`strip.upcase.reverse`
4. **frozen_string_literal: true 是惯例**：每行文件加这个注释
5. **Heredoc 处理多行**：`<<~SQL` 自动处理缩进

**术语**：

- **Interpolation（插值）**：在字符串中嵌入表达式
- **Frozen String（冻结字符串）**：不可变的字符串对象
- **Method Chaining（方法链）**：连续调用方法
- **Heredoc（多行字符串）**：`<<~` 语法的缩进感知多行文本

## 继续学习

- **上一章**: [变量与作用域](variables.md)
- **下一章**: [数组](arrays.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic strings` 查看完整示例代码。
