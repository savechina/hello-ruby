# typed: true
# frozen_string_literal: true

require "csv"
require "json"
require "yaml"

module Hello
  module Advance
    # 数据处理脚本 — CSV/JSON/YAML 解析、文本管道、一行式脚本
    class DataProcessingSample
      FIXTURES_DIR = File.expand_path("../../../spec/fixtures", __dir__)

      def self.run
        puts "=== 数据处理脚本 ==="
        puts

        csv_parsing_generation
        puts

        json_yaml_transforms
        puts

        text_pipeline_patterns
        puts

        one_liner_patterns
        puts

        ruby_vs_python_bash
        puts

        puts "=== 数据处理演示完成 ==="
      end

      # --- 1. CSV 解析与生成 ---
      def self.csv_parsing_generation
        puts "--- 1. CSV 解析与生成 ---"

        csv_path = File.join(FIXTURES_DIR, "sample.csv")

        # CSV.read — 一次性读取
        puts "  CSV.read(整个文件):"
        data = CSV.read(csv_path, headers: true)
        data.each do |row|
          puts "    #{row["name"]} (#{row["age"]}岁, #{row["city"]})"
        end

        # CSV.parse — 从字符串解析
        puts "  CSV.parse(字符串):"
        raw = "x,y\n1,2\n3,4"
        matrix = CSV.parse(raw, headers: true).map { |r| [r["x"].to_i, r["y"].to_i] }
        puts "    解析结果: #{matrix.inspect}"

        # CSV.open — 流式读取 + 生成新文件
        puts "  CSV.open(流式处理):"
        out_path = File.join(Dir.tmpdir, "output.csv")
        CSV.open(out_path, "w") do |out|
          out << ["name", "age", "city", "category"]
          CSV.foreach(csv_path, headers: true) do |row|
            age = row["age"].to_i
            category = age < 30 ? "young" : "senior"
            out << [row["name"], row["age"], row["city"], category]
          end
        end

        parsed = CSV.read(out_path, headers: true)
        parsed.each { |r| puts "    #{r["name"]} → #{r["category"]}" }
      end

      # --- 2. JSON / YAML 转换 ---
      def self.json_yaml_transforms
        puts "--- 2. JSON / YAML 转换 ---"

        json_path = File.join(FIXTURES_DIR, "sample.json")
        yaml_path = File.join(FIXTURES_DIR, "sample.yaml")

        # JSON 解析
        puts "  JSON 解析:"
        json_data = JSON.parse(File.read(json_path))
        json_data["users"].each { |u| puts "    #{u["name"]} (#{u["age"]}岁)" }
        puts "    总数: #{json_data["total"]}"

        # YAML 解析
        puts "  YAML 解析:"
        yaml_data = YAML.load_file(yaml_path)
        puts "    数据库配置: #{yaml_data["database"]}"

        # JSON → YAML 转换
        puts "  JSON → YAML 转换:"
        as_yaml = YAML.dump(json_data)
        puts "    转换后的 YAML:"
        as_yaml.each_line { |line| puts "      #{line.chomp}" }

        # YAML → JSON 转换
        puts "  YAML → JSON 转换:"
        as_json = JSON.pretty_generate(yaml_data)
        puts "    转换后的 JSON:"
        as_json.each_line { |line| puts "      #{line.chomp}" }
      end

      # --- 3. 文本管道模式(grep/awk 替代) ---
      def self.text_pipeline_patterns
        puts "--- 3. 文本管道模式(grep/awk-like) ---"

        # 生成测试文本
        lines = [
          "INFO: Server started on port 3000",
          "ERROR: Connection refused",
          "WARN: Memory usage at 80%",
          "INFO: Request processed in 200ms",
          "ERROR: Timeout after 30s",
          "DEBUG: Loading config",
        ]

        # grep 替代: 过滤匹配行
        puts "  grep('ERROR') 过滤错误行:"
        errors = lines.grep(/^ERROR/)
        errors.each { |l| puts "    #{l}" }

        # grep_v 替代: 排除匹配行
        puts "  grep_v('DEBUG') 排除调试行:"
        non_debug = lines.grep_v(/^DEBUG/)
        puts "    非调试行: #{non_debug.length} 条"

        # awk 替代: 提取字段并转换
        puts "  awk-like 提取响应时间:"
        times = lines.grep(/processed in/).map do |line|
          line[/(\d+)ms/, 1].to_i
        end
        puts "    响应时间: #{times.inspect} ms, 平均: #{times.sum / times.length}ms"

        # 管道链式操作: filter → transform → aggregate
        puts "  管道链式操作:"
        severity_counts = lines.map { |l| l[/\w+:/] }.tally
        puts "    级别统计: #{severity_counts}"
      end

      # --- 4. Ruby 一行式脚本(ruby -e) ---
      def self.one_liner_patterns
        puts "--- 4. Ruby 一行式脚本(ruby -e) ---"

        # 这些展示了 ruby -e 的等效写法
        puts "  ruby -e 'puts 1..5 的平方' (ruby -e '(1..5).each {|n| puts n**2}')"
        squares = (1..5).map { |n| n**2 }
        puts "    结果: #{squares.inspect}"

        puts "  ruby -n -e 'puts $_.chomp.reverse' (逐行处理)"
        reversed = ["hello", "world"].map(&:reverse)
        puts "    反转: #{reversed.inspect}"

        puts "  ruby -F: -ane 'puts $F[0]' (字段分割)"
        fields = "name:alice:30".split(":")
        puts "    第一个字段: #{fields[0]}"

        puts "  ruby -e 'puts Dir.glob(\"*.rb\").length' (目录操作)"
        rb_count = Dir.glob("**/*.rb", base: __dir__).length
        puts "    当前项目 .rb 文件数: #{rb_count}"

        puts "  常用 ruby -e 场景:"
        puts "    - 快速数据转换: echo '1 2 3' | ruby -ane 'puts $F.sum'"
        puts "    - 文件批量重命名: ruby -e 'Dir[\"*.txt\"].each { |f| File.rename(f, f.gsub(/ /, \"_\")) }'"
        puts "    - 行号添加: ruby -ne 'puts \"#{$.}: #{$_}\"' file.txt"
      end

      # --- 5. Ruby vs Python/Bash 对比 ---
      def self.ruby_vs_python_bash
        puts "--- 5. Ruby vs Python/Bash 对比 ---"

        # Bash 一行式 vs Ruby 一行式
        puts "  Bash: cat file.txt | grep ERROR | wc -l"
        puts "  Ruby: File.read(\"file.txt\").lines.grep(/ERROR/).length"
        sample_errors = ["ERROR: x", "INFO: y", "ERROR: z"].count { |l| l.include?("ERROR") }
        puts "    结果: #{sample_errors} 条错误"

        # Python 列表推导 vs Ruby 链式
        puts "  Python: [x**2 for x in range(1,6) if x % 2 == 1]"
        puts "  Ruby:   (1..5).select(&:odd?).map { |x| x**2 }"
        result = (1..5).select(&:odd?).map { |x| x**2 }
        puts "    结果: #{result.inspect}"

        # 数据处理优雅性
        puts "  Ruby 优势:"
        puts "    - 链式调用更自然: lines.map(&:strip).grep(/pattern/).take(5)"
        puts "    - 内置 Enumerable: 无需导入 itertools"
        puts "    - 优雅的语法糖: %w[], %i[], heredoc(<<~), 块语法"
        puts "    - 命令行工具: ruby -e/-n/-p/-a 原生支持"
        puts "    - 字符串插值: \"#{result}个奇数平方\" vs Python f-string"
        puts "    #{result.length}个奇数平方"
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "data_processing", "数据处理脚本", Hello::Advance::DataProcessingSample)
