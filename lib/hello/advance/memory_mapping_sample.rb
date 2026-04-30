# typed: true
# frozen_string_literal: true

require "benchmark"
require "tempfile"

module Hello
  module Advance
    # 内存映射 — IO::Buffer.map, File#seek, 流式读取, mmap 性能对比
    class MemoryMappingSample
      TEST_CONTENT = "Hello, mmap world! This is a memory-mapped file demo.\n" \
                     "内存映射是一种高效的文件 I/O 技术。\n" \
                     "Line 3: Random access via offset.\n" \
                     "Line 4: 逐行流式读取也很高效。\n"

      class << self
        def run
          puts "=== 内存映射 — IO::Buffer.map 与文件随机访问 ==="
          puts

          mmap_concept_intro
          puts "-" * 50
          puts

          io_buffer_map_demo
          puts "-" * 50
          puts

          seek_based_access
          puts "-" * 50
          puts

          streaming_large_files
          puts "-" * 50
          puts

          performance_comparison
          puts

          puts "=== 内存映射演示完成 ==="
        end

        # 概念介绍 — mmap vs File.read
        def mmap_concept_intro
          puts "--- 1. 内存映射概念 ---"
          puts
          puts "  mmap (memory map) 将文件直接映射到进程地址空间，"
          puts "  由操作系统按需加载页面到内存，避免一次性读入整个文件。"
          puts
          puts "  | 方法 | 适用场景 | 内存占用 |"
          puts "  |------|---------|----------|"
          puts "  | File.read | 小文件一次性读取 | O(file_size) |"
          puts "  | File.foreach | 逐行流式处理 | O(line_size) |"
          puts "  | IO#seek/pos | 随机偏移读取 | O(chunk_size) |"
          puts "  | IO::Buffer.map | 零拷贝随机读写 | O(file_size) 物理按需 |"
          puts
          puts "  关键优势："
          puts "  - 零拷贝：数据直接从磁盘映射到内存，无需内核到用户态拷贝"
          puts "  - 惰性加载：操作系统只在访问时才将页面载入物理内存"
          puts "  - 随机访问：O(1) 偏移寻址，无需 seek"
          puts "  - 双向同步：修改内存直接写回文件"
        end

        # IO::Buffer.map 实际演示
        def io_buffer_map_demo
          puts "--- 2. IO::Buffer.map 基础用法 ---"
          puts

          temp_path = _write_temp_file

          # Suppress experimental warning
          old_verbose = $VERBOSE
          $VERBOSE = nil

          begin
            file = File.open(temp_path, "r+")
            buffer = IO::Buffer.map(file)

            puts "  文件大小: #{buffer.size} 字节"
            puts "  是否映射: #{buffer.mapped?}"
            puts "  是否可写: #{!buffer.readonly?}"
            puts

            # Read via offset
            content = buffer.get_string(0, 30)
            puts "  读取前 30 字节: #{content.inspect}"

            # Partial read at offset
            offset_5 = buffer.get_string(30, 20)
            puts "  偏移 30 起读 20 字节: #{offset_5.inspect}"

            # Write via mmap (modify in place)
            buffer.set_string("HELLO", 0)
            puts "  修改前 5 字节为 'HELLO'"

            # Verify write persisted to file
            file.rewind
            file_content = file.read
            puts "  文件内容确认: #{file_content[0, 10].inspect}"
            puts "  mmap 写入已同步到磁盘 ✓"

            buffer.free
            file.close
          ensure
            $VERBOSE = old_verbose
          end
        end

        # IO#seek/pos 随机访问
        def seek_based_access
          puts "--- 3. File#seek 随机访问 ---"
          puts

          temp_path = _write_temp_file

          begin
            file = File.open(temp_path, "r+")

            # SEEK_SET = 从文件开头开始
            file.seek(0, IO::SEEK_SET)
            puts "  seek(0) → 读取开头: #{file.read(10).inspect}"

            # SEEK_CUR = 从当前位置继续
            file.seek(40, IO::SEEK_CUR)
            puts "  当前位置: #{file.pos}"

            # SEEK_END = 从文件结尾回退
            file.seek(-5, IO::SEEK_END)
            puts "  文件末尾回退 5 字节: #{file.read(5).inspect}"
            puts

            # Using pos= for direct positioning
            file.pos = 50
            chunk = file.read(15)
            puts "  pos=50 → read(15): #{chunk.inspect}"

            file.close
          end
        end

        # 流式大文件读取
        def streaming_large_files
          puts "--- 4. 流式大文件读取 ---"
          puts

          # Generate a simulated large file (1000 lines)
          temp_path = _write_simulated_large_file(1000)

          begin
            # Read specific lines with File.foreach (lazy)
            puts "  File.foreach 是惰性迭代器，适合大文件逐行处理。"
            puts

            # Count lines containing a keyword
            match_count = File.foreach(temp_path).count { |l| l.include?("data_00100") }
            puts "  包含 'data_00100' 的行数: #{match_count}"

            # Read specific line range (lines 100-105)
            range_lines = []
            File.foreach(temp_path).with_index do |line, idx|
              if idx >= 100 && idx < 105
                range_lines << line.strip
              end
            end
            puts "  第 100~104 行:"
            range_lines.each { |l| puts "    #{l}" }
            puts

            # Compare memory: read vs foreach
            puts "  内存对比:"
            puts "  - File.read: 一次性加载全部内容到内存"
            puts "  - File.foreach: 每次只持有当前行，内存恒定"
          end
        end

        # 性能对比
        def performance_comparison
          puts "--- 5. 各方案性能对比 ---"
          puts

          # Generate a ~5MB file
          temp_path = _write_simulated_large_file(50_000)
          file_size = File.size(temp_path)
          puts "  测试文件大小: #{(file_size / 1024.0).round(1)} KB"
          puts

          n = 100

          Benchmark.bm(22) do |x|
            # File.read — full load each iteration
            x.report("File.read") do
              n.times { File.read(temp_path) }
            end

            # File.foreach — lazy iteration
            x.report("File.foreach") do
              n.times { |i| File.foreach(temp_path) { |l| l } }
            end

            # IO#seek + read at random offsets
            x.report("seek + read") do
              n.times do
                File.open(temp_path, "r") do |f|
                  100.times do
                    f.seek(rand(file_size - 100), IO::SEEK_SET)
                    f.read(100)
                  end
                end
              end
            end

            # IO::Buffer.map — mmap
            old_verbose = $VERBOSE
            $VERBOSE = nil
            begin
              x.report("IO::Buffer.map") do
                n.times do
                  File.open(temp_path, "r+") do |f|
                    buf = IO::Buffer.map(f)
                    buf.get_string(0, [100, buf.size].min)
                    buf.free
                  end
                end
              end
            ensure
              $VERBOSE = old_verbose
            end
          end

          puts
          puts "  结论:"
          puts "  - mmap 首次访问快（惰性页面加载），适合随机读取"
          puts "  - File.foreach 内存最优，适合顺序遍历"
          puts "  - File.read 简单直接但内存峰值高"
          puts "  - 大文件 + 随机访问 → 首选 IO::Buffer.map"
        end

        private

        def _write_temp_file
          dir = Dir.mktmpdir("mapping_sample")
          path = File.join(dir, "file.txt")
          File.write(path, TEST_CONTENT)
          path
        end

        def _write_simulated_large_file(line_count)
          dir = Dir.mktmpdir("mapping_large")
          path = File.join(dir, "large.txt")
          File.open(path, "w") do |f|
            line_count.times do |i|
              f.write("data_#{i.to_s.rjust(5, "0")} | 这是一个模拟的大文件行号 #{i}\n")
            end
          end
          path
        end
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "memory_mapping", "内存映射", Hello::Advance::MemoryMappingSample)
