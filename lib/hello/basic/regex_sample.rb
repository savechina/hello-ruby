# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 正则表达式 — 实际运行的代码示例
    module RegexSample
      def self.run
        puts "=== 正则表达式 ==="
        puts

        # 1. 创建正则
        pattern_slash = /hello/
        pattern_r = %r{https?://[\w.]+}
        dynamic = Regexp.new("\d{3}-\d{4}")
        puts "1. Pattern creation:"
        puts "   /pattern/: #{pattern_slash.inspect}"
        puts "   %r{}: #{pattern_r.inspect}"
        puts "   Regexp.new: #{dynamic.inspect}"
        puts

        # 2. 修饰符
        insensitive = /hello/i
        multiline = /a.*b/m
        verbose = /\d+ - \d+/x
        puts "2. Flags:"
        puts "   /i case-insensitive: #{insensitive.match?("Hello")}"
        puts "   /m multiline: #{multiline.match?("a\nb")}"
        puts

        # 3. 匹配操作
        text = "My phone: 138-1234-5678"
        index = text =~ /\d{3}-\d{4}-\d{4}/
        match_data = text.match(/(\d{3})-(\d{4})-(\d{4})/)
        puts "3. Matching:"
        puts "   =~ index: #{index}"
        puts "   MatchData: #{match_data.class}"
        puts "   Full: #{match_data[0]}"
        puts "   Group 1: #{match_data[1]}"
        puts "   Group 2: #{match_data[2]}"
        puts "   Group 3: #{match_data[3]}"
        puts

        # 4. 元字符
        sample = "abc123 XYZ def45"
        puts "4. Metacharacters:"
        puts "   \\d (digits): #{sample.scan(/\d/).inspect}"
        puts "   \\w (word): #{sample.scan(/\w/).inspect}"
        puts "   \\s (space): #{sample.scan(/\s/).inspect}"
        puts "   \\D (non-digits): #{sample.scan(/\D/).inspect}"
        puts

        # 5. 量词
        puts "5. Quantifiers:"
        puts "   + (1+): #{sample.scan(/\d+/).inspect}"
        puts "   * (0+): #{sample.scan(/\d*/).inspect}"
        puts "   ? (0-1): #{sample.scan(/\w?\d?/).inspect}"
        puts "   {3}: #{sample.scan(/\d{3}/).inspect}"
        puts

        # 6. 捕获组
        date = "2025-12-31"
        date_match = date.match(/(\d{4})-(\d{2})-(\d{2})/)
        named = date.match(/(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/)
        puts "6. Capture groups:"
        puts "   Positional: year=#{date_match[1]}, month=#{date_match[2]}, day=#{date_match[3]}"
        puts "   Named: year=#{named[:year]}, month=#{named[:month]}, day=#{named[:day]}"
        puts

        # 7. 贪婪 vs 惰性
        greedy = "<div>hello</div>".match(/<.*>/)
        lazy = "<div>hello</div>".match(/<.*?>/)
        puts "7. Greedy vs lazy:"
        puts "   Greedy .*: #{greedy[0]}"
        puts "   Lazy .*?: #{lazy[0]}"
        puts

        # 8. gsub / sub / scan
        sentence = "Hello World Hello Ruby"
        subbed = sentence.sub(/Hello/, "Hi")
        gsubbed = sentence.gsub(/Hello/, "Hi")
        numbers = "a1b22c333d4444".scan(/\d+/)
        puts "8. String + Regex:"
        puts "   sub: #{subbed}"
        puts "   gsub: #{gsubbed}"
        puts "   scan: #{numbers.inspect}"
        puts

        # 9. 特殊变量
        "hello 123 world" =~ /(\d+)/
        puts "9. Special variables:"
        puts "   $1: #{$1}"
        puts "   $&: #{$&}"
        puts "   $`: #{$`}"
        puts "   $': #{$'}"
        puts

        # 10. 实用示例
        emails = [
          "user@example.com",
          "invalid@",
          "good.email+tag@domain.co.uk",
          "no-at-sign.com"
        ]
        email_pattern = /\A[\w.+-]+@[\w-]+\.[\w.]+\z/
        puts "10. Email validation:"
        emails.each do |email|
          valid = email.match?(email_pattern) ? "✓" : "✗"
          puts "   #{valid} #{email}"
        end
        puts

        contacts = "Zhang: 138-1234-5678, Li: 159-8765-4321"
        phones = contacts.scan(/1\d{2}-\d{4}-\d{4}/)
        puts "    Phone extraction (#{phones.length} found):"
        phones.each { |p| puts "      - #{p}" }
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "regex", "正则表达式", Hello::Basic::RegexSample)
