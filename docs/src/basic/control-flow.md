# 控制流

## 开篇故事

程序之所以能处理复杂业务，不是因为它能计算多少东西，而是因为它能根据不同条件做不同决策。控制流就是 Ruby 代码的"判断力"——什么时候走这条路，什么时候走那条路，什么时候停下来。

## 本章适合谁

如果你需要让代码做出决策（条件判断）或重复执行（循环），本章涵盖了 Ruby 中所有控制流结构。

## 你会学到什么

1. if/elsif/else 和三元运算符
2. unless — Ruby 特有的否定条件
3. case/when — 多路分支的优雅写法
4. while/until — 循环
5. each 迭代器 — Ruby 的推荐遍历方式
6. next/break/redo — 循环控制

## 前置要求

- [数组](arrays.md) — 遍历基础
- [哈希](hashes.md) — 循环基础

## 第一个例子

```ruby
# 运行: hello basic control-flow

score = 85
grade = if score >= 90
  "A"
elsif score >= 80
  "B"
elsif score >= 70
  "C"
else
  "D"
end
puts "#{score}分 → #{grade}"
# 输出: 85分 → B
```

**这为什么值得注意**：在 Java/C++ 中，`if` 是语句，不返回值。在 Ruby 中，`if` 是表达式，它本身有返回值，可以直接赋值给变量。

## if / elsif / else

```ruby
# 多行形式
score = 85
grade = if score >= 90
  "A"
elsif score >= 80
  "B"
else
  "D"
end
```

**三元运算符**：

```ruby
status = score >= 60 ? "及格" : "不及格"
puts status  # "及格"
```

**Ruby 的所有都是表达式**：if、case、循环都返回值。这让你在需要时写出更简洁的赋值语句。

## unless

`unless` 是 "if not" 的 Ruby 式写法。它只在条件为 false 时执行：

```ruby
password = "secret123"

unless password.length >= 8
  puts "密码长度不足！"
end

# 单行形式（Ruby 特色）
puts "unless 单行: #{password.length < 8 && "密码不够长"}"
```

**何时使用 unless**：仅在逻辑是否定时使用。如果条件本身已经是正向描述，不要为了让代码"看起来像 Ruby"就硬套 unless。

```ruby
# ✅ 好的用法
unless user.admin?
  raise "权限不足"
end

# ❌ 不推荐（否定逻辑嵌套）
unless !user.active?
  puts "用户已激活"
end
# 应该写成 if user.active?
```

## case / when

`case` 替代多重 `if/elsif`，更清晰：

```ruby
day = "Monday"
activity = case day
           when "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"
             "工作日"
           when "Saturday", "Sunday"
             "周末"
           else
             "未知"
           end
puts "case/when: #{day} → #{activity}"
```

**case 的强大之处是匹配规则不只是等号**。它使用 `===` 操作符，所以可以匹配：

```ruby
# Range 匹配
temperature = 35
weather = case temperature
          when 0..15   then "寒冷"
          when 16..25  then "舒适"
          when 26..35  then "炎热"
          else "极端"
          end

# 正则匹配
input = "user@example.com"
kind = case input
       when /\A[\w.]+@[\w.]+\z/ then "邮箱地址"
       when /\A\d{3}-\d{4}\z/  then "电话号码"
       else "其他格式"
       end
```

## while 和 until

```ruby
# while
sum = 0
i = 1
while i <= 5
  sum += i
  i += 1
end
puts "while: 1+2+3+4+5 = #{sum}"

# until（等效于 while not）
countdown = 3
until countdown == 0
  print "#{countdown}... "
  countdown -= 1
end
puts "🚀!"
```

**while 的返回值是 nil**。如果最后一次循环体执行后没有显式返回，整个 while 表达式返回 nil。

## for 循环

```ruby
print "for (1..3): "
for n in 1..3
  print "#{n} "
end
# 输出: for (1..3): 1 2 3
```

**Ruby 社区几乎不用 for**：`for` 在 Ruby 中不常用，更地道的写法是 `each` 迭代器。

## each 迭代器

```ruby
colors = %w[red green blue]

# each 遍历
colors.each { |c| print "#{c} " }

# each_with_index
colors.each_with_index { |c, i| puts "[#{i}] = #{c}" }
```

**为什么 each 比 for 更受推崇**：

1. **作用域隔离**：`each` 中的块变量不会泄漏到外部
2. **链式调用**：可以接 `map`、`select` 等方法
3. **延迟计算**：配合 `Lazy` 可以处理大数据集

## 循环控制：next / break

```ruby
# next — 跳过当前迭代（类似 continue）
(1..5).each do |n|
  next if n.even?
  print "#{n} "
end
# 输出: 1 3 5

# break — 终止整个循环
(1..10).each do |n|
  break if n > 4
  print "#{n} "
end
# 输出: 1 2 3 4
```

##  ranges

```ruby
# 范围是 case 和循环的好搭档
(1..5).each { |n| print "#{n} " }   # 包含结束值
(1...5).each { |n| print "#{n} " }  # 不包含5..5)  # 不包含结束值
```

## 三元运算符

```ruby
status = score >= 60 ? "及格" : "不及格"
```

**Ruby 习惯用法**：三元运算符在 Ruby 中不常用，因为 `if/unless` 单行形式通常更清楚：

```ruby
# 传统三元
result = x > 0 ? "正" : "负"

# Ruby 风格
result = if x > 0; "正"; else; "负"; end
```

## 常见错误

### 错误 1：在 unless 中使用 else

```ruby
# ❌ unless 不建议带 else（语义混乱）
unless user.active?
  puts "已禁用"
else
  puts "活跃"
end

# ✅ 改用 if 更清晰
if user.active?
  puts "活跃"
else
  puts "已禁用"
end
```

### 错误 2：case 匹配时忘记顺序

```ruby
# 注意：case 从上到下匹配，更具体的条件放前面！
case value
when 1..10
  puts "1-10"
when 1..5       # 永远不会执行！被上面的 1..10 截胡了
  puts "1-5"
end
```

### 错误 3：用 while 做数组遍历

```ruby
# ❌ C/C++ 风格（Ruby 不推荐）
i = 0
while i < arr.length
  puts arr[i]
  i += 1
end

# ✅ Ruby 风格
arr.each { |item| puts item }
```

## 动手练习

### 练习 1：FizzBuzz

```ruby
# 经典面试题：打印 1-20
# 3的倍数打印 "Fizz"，5的倍数打印 "Buzz"
# 同时是3和5的倍数打印 "FizzBuzz"
```

<details>
<summary>参考答案</summary>

```ruby
(1..20).each do |n|
  if n % 15 == 0
    puts "FizzBuzz"
  elsif n % 3 == 0
    puts "Fizz"
  elsif n % 5 == 0
    puts "Buzz"
  else
    puts n
  end
end
```

</details>

### 练习 2：用 case 分类

```ruby
# 根据分数输出等级（100-90: A, 89-80: B, 79-70: C, 69-60: D, <60: F）
# 用 case when range 写法
```

<details>
<summary>参考答案</summary>

```ruby
def grade(score)
  case score
  when 90..100 then "A"
  when 80..89  then "B"
  when 70..79  then "C"
  when 60..69  then "D"
  else             "F"
  end
end
```

</details>

## 故障排查 (FAQ)

### Q: Ruby 有没有 switch 语句？

**A**: 没有。Ruby 用 `case/when` 替代 switch。它更强大——支持 Range 匹配和正则匹配，不仅是等号比较。

### Q: next 和 break 有什么区别？

**A**: `next` 跳过当前迭代（进入下一次循环），`break` 终止整个循环。类比：next 是跳过一个音符，break 是终止整首歌。

### Q: Ruby 为什么不用 for 循环？

**A**: Ruby 的 `for` 关键字存在但很少使用。`each` 迭代器更 Ruby——闭包隔离作用域、支持方法链、更符合函数式风格。

## 小结

**核心要点**：

1. **if 也是表达式**：可以赋值给变量，不只能做语句
2. **unless 仅用于简单否定**：复杂的不要强行用 unless
3. **case 不只匹配等号**：支持 Range、正则、类名
4. **each 是主流遍历方式**：而非 while/for
5. **next/break 控制循环**：next 跳过当前，break 终止全部
6. **Range 是条件匹配利器**：`90..100` 用于 case 非常直观

**术语**：

- **Expression（表达式）**：求值并返回结果（if、case 都是）
- **Iteration（迭代）**：重复执行代码块
- **Guard Clause（卫语句）**：提前返回的条件判断
- **Predicate（谓词）**：返回 true/false 的方法（以 `?` 结尾）

## 继续学习

- **上一章**: [哈希](hashes.md)
- **下一章**: [方法定义与调用](methods.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic control-flow` 查看完整示例代码。
