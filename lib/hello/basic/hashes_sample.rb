# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 哈希操作 — 实际运行的代码示例
    module HashesSample
      def self.run
        puts "=== 哈希操作 ==="
        puts

        # 1. 创建哈希
        user_sym = { name: "Alice", age: 30, city: "Shanghai" }
        user_str = { "name" => "Bob", "age" => 25, "city" => "Beijing" }
        puts "1. 创建哈希:"
        puts "   符号键: #{user_sym.inspect}"
        puts "   字符串键: #{user_str.inspect}"
        puts

        # 2. 访问 — [] vs fetch
        puts "2. 访问:"
        puts "   user[:name]: #{user_sym[:name]}"
        puts "   user[:missing]: #{user_sym[:missing].inspect} (nil)"
        puts "   fetch(:missing, 'N/A'): #{user_sym.fetch(:missing, "N/A")}"
        puts

        # 3. 嵌套访问 — dig
        config = {
          database: {
            host: "localhost",
            port: 5432,
            options: { timeout: 5, pool: 10 }
          }
        }
        timeout_val = config.dig(:database, :options, :timeout)
        missing = config.dig(:redis, :host)
        puts "3. dig (安全嵌套访问):"
        puts "   config.dig(:database, :options, :timeout) = #{timeout_val}"
        puts "   config.dig(:redis, :host) = #{missing.inspect} (nil, 不抛异常)"
        puts

        # 4. merge
        defaults = { log_level: :info, verbose: false, timeout: 30 }
        overrides = { log_level: :debug, verbose: true }
        merged = defaults.merge(overrides)
        puts "4. merge:"
        puts "   defaults.merge(overrides):"
        puts "   #{merged.inspect}"
        puts "   原始不变: #{defaults.inspect}"
        puts

        # 5. transform_values
        scores = { math: 95, english: 88, science: 92 }
        grades = scores.transform_values do |score|
          case score
          when 90..100 then "A"
          when 80..89  then "B"
          when 70..79  then "C"
          else               "D"
          end
        end
        puts "5. transform_values (分数 → 等级):"
        puts "   #{scores.inspect} → #{grades.inspect}"
        puts

        # 6. transform_keys — 键转换
        str_keys = user_sym.transform_keys(&:to_s)
        puts "6. transform_keys (符号 → 字符串键):"
        puts "   #{str_keys.inspect}"
        puts

        # 7. select / reject on Hash
        high_scores = scores.select { |_, v| v >= 90 }
        low_scores = scores.reject { |_, v| v >= 90 }
        puts "7. select / reject on Hash:"
        puts "   >= 90: #{high_scores.inspect}"
        puts "   <  90: #{low_scores.inspect}"
        puts

        # 8. 遍历
        puts "8. 遍历:"
        user_sym.each do |key, value|
          puts "   #{key} => #{value}"
        end
        puts "   keys: #{user_sym.keys.inspect}"
        puts "   values: #{user_sym.values.inspect}"
        puts "   value?('Alice'): #{user_sym.value?("Alice")}"
        puts

        # 9. compact / slice — Ruby 2.5+
        sparse = { a: 1, b: nil, c: 3, d: nil }
        puts "9. compact:"
        puts "   sparse.compact: #{sparse.compact.inspect}"
        taken = user_sym.slice(:name, :city)
        puts "   slice(:name, :city): #{taken.inspect}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "hashes", "哈希操作", Hello::Basic::HashesSample)
