# typed: true
# frozen_string_literal: true

module Hello
  # 根错误类 — 所有自定义异常的基类
  # 继承 StandardError（而非 Exception），遵循 Ruby 最佳实践
  class Error < StandardError; end

  # 未找到错误 — 当 topic 或组件不存在时抛出
  class NotFoundError < Error; end

  # 配置错误 — 当配置验证失败时抛出
  class ConfigurationError < Error; end

  # 验证错误 — 当输入数据不符合预期时抛出
  class ValidationError < Error; end
end
