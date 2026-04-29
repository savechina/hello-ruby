# 阶段复习：基础部分

## 开篇故事

想象你学完了驾驶理论——交通规则、标志含义、操作步骤全都清楚。但真正上路前，你需要一次"驾驶模拟考"——把分散的概念整合成完整的能力。阶段复习就是你的实践练习——把变量、控制流、方法、集合等概念串起来。

## 本章适合谁

如果你已经完成了基础部分所有 15 章，现在想检验自己的学习成果并综合运用，本章适合你。

## 你会学到什么

完成本章后，你可以：

1. 综合运用变量、控制流、方法、集合知识
2. 识别 Ruby 代码中的最佳实践
3. 设计包含类、模块、方法的小系统
4. 调试常见 Ruby 错误

## 前置要求

完成以下所有章节：
- [变量与作用域](variables.md)
- [字符串操作](strings.md)
- [数组](arrays.md)
- [哈希](hashes.md)
- [控制流](control-flow.md)
- [方法定义与调用](methods.md)
- [类与对象](classes.md)
- [模块与混入](modules.md)
- [块与 Proc](blocks-procs.md)
- [文件 I/O](file-io.md)
- [异常处理](exceptions.md)
- [数字与数值运算](numbers.md)
- [符号](symbols.md)
- [正则表达式](regex.md)
- [文件管理](file-management.md)

## 知识整合图

```
基础部分知识体系:

变量与数据类型 → 字符串 → 集合（数组/哈希） → 控制流 → 方法
                                              ↓
类 ←── 模块 ←── 块与 Proc ←── 文件 I/O ←── 异常
                                              ↓
数字 ←── 符号 ←── 正则 ←── 文件管理 → 🎓 阶段复习
```

每个概念都建立在前一个概念之上，形成完整的知识链。

## 复习范围

第 1-15 章：变量、字符串、数组、哈希、控制流、方法、类、模块、块、文件 I/O、异常、数字、符号、正则、文件管理

## 综合练习 1：学生成绩管理系统

### 需求

设计一个简单的学生成绩管理系统：
- 学生有姓名、学号、成绩列表
- 计算平均分、最高分、最低分
- 按成绩排序
- 输出成绩单

### 练习代码

```ruby
# TODO: 实现 Student 类
# 字段: name (String), id (String), scores (Array<Integer>)
# 方法: average_score, max_score, min_score, grade_level

# TODO: 实现 GradeBook 类
# 方法: add_student, find_student, print_report
```

<details>
<summary>参考答案</summary>

```ruby
class Student
  attr_reader :name, :id, :scores

  def initialize(name, id, scores = [])
    @name = name
    @id = id
    @scores = scores
  end

  def average_score
    return 0.0 if scores.empty?
    scores.sum.to_f / scores.length
  end

  def max_score
    scores.max || 0
  end

  def min_score
    scores.min || 0
  end

  def grade_level
    avg = average_score
    case avg
    when 90..100 then "A"
    when 80..89  then "B"
    when 70..79  then "C"
    else "D"
    end
  end

  def to_s
    "#{name} (#{id}): 平均 #{average_score.round(1)} 分, 等级 #{grade_level}"
  end
end

class GradeBook
  def initialize
    @students = {}
  end

  def add_student(student)
    @students[student.id] = student
  end

  def find_student(id)
    @students[id]
  end

  def print_report
    @students.values.sort_by(&:average_score).reverse.each do |s|
      puts s
    end
  end
end
```

</details>

## 综合练习 2：日志分析器

### 需求

分析以下格式的日志文件，统计每个 IP 的请求次数和错误率：

```
192.168.1.1 - GET /api/users 200
192.168.1.2 - POST /api/login 401
192.168.1.1 - GET /api/users 200
```

```ruby
# TODO: 实现 LogAnalyzer 类
# 方法: parse_line, count_by_ip, error_rate
```

<details>
<summary>参考答案</summary>

```ruby
class LogAnalyzer
  def initialize
    @data = []
  end

  def parse_line(line)
    # 解析日志
    ip, method, path, status = line.match(/(\d+\.\d+\.\d+\.\d+) - (\w+) (\S+) (\d+)/).captures
    { ip: ip, method: method, path: path, status: status.to_i }
  rescue
    nil
  end

  def count_by_ip
    @data.group_by { |r| r[:ip] }.map do |ip, records|
      [ip, records.length]
    end.to_h
  end

  def error_rate(ip)
    records = @data.select { |r| r[:ip] == ip }
    return 0.0 if records.empty?
    
    errors = records.count { |r| r[:status] >= 400 }
    errors.to_f / records.length * 100
  end
end
```

</details>

## 综合练习 3：配置管理器

### 需求

设计一个配置管理器：
- 支持嵌套哈希配置
- 支持默认值合并
- 支持覆盖配置

```ruby
# TODO: 实现 ConfigManager 类
# 方法: set, get, merge, save, load
```

<details>
<summary>参考答案</summary>

```ruby
class ConfigManager
  def initialize(defaults = {})
    @config = defaults
  end

  def set(key, value)
    # 设置配置项
    @config[key] = value
  end

  def get(key, default = nil)
    # 获取配置项
    @config.dig(*key.to_s.split(".")) || default
  end

  def merge(other)
    # 合并配置
    @config = @config.deep_merge(other)
  end

  def save(path)
    require "yaml"
    File.write(path, @config.to_yaml)
  end

  def load(path)
    require "yaml"
    @config = YAML.load_file(path)
  end
end
```

</details>

## 知识检查

### 问题 1：变量作用域

```ruby
class Test
  @@count = 0
  @count = 10

  def self.check_count
    puts "类变量 @@count: #{@@count}"
    puts "类实例变量 @count: #{@count}"
  end
end

Test.check_count
```

<details>
<summary>输出是什么？</summary>

```
类变量 @@count: 0
类实例变量 @count: 10
```

</details>

### 问题 2：块与 Proc

```ruby
def test_block
  [1, 2, 3].each do |n|
    Proc.new { return "从块 return" }.call
    puts "这行会执行吗？"
  end
  "循环结束"
end

puts test_block
```

<details>
<summary>输出是什么？</summary>

```
从块 return
```

Proc.new 的 return 会跳出整个 test_block 方法。

</details>

### 问题 3：哈希键

```ruby
h = { :name => "符号", "name" => "字符串" }
puts h[:name]
puts h["name"]
```

<details>
<summary>输出是什么？</summary>

```
符号
字符串
```

</details>

### 问题 4：正则匹配

```ruby
text = "2025-04-15"
match = text.match(/(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/)
puts match[:year]
puts match[:month]
```

<details>
<summary>输出是什么？</summary>

```
2025
04
```

</details>

## 常见错误回顾

| 错误 | 原因 | 修复 |
|------|------|------|
| `undefined local variable` | 变量拼写错误或拼写 | 检查变量名拼写 |
| `undefined method` | 调用了没有定义 | 检查调用方法 |
| `TypeError` | 类型不匹配 | 用 `to_s`、`to_i` 转换 |
| `FrozenError` | frozen_string_literal | 用 `.dup` 创建可变副本 |
| `KeyError` | 哈希键不存在 | 用 `fetch` 带默认值 |

## 小结

**核心要点**：

1. **变量有五类**：局部、实例、类、全局、常量
2. **字符串操作丰富**：插值、方法链、frozen
3. **集合三剑客**：map/select/reduce
4. **控制流：if/case/unless/循环**
5. **类是 OOP 基础**：实例变量、方法、继承
6. **模块是组合优于继承**
7. **块是 Ruby 的灵魂**：yield/Proc/Lambda
8. **文件/异常/正则/文件管理**

## 术语表

| English | 中文 |
|---------|------|
| Scope | 作用域 |
| Interpolation | 插值 |
| Collection | 集合 |
| Control Flow | 控制流 |
| Class | 类 |
| Object (对象) | 对象 |
| Module | 模块 |
| Mixin | 混入 |
| Block | 块 |
| Iterator | 迭代器 |
| Yield | 产出 |

---

**下一步**：[高级进阶](../advance/advance-overview.md) 🎓

**相关**: [基础入门](basic-overview.md) | [高级进阶](../advance/advance-overview.md)
