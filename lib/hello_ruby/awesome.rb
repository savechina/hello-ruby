# typed: true
# frozen_string_literal: true

# 加载 awesome 层级的示例
# Awesome 层包含生产级 Web 框架和异步任务示例

require_relative "../hello/awesome/sinatra_demo"
require_relative "../hello/awesome/hanami_demo"
require_relative "../hello/awesome/grape_demo"
require_relative "../hello/awesome/sidekiq_demo"
require_relative "../hello/awesome/falcon_demo"

module Hello
  module Awesome
    # 所有 Awesome 层级示例已通过上述 require 加载
    # 每个示例通过 TopicRegistry 注册到 CLI
  end
end
