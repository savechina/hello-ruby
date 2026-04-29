# typed: true
# frozen_string_literal: true

# Hello Ruby — 交互式 Ruby 学习项目
# 采用 dry-system 依赖注入 + Thor CLI 架构
# 参考 zenspace/ruby 工程模式，适配 hello-rust 分层教学结构

require "pathname"

module Hello
  # 项目根目录常量
  ROOT = Pathname.new(__dir__).parent.freeze

  # 版本 — 最先加载
  require_relative "hello_ruby/version"

  # 核心子系
  require_relative "hello_ruby/system"
  require_relative "hello_ruby/errors"
  require_relative "hello_ruby/configuration"
  require_relative "hello_ruby/topic_registry"

  # CLI 层
  require_relative "hello_ruby/command"
  require_relative "hello_ruby/cli"

  # 分层示例（按层级加载）
  require_relative "hello_ruby/basic"
  require_relative "hello_ruby/advance"
  require_relative "hello_ruby/awesome"
end
