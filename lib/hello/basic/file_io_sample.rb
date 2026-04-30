# typed: true
# frozen_string_literal: true

require "tempfile"
require "pathname"
require "csv"

module Hello
  module Basic
    # 文件 I/O — 实际运行的代码示例
    module FileIOSample
      def self.run
        puts "=== 文件 I/O ==="
        puts

        # 1. File.write — 写入文件
        tmp = Tempfile.new("hello_ruby_demo")
        content = "第一行\n第二行\n第三行\n"
        bytes_written = File.write(tmp.path, content)
        puts "1. File.write:"
        puts "   写入 #{bytes_written} 字节"

        # 2. File.read — 读取整个文件
        read_content = File.read(tmp.path)
        lines = read_content.split("\n")
        puts "2. File.read:"
        puts "   读取 #{lines.length} 行: #{lines.inspect}"
        puts

        # 3. File.open — 块形式
        File.open(tmp.path, "a") do |f|
          f.puts "第四行（追加）"
        end
        appended = File.read(tmp.path)
        appended_lines = appended.split("\n")
        puts "3. File.open (追加):"
        puts "   追加后共 #{appended_lines.length} 行"
        puts

        # 4. Pathname 操作
        path = Pathname.new(tmp.path)
        puts "4. Pathname:"
        puts "   basename: #{path.basename}"
        puts "   extname: #{path.extname}"
        puts "   exist?: #{path.exist?}"
        puts "   readable?: #{path.readable?}"
        puts "   size: #{path.size} bytes"
        puts

        # 5. Dir.glob
        tmp_dir = Dir.mktmpdir
        tmp_dir_path = Pathname.new(tmp_dir)
        %w[foo.txt bar.rb baz.txt qux.rb].each do |name|
          File.write(tmp_dir_path / name, "")
        end
        txt_files = Dir.glob("#{tmp_dir}/**/*.txt")
        rb_files = Dir.glob("#{tmp_dir}/**/*.rb")
        puts "5. Dir.glob:"
        puts "   .txt: #{txt_files.map { |f| File.basename(f) }.join(", ")}"
        puts "   .rb:  #{rb_files.map { |f| File.basename(f) }.join(", ")}"
        puts

        # 6. IO.foreach — 逐行读取
        line_count = 0
        lines_read = []
        IO.foreach(tmp.path) do |line|
          line_count += 1
          lines_read << line.chomp
        end
        puts "6. IO.foreach:"
        puts "   读取了 #{line_count} 行"
        lines_read.each { |l| puts "   #{l}" }
        puts

        # 7. CSV 读取
        csv_tmp = Tempfile.new(%w[hello_csv .csv])
        csv_content = <<~CSV
          name,age,city
          Alice,30,Shanghai
          Bob,25,Beijing
          Charlie,35,Shenzhen
        CSV
        File.write(csv_tmp.path, csv_content)

        csv_rows = CSV.read(csv_tmp.path, headers: true)
        cities = csv_rows.map { |r| r["city"] }
        puts "7. CSV:"
        puts "   总行数: #{csv_rows.length}"
        puts "   城市列表: #{cities.join(", ")}"

        CSV.foreach(csv_tmp.path, headers: true) do |row|
          puts "   #{row["name"]} (#{row["age"]}) from #{row["city"]}"
        end

        # 清理
        tmp.close
        tmp.unlink
        csv_tmp.close
        csv_tmp.unlink
        require "fileutils"
        FileUtils.remove_entry(tmp_dir_path)
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "file_io_sample", "文件 I/O", Hello::Basic::FileIOSample)
