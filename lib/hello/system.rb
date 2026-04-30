# typed: true
# frozen_string_literal: true

# dry-system 容器加载入口
require "dry/system"

module Hello
  module System
    # 此文件仅作为子系统 namespace 存在
    # 实际容器定义在 system/container.rb
  end
end

# 再加载容器和注入器
require_relative "system/container"
require_relative "system/import"
