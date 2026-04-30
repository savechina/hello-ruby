# 数据处理脚本 (Data Processing Scripting)

## 概述

Ruby 作为脚本语言在数据处理领域有独特优势：简洁的语法、强大的 Enumerable 方法、灵活的文本处理能力，以及 CSV/JSON/YAML 的标准库支持。相比 Python 和 Bash，Ruby 的可读性更高，适合快速编写数据处理管道。本章节将介绍格式转换、文本管道、单行模式，以及 Ruby 与其他脚本的对比。

核心要点：
- **CSV 处理**：CSV.read/parse/open，支持 headers
- **JSON/YAML**：JSON/YAML.parse/dump，格式互转
- **文本管道**：grep/grep_v/map 链式处理
- **单行模式**：ruby -e 快速转换
- **Ruby 优势**：可读性高于 Bash，灵活性优于 Python

## 示例

### 示例 1：CSV 解析与生成

```ruby
require 'csv'

# 读取 CSV（带 headers）
data = CSV.read('data.csv', headers: true)
puts data.first['name']  # => "Alice"

# 流式处理大 CSV
CSV.foreach('large.csv', headers: true) do |row|
  puts row['email'] if row['active'] == 'true'
end

# 生成 CSV
CSV.open('output.csv', 'w') do |csv|
  csv << ['name', 'age']
  csv << ['Bob', 25]
end
```

### 示例 2：JSON/YAML 格式转换

```ruby
require 'json'
require 'yaml'

# JSON 转 YAML
json_data = '{"users": [{"name": "Alice"}]}'
yaml_data = YAML.dump(JSON.parse(json_data))
puts yaml_data
# => ---
#    users:
#    - name: Alice

# YAML 转 JSON
yaml_content = YAML.load_file('config.yaml')
json_output = JSON.pretty_generate(yaml_content)
File.write('config.json', json_output)
```

### 示例 3：文本管道处理

```ruby
# grep-like 过滤
lines = File.readlines('log.txt')
errors = lines.grep(/ERROR/)
active = lines.grep_v(/DEBUG/)

# awk-like 字段提取
fields = lines.map { |l| l.split(',').first }

# 统计频率
counts = lines.tally
puts counts['success']  # => 150

# 组合管道
result = lines.lazy
  .grep(/ERROR/)
  .map { |l| l.split(':')[1] }
  .take(10)
  .to_a
```

## 知识检查

1. CSV.foreach 与 CSV.read 有什么区别？大文件应该用哪个？
2. 如何实现 JSON 与 YAML 的相互转换？需要哪些标准库？
3. Ruby 的 grep/grep_v 与 Bash grep 有什么相似之处？tally 方法做什么？

## 参考资源

- [Ruby CSV 文档](https://ruby-doc.org/stdlib/CSV.html)
- [Ruby JSON 模块](https://ruby-doc.org/stdlib/JSON.html)
- [Ruby YAML 文档](https://ruby-doc.org/stdlib/YAML.html)
- [Enumerable 方法](https://ruby-doc.org/core/Enumerable.html)