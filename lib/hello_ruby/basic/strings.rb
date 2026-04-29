# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 字符串操作
    # 涵盖插值、% 字符串、常用方法、frozen_string_literal、heredoc
    module Strings
      def self.run
        puts "=== 字符串操作 ==="
        puts

        # 单引号 vs 双引号
        # 单引号：无插值，无大多数转义（仅 \\' 和 \\\\）
        single = "Hello\nRuby"
        puts "双引号（支持 \\n 换行）: #{single}"
        single_quoted = "Hello\\nRuby"
        # %q[] 等价于单引号
        single_quoted = %q[Hello\nRuby]
        puts "单引号/%q[]（无插值）: #{single_quoted}"
        puts

        # 字符串插值（双引号中用 #{} 嵌入表达式）
        name = "Ruby"
        version = 3.4
        interpolated = "#{name} 当前版本 #{version}"
        puts "插值: #{interpolated}"
        puts "表达式插值: 1+2+3 = #{1 + 2 + 3}"
        # %() 等价于双引号，适合包含引号的字符串
        interpolated2 = %(他说："我爱 #{name}")
        puts "插值(% 语法): #{interpolated2}"
        puts

        # 常用字符串方法
        text = "  Hello, Ruby World!  "
        puts "原始字符串: '#{text}'"
        puts "strip: '#{text.strip}'"          # 去除首尾空白
        puts "upcase: '#{text.strip.upcase}'"   # 大写
        puts "downcase: '#{text.strip.downcase}'" # 小写
        puts "swapcase: '#{text.strip.swapcase}'" # 大小写互换
        puts "reverse: '#{text.strip.reverse}'" # 反转
        puts "length: #{text.strip.length}"   # 长度
        puts "include?('Ruby'): #{text.include?("Ruby")}" # 包含
        puts "start_with?('Hello'): #{text.strip.start_with?("Hello")}" # 前缀
        puts "end_with?('World!'): #{text.strip.end_with?("World!")}" # 后缀
        puts

        # 分割与连接
        csv = "apple,banana,cherry"
        parts = csv.split(",")
        puts "split: #{parts.inspect}"
        joined = parts.join(" - ")
        puts "join: #{joined}"
        # 链式调用
        chained = "hello world ruby".split.map(&:capitalize).join(" ")
        puts "链式 split→map→join: #{chained}"
        puts

        # gsub / sub — 全局/单次替换
        original = "Hello World"
        global_replaced = original.gsub("o", "0")
        puts "gsub(o→0): #{global_replaced}"
        single_replaced = original.sub("o", "0")
        puts "sub(o→0): #{single_replaced}"

        # 正则替换
        redacted = "My email is user@example.com".gsub(/[\w.]+@[\w.]+/, "[已隐藏]")
        puts "正则替换: #{redacted}"
        puts

        # frozen_string_literal: true 的影响
        # 在文件头部添加该注释后，所有字符串常量默认 frozen
        normal = "可以变"
        # normal << "化"  # 在 frozen 模式下会 frozen string 异常
        mutable = "动态修改".dup    # .dup 创建可变副本（UTF-8 编码）
        mutable << "完毕"
        puts "frozen 下 .dup 创建副本: #{mutable}"
        # 显式冻结
        frozen_string = "冻结了".freeze
        # frozen_string << "！"  # 会抛 FrozenError
        puts "显式冻结: #{frozen_string.frozen?}"
        puts

        # Heredoc 语法
        sql = <<~SQL
          SELECT users.name, orders.total
          FROM users
          JOIN orders ON users.id = orders.user_id
          WHERE orders.total > 100
          ORDER BY orders.total DESC
        SQL
        puts "Heredoc (<<~):"
        puts sql

        # 多行 % 字符串
        poem = %{
          Ruby 是一门优雅的语言，
          如同 Perl 的母亲，
          也如 Lisp 的女儿。
        }
        puts "%{} 多行: #{poem.strip}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "strings", "字符串操作", Hello::Basic::Strings)
