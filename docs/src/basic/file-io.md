# 文件 I/O

## 开篇故事

文件 I/O 是每个实用程序都需要的功能。Ruby 提供了一套简洁的文件操作 API——`File.open`、`Dir.glob`、`Pathname`、`CSV`——让你用几行代码就能完成文件的读写、匹配和解析。

## 本章适合谁

如果你需要读取配置文件、解析 CSV 数据、批量处理文件，本章涵盖了 Ruby 标准库中最常用的文件操作。

## 你会学到什么

1. `File.write` 和 `File.read`
2. `File.open` 的块模式（自动关闭文件）
3. `Pathname` — 面向对象的文件路径
4. `Dir.glob` — 文件模式匹配
5. `CSV` 读写
6. `IO.foreach` — 逐行读取

## 前置要求

- [数组](arrays.md) — 数据存储基础
- [字符串操作](strings.md) — 字符串处理

## 第一个例子

```ruby
# 运行: hello basic file-io

require "tempfile"

tmp = Tempfile.new("hello_ruby_demo")
content = "第一行\n第二行\n第三行\n"
bytes_written = File.write(tmp.path, content)
puts "写入 #{bytes_written} 字节"

read_content = File.read(tmp.path)
puts "读取内容: #{read_content}"
```

**为什么这很方便**：Ruby 的文件 API 非常直观。`File.write` 一行写完，`File.read` 一行读完。

## File.write 和 File.read

```ruby
# 写入文件
File.write("output.txt", "Hello, World!\n")

# 读取整个文件
content = File.read("output.txt")
puts content
```

`File.write` 返回写入的字节数。`File.read` 返回完整字符串。

## File.open 块模式

```ruby
# 块形式自动关闭文件，即使块内抛异常
File.open("output.txt", "a") do |f|
  f.puts "追加一行"
  f.puts "又追加一行"
end
# 退出块时自动 f.close
```

**打开模式**：

| 模式 | 含义 |
|------|------|
| `"r"` | 只读（默认） |
| `"w"` | 写入（清空已有内容） |
| `"a"` | 追加（在尾部添加） |
| `"r+"` | 读写 |

**块模式是 Ruby 惯例**：`File.open` 如果传块，块执行完毕后自动关闭文件，即使块内抛异常。

## Pathname — 面向对象路径操作

```ruby
require "pathname"

path = Pathname.new("/usr/local/bin/ruby")

puts "basename: #{path.basename}"    # "ruby"
puts "dirname:  #{path.dirname}"     # "/usr/local/bin"
puts "extname:  #{path.extname}"     # ""（无扩展名）
puts "存在？#{path.exist?}"
puts "可读？#{path.readable?}"
puts "大小: #{path.size} 字节"
```

`Pathname` 的 `/` 运算符合并路径：

```ruby
project_root = Pathname.new(".")
lib_path = project_root / "lib" / "hello_ruby.rb"
# → lib/hello_ruby.rb
```

## Dir.glob — 文件模式匹配

```ruby
# 查找当前目录的所有 .rb 文件
rb_files = Dir.glob("*.rb")

# 递归查找
all_rb = Dir.glob("**/*.rb")

# 匹配多种扩展名
all_docs = Dir.glob("**/*.{rb,md}")

# Pathname 也有 glob
Pathname.glob("docs/src/**/*.md")
```

**glob 模式**：
- `*` — 匹配单个目录层级
- `**` — 递归匹配所有层级
- `{a,b}` — 匹配 a 或 b

## IO.foreach — 逐行读取

```ruby
File.write("large.txt", "line1\nline2\nline3\n")

line_count = 0
IO.foreach("large.txt") do |line|
  line_count += 1
  puts "第 #{line_count} 行: #{line.chomp}"
end
```

`IO.foreach` 逐行读取，不把所有内容加载到内存。**适合大文件**。

## CSV 读写

```ruby
require "csv"

csv_content = <<~CSV
  name,age,city
  Alice,30,Shanghai
  Bob,25,Beijing
  Charlie,35,Shenzhen
CSV

File.write("data.csv", csv_content)

# 逐行读取
CSV.foreach("data.csv", headers: true) do |row|
  puts "#{row["name"]} (#{row["age"]}岁), 来自 #{row["city"]}"
end

# 读取全部
all_rows = CSV.read("data.csv", headers: true)
puts "共 #{all_rows.length} 行"
```

## 常见错误

### 错误 1：忘记关闭文件

```ruby
f = File.open("data.txt")
content = f.read
# 忘记 f.close 导致文件描述符泄漏
```

**修复**：用块模式自动关闭。

### 错误 2：用 File.read 处理大文件

```ruby
# ❌ 1GB 文件会把 1GB 数据加载到内存
content = File.read("huge_log.txt")

# ✅ 逐行处理（内存友好）
IO.foreach("huge_log.txt") do |line|
  process(line)
end
```

### 错误 3：路径拼接用字符串拼接

```ruby
# ❌ 容易出错
path = "/tmp/" + filename  # 可能变成 "//tmp//file.txt"

# ✅ 用 Pathname 或 File.join
path = Pathname.new("/tmp") / filename
path = File.join("/tmp", filename)
```

## 动手练习

### 练习 1：统计文件行数

```ruby
# 写一个方法 count_lines(filename)
# 返回文件的行数
```

<details>
<summary>参考答案</summary>

```ruby
def count_lines(filename)
  IO.foreach(filename).count
end
```

</details>

### 练习 2：查找大文件

```ruby
# 查找当前目录下所有超过 1MB 的文件
```

<details>
<summary>参考答案</summary>

```ruby
Dir.glob("**/*").select do |f|
  File.file?(f) && File.size(f) > 1_000_000
end
```

</details>

## 故障排查 (FAQ)

### Q: File.read 和 IO.foreach 的区别？

**A**: `File.read` 一次全部读入内存；`IO.foreach` 逐行读取。小文件用 `read`，大文件用 `foreach`。

### Q: Pathname 和 File 的区别？

**A**: `File` 是模块方法（函数式），`Pathname` 是面向对象。`Pathname` 更优雅（支持 `/` 操作符），`File` 更直接。两者都用，`Pathname` 在路径操作中更清晰。

### Q: 怎么判断路径是文件还是目录？

**A**: 用 `File.file?` 和 `File.directory?`（或 `FileTest` 模块）。

## 小结

**核心要点**：

1. **File.write/read 最简单**：一行搞定
2. **File.open 用块模式**：自动关闭文件，安全
3. **Pathname 是 OOP 路径操作**：支持 `/` 运算符
4. **Dir.glob 查找文件**：`**/*.rb` 递归匹配
5. **IO.foreach 处理大文件**：逐行读取，内存友好
6. **CSV 是标准库**：headers: true 使用行头

**术语**：

- **File Handle（文件句柄）**：打开文件的引用
- **Stream（流）**：文件内容的序列
- **Buffer（缓冲区）**：内存临时存储区
- **Descriptor（描述符）**：操作系统级别的文件标识

## 继续学习

- **上一章**: [块与 Proc](blocks-procs.md)
- **下一章**: [异常处理](exceptions.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic file-io` 查看完整示例代码。
