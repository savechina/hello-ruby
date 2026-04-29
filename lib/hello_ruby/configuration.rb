# typed: true
# frozen_string_literal: true

module Hello
  # 应用配置类
  # 提供简单的属性读写，可在初始化或运行时调整
  class Configuration
    attr_accessor :log_level    # 日志级别 :debug / :info / :warn / :error
    attr_accessor :database_url # 数据库连接字符串
    attr_accessor :verbose      # 是否启用详细输出

    # 默认配置值
    DEFAULTS = {
      log_level: :info,
      database_url: "sqlite::memory:",
      verbose: false
    }.freeze

    def initialize
      @log_level    = DEFAULTS[:log_level]
      @database_url = DEFAULTS[:database_url]
      @verbose      = DEFAULTS[:verbose]
    end

    # 校验配置有效性
    def validate!
      valid_levels = %i[debug info warn error]
      unless valid_levels.include?(log_level)
        raise ConfigurationError, "Invalid log_level: #{log_level}. Must be one of #{valid_levels.join(", ")}"
      end
    end
  end
end
