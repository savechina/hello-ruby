# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 文件 I/O
    # 涵盖 File.open、read/write、Pathname、Dir.glob、IO.foreach
    module FileIO
      def self.run
        puts "=== 文件 I/O ==="
        puts

        # 创建临时文件进行演示
        require "tempfile"
        require "pathname"
        require "csv"

        # --- 1. File.write — 写入文件 ---
        tmp = Tempfile.new("hello_ruby_demo")
        content = "第一行\n第二行\n第三行\n"
        bytes_written = File.write(tmp.path, content)
        puts "File.write: 写入 #{bytes_written} 字节到 #{Pathname.new(tmp.path).basename}"
        puts

        # --- 2. File.read — 读取整个文件 ---
        read_content = File.read(tmp.path)
        puts "File.read:"
        # 注意：使用临时文件内容，不是硬编码字符串
        puts "  #{read_content.split("\n").map { |l| "| #{l}" }.join("\n  ")}"
        puts

        # --- 3. File.open — 块形式（自动关闭文件） ---
        puts "File.open（追加模式）:"
        File.open(tmp.path, "a") do |f|
          f.puts "第四行（追加）"
        end
        puts "  已追加 '第四行（追加）'"
        puts

        # --- 4. Pathname — 面向对象的文件路径操作 ---
        path = Pathname.new(tmp.path)
        puts "Pathname 元信息:"
        puts "  basename: #{path.basename}"
        puts "  dirname:  #{path.dirname}"
        puts "  extname:  #{path.extname}"
        puts "  basename(不含扩展名): #{path.basename(path.extname)}"
        puts "  存在？#{path.exist?}"
        puts "  可读？#{path.readable?}"
        puts "  大小: #{path.size} 字节"
        puts

        # --- 5. Dir.glob — 匹配文件模式 ---
        tmp_dir = Dir.mktmpdir
        tmp_dir_path = Pathname.new(tmp_dir)
        # 创建一些示例文件
        %w[foo.txt bar.rb baz.txt qux.rb].each do |name|
          File.write(tmp_dir_path / name, "")
        end

        txt_files = Dir.glob("#{tmp_dir}/**/*.txt")
        rb_files  = Dir.glob("#{tmp_dir}/**/*.rb")
        puts "Dir.glob:"
        puts "  .txt 文件: #{txt_files.map { |f| File.basename(f) }.join(", ")}"
        puts "  .rb 文件:  #{rb_files.map { |f| File.basename(f) }.join(", ")}"
        # Pathname 也有 glob
        puts "  Pathname.glob(*.txt): #{Pathname.glob(tmp_dir_path / "*.txt").map(&:basename).join(", ")}"
        puts

        # --- 6. IO.foreach — 逐行读取（内存友好）---
        puts "IO.foreach（逐行读取）:"
        line_count = 0
        IO.foreach(tmp.path) do |line|
          line_count += 1
          puts "  行 #{line_count}: #{line.chomp}"
        end
        puts

        # --- 7. CSV — 读取 CSV 数据 ---
        csv_tmp = Tempfile.new(%w[hello_csv .csv])
        csv_content = <<~CSV
          name,age,city
          Alice,30,Shanghai
          Bob,25,Beijing
          Charlie,35,Shenzhen
        CSV
        File.write(csv_tmp.path, csv_content)

        puts "CSV 读取:"
        CSV.foreach(csv_tmp.path, headers: true) do |row|
          puts "  #{row["name"]} (#{row["age"]}岁), 来自 #{row["city"]}"
        end

        # 转换为数组
        all_rows = CSV.read(csv_tmp.path, headers: true)
        puts "  转数组: #{all_rows.length} 行"
        puts "  所有城市: #{all_rows.map { |r| r["city"] }.join(", ")}"

        # 清理临时文件
        tmp.close
        tmp.unlink
        csv_tmp.close
        csv_tmp.unlink
        FileUtils.remove_entry(tmp_dir_path)
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "file_io", "文件I/O", Hello::Basic::FileIO)
