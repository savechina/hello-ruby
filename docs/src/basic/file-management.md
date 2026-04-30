# 文件管理

## 开篇故事

文件管理是文件系统操作的集合。你经常需要：列出某个目录下的所有文件、查找特定类型的文件、检查文件是否存在、获取文件大小、创建临时目录。**File** 方法、**Dir** 的目录操作、**Pathname** 对象的文件路径操作、**FileTest** 方法的文件属性检查、临时目录创建。

## 本章适合谁

如果你需要写脚本、做批量文件处理、或管理文件系统，本章覆盖了 Ruby 标准库中所有文件管理的工具。

## 你会学到什么

1. **File 路径操作** — join、basename、dirname、extname
2. **Dir** — pwd、entries、each_child、mkpath、rmdir
3. **FileTest** — exist?、file?、directory?、size、identical?
4. **Pathname** — basename、dirname、extname、ascend、glob
5. **临时目录** — tmpdir、mktmpdir

## 前置要求

- [字符串操作](strings.md) — 路径是字符串
- [数组](arrays.md) — 遍历文件列表

## 第一个例子

```ruby
# 运行: hello basic file-management

# Pathname — 面向对象的文件路径
pn = Pathname.new("/usr/local/bin/ruby")
puts "basename: #{pn.basename}"    # ruby
puts "dir: #{pn.dirname}"         # /usr/local/bin
```

**为什么这比 File.basename 好**：Pathname 提供路径的"面向对象"接口。`/` 操作符拼接路径，比 `File.join` 更优雅。

## File 路径操作

```ruby
# 拼接路径
joined = File.join("usr", "local", "bin", "ruby")
puts "File.join: #{joined}"

# 提取文件名
basename = File.basename("/usr/local/bin/ruby")
puts "File.basename: #{basename}"

# 提取文件名（去掉扩展名）
basename_no_ext = File.basename("/usr/local/bin/ruby", ".rb")
puts "File.basename (去扩展名): #{basename_no_ext}"

# 提取目录名
dirname = File.dirname("/usr/local/bin/ruby")
puts "File.dirname: #{dirname}"

# 提取扩展名
extname = File.extname("/usr/local/bin/script.rb")
puts "File.extname: #{extname}"

# 判断是否为绝对路径
puts "绝对路径? #{File.absolute_path?("/usr/local")}"

# 展开路径（~ 缩写）
expanded = File.expand_path("~")
puts "扩展 ~/ #{expanded}"
```

## Dir 目录操作

```ruby
# 当前工作目录
puts "Dir.pwd: #{Dir.pwd}"

# 获取当前目录下的 .rb 文件
puts "当前目录 .rb 文件:"
Dir.glob("*.rb").each { |f| puts "  #{f}" }

# 递归查找所有 .rb 文件
rb_count = Dir.glob("**/*.rb").length
puts "项目中 .rb 文件总数: #{rb_count}"

# 匹配多种扩展名（花括号扩展）
all_docs = Dir.glob("**/*.{rb,md}")
puts "Ruby + Markdown 文件总数: #{all_docs.length}"

# Dir.entries — 列出目录所有内容（含 . 和 ..）
puts "Dir.entries('lib/hello/basic'):"
Dir.entries("lib/hello/basic").each { |entry| puts "  #{entry}" }

# Dir.each_child — 迭代子目录/文件（不含 . 和 ..）
puts "Dir.each_child('lib/hello/basic'):"
Dir.each_child("lib/hello/basic") { |child| puts "  #{child}" }
```

## FileTest — 文件属性检查

```ruby
gemfile_path = "Gemfile"

# 检查文件是否存在
puts "FileTest.exist?(#{gemfile_path}): #{FileTest.exist?(gemfile_path)}"

# 检查是否为普通文件
puts "FileTest.file?(#{gemfile_path}): #{FileTest.file?(gemfile_path)}"

# 检查是否为目录
puts "FileTest.directory?('lib'): #{FileTest.directory?("lib")}"

# 检查可读/可写权限
puts "FileTest.readable?(#{gemfile_path}): #{FileTest.readable?(gemfile_path)}"

# 获取文件大小（字节）
size = FileTest.size(gemfile_path)
puts "FileTest.size(#{gemfile_path}): #{size} bytes"

# 检查两个路径是否指向同一文件
readme_a = "README.md"
readme_real = File.realpath(readme_a)
puts "FileTest.identical?(#{readme_a}, #{readme_real}): #{FileTest.identical?(readme_a, readme_real)}"
```

## Pathname — 面向对象路径操作

```ruby
# 创建 Pathname 对象
pn = Pathname.new("/usr/local/bin/ruby")
puts "Pathname('/usr/local/bin/ruby'):"
puts "  .basename: #{pn.basename}"
puts "  .dirname:  #{pn.dirname}"
puts "  .extname:  #{pn.extname}"
puts "  .ascend:   #{pn.ascend.to_a}"

# / 运算符拼接路径（比 File.join 更优雅）
project_root = Pathname.new(".")
lib_path = project_root / "lib" / "hello.rb"
puts "\nPathname / 运算符:"
puts "  lib/hello.rb 路径: #{lib_path}"
puts "  存在？#{lib_path.exist?}"

# 读取文件内容
readme_path = Pathname.new("README.md")
if readme_path.exist?
  first_three = readme_path.readlines.take(3)
  puts "\nREADME.md 前 3行:"
  first_three.each { |line| puts "  ${line.chomp}" }
end

# Pathname.glob — 匹配文件模式
md_count = Pathname.glob("docs/src/**/*.md").length
puts "\nPathname.glob('docs/src/**/*.md'): #{md_count} 个文件"

# relative_path_from — 计算相对路径
absolute = Pathname.new("/usr/local/bin/ruby")
base = Pathname.new("/usr/local")
relative = absolute.relative_path_from(base)
puts "\nPathname#relative_path_from:"
puts "  #{absolute} 相对 /usr/local 是: #{relative}"
```

## 临时目录 — Dir.mktmpdir

```ruby
Dir.mktmpdir("hello_") do |tmp_dir|
  tmp_path = Pathname.new(tmp_dir)
  puts "创建临时目录: #{tmp_dir}"

  # 在临时目录中创建文件
  demo_file = tmp_path / "demo.txt"
  demo_file.write("Hello from 临时文件!")
  puts "  写入 #{demo_file}: #{demo_file.read}"

  # 创建子目录
  subdir = tmp_path / "subdir"
  subdir.mkpath
  subdir_file = subdir / "nested.txt"
  subdir_file.write("嵌套文件内容")

  # 列出临时目录的所有内容
  puts "  临时目录内容:"
  tmp_path.glob("**/*").each do |item|
    type = item.directory? ? "[目录]" : "[文件]"
    puts "    #{type} #{item.relative_path_from(tmp_path)}"
  end

  puts "  临时目录大小: #{tmp_path.size} (目录元数据大小)"
  puts "  临时目录可读：#{tmp_path.readable?}"
end
# 退出块后，临时目录已自动清理
puts "临时目录已自动清理完毕"
```

**mktmpdir 的优势**：自动清理临时文件，不需要手动 `rm -rf`。

## 常见错误

### 错误 1：用字符串拼接处理路径

```ruby
# ❌ 容易出错，不同 OS 的斜杠不同
path = "/tmp/" + filename  # 可能 "//tmp//file.txt"
path = filename + "/"      # 可能 "/tmp//file.txt"

# ✅ 用 File.join 或 Pathname
path = File.join("/tmp", filename)
path = Pathname.new("/tmp") / filename
```

### 错误 2：检查文件存在后操作

```ruby
# ❌ TOCTOU 问题：检查和操作之间文件可能被删除
if File.exist?("data.txt")
  content = File.read("data.txt")  # 可能已经不存在了
end

# ✅ 用 rescue 处理
begin
  content = File.read("data.txt")
rescue Errno::ENOENT
  puts "文件不存在"
end
```

### 错误 3：忘记临时目录的清理

```ruby
# ❌ 手动创建的临时目录不会自动清理
tmp = Dir.mktmpdir
# ... 使用后忘记清理

# ✅ 用 Dir.mktmpdir 块形式
Dir.mktmpdir("hello_") do |tmp_dir|
  # ... 自动清理
end
```

## 动手练习

### 练习 1：递归查找大文件

```ruby
# 查找当前目录下所有超过 1MB 的文件，按大小排序
```

<details>
<summary>参考答案</summary>

```ruby
Dir.glob("**/*").map do |f|
  next unless File.file?(f)
  size = File.size(f)
  [f, size] if size > 1_000_000
end.compact.sort_by(&:last)
```

</details>

### 练习 2：批量重命名

```ruby
# 将当前目录所有 .txt 文件改为 .md
```

<details>
<summary>参考答案</summary>

```ruby
Dir.glob("*.txt").each do |f|
  new_name = f.sub(/\.txt$/, ".md")
  FileUtils.mv(f, new_name)
end
```

</details>

## 故障排查 (FAQ)

### Q: File.join 和 Pathname / 运算哪个更好？

**A**: 两者功能相同。`Pathname` 更面向对象，支持方法链；`File.join` 更直接。项目一致即可。

### Q: 怎么判断路径是文件、目录、或符号链接？

**A**: 用 `FileTest` 模块：

```ruby
FileTest.file?("path")       # 是普通文件
FileTest.directory?("path")  # 是目录
FileTest.symlink?("path")    # 是符号链接
```

### Q: Dir.glob 和 Pathname.glob 的区别？

**A**: `Dir.glob` 返回字符串数组；`Pathname.glob` 返回 Pathname 对象数组，支持后续方法。`Pathname.glob` 更面向对象。

## 小结

**核心要点**：

1. **File.join 拼接路径**：跨平台安全
2. **Pathname 面向对象路径**：支持 `/` 运算符
3. **Dir.glob 查找文件**：`**/*.rb` 递归
4. **FileTest 检查属性**：exist?、file?、directory?、size
5. **Dir.mktmpdir 自动清理**：块形式自动清理
6. **FileTest vs File 模块**：`FileTest.exist?` 和 `File.exist?` 功能相同

## 继续学习

- **上一章**: [正则表达式](regex.md)
- **下一章**: [阶段复习：基础部分](review-basic.md)
- **返回**: [基础入门](basic-overview.md)

运行 `hello basic file-management` 查看完整示例代码.
