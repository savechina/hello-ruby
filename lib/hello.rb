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
  require_relative "hello/version"

  # 核心子系统
  require_relative "hello/system"
  require_relative "hello/errors"
  require_relative "hello/configuration"
  require_relative "hello/topic_registry"

  # CLI 层
  require_relative "hello/command"
  require_relative "hello/cli"

  # 分层示例（按层级加载）
  require_relative "hello/basic_sample"
  require_relative "hello/advance_sample"
  require_relative "hello/awesome"
end
