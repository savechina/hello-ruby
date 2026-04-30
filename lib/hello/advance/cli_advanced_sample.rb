# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # CLI 高级模式 — 模拟 Thor 的路由、参数解析、help 生成
    class CliAdvancedSample
      def self.run
        puts "=== CLI 高级模式（模拟 Thor） ==="
        puts

        # --- 1. 路由注册与命令映射 ---
        puts "--- 1. 命令路由 ---"
        app = CliApp.new

        app.add_command("build", BuildCommand)
        app.add_command("deploy", DeployCommand)
        app.add_command("status", StatusCommand)

        puts "  注册命令: #{app.commands.keys.join(', ')}"

        # 执行命令
        puts
        puts "  $ cli build --target=production"
        output = app.run("build", { target: "production" })
        puts "  输出: #{output}"

        puts
        puts "  $ cli deploy --env staging --force"
        output = app.run("deploy", { env: "staging", force: true })
        puts "  输出: #{output}"
        puts

        # --- 2. 选项类型验证 ---
        puts "--- 2. 选项类型处理 ---"
        cli = OptionParser.new

        puts "  boolean (默认 false): cli.parse('--force') → #{cli.parse("--force").inspect}"
        puts "  string (默认值): cli.parse('--env', 'production') → #{cli.parse("--env", "production").inspect}"
        puts "  numeric: cli.parse('--timeout', '30') → #{cli.parse("--timeout", "30").inspect}"
        puts "  array (多次): cli.parse('--files', 'a.txt', '--files', 'b.txt') → #{cli.parse("--files", "a.txt", "--files", "b.txt").inspect}"
        puts "  hash: cli.parse('--config', 'key=val') → #{cli.parse("--config", "key=val").inspect}"
        puts

        # --- 3. 位置参数解析 ---
        puts "--- 3. 位置参数解析 ---"
        parser = PositionalParser.new

        args = %w[alice bob charlie 2024]
        result = parser.parse(args, required: [:from, :to], named: [:year])
        puts "  输入: #{args.inspect}"
        puts "  位置参数: from=#{result[:from]}, to=#{result[:to]}, year=#{result[:year]}"
        puts "  剩余参数: #{result[:extra].inspect}"
        puts

        # --- 4. Help 生成 ---
        puts "--- 4. 帮助文档生成 ---"
        help_gen = HelpGenerator.new
        puts "  命令帮助:"
        help_gen.generate(BuildCommand).each_line do |line|
          puts "    #{line}"
        end
        puts
        puts "  命令列表:"
        app.commands.each do |name, klass|
          desc = klass.description
          puts "    #{name.ljust(10)} #{desc}"
        end
        puts

        # --- 5. 子命令 ---
        puts "--- 5. 子命令 (Subcommands) ---"
        user_cli = SubcommandRouter.new
        user_cli.register(:list) { { users: ["Alice", "Bob", "Carol"], count: 3 } }
        user_cli.register(:create) { { action: "created", user: "Dave" } }
        user_cli.register(:delete) { { action: "deleted", user: "Eve" } }

        user_cli.execute(:list) do |result|
          puts "  user list → #{result.inspect}"
        end
        user_cli.execute(:create) do |result|
          puts "  user create → #{result.inspect}"
        end
        user_cli.execute(:delete) do |result|
          puts "  user delete → #{result.inspect}"
        end
        puts

        puts "=== CLI 演示完成 ==="
      end
    end

    # --- 命令类 ---
    class BuildCommand
      def self.description
        "构建项目"
      end

      def self.run(options)
        target = options[:target] || "development"
        "Building (#{target})..."
      end
    end

    class DeployCommand
      def self.description
        "部署到环境"
      end

      def self.run(options)
        env = options[:env] || "production"
        force = options[:force] ? " (强制)" : ""
        "Deploying to #{env}#{force}..."
      end
    end

    class StatusCommand
      def self.description
        "查看服务状态"
      end

      def self.run(_options)
        { uptime: "99.9%", health: "ok" }
      end
    end

    # --- CLI 应用 ---
    class CliApp
      def initialize
        @commands = {}
      end

      attr_reader :commands

      def add_command(name, klass)
        @commands[name] = klass
      end

      def run(name, options)
        klass = @commands[name]
        raise "Unknown command: #{name}" unless klass
        klass.run(options)
      end
    end

    # --- 选项解析 ---
    class OptionParser
      def parse(*args)
        result = { flags: [], options: {} }
        i = 0
        while i < args.length
          arg = args[i]
          if arg.start_with?("--")
            name = arg[2..]
            if i + 1 < args.length && !args[i + 1].start_with?("--")
              result[:options][name.to_sym] = case name
              when "force", "verbose" then true
              when "timeout" then args[i + 1].to_i
              when "config"
                key, value = args[i + 1].split("=")
                { key.to_sym => value }
              else
                args[i + 1]
              end
              result[:flags] << arg
              i += 2
            else
              result[:options][name.to_sym] = true
              result[:flags] << arg
              i += 1
            end
          else
            result[:flags] << arg
            i += 1
          end
        end
        result
      end
    end

    # --- 位置参数解析 ---
    class PositionalParser
      def parse(args, required:, named: [])
        result = {}
        idx = 0
        required.each do |key|
          result[key] = args[idx] if idx < args.length
          idx += 1
        end
        named.each do |key|
          result[key] = args[idx] if idx < args.length
          idx += 1
        end
        result[:extra] = args[idx..] if idx < args.length
        result
      end
    end

    # --- Help 生成 ---
    class HelpGenerator
      def generate(klass)
        <<~HELP
        Usage: cli #{klass.name.split("::").last.downcase} [OPTIONS]

        #{klass.description}

        Options:
          --target=TARGET     Build target (default: development)
          --config=FILE       Config file path
          --verbose, -v       Enable verbose output
          --help, -h          Show help
        HELP
      end
    end

    # --- 子命令路由 ---
    class SubcommandRouter
      def initialize
        @handlers = {}
      end

      def register(name, &handler)
        @handlers[name] = handler
      end

      def execute(name)
        handler = @handlers[name]
        raise "Unknown subcommand: #{name}" unless handler
        result = handler.call
        yield result if block_given?
        result
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "cli_advanced", "Thor CLI 高级用法", Hello::Advance::CliAdvancedSample)
