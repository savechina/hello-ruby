# 数字与数值运算

## 开篇故事

数字是编程的基本材料。Ruby 处理数字的方式与其他语言不同——整数没有大小限制、浮点数遵循 IEEE 754、金融计算用 BigDecimal。了解 Ruby 数字的特性，能避免精度错误和性能陷阱。

## 本章适合谁

如果你的程序涉及数值计算、财务数据、或需要处理大范围数字，本章帮你理解 Ruby 数字系统的完整图景。

## 你会学到什么

1. Integer 的任意精度
2. Float 精度问题
3. BigDecimal 用于金融计算
4. Rational 精确分数
5. 进制转换和位运算
6. 浮点数舍入
7. 数字格式化输出

## 前置要求

- [变量与作用域](variables.md) — 基础概念

## 第一个例子

```ruby
# 运行: hello basic numbers

# Ruby 整数没有大小限制
small_int = 42
huge_int = 2**100
puts "小整数: #{small_int}"
puts "超大整数: #{huge_int}"
# → 1267650600228229401496703205376
```

**为什么这很强大**：Ruby 3 中 Fixnum 和 Bignum 已统一为 Integer，不再区分"小整数"和"大整数"。内部自动管理，你不需要关心。

## 整数类型

```ruby
small = 42
big = 999_999_999_999_999_999   # 用下划线分隔更易读
huge = 2**100                   # 自动处理超大整数

puts small.class  # Integer
puts big.class    # Integer（不是 Bignum！）
puts huge.class   # Integer

# 任意精度意味着没有溢出
puts huge + 1  # 1267650600228229401496703205377
```

**Ruby 2 vs Ruby 3**：Ruby 2 有 Fixnum 和 Bignum 两个类（自动切换）。Ruby 3 统一为 Integer。你不需要知道这个区别，但看老代码时可能会遇到。

## 浮点数

Float 遵循 IEEE 754 双精度标准，有效精度约 15-17 位十进制数。

```ruby
pi = 3.14159265358979
tiny = 1.0e-10        # 科学计数法
huge = 1.5e20

puts pi.class     # Float
puts Float::DIG       # 15（有效精度位数）
puts Float::EPSILON   # 2.220446049250313e-16
```

### 浮点精度问题

```ruby
puts 0.1 + 0.2      # 0.30000000000000004（不是 0.3！）
puts (0.1 + 0.2).round(10) == 0.3  # true
```

**为什么会这样**：二进制无法精确表示 0.1。这是所有语言都有的问题，不是 Ruby 独有的。

## BigDecimal — 金融级精确计算

```ruby
require "bigdecimal"
require "bigdecimal/util"

# 精确的小数运算
exact = BigDecimal("0.1") + BigDecimal("0.2")
puts exact  # 0.3e0（精确的 0.3）

# 金额计算
price = BigDecimal("99.99")
tax = BigDecimal("0.13")
total = price * (1 + tax)
puts "￥#{price} × 1.13 = ￥#{total.round(2)}"
# → ￥99.99 × 1.13 = ￥112.99
```

**什么时候用 BigDecimal**：任何涉及金钱的计算。浮点数的精度问题会导致 0.01 的误差，在财务系统中这是 unacceptable 的。

## 算术运算符

```ruby
a = 17
b = 5

puts "#{a} + #{b} = #{a + b}"       # 22
puts "#{a} - #{b} = #{a - b}"       # 12
puts "#{a} * #{b} = #{a * b}"       # 85
puts "#{a} / #{b} = #{a / b}"       # 3（整数除法！）
puts "#{a}.to_f / #{b} = #{a.to_f / b}"  # 3.4（浮点除法）
puts "#{a} % #{b} = #{a % b}"       # 2（取模）
puts "#{a} ** #{b} = #{a ** b}"     # 1419857（幂）
puts "#{a}.divmod(#{b}) = #{a.divmod(b)}"  # [3, 2]（商和余数）
```

**注意整数除法**：`17 / 5` 在 Ruby 中等于 3（截断），不是 3.4。用 `to_f` 转换或直接把除数写为浮点数：`17 / 5.0`。

## 整数方法

```ruby
n = 0xFF  # 255

puts "#{n}.to_s(16) = #{n.to_s(16)}"  # ff（十六进制）
puts "#{n}.to_s(2)  = #{n.to_s(2)}"   # 11111111（二进制）
puts "#{n}.to_s(8)  = #{n.to_s(8)}"   # 377（八进制）
puts "#{n}.bit_length = #{n.bit_length}"  # 8（二进制位数）
puts "#{n}.even?    = #{n.even?}"      # false
puts "#{n}.odd?     = #{n.odd?}"       # true

# Ruby 提供了奇偶判断
puts 42.even?   # true
puts 43.odd?    # true
```

## 浮点数舍入

```ruby
f = 3.7
nf = -3.7

puts "#{f}.ceil     = #{f.ceil}"      # 4（向上）
puts "#{f}.floor    = #{f.floor}"     # 3（向下）
puts "#{f}.round    = #{f.round}"     # 4（四舍五入）
puts "#{f}.truncate = #{f.truncate}"  # 3（向零）

puts "#{nf}.ceil     = #{nf.ceil}"    # -3
puts "#{nf}.floor    = #{nf.floor}"   # -4
puts "#{nf}.truncate = #{nf.truncate}"# -3
```

**注意负数的区别**：
- `ceil`（向上）：-3.7 → -3
- `floor`（向下）：-3.7 → -4
- `truncate`（向零）：-3.7 → -3

## Rational 有理数

```ruby
r1 = Rational(1, 3)
r2 = Rational(2, 5)

puts r1               # (1/3)
puts r2 + r1          # (11/15)
puts r1 * 3           # (1/1)（精确等于 1）
puts Rational(0.5)    # (1/2)
```

**有理数的意义**：分数运算不会丢失精度。`1/3` 在浮点数中是 `0.3333...` 的近似值，Rational 能精确表示。

## 数字格式化

```ruby
v = 42.123456789
puts sprintf("%.2f", v)       # "42.12"
puts sprintf("%05d", 42)      # "00042"
puts sprintf("%x", 255)       # "ff"
puts sprintf("%08b", 42)      # "00101010"
puts sprintf("%e", 1234567)   # "1.234567e+06"

# % 运算符
puts '%.3f' % 3.14159    # "3.142"
puts '%010d' % 42        # "0000000042"
```

## 特殊值

```ruby
puts Float::MAX           # 最大浮点数
puts Float::INFINITY      # Infinity
puts Float::NAN           # NaN

puts 1.0 / 0.0            # Infinity
puts 0.0 / 0.0            # NaN
puts Float::NAN.nan?      # true
puts Float::INFINITY.infinite?  # 1
puts 1.0.finite?          # true
```

## 常见错误

### 错误 1：浮点数直接比较

```ruby
# ❌ 不可靠
if 0.1 + 0.2 == 0.3
  puts "相等"
end

# ✅ 用 epsilon 容差
if (0.1 + 0.2 - 0.3).abs < 1e-10
  puts "近似相等"
end
```

### 错误 2：用 Float 做金额计算

```ruby
# ❌ 精度丢失
total = 99.99 * 0.13
# → 13.099999999999998（不是精确的 13.0999...999...）

# ✅ 用 BigDecimal
total = BigDecimal("52.99") * BigDecimal("0.13")
```

### 错误 3：整数除法陷阱

```ruby
# ❌ 17 / 5 = 3，不是 3.4
result = 17 / 5
puts result  # 3

# ✅ 转浮点数
result = 17.to_f / 5
puts result  # 3.4
```

## 动手练习

### 练习 1：温度转换

```ruby
# 写一个 celsius_to_fahrenheit(c) 方法
# 公式: F = C * 9/5 + 32
# 用 Rational 保持精度
```

<details>
<summary>参考答案</summary>

```ruby
def celsius_to_fahrenheit(c)
  c * Rational(9, 5) + 32
end

puts celsius_to_fahrenheit(0)   # 212
puts celsius_to_fahrenheit(100) # 212（浮点 212.0）
```

</details>

### 练习 2：计算斐波那契

```ruby
# 计算前 20 个斐波那契数
# 提示：递归或迭代
```

<details>
<summary>参考答案</summary>

```ruby
fib = [0, 1]
18.times do
  fib << fib[-1] + fib[-2]
end
puts fib.inspect
```

</details>

## 故障排查 (FAQ)

### Q: 什么时候用 Integer，什么时候用 Float？

**A**: 精确计算用 Integer（计数、索引、ID），近似计算用 Float（物理量、科学计算），金融计算用 BigDecimal。

### Q: Float 精度不够怎么办？

**A**: 用 BigDecimal。`BigDecimal` 支持任意精度（但速度较慢）。

### Q: 怎么把字符串转为数字？

**A**:
- `"42".to_i` → 42
- `"3.14".to_f` → 3.14
- `Integer("42")` → 42（失败抛异常）
- `Float("3.14")` → 3.14（失败抛异常）

`to_i` 和 `to_f` 失败时返回 0（宽松），`Integer()` 和 `Float()` 失败时抛异常（严格）。

## 小结

**核心要点**：

1. **Integer 任意精度**：没有大小限制，不会溢出
2. **Float 有精度问题**：0.1 + 0.2 ≠ 0.3
3. **金融计算用 BigDecimal**：避免浮点精度丢失
4. **Rational 精确分数**：不丢失精度
5. **整数除法会被截断**：17/5 = 3，不是 3.4
6. **格式化用 sprintf**：控制输出精度

**术语**：

- **Arbitrary Precision（任意精度）**：不受固定位数限制
- **IEEE 754**：浮点数标准
- **Epsilon（ε）**：最小可表示差值
- **Rational Number（有理数）**：分数形式
- **Float（浮点数）**：有限精度的小数
- **BigDecimal**：高精度小数库

## 继续学习

- **上一章**: [异常处理](exceptions.md)
- **下一章**: [符号（Symbol）](symbols.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic numbers` 查看完整示例代码。
