# typed: true
# frozen_string_literal: true

module Hello
  module System
    # 依赖注入的入口点
    # 通过 Dry::System::Injector 创建混入（mixin）
    # 使用方式：
    #   class MyService
    #     extend Hello::System::Import["my_component"]
    #   end
    Import = Application.injector
  end
end
