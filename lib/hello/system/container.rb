# typed: true
# frozen_string_literal: true

require "fileutils"

module Hello
  module System
    # 应用级 DI 容器 — 基于 dry-system 1.2+
    # 使用 zeitwerk 插件进行代码加载，env 插件做环境感知
    class Application < Dry::System::Container
      use :logging
      use :env, inferrer: -> { ENV.fetch("RUBY_ENV", :development).to_sym }
      use :zeitwerk, debug: false

      configure do |config|
        config.root = Hello::ROOT
        config.log_dir = File.join(Hello::ROOT, "log")
        FileUtils.mkdir_p(config.log_dir)

        # lib/ 目录自动注册（仅加载 hello.commands/ 和 hello.components/ 路径）
        config.component_dirs.add "lib" do |dir|
          dir.auto_register = lambda do |component|
            identifier = component.identifier
            identifier.start_with?("hello.commands") ||
              identifier.start_with?("hello.components")
          end
        end
      end
    end
  end
end
