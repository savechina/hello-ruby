# typed: true
# frozen_string_literal: true

require "thor"

module Hello
  # CLI 入口 — 基于 Thor 的命令行界面
  # 提供 hello、version、play(运行主题) 三个核心命令
  class Cli < Thor
    # 短选项 "-v" 映射到 version 命令
    map "-v" => :version

    # 遇到未知子命令时退出而非静默忽略
    def self.exit_on_failure?
      true
    end

    desc "hello [NAME]", "向指定名称问好（默认 'World'）"
    def hello(name = "World")
      puts "Hello, #{name}! 👋"
      puts "欢迎进入 Ruby 世界！"
    end

    desc "version", "显示当前版本号"
    def version
      puts "hello_ruby v#{Hello::VERSION}"
    end

    desc "play TIER TOPIC", "运行指定层级和主题的代码示例\n  hello play basic variables"
    method_option :detail, type: :boolean, aliases: "-d", default: false,
                           desc: "显示详细的执行信息"
    def play(tier = nil, topic = nil)
      if tier.nil?
        puts "用法: hello play TIER [TOPIC]"
        puts
        puts "可用层级: basic  advance  awesome"
        puts
        puts "示例:"
        puts "  hello play basic         — 运行所有基础主题"
        puts "  hello play basic strings  — 运行基础/strings 主题"
        puts "  hello basic               — 快捷方式，同上"
        return
      end

      unless %w[basic advance awesome].include?(tier)
        puts "错误：未知层级 '#{tier}'，可选: basic, advance, awesome"
        exit 1
      end

      if topic.nil?
        # 运行整个 tier
        topics = TopicRegistry.list(tier)
        if topics.empty?
          puts "该层级暂无已注册主题"
          return
        end
        topics.each { |t| TopicRegistry.run(t[:tier], t[:name]) }
        return
      end

      topic_data = TopicRegistry.lookup(tier, topic)

      unless topic_data
        puts "错误：找不到 '#{tier}/#{topic}'"
        puts
        puts "可用的 #{tier} 主题："
        TopicRegistry.list(tier).each do |t|
          puts "  #{t[:name]}  —  #{t[:description]}"
        end
        exit 1
      end

      if options[:detail]
        puts "[DEBUG] 准备运行: #{topic_data[:description]}"
        puts "[DEBUG] 层级: #{tier}, 主题: #{topic}"
        puts
      end

      TopicRegistry.run(tier, topic)
    end

    desc "basic [TOPIC]", "运行所有基础主题，或运行指定主题"
    def basic(topic = nil)
      play("basic", topic)
    end

    desc "advance [TOPIC]", "运行所有进阶主题，或运行指定主题"
    def advance(topic = nil)
      play("advance", topic)
    end

    desc "awesome [TOPIC]", "运行所有实战主题，或运行指定主题"
    def awesome(topic = nil)
      play("awesome", topic)
    end
  end
end
