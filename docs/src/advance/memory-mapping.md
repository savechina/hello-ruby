# 内存映射 (Memory Mapping)

## 概述

内存映射（mmap）是一种高效的文件访问技术，将文件内容直接映射到进程地址空间，实现零拷贝读取。Ruby 3.2+ 通过 IO::Buffer.map 提供了内置的 mmap 支持，无需外部 gem。本章节将介绍 mmap 概念、IO::Buffer.map 使用方法、File#seek 随机访问，以及大文件流式处理的最佳实践。

核心要点：
- **mmap 概念**：文件映射到内存，避免 read 系统调用
- **IO::Buffer.map**：Ruby 3.2+ stdlib 内置 mmap
- **seek 访问**：IO#seek/pos 实现随机位置读取
- **流式处理**：File.foreach 内存恒定，适合大文件
- **性能对比**：mmap 随机访问快，foreach 顺序遍历优

## 示例

### 示例 1：IO::Buffer.map 内存映射

```ruby
# Ruby 3.2+ stdlib
# 创建测试文件
File.write('test.txt', 'Hello mmap world!')

# 内存映射（只读）
file = File.open('test.txt', 'r')
buffer = IO::Buffer.map(file, nil, 0, IO::Buffer::READONLY)

# 读取映射内容
content = buffer.get_string(0, 5)
puts "前5字节: #{content}"  # => "Hello"

# 修改映射（读写模式）
rw_file = File.open('test.txt', 'r+')
rw_buffer = IO::Buffer.map(rw_file)
rw_buffer.set_string('HELLO', 0)  # 原地修改

buffer.free
file.close
```

### 示例 2：seek 随机访问

```ruby
File.open('data.bin', 'rb') do |f|
  # 绝对定位
  f.seek(1000, IO::SEEK_SET)
  chunk1 = f.read(100)

  # 相对定位（当前位置前进）
  f.seek(50, IO::SEEK_CUR)
  chunk2 = f.read(50)

  # 相对文件末尾
  f.seek(-100, IO::SEEK_END)
  tail = f.read(100)

  # 直接设置位置
  f.pos = 0
  header = f.read(16)
end
```

### 示例 3：大文件流式处理

```ruby
# 逐行处理，内存恒定
File.foreach('large.log') do |line|
  if line.include?('ERROR')
    puts line
  end
end

# 惰性迭代器
errors = File.foreach('large.log').lazy
  .select { |l| l.include?('ERROR') }
  .take(100)
  .to_a
```

## 知识检查

1. mmap 相比 File.read 有什么优势？什么场景最适合使用 mmap？
2. IO::Buffer.map 的 READONLY 和读写模式有什么区别？如何安全修改映射内容？
3. File.foreach 为什么适合处理大文件？与 File.read 有什么内存差异？

## 参考资源

- [IO::Buffer 文档](https://ruby-doc.org/core/IO/Buffer.html)
- [mmap 系统调用](https://man7.org/linux/man-pages/man2/mmap.2.html)
- [Ruby File 类](https://ruby-doc.org/core/File.html)