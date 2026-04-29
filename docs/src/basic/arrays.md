# 数组

## 开篇故事

数组是编程世界中最基础的数据容器。它像一个有编号的储物柜，每个格子都能放一个东西，按编号取用，整齐有序。Ruby 的数组比许多语言更灵活——可以放任意类型的对象，支持负数索引，还有丰富的变换方法。

## 本章适合谁

如果你需要有序地存储一组数据（无论是名单、数字列表还是文件路径），数组就是你的首选工具。

## 你会学到什么

1. 创建数组的多种写法
2. 索引访问（正数、负数、切片）
3. 添加与移除元素（push/pop/shift/unshift）
4. 集合变换（map/select/reduce/compact/flatten）
5. each 迭代器

## 前置要求

- [字符串操作](strings.md) — 基础类型操作

## 第一个例子

```ruby
# 运行: hello basic arrays

fruits = ["apple", "banana", "cherry"]
puts "第一个水果: #{fruits[0]}"
puts "最后一个水果: #{fruits[-1]}"
```

**输出**：

```
第一个水果: apple
最后一个水果: cherry
```

Ruby 数组的负数索引 `[-1]` 直接取最后一个元素，不需要 `length - 1` 的繁琐计算。

## 创建数组

```ruby
# 字面量（最常见）
fruits = ["apple", "banana", "cherry"]

# 从范围创建
numbers = Array(1..5)   # [1, 2, 3, 4, 5]

# %w[] — 单词数组（不需要引号和逗号）
words = %w[foo bar baz]  # ["foo", "bar", "baz"]

# %W[] — 支持插值
today = "Monday"
days = %W[Monday #{today} Wednesday]  # ["Monday", "Monday", "Wednesday"]

# Array.new — 预设大小和默认值
zeros = Array.new(5, 0)  # [0, 0, 0, 0, 0]
```

## 索引与访问

```ruby
fruits = ["apple", "banana", "cherry"]

# 正数索引
puts "fruits[0]: #{fruits[0]}"       # "apple"

# 负数索引
puts "fruits[-1]: #{fruits[-1]}"     # "cherry"（最后）
puts "fruits[-2]: #{fruits[-2]}"     # "banana"（倒数第二）

# 切片 — 从索引 1 开始取 2 个
puts "fruits[1, 2]: #{fruits[1, 2].inspect}"  # ["banana", "cherry"]

# 辅助方法
puts "fruits.first: #{fruits.first}"         # "apple"
puts "fruits.first(2): #{fruits.first(2).inspect}"  # ["apple", "banana"]
puts "fruits.last: #{fruits.last}"           # "cherry"
```

**为什么负数索引好用**：在 Python 中也支持，但 Java/C++ 不支持。这个设计让"取最后一个元素"变成一行代码。

## 添加与移除元素

数组像栈一样，两端都可以操作：

```ruby
arr = [1, 2, 3]

# 尾部操作
arr.push(4)        # [1, 2, 3, 4]
arr << 5           # [1, 2, 3, 4, 5]（链式）

# 头部操作
arr.unshift(0)     # [0, 1, 2, 3, 4, 5]

puts "操作后: #{arr.inspect}"

# 移除 — 尾部
popped = arr.pop   # 移除并返回 5
puts "pop 返回: #{popped}"

# 移除 — 头部
shifted = arr.shift  # 移除并返回 0
puts "shift 返回: #{shifted}"

puts "剩余: #{arr.inspect}"  # [1, 2, 3, 4]
```

| 方法 | 操作位置 | 返回值 |
|------|---------|--------|
| `push` / `<<` | 尾部添加 | 数组本身 |
| `unshift` | 头部添加 | 数组本身 |
| `pop` | 尾部移除 | 移除的元素 |
| `shift` | 头部移除 | 移除的元素 |

## map 变换

`map` 对每个元素执行变换，返回新数组：

```ruby
numbers = [1, 2, 3, 4, 5]

# 块语法
squared = numbers.map { |n| n ** 2 }
puts "平方: #{squared.inspect}"  # [1, 4, 9, 16, 25]

# & 速记语法（:upcase 被转为 Proc）
fruits = ["apple", "banana", "cherry"]
upper = fruits.map(&:upcase)
puts "大写: #{upper.inspect}"  # ["APPLE", "BANANA", "CHERRY"]
```

**`&:upcase` 的原理**：`:upcase.to_proc` 返回一个 Proc，等价于 `{ |obj| obj.upcase }`。这是 Ruby 惯用写法。

## select 和 reject

过滤元素：

```ruby
numbers = [1, 2, 3, 4, 5]

evens = numbers.select(&:even?)
puts "偶数: #{evens.inspect}"   # [2, 4]

odds = numbers.reject(&:even?)
puts "奇数: #{odds.inspect}"    # [1, 3, 5]
```

`select` 保留符合条件的元素，`reject` 剔除它们。

## reduce 聚合

`reduce`（也叫 `inject`）将数组聚合为单个值：

```ruby
numbers = [1, 2, 3, 4, 5]

# 求和
sum = numbers.reduce(0) { |acc, n| acc + n }
puts "求和: #{sum}"  # 15

# 用法简化（符号法）
product = numbers.reduce(1, :*)
puts "积: #{product}"  # 120
```

**`reduce` 的思维方式**：想象你在折叠一摞纸，每次把两张压成一张。`0` 是初始值，`acc` 是已折叠的结果 (`acc` 初始为 0)，然后 `0 + 1 = 1`, `1 + 2 = 3`, `3 + 3 = 6`... 最后得到 15。

## compact 和 flatten

```ruby
# compact 移除 nil
with_nils = [1, nil, 2, nil, 3]
puts "compact: #{with_nils.compact.inspect}"  # [1, 2, 3]

# flatten 展平嵌套
# 展平嵌套数组
nested = [[1, 2], [3, [4, 5]]]
puts "展平所有: #{nested.flatten.inspect}"    # [1, 2, 3, 4, 5]
puts "展平一层: #{nested.flatten(1).inspect}"   # [1, 2, 3, [4, 5]]

# uniq 去重
duplicates = [1, 2, 2, 3, 3, 3]
puts "去重: #{duplicates.uniq.inspect}"  # [1, 2, 3]
```

## each 迭代器

`each` 是 Ruby 中最常用的遍历方式：

```ruby
arr = [10, 20, 30]
arr.each do |val|
  puts "值: #{val}"
end

# 带索引
arr.each_with_index do |val, idx|
  puts "  [#{idx}] = #{val}"
end
# 输出:
#   [0] = 10
#   [1] = 20
#   [2] = 30
```

**为什么不常见 for 循环**：Ruby 的 `for` 关键字存在但很少使用。`each` 更符合 Ruby 的函数式编程风格。

## 常见错误

### 错误 1：修改正在遍历的数组

```ruby
arr = [1, 2, 3, 4, 5]
arr.each do |n|
  arr.delete(n) if n.even?  # 行为不可预测
end
```

**修复**：用 `select` 或 `reject` 创建新数组：

```ruby
arr.reject!(&:even?)  # 删除所有偶数
```

### 错误 2：用 reduce 做 map 能做的事

```ruby
# ❌ 不必要的复杂度
result = arr.reduce([]) { |acc, x| acc << x * 2 }

# ✅ 直接用
result = arr.map { |x| x * 2 }
```

### 错误 3：混淆 push 和 <<

```ruby
arr = [1]
arr.push(2, 3)  # ✅ 可以添加多个元素
arr << 2 << 3   # ✅ 链式添加，但每次只添加一个

# 注意返回值不同
arr.push(4)     # 返回 arr
arr << 4        # 返回 arr（支持链式）
```

## 动手练习

### 练习 1：方法组合

将 `[1, -2, 3, nil, -4, 5]` 变成 `[1, 2, 3, 4, 5]`（取绝对值，移除 nil）

<details>
<summary>参考答案</summary>

```ruby
[1, -2, 3, nil, -4, 5].compact.map(&:abs)
# → [1, 2, 3, 4, 5]
```

</details>

### 练习 2：用 reduce 实现 join

```ruby
words = ["hello", "world", "ruby"]
# 不用 join 方法，用 reduce 实现 "hello-world-ruby"
```

<details>
<summary>参考答案</summary>

```ruby
words.reduce("") { |acc, w| acc.empty? ? w : "#{acc}-#{w}" }
# → "hello-world-ruby"
```

</details>

## 故障排查 (FAQ)

### Q: 怎么判断数组中是否包含某个元素？

**A**: 用 `include?`：

```ruby
[1, 2, 3].include?(2)  # true
[1, 2, 3].include?(5)  # false
```

### Q: `map` 和 `each` 的区别？

**A**: `each` 遍历并执行动作（返回原数组），`map` 遍历并生成新数组。需要收集结果时用 `map`。

### Q: 数组元素是引用还是拷贝？

**A**: Ruby 里都是引用。修改可变对象会影响原数组：

```ruby
arr = ["hi"]
copy = arr.map { |s| s }
copy[0] << "!"
puts arr[0]  # "hi!"（被修改了）
```

## 小结

**核心要点**：

1. **创建方式多样**：`[]`、`%w[]`、`Array()` 各有所长
2. **负数索引取末尾**：`[-1]` 是最后元素，很 Ruby
3. **两端操作**：push/pop（尾）、shift/unshift（头）
4. **map/select/reduce 三件套**：变换、过滤、聚合
5. **compact/flatten/uniq**：清理和整理数组
6. **each 是主力遍历**：而不是 for 循环

**术语**：

- **Index（索引）**：数组中元素的位置编号
- **Slice（切片）**：取出子数组
- **Transform（变换）**：对每个元素应用函数（map）
- **Filter（过滤）**：筛选符合条件的元素（select/reject）
- **Reduce（归约）**：将数组聚合为单个值

## 继续学习

- **上一章**: [字符串操作](strings.md)
- **下一章**: [哈希](hashes.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic arrays` 查看完整示例代码。
