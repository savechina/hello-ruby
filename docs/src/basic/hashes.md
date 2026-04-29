# 哈希

## 开篇故事

哈希（Hash）是 Ruby 里最通用的数据容器。它就像一本字典：根据词语查释义。相比数组需要记住位置编号，哈希允许你用"名字"直接找到对应的值。Ruby 的哈希灵活、高效，几乎每个 Ruby 程序都会大量使用它。

## 本章适合谁

如果你需要用名称而非编号来组织数据（比如配置项、用户信息、JSON 响应），哈希是最佳选择。

## 你会学到什么

1. 符号键和字符串键的区别
2. 安全访问嵌套哈希（dig）
3. 哈希合并（merge）
4. 值变换（transform_values）
5. 遍历键值对

## 前置要求

- [数组](arrays.md) — 集合概念

## 第一个例子

```ruby
# 运行: hello basic hashes

user = { name: "Alice", age: 30, city: "Shanghai" }
puts "#{user[:name]} 今年 #{user[:age]} 岁，住在 #{user[:city]}"
# 输出: Alice 今年 30 岁，住在 Shanghai
```

**为什么这很 Ruby**：符号键 `{name: "Alice"}` 的写法接近 JSON，但性能更好。Ruby 社区约定俗成——哈希键用符号。

## 符号键 vs 字符串键

```ruby
# 符号键（Ruby 1.9+ 推荐写法）
user_sym = { name: "Alice", age: 30, city: "Shanghai" }

# 字符串键（火箭语法，旧写法）
user_str = { "name" => "Bob", "age" => 25, "city" => "Beijing" }

# 互相转换
str_from_sym = user_sym.transform_keys(&:to_s)
puts "符号键: #{user_sym.inspect}"
puts "字符串键: #{user_str.inspect}"
puts "转换后: #{str_from_sym.inspect}"
```

**关键区别**：符号键 `:name` 和字符串键 `"name"` 在同一个哈希中是**不同的键**。

```ruby
mixed = { :name => "符号键的值", "name" => "字符串键的值" }
puts mixed[:name]     # "符号键的值"
puts mixed["name"]    # "字符串键的值"
```

## 访问方式：[] vs fetch

```ruby
user = { name: "Alice", age: 30 }

# [] 访问 — 找不到返回 nil
puts user[:name]         # "Alice"
puts user[:missing].inspect  # nil

# fetch 访问 — 找不到抛 KeyError（或指定默认值）
puts user.fetch(:name, "N/A")  # "Alice"
puts user.fetch(:missing, "N/A")  # "N/A"（默认值）

# fetch 无默认值时，找不到抛出 KeyError
# user.fetch(:missing)  # ❌ KeyError
```

**选择建议**：如果你希望"找不到"时程序报错（及早发现问题），用 `fetch`。如果可以接受 nil（可选值），用 `[]`。

## 嵌套哈希与 dig

深层嵌套时，`dig` 是救命稻草：

```ruby
config = {
  database: {
    host: "localhost",
    port: 5432,
    options: { timeout: 5, pool: 10 }
  }
}

# dig — 安全访问任意层级
puts config.dig(:database, :options, :timeout)  # 5
puts config.dig(:redis, :host).inspect   # nil（不会报错）
```

**对比传统写法**：

```ruby
# ❌ 容易报 NoMethodError
if config[:database] && config[:database][:options]
  config[:database][:options][:timeout]
end

# ✅ dig 一行搞定
config.dig(:database, :options, :timeout)
```

## 合并哈希

```ruby
defaults = { log_level: :info, verbose: false, timeout: 30 }
overrides = { log_level: :debug, verbose: true }

merged = defaults.merge(overrides)
puts "合并后: #{merged.inspect}"
# → { log_level: :debug, verbose: true, timeout: 30 }
```

`merge` 不修改原哈希。`merge!` 会原地修改。

## 值变换

`transform_values` 对每个值应用变换：

```ruby
scores = { math: 95, english: 88, science: 92 }

letter_grades = scores.transform_values do |score|
  case score
  when 90..100 then "A"
  when 80..89  then "B"
  when 70..79  then "C"
  else              "D"
  end
end

puts "等级: #{letter_grades.inspect}"
# → { math: "A", english: "B", science: "A" }
```

## 遍历

```ruby
user = { name: "Alice", age: 30, city: "Shanghai" }

# 遍历键值对
user.each do |key, value|
  puts "  #{key}: #{value}"
end

# 获取所有键、值
puts "keys: #{user.keys.inspect}"      # [:name, :age, :city]
puts "values: #{user.values.inspect}"  # ["Alice", 30, "Shanghai"]

# 检查值是否存在
puts "包含 Alice?: #{user.value?("Alice")}"  # true
```

**哈希是有序的**：Ruby 1.9+ 的哈希保持插入顺序。遍历时会按添加顺序返回键值对。

## 常见错误

### 错误 1：混用符号键和字符串键

```ruby
data = { name: "Alice" }
puts data["name"]  # nil（找不到！）
```

**修复**：统一使用符号键，或在接收外部数据时标准化：

```ruby
data = { name: "Alice" }
data[:name]  # "Alice" ✅
```

### 错误 2：嵌套哈希访问崩溃

```ruby
config = { database: { host: "localhost" } }
puts config[:database][:options][:timeout]  # ❌ NoMethodError（options 是 nil）
```

**修复**：用 `dig` 安全访问。

### 错误 3：在遍历时修改哈希

```ruby
hash = { a: 1, b: 2, c: 3 }
hash.each do |key, value|
  hash.delete(key) if value == 2  # 行为可能不可预测
end
```

**修复**：用 `reject!` 或 `transform_values`：

```ruby
hash.reject! { |_, v| v == 2 }  # 安全
```

## 动手练习

### 练习 1：嵌套数据提取

```ruby
response = {
  data: {
    users: [
      { name: "Alice", contacts: { email: "alice@example.com" } },
      { name: "Bob", contacts: { phone: "138-1234-5678" } }
    ]
  }
}

# 用 dig 提取第一个用户的邮箱
```

<details>
<summary>参考答案</summary>

```ruby
response.dig(:data, :users, 0, :contacts, :email)
# → "alice@example.com"
```

</details>

### 练习 2：统计词频

```ruby
words = %w[apple banana apple cherry banana apple]
# 用 reduce 统计每个单词出现的次数
```

<details>
<summary>参考答案</summary>

```ruby
words.reduce(Hash.new(0)) do |counts, word|
  counts[word] += 1
  counts
end
# → {"apple"=>3, "banana"=>2, "cherry"=>1}

# Ruby 2.7+ 有更简单的写法：
words.tally
```

</details>

## 故障排查 (FAQ)

### Q: 什么时候用符号键，什么时候用字符串键？

**A**: 代码内部的哈希用符号键。从外部（如 JSON 解析、HTTP 请求参数）接收的哈希用字符串键。Rails 中 `params` 就是字符串键。

### Q: 哈希的查找效率如何？

**A**: O(1) 平均时间复杂度。哈希表用哈希函数计算键的存储位置，所以查找速度和哈希大小基本无关。

### Q: 怎么给哈希设置默认值？

**A**: `Hash.new(default_value)` 或带 Proc 的 `Hash.new { |h, k| h[k] = [] }`：

```ruby
# 所有找不到的键默认返回空数组
grouped = Hash.new { |h, k| h[k] = [] }
grouped[:fruits] << "apple"  # 不报错
```

## 小结

**核心要点**：

1. **符号键是惯例**：`{ name: "Alice" }` 而非 `{ "name" => "Alice" }`
2. **fetch 比 [] 更安全**：能指定默认值，找不到时报错而非静默 nil
3. **dig 处理嵌套**：安全穿透多层哈希，任何一层 nil 都安全返回 nil
4. **merge 合并配置**：默认值和覆盖值的经典模式
5. **transform_values 变换**：对值批量处理
6. **哈希保持插入顺序**：遍历顺序等于添加顺序

**术语**：

- **Key-Value Pair（键值对）**：哈希的基本数据单元
- **Hash Key（哈希键）**：用于查找的标识符
- **Default Value（默认值）**：找不到键时的回退值
- **Transform（变换）**：对每个值应用函数

## 继续学习

- **上一章**: [数组](arrays.md)
- **下一章**: [控制流](control-flow.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic hashes` 查看完整示例代码。
