# typed: true
# frozen_string_literal: true

require "thor"

module Hello
  # 子命令基类
  # 提供元数据支持和子命令描述辅助方法
  # 具体的 topic 命令可继承此类
  class BaseCommand < Thor
    class << self
      # 为子命令添加描述
      #
      # @param desc [String] 命令描述
      # @param command_name [String] 命令名
      def subcommand_description(desc, command_name = nil)
        @subcommand_description = desc
      end

      # 获取子命令描述
      def subcommand_description_value
        @subcommand_description || "无描述"
      end
    end

    # 命令元数据 — 可在子类中 override
    def self.metadata
      {
        name: self.name.split("::").last.downcase,
        description: subcommand_description_value,
        created_at: Time.now.iso8601
      }
    end
  end
end
