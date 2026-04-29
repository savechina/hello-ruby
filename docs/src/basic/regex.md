# 正则表达式

## 开篇故事

正则表达式是文本处理的瑞士军刀。它能在一行代码中提取邮箱、验证手机、解析 URL、替换格式——这些事用字符串方法要写十几行。Ruby 的正则表达式语法强大、表达力强，是值得投资的技能。

## 本章适合谁

如果你需要处理文本模式匹配（验证表单、解析日志、提取数据），本章教你 Ruby 正则表达式的完整使用方法。

## 你会学到什么

1. 创建正则表达式的三种方式
2. 修饰符 `/i`、`/m`、`/x`
3. 匹配操作 `=~`、`match`
4. 捕获组（位置组和命名组）
5. 贪婪 vs 惰性
6. 字符串方法配合正则（`gsub`/`scan`/`split`）
7. 实用示例

## 前置要求

- [字符串操作](strings.md) — 字符串基础
- [变量与作用域](variables.md) — 变量概念

## 第一个例子

```ruby
# 运行: hello basic regex

text = "我的电话是 138-1234-5678"

# =~ 返回匹配的起始索引
index = text =~ /\d{3}-\d{4}-\d{4}/
puts "=~ 返回索引: #{index}"  # 5

# match 返回 MatchData 对象
match = text.match(/(\d{3})-(\d{4})-(\d{4})/)
puts "完整匹配: #{match[0]}"  # 138-1234-5678
puts "第1组: #{match[1]}"     # 138
puts "第2组: #{match[2]}"     # 1234
puts "第3组: #{match[3]}"     # 5678
```

**为什么用正则**：如果用字符串方法，你需要写循环、判断、截取。一行正则搞定。

## 创建正则表达式

```ruby
# 字面量斜杠（最常用）
pattern_slash = /hello/

# %r{} — 适合包含斜杠的正则（如 URL）
pattern_r = %r{https?://[\w.]+}

# Regexp.new — 适合动态构建正则
dynamic = Regexp.new("\d{3}-\d{4}")
```

## 修饰符

```ruby
# /i — 忽略大小写
insensitive = /hello/i
puts "忽略大小写: #{insensitive.match?("Hello")}"  # true

# /m — 多行模式（. 也匹配换行符）
multiline = /a.*b/m
puts "多行模式: #{multiline.match?("a\nb")}"  # true

# /x — 忽略空白，允许注释（适合复杂正则）
verbose = /
  \d +    # 一位或多位数字
  -       # 连字符
  \d +    # 一位或多位数字
/x
puts "verbose 模式: #{verbose.match?("123-456")}"  # true
```

## 匹配操作

```ruby
text = "我的电话是 138-1234-5678"

# =~ 返回索引或 nil
index = text =~ /\d{3}-\d{4}-\d{4}/
puts "=~ 返回索引: #{index}"  # 5

# !~ 不匹配返回 true/false
puts "不匹配: #{(text !~ /xyz/)}"  # true

# match 返回 MatchData
match_data = text.match(/(\d{3})-(\d{4})-(\d{4})/)
puts "完整匹配: #{match_data[0]}"
puts "第1组: #{match_data[1]}"

# match? 只判断是否匹配（更快）
puts "包含数字?: #{text.match?(/\d+/)}"  # true
```

## 常用元字符

```ruby
sample = "abc123 XYZ def45"

puts "原始字符串: '#{sample}'"

# 字符类
puts "\d (数字): #{sample.scan(/\d/).inspect}"      # ["1", "2", "3", "4", "5"]
puts "\w  (单词字符): #{sample.scan(/\w/).inspect}"  # 包括字母数字下划线
puts "\s  (空白符): #{sample.scan(/\s/).inspect}"    # [" ", " "]
puts "\D (非数字): #{sample.scan(/\D/).inspect}"     # 非数字
puts "\W (非单词): #{sample.scan(/\W/).inspect}"     # 非单词字符
```

### 量词

```ruby
puts "+ (1次或多次): #{sample.scan(/\d+/).inspect}"     # ["123", "45"]
puts "* (0次或多次): #{sample.scan(/\d*/).inspect}"       # ["123", "45", "", "", "", ""]
puts "? (0次或1次): #{sample.scan(/\w\w?\d?/).inspect}"     # 允许0次
puts "{2,3} (2到3次): #{sample.scan(/\w{2,3}/).inspect}"  # 范围
puts "{3} (恰好3次): #{sample.scan(/\d{3}/).inspect}"    # 精确次数
```

## 捕获组

### 位置捕获组 `( )`

```ruby
date = "2025-12-31"
date_match = date.match(/(\d{4})-(\d{2})-(\d{2})/)
puts "年: #{date_match[1]}"  # 2025
puts "月: #{date_match[2]}"  # 12
puts "日: #{date_match[3]}"  # 31
```

### 命名捕获组 `(?<name>pattern)`

```ruby
named_match = date.match(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/)
puts "year: #{named_match[:year]}"    # 2025
puts "month: #{named_match[:month]}"  # 12
puts "day: #{named_match[:day]}"      # 31
```

### 非捕获组 `(?:pattern)`

```ruby
# 分组但不捕获
non_capturing = "2025-12-31".match(/(?:\d{4})-(\d{2})-(\d{2})/)
puts "捕获组数量: #{non_capturing.captures.length}"  # 2（不是3）
```

### 贪婪 vs 惰性

```ruby
greedy = "<div>hello</div>".match(/<.*>/)    # 匹配: `<div>hello</div>`
lazy = "<div>hello</div>".match(/<.*?>/)   # 匹配: `<div>`
puts "贪婪 .*: #{greedy[0]}"
puts "惰性 .*?: #{lazy[0]}"
```

## 字符串方法配合正则

```ruby
sentence = "Hello World Hello Ruby Hello World"

# sub — 单次替换
puts "sub: #{sentence.sub(/Hello/, "Hi")}"
# → "Hi World Hello Ruby Hello World"

# gsub — 全局替换
puts "gsub: #{sentence.gsub(/Hello/, "Hi")}"
# → "Hi World Hi Ruby Hi World"

# split — 用正则分割
csv = "apple,banana;cherry:dragon"
puts "split: #{csv.split(/[,;:]/).inspect}"
# → ["apple", "banana", "cherry", "dragon"]

# scan — 查找所有匹配
numbers = "a1b22c333d4444e5555".scan(/\d+/)
puts "scan: #{numbers.inspect}"
# → ["1", "22", "333", "4444"]

# grep — 数组匹配
words = %w{apple banana cherry date elderberry}
puts "grep: #{words.grep(/e$/).inspect}"
# → ["apple", "cherry", "date", "elderberry"]
```

## 特殊变量

匹配后 Ruby 设置了一些全局变量：

```ruby
"hello 123 world" =~ /(\d+)/

puts "$1 (最后匹配的第1组): #{$1}"    # "123"
puts "$& (最后完整匹配): #{$&}"      # "123"
puts "$~ (MatchData): #{$~.class}"    # MatchData
puts "$` (匹配前): #{$`}"            # "hello "
puts "$' (匹配后): #{$'}"            # " world"
```

## Regexp.escape — 转义特殊字符

```ruby
raw = "Price: $19.99 (50% off)"
escaped = Regexp.escape(raw)
puts "转义: #{escaped}"
# Price: \$19\.99 \(50% off\)
```

## 实用示例

### 邮箱验证

```ruby
email_pattern = /\A[\w.+-]+@[\w-]+\.[\w.]+\z/
emails = [
  "user@example.com",
  "invalid@",
  "good+tag@domain.co.uk"
]

emails.each do |email|
  valid = email =~ email_pattern ? "✓" : "✗"
  puts "  #{valid} #{email}"
end
```

### 解析 URL

```ruby
url_pattern = %r{(?<protocol>https?)//(?<host>[\w.:-]+)(?<path>/[\w/.-]*)?(?:\?(?<query>[\w=&-]+))?(?:#(?<fragment>\w+))?}

url = "http://example.com:8080/path/to/page?query=1#anchor"
m = url.match(url_pattern)
puts "协议: #{m[:protocol]}"      # http
puts "主机: #{m[:host]}"          # example.com:8080
puts "路径: #{m[:path]}"          # /path/to/page
puts "查询: #{m[:query]}"         # query=1
puts "锚点: #{m[:fragment]}"      # anchor
```

## 常见错误

### 错误 1：忘记锚点

```ruby
# 只匹配包含，不匹配完整
"hello world".match?(/hello/)  # true
"hello world".match?(/\Ahello\z/)  # false（多了 world）
```

**修复**：用 `\A` 和 `\z` 限制完整匹配。

### 错误 2：贪婪匹配

```ruby
"<div>hello</div>".match(/<.*>/)[0]
# → "<div>hello</div>"（贪婪匹配整个）

"<div>hello</div>".match(/<.*?>/)  # → "<div>"（惰性，只匹配第一个标签）
```

### 错误 3：用正则解析 HTML

```ruby
# ❌ 正则不适合解析 HTML
# HTML 结构复杂，嵌套、属性顺序、实体字符等
# 应使用 Nokogiri 等 HTML 解析器
```

## 动手练习

### 练习 1：提取中文数字

```ruby
# 从文本提取所有连续的中文数字
# "今天买了三斤苹果，花了二十元" → ["三", "二十"]
```

<details>
<summary>参考答案</summary>

```ruby
text = "今天买了三斤苹果，花了二十元"
text.scan(/[\u4e00-\u9fff]+/)
# 需要更复杂的逻辑处理中文数字
```

</details>

### 练习 2：驼峰转蛇形

```ruby
# "helloWorld" → "hello_world"
# "XMLHttpRequest" → "xml_http_request"
```

<details>
<summary>参考答案</summary>

```ruby
def camel_to_snake(str)
  str.gsub(/([A-Z])/, '_\1').downcase.sub(/^_/, '')
end
```

</details>

## 故障排除 (FAQ)

### Q: 为什么 \d 在 Ruby 里和 Python 不一样？

**A**: Ruby 的 `\d` 默认只匹配 ASCII 数字（0-9）。如需匹配 Unicode 数字，用 `\p{Nd}`。

### Q: 匹配特殊字符如 `/` 的 `/` 需要转义吗？

**A**: 需要。`/` 是正则的边界字符，所以 `/` 需要写 `\/`。或者用 `%r{}` 代替：`%r{https?://}`。

### Q: /i /m /x 可以一起用吗？

**A**: 可以：`/pattern/imx`。

## 小结

**核心要点**：

1. **字面量 `/pattern/` 最常用**
2. `=~` 返回索引 / `match` 返回 MatchData / `match?` 返回布尔
3. **捕获组 `(...)`** 和命名组 `(?<name>pattern)`
4. **量词区分贪婪 vs 惰性**
5. **`gsub`/`scan`/`split`** 配合正则处理字符串
6. `\A` 锚定开头/结尾

## 继续学习

- **上一章**: [符号（Symbol）](symbols.md)
- **下一章**: [文件管理](file-management.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic regex` 查看完整示例代码.
