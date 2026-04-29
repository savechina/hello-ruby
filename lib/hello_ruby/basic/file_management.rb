# typed: true
# frozen_string_literal: true

require "tmpdir"
require "pathname"
require "fileutils"

module Hello
  module Basic
    # 文件管理 — Dir、File、FileTest、Pathname、临时目录
    module FileManagement
      def self.run
        puts "=== 文件管理 ==="
        puts

        # ============================================================
        # 1. File 模块 — 路径操作
        # ============================================================
        puts "--- 1. File 路径操作 ---"

        # 拼接路径（自动处理斜杠）
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
        puts "File.absolute_path?('/usr/local'): #{File.absolute_path?("/usr/local")}"
        puts "File.absolute_path?('relative/path'): #{File.absolute_path?("relative/path")}"

        # 展开路径（支持 ~ 缩写）
        expanded = File.expand_path("~")
        puts "File.expand_path('~'): #{expanded}"

        puts

        # ============================================================
        # 2. Dir — 目录操作
        # ============================================================
        puts "--- 2. Dir 目录操作 ---"

        # 当前工作目录
        puts "Dir.pwd: #{Dir.pwd}"

        # 获取当前目录下的 .rb 文件
        puts "当前目录下的 .rb 文件:"
        Dir.glob("*.rb").each do |f|
          puts "  #{f}"
        end

        # 递归查找所有 .rb 文件（** 表示递归）
        rb_count = Dir.glob("**/*.rb").length
        puts "项目中 .rb 文件总数: #{rb_count}"

        # 匹配多种扩展名（花括号扩展）
        all_docs = Dir.glob("**/*.{rb,md}")
        puts "Ruby + Markdown 文件总数: #{all_docs.length}"

        # Dir.entries — 列出目录所有内容（包含 . 和 ..）
        puts "\nDir.entries('lib/hello_ruby/basic'):"
        Dir.entries("lib/hello_ruby/basic").each do |entry|
          puts "  #{entry}"
        end

        # Dir.each_child — 迭代子目录/文件（不包含 . 和 ..）
        puts "\nDir.each_child('lib/hello_ruby/basic'):"
        Dir.each_child("lib/hello_ruby/basic") do |child|
          puts "  #{child}"
        end

        puts

        # ============================================================
        # 3. FileTest — 文件属性检查
        # ============================================================
        puts "--- 3. FileTest — 文件属性检查 ---"

        gemfile_path = "Gemfile"

        # 检查文件是否存在
        puts "FileTest.exist?(#{gemfile_path}): #{FileTest.exist?(gemfile_path)}"

        # 检查是否为普通文件
        puts "FileTest.file?(#{gemfile_path}): #{FileTest.file?(gemfile_path)}"

        # 检查是否为目录
        puts "FileTest.directory?('lib'): #{FileTest.directory?("lib")}"
        puts "FileTest.directory?(#{gemfile_path}): #{FileTest.directory?(gemfile_path)}"

        # 检查可读/可写权限
        puts "FileTest.readable?(#{gemfile_path}): #{FileTest.readable?(gemfile_path)}"
        puts "FileTest.writable?(#{gemfile_path}): #{FileTest.writable?(gemfile_path)}"

        # 获取文件大小（字节）
        if FileTest.exist?(gemfile_path)
          size = FileTest.size(gemfile_path)
          puts "FileTest.size(#{gemfile_path}): #{size} bytes"
        end

        # 检查两个路径是否指向同一文件
        readme_a = "README.md"
        if FileTest.exist?(readme_a)
          readme_real = File.realpath(readme_a)
          puts "File.realpath(#{readme_a}): #{readme_real}"
          puts "FileTest.identical?(#{readme_a}, #{readme_real}): #{FileTest.identical?(readme_a, readme_real)}"
        end

        puts

        # ============================================================
        # 4. Pathname — 面向对象的文件路径 API
        # ============================================================
        puts "--- 4. Pathname — 面向对象路径操作 ---"

        # 创建 Pathname 对象
        pn = Pathname.new("/usr/local/bin/ruby")
        puts "Pathname('/usr/local/bin/ruby'):"
        puts "  .basename: #{pn.basename}"
        puts "  .dirname:  #{pn.dirname}"
        puts "  .extname:  #{pn.extname}"
        puts "  .ascend:   #{pn.ascend.to_a}"

        # / 运算符拼接路径（比 File.join 更优雅）
        project_root = Pathname.new(".")
        lib_path = project_root / "lib" / "hello_ruby.rb"
        puts "\nPathname / 运算符:"
        puts "  lib/hello_ruby.rb 路径: #{lib_path}"
        puts "  存在？#{lib_path.exist?}"
        puts "  文件？#{lib_path.file?}"

        # 读取文件内容
        readme_path = Pathname.new("README.md")
        if readme_path.exist?
          # 只读取前 3 行
          first_three = readme_path.readlines.take(3)
          puts "\nREADME.md 前 3 行:"
          first_three.each { |line| puts "  #{line.chomp}" }
        end

        # Pathname.glob — 匹配文件模式
        md_count = Pathname.glob("docs/src/**/*.md").length
        puts "\nPathname.glob('docs/src/**/*.md'): #{md_count} 个文件"

        # relative_path_from — 计算相对路径
        absolute = Pathname.new("/usr/local/bin/ruby")
        base = Pathname.new("/usr/local")
        relative = absolute.relative_path_from(base)
        puts "\nPathname#relative_path_from:"
        puts "  /usr/local/bin/ruby 相对 /usr/local 是: #{relative}"

        puts

        # ============================================================
        # 5. 临时目录 — Dir.tmpdir 和 Dir.mktmpdir
        # ============================================================
        puts "--- 5. 临时目录 ---"

        # 系统临时目录路径
        puts "系统临时目录 (tmpdir): #{Dir.tmpdir}"

        # 创建唯一的临时目录（自动命名），使用完后自动清理
        Dir.mktmpdir("hello_ruby_") do |tmp_dir|
          tmp_path = Pathname.new(tmp_dir)
          puts "\n创建临时目录: #{tmp_dir}"

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

          # 检查临时目录属性
          puts "  临时目录大小: #{tmp_path.size} (目录元数据大小)"
          puts "  临时目录可读：#{tmp_path.readable?}"
        end
        # 退出块后，临时目录已自动清理
        puts "临时目录已自动清理完毕"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "file_management", "文件管理", Hello::Basic::FileManagement)
