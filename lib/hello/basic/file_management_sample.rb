# typed: true
# frozen_string_literal: true

require "tmpdir"
require "pathname"
require "fileutils"

module Hello
  module Basic
    # 文件管理 — 实际运行的代码示例
    module FileManagementSample
      def self.run
        puts "=== 文件管理 ==="
        puts

        # 1. File 路径操作
        joined = File.join("usr", "local", "bin", "ruby")
        basename = File.basename("/usr/local/bin/ruby")
        basename_no_ext = File.basename("/usr/local/bin/ruby", ".rb")
        extname = File.extname("/usr/local/bin/script.rb")
        full_ext = File.extname("archive.tar.gz")
        puts "1. File path operations:"
        puts "   join: #{joined}"
        puts "   basename: #{basename}"
        puts "   basename (no ext): #{basename_no_ext}"
        puts "   extname: #{extname}"
        puts "   extname (tar.gz): #{full_ext}"
        puts "   absolute?('/usr/local'): #{File.absolute_path?("/usr/local")}"
        puts "   absolute?('relative'): #{File.absolute_path?("relative")}"
        puts

        # 2. Dir 操作
        puts "2. Dir operations:"
        puts "   pwd: #{Dir.pwd}"

        rb_dir = File.join(Hello::ROOT, "lib", "hello_ruby")
        rb_files = Dir.glob(File.join(rb_dir, "*.rb"))
        puts "   .rb files in lib/hello_ruby: #{rb_files.length}"

        all_ruby = Dir.glob(File.join(rb_dir, "**", "*.rb"))
        puts "   All .rb (recursive): #{all_ruby.length}"
        puts

        # 3. FileTest
        gemfile = "Gemfile"
        puts "3. FileTest:"
        puts "   exist?(Gemfile): #{FileTest.exist?(gemfile)}"
        puts "   file?(Gemfile): #{FileTest.file?(gemfile)}"
        puts "   directory?('lib'): #{FileTest.directory?("lib")}"
        puts "   readable?(Gemfile): #{FileTest.readable?(gemfile)}"
        if FileTest.exist?(gemfile)
          puts "   size(Gemfile): #{FileTest.size(gemfile)} bytes"
        end
        puts

        # 4. Pathname
        pn = Pathname.new("/usr/local/bin/ruby")
        puts "4. Pathname:"
        puts "   basename: #{pn.basename}"
        puts "   dirname: #{pn.dirname}"
        puts "   extname: #{pn.extname}"
        puts "   ascend: #{pn.ascend.to_a.inspect}"

        root = Pathname.new(".")
        lib_path = root / "lib" / "hello_ruby.rb"
        puts "   root / lib / hello_ruby.rb: #{lib_path}"
        puts "   exists?: #{lib_path.exist?}"

        readme = Pathname.new("README.md")
        if readme.exist?
          first_three = readme.readlines.take(3)
          puts "   README.md head (3 lines):"
          first_three.each { |line| puts "     #{line.chomp}" }
        end

        relative = Pathname.new("/usr/local/bin/ruby").relative_path_from(Pathname.new("/usr/local"))
        puts "   relative_path_from: #{relative}"
        puts

        # 5. 临时目录
        puts "5. Temporary directory:"
        puts "   tmpdir: #{Dir.tmpdir}"

        Dir.mktmpdir("hello_ruby_") do |tmp_dir|
          tmp_path = Pathname.new(tmp_dir)
          puts "   Created: #{tmp_dir}"

          demo = tmp_path / "demo.txt"
          demo.write("Hello from temp file!")
          puts "   Written: #{demo.read}"

          subdir = tmp_path / "subdir"
          subdir.mkpath
          nested = subdir / "nested.txt"
          nested.write("nested content")

          items = tmp_path.glob("**/*").map do |item|
            type = item.directory? ? "[dir] " : "[file]"
            name = item.relative_path_from(tmp_path)
            "     #{type} #{name}"
          end
          puts "   Contents:"
          items.each { |i| puts i }
        end
        puts "   Temp directory cleaned"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "file_management_sample", "文件管理", Hello::Basic::FileManagementSample)
