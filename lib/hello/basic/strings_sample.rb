# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 字符串操作 — 实际运行的代码示例
    module StringsSample
      def self.run
        puts "=== 字符串操作 ==="
        puts

        # 1. 字符串插值
        name = "Ruby"
        year = 2026
        interpolated = "#{name} is #{year - 1995} years old (born 1995)"
        puts "1. 插值:"
        puts "   #{interpolated}"
        puts "   表达式: 2^10 = #{2**10}"
        puts

        # 2. 字符串方法链
        text = "  Hello, Ruby World!  "
        stripped = text.strip
        upper = stripped.upcase
        reversed = upper.reverse
        puts "2. 方法链:"
        puts "   原始: #{text.inspect}"
        puts "   strip: #{stripped.inspect}"
        puts "   upcase: #{upper.inspect}"
        puts "   reversed: #{reversed.inspect}"
        puts

        # 3. frozen_string_literal — 冻结字符串不可修改
        frozen_str = "immutable"
        duped = frozen_str.dup
        duped << " - mutable copy"
        puts "3. frozen_string_literal:"
        puts "   frozen_str.class: #{frozen_str.class}"
        puts "   frozen_str.frozen?: #{frozen_str.frozen?}"
        puts "   dup + <<: #{duped.inspect}"
        puts

        # 4. 分割与连接
        csv = "apple,banana,cherry,date"
        parts = csv.split(",")
        joined = parts.join(" | ")
        puts "4. split & join:"
        puts "   csv: #{csv}"
        puts "   split: #{parts.inspect}"
        puts "   join: #{joined}"
        puts

        # 5. 链式变换
        chain_result = "hello world ruby".split.map(&:capitalize).join(" ")
        puts "5. 链式变换 (split → map → join):"
        puts "   #{chain_result}"
        puts

        # 6. gsub / sub 替换
        original = "Hello World"
        global = original.gsub("o", "0")
        single = original.sub("o", "0")
        puts "6. gsub vs sub:"
        puts "   gsub: #{global}"
        puts "   sub:  #{single}"
        puts

        # 7. 正则替换
        redacted = "Contact: user@example.com".gsub(/[\w.]+@[\w.]+/, "[EMAIL REDACTED]")
        puts "7. 正则替换:"
        puts "   #{redacted}"
        puts

        # 8. Heredoc 语法
        sql = <<~SQL
          SELECT name, age
          FROM users
          WHERE age > 18
          ORDER BY name
        SQL
        puts "8. Heredoc: (#{sql.lines.length} lines)"
        sql.lines.each { |line| puts "   #{line.chomp}" }
        puts

        # 9. 编码信息
        unicode = "こんにちは"
        puts "9. Unicode 字符串:"
        puts "   内容: #{unicode}"
        puts "   length: #{unicode.length} (字符数)"
        puts "   bytesize: #{unicode.bytesize} (字节数)"
        puts "   encoding: #{unicode.encoding}"
        puts "   chars: #{unicode.chars.inspect}"
        puts

        # 10. 字符串格式化
        formatted = sprintf("Pi ≈ %.4f, e ≈ %.4f", Math::PI, Math::E)
        percent_format = "%.2f" % 3.14159
        puts "10. sprintf / % 格式化:"
        puts "   #{formatted}"
        puts "   %.2f %% 3.14159 = #{percent_format}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "strings_sample", "字符串操作", Hello::Basic::StringsSample)
