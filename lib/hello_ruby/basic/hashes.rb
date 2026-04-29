# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 哈希操作
    # 涵盖按键访问、安全查找、合并、变换
    module Hashes
      def self.run
        puts "=== 哈希操作 ==="
        puts

        # 创建哈希 — 符号键 vs 字符串键
        user_sym = { name: "Alice", age: 30, city: "Shanghai" }
        user_str = { "name" => "Bob", "age" => 25, "city" => "Beijing" }
        # Ruby 3.1+ 键序转换
        str_from_sym = user_sym.transform_keys(&:to_s)
        puts "符号键: #{user_sym.inspect}"
        puts "字符串键: #{user_str.inspect}"
        puts "符号键转字符串键: #{str_from_sym.inspect}"
        puts

        # 访问 — [] vs fetch
        puts "user_sym[:name]: #{user_sym[:name]}"
        puts "user_sym[:missing]: #{user_sym[:missing].inspect}" # nil
        # fetch 在键不存在时可指定默认值或抛 KeyError
        puts "fetch(:missing, 'N/A'): #{user_sym.fetch(:missing, "N/A")}"
        puts
        # begin
        #   user_sym.fetch(:missing) # 抛出 KeyError
        # rescue KeyError => e
        #   puts "fetch 无默认值: KeyError — #{e.message}"
        # end
        puts

        # 嵌套哈希 — dig 安全访问
        config = {
          database: {
            host: "localhost",
            port: 5432,
            options: { timeout: 5, pool: 10 }
          }
        }
        # dig 在任意层级为 nil 时返回 nil（不抛异常）
        puts "dig: #{config.dig(:database, :options, :timeout)}"
        puts "dig(不存在的): #{config.dig(:redis, :host).inspect}"
        puts

        # 合并
        defaults = { log_level: :info, verbose: false, timeout: 30 }
        overrides = { log_level: :debug, verbose: true }
        merged = defaults.merge(overrides)
        puts "merge: #{merged.inspect}"
        # merge 不修改原哈希；merge! 会修改
        puts

        # transform_values
        scores = { math: 95, english: 88, science: 92 }
        letter_grades = scores.transform_values do |score|
          case score
          when 90..100 then "A"
          when 80..89  then "B"
          when 70..79  then "C"
          else               "D"
          end
        end
        puts "transform_values → 等级: #{letter_grades.inspect}"
        puts

        # 遍历
        puts "each: "
        user_sym.each { |key, value| puts "  #{key}: #{value}" }
        # 键 / 值 / 对
        puts "keys: #{user_sym.keys.inspect}"
        puts "values: #{user_sym.values.inspect}"
        puts "值包含 Alice?: #{user_sym.value?("Alice")}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "hashes", "哈希操作", Hello::Basic::Hashes)
