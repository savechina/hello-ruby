# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 正则表达式
    # 涵盖 Regexp 创建、匹配、捕获组、特殊变量、常用模式、实用示例
    module Regex
      def self.run
        puts "=== 正则表达式 ==="
        puts

        # ===== 1. 创建 Regexp 的三种方式 =====
        puts "--- 1. 创建正则表达式 ---"

        # 字面量斜杠（最常用）
        pattern_slash = /hello/
        puts "/pattern/: #{pattern_slash.inspect}"

        # %r{} — 适合包含斜杠的正则（如 URL）
        pattern_r = %r{https?://[\w.]+}
        puts "%r{}: #{pattern_r.inspect}"

        # Regexp.new — 适合动态构建正则
        dynamic = Regexp.new("\d{3}-\d{4}")
        puts "Regexp.new: #{dynamic.inspect}"
        puts

        # ===== 2. 正则修饰符（flags） =====
        puts "--- 2. 正则修饰符 ---"

        # /i — 忽略大小写
        insensitive = /hello/i
        puts "/i 忽略大小写: #{insensitive.match?("Hello")}"

        # /m — 多行模式（. 也匹配换行符）
        multiline = /a.*b/m
        puts "/m 多行模式: #{multiline.match?("a\nb")}"

        # /x — 忽略空白，允许注释（适合复杂正则）
        verbose = /
          \d +    # 一位或多位数字
          -       # 连字符
          \d +    # 一位或多位数字
        /x
        puts "/x .verbose: #{verbose.match?("123-456")}"
        puts

        # ===== 3. 匹配操作 =====
        puts "--- 3. 匹配操作 ---"

        text = "我的电话是 138-1234-5678"

        # =~ 返回匹配起始索引，不匹配返回 nil
        index = text =~ /\d{3}-\d{4}-\d{4}/
        puts "=~ 返回索引: #{index}"

        # !~ 返回 true/false（不匹配判断）
        puts "!~ 不匹配: #{(text !~ /xyz/)}"

        # String#match 返回 MatchData 对象
        match_data = text.match(/(\d{3})-(\d{4})-(\d{4})/)
        puts "match 返回 MatchData: #{match_data.class}"
        puts "完整匹配: #{match_data[0]}"
        puts "第1组: #{match_data[1]}"
        puts "第2组: #{match_data[2]}"
        puts "第3组: #{match_data[3]}"
        puts

        # ===== 4. 字符类与量词 =====
        puts "--- 4. 常用元字符 ---"

        sample = "abc123 XYZ def45"

        puts "原始字符串: '#{sample}'"
        # \d 数字，\w 单词字符，\s 空白字符
        puts "\\d (数字): #{sample.scan(/\d/).inspect}"
        puts "\\w (单词字符): #{sample.scan(/\w/).inspect}"
        puts "\\s (空白符): #{sample.scan(/\s/).inspect}"
        puts "\\D (非数字): #{sample.scan(/\D/).inspect}"
        puts "\\W (非单词): #{sample.scan(/\W/).inspect}"

        # 量词
        puts
        puts "--- 量词 ---"
        puts "+ (1次或多次): #{sample.scan(/\d+/).inspect}"     # 至少1次
        puts "* (0次或多次): #{sample.scan(/\d*/).inspect}"     # 允许0次
        puts "? (0次或1次): #{sample.scan(/\w?\d?/).inspect}"   # 可选
        puts "{2,3} (2到3次): #{sample.scan(/\w{2,3}/).inspect}" # 范围
        puts "{3} (恰好3次): #{sample.scan(/\d{3}/).inspect}"   # 精确次数
        puts

        # ===== 5. 捕获组 =====
        puts "--- 5. 捕获组 ---"

        # 位置捕获组 ( )
        date = "2025-12-31"
        date_match = date.match(/(\d{4})-(\d{2})-(\d{2})/)
        puts "位置捕获组:"
        puts "  年: #{date_match[1]}"
        puts "  月: #{date_match[2]}"
        puts "  日: #{date_match[3]}"

        # 命名捕获组 (?<name>pattern)
        named_match = date.match(/(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/)
        puts "命名捕获组:"
        puts "  year: #{named_match[:year]}"
        puts "  month: #{named_match[:month]}"
        puts "  day: #{named_match[:day]}"

        # 非捕获组 (?:pattern) — 分组但不捕获
        non_capturing = "2025-12-31".match(/(?:\d{4})-(\d{2})-(\d{2})/)
        puts "非捕获组 (仅2组): #{non_capturing.captures.length} 组"

        # 贪婪 vs 惰性
        greedy = "<div>hello</div>".match(/<.*>/)
        lazy = "<div>hello</div>".match(/<.*?>/)
        puts "贪婪 .*: #{greedy[0]}"
        puts "惰性 .*?: #{lazy[0]}"
        puts

        # ===== 6. 字符串方法配合正则 =====
        puts "--- 6. 字符串方法配合正则 ---"

        sentence = "Hello World Hello Ruby Hello World"

        # sub — 单次替换
        puts "sub: #{sentence.sub(/Hello/, /Hello/ => "Hi")}"
        puts "sub: #{sentence.sub(/Hello/, "Hi")}"

        # gsub — 全局替换
        puts "gsub: #{sentence.gsub(/Hello/, "Hi")}"

        # gsub 也可以用块
        upper_hello = sentence.gsub(/Hello/) { |m| m.upcase }
        puts "gsub 块: #{upper_hello}"

        # split — 用正则分割
        csv = "apple,banana;cherry:dragon"
        puts "split (标点分割): #{csv.split(/[,;:]/).inspect}"

        # scan — 查找所有匹配
        numbers = "a1b22c333d4444".scan(/\d+/)
        puts "scan: #{numbers.inspect}"

        # grep — 数组过滤
        words = %w[apple banana cherry date elderberry]
        puts "grep (/e$/): #{words.grep(/e$/).inspect}"
        puts

        # ===== 7. 匹配后的特殊变量 =====
        puts "--- 7. 匹配特殊变量 ---"

        "hello 123 world" =~ /(\d+)/
        puts "$1 (最后匹配的第1组): #{$1}"
        puts "$2 (最后匹配的第2组): #{$2.inspect}"
        puts "$& (最后完整匹配): #{$&}"
        puts "$~ (MatchData 对象): #{$~.class}"
        puts "$` (匹配前的字符串): #{$`}"
        puts "$' (匹配后的字符串): #{$'}"
        puts

        # ===== 8. Regexp.escape — 转义特殊字符 =====
        puts "--- 8. Regexp.escape ---"

        raw = "Price: $19.99 (50% off)"
        escaped = Regexp.escape(raw)
        puts "原始: #{raw}"
        puts "转义: #{escaped}"
        # 可用于安全地在正则中查找包含特殊字符的文本
        sentence2 = "The Price: $19.99 (50% off) is great"
        puts "转义后匹配: #{sentence2.match?(Regexp.new(escaped))}"
        puts

        # ===== 9. 实用示例 =====
        puts "--- 9. 实用示例 ---"

        # 示例 A: 邮箱验证
        emails = [
          "user@example.com",
          "invalid@",
          "also@invalid",
          "good.email+tag@domain.co.uk",
          "no-at-sign.com"
        ]
        email_pattern = /\A[\w.+-]+@[\w-]+\.[\w.]+\z/
        puts "邮箱验证:"
        emails.each do |email|
          valid = email =~ email_pattern ? "✓" : "✗"
          puts "  #{valid} #{email}"
        end
        puts

        # 示例 B: 提取手机号
        contacts = "张三: 138-1234-5678, 李四: 159-8765-4321, 王五: 186-0000-1111"
        phones = contacts.scan(/1\d{2}-\d{4}-\d{4}/)
        puts "提取手机号 (共 #{phones.count} 个):"
        phones.each { |phone| puts "  - #{phone}" }
        puts

        # 示例 C: 解析 URL
        urls = [
          "https://github.com/ruby/ruby",
          "http://example.com:8080/path/to/page?query=1#anchor"
        ]
        url_pattern = %r{(?<protocol>https?)://(?<host>[\w.:-]+)(?<path>/[\w/.-]*)?(?:\?(?<query>[\w=&-]+))?(?:#(?<fragment>\w+))?}
        puts "解析 URL:"
        urls.each do |url|
          m = url.match(url_pattern)
          puts "  URL: #{url}"
          puts "    protocol: #{m[:protocol]}"
          puts "    host:     #{m[:host]}"
          puts "    path:     #{m[:path] || "(无)"}"
          puts "    query:    #{m[:query] || "(无)"}"
          puts "    fragment: #{m[:fragment] || "(无)"}"
        end
        puts

        # 示例 D: 提取 Markdown 链接
        markdown = " Visit [Google](https://google.com) and [GitHub](https://github.com)"
        links = markdown.scan(/\[(?<text>[^\]]+)\]\((?<url>[^\)]+)\)/)
        puts "提取 Markdown 链接:"
        links.each do |text, url|
          puts "  [#{text}]: #{url}"
        end
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "regex", "正则表达式", Hello::Basic::Regex)
