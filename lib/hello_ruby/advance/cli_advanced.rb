# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # Thor CLI 高级用法
    # class_option、method_option、子命令、参数解析、帮助生成
    module CliAdvanced
      def self.run
        puts "=== Thor CLI 高级用法 ==="
        puts

        # 本文件展示 Thor 的高级功能——无需实际运行 CLI
        # 这些模式可复用于 hello_ruby 的 CLI 扩展

        # --- 1. class_option / method_option ---
        puts "--- class_option vs method_option ---"
        puts "  # class_option — 类内所有方法共享"
        puts "  class MyCLI < Thor"
        puts "    class_option :verbose, type: :boolean, default: false"
        puts "    class_option :config, aliases: ['-c']"
        puts

        puts "  # method_option — 单个命令专属"
        puts "    desc 'build [INPUT]', '构建项目'"
        puts "    method_option :output, aliases: ['-o'], default: './dist'"
        puts "    method_option :minify, type: :boolean, default: false"
        puts "    def build(input = '.')"
        puts '      puts "#{options.inspect}"'
        puts "    end"
        puts "  end"
        puts

        # --- 2. 选项类型 ---
        puts "--- 选项类型 ---"
        types = [
          "string   — 默认类型，接受任意字符串",
          "boolean  — 标志位（无需值），也支持 --no-flag 形式",
          "numeric  — 数字类型，自动转换",
          "hash     — 键值对，--config key=value --config k2=v2",
          "array    — 数组，--files a.txt --files b.txt",
          "default  — 允许 nil（与 string 区别：nil 不转默认值）"
        ]
        types.each { |t| puts "  #{t}" }
        puts

        # --- 3. subcommands（子命令） ---
        puts "--- Subcommands（子命令注册） ---"
        puts "  # 方法一：使用 Thor::Group 注册"
        puts "  class AppCLI < Thor"
        puts "    # Thor 会自动查找 exe/ 下的命令"
        puts "  end"
        puts
        puts "  # 方法二：动态注册子命令"
        puts "  class AppCLI < Thor"
        puts "    register(UserCommands, 'user', 'user [CMD]', '用户管理')"
        puts "    register(BuildCommands, 'build', 'build [CMD]', '构建工具')"
        puts "    register(DeployCommands, 'deploy', 'deploy [CMD]', '部署工具')"
        puts "  end"
        puts

        # --- 4. 参数解析模式 ---
        puts "--- 参数解析 ---"
        puts "  # 位置参数"
        puts "  desc 'transfer FROM TO AMOUNT', '转账'"
        puts "  def transfer(from, to, amount)"
        puts "    # 三个位置参数自动映射"
        puts "  end"
        puts
        puts "  # 剩余参数（splat）"
        puts "  desc 'add FILES...', '添加文件'"
        puts "  def add(*files)"
        puts "    files.each { |f| process(f) }"
        puts "  end"
        puts
        puts "  # 必须参数（无默认值 = 必填）"
        puts "  desc 'create NAME EMAIL', '创建用户'"
        puts "  def create(name, email)"
        puts "    # 缺少参数时 Thor 自动报错并显示帮助"
        puts "  end"
        puts

        # --- 5. 帮助生成 ---
        puts "--- 帮助与文档 ---"
        puts "  desc 'COMMAND', description — 自动生成 --help 输出"
        puts "  long_desc 'Long text...'   — 详细帮助（thor help COMMAND）"
        puts "  banner 'thor app:deploy'   — 自定义横幅"
        puts "  map '-T' => :tasks         — 短选项"
        puts "  disable_columnize          — 禁用列对齐"
        puts
        puts "  # 隐藏命令"
        puts "  method_options.merge!({hidden: true})  # 不显示在帮助中"
        puts

        # --- 6. Thor 最佳实践 ---
        puts "--- Best Practices ---"
        best_practices = [
          "每个命令一个 method，保持方法体简洁",
          "用 class_option 共享全局选项（如 --verbose、--config）",
          "用 method_option 定义命令专属选项",
          "option 和 argument 在 options[] 和 args[] 中访问",
          "复杂命令抽离为独立类，通过 register 挂载",
          "exit_on_failure? = true 确保未知子命令时退出",
          "自定义版本和帮助命令，避免 Thor 默认行为"
        ]
        best_practices.each { |p| puts "  ✓ #{p}" }
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "cli_advanced", "Thor CLI 高级用法", Hello::Advance::CliAdvanced)
