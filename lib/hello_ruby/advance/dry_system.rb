# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # dry-system 依赖注入模式
    # 容器、自动注册、Provider、Import mixin
    module DrySystem
      def self.run
        puts "=== dry-system 依赖注入 ==="
        puts

        # --- 1. 容器设置 ---
        puts "--- 容器设置 ---"
        puts "  # 定义应用级 DI 容器"
        puts "  class Application < Dry::System::Container"
        puts "    config.root = Pathname('/path/to/app')"
        puts
        puts "    config.component_dirs.add 'lib/services' do |dir|"
        puts "      dir.auto_register = true"
        puts "    end"
        puts "  end"

        # 使用当前项目已定义的容器
        puts "  → Hello::System::Application 已定义"
        if defined?(Hello::System::Application)
          puts "    容器类: #{Hello::System::Application}"
        end
        puts

        # --- 2. 自动注册（Auto-registration）---
        puts "--- 自动注册 ---"
        puts "  # 按命名约定自动将文件注册为组件"
        puts "  # lib/services/email_service.rb → 'email_service'"
        puts "  # lib/services/user_repo.rb → 'user_repo'"
        puts "  # lib/commands/create_user.rb → 'create_user'"
        puts
        puts "  # 命名约定："
        puts "  #   email_service.rb → class EmailService"
        puts "  #   user_repo.rb → class UserRepo"
        puts "  # 组件通过 Application['email_service'] 访问"
        puts

        # --- 3. Provider ---
        puts "--- Provider（Provider 管理资源生命周期）---"
        puts "  # Provider 允许管理有状态资源（数据库连接、HTTP 客户端等）"
        puts "  register_provider :database do"
        puts "    start do"
        puts "      target.use :sequel, url: config[:database_url]"
        puts "    end"
        puts
        puts "    stop do"
        puts "      target[:database].disconnect if target[:database]"
        puts "    end"
        puts "  end"
        puts
        puts "  # 注册后，组件可通过 Application['database'] 获取连接池"
        puts "  # start/stop 控制资源初始化/清理生命周期"
        puts

        # --- 4. Import mixin ---
        puts "--- Import Mixin（注入依赖）---"
        puts "  # 使用 Import 将容器中的组件注入到类中"
        puts "  module Import"
        puts "    extend Application.injector"
        puts "  end"
        puts
        puts "  # 使用方式："
        puts "  class CreateUserService"
        puts "    extend Import['user_repo', 'email_service', 'logger']"
        puts
        puts "    def call(attrs)"
        puts "      user = user_repo.create(attrs)"
        puts "      email_service.welcome(user)"
        puts "      logger.info(\"Created user: \#{user.email}\")"
        puts "      user"
        puts "    end"
        puts "  end"
        puts
        puts "  # Import 提供的方法："
        puts "  #   self.user_repo → 从容器解析"
        puts "  #   self.email_service → 从容器解析"
        puts "  #   self.logger → 从容器解析"

        puts
        # 演示实际的 injector（如果容器已配置）
        if defined?(Hello::System::Application) && Hello::System::Application.respond_to?(:injector)
          puts "  实际 injector: #{Hello::System::Import}"
        end
        puts

        # --- 5. 与 Hello 项目的集成 ---
        puts "--- 集成到 hello_ruby ---"
        puts "  # lib/hello_ruby/ 文件结构："
        puts "  system/"
        puts "  ├── container.rb  → Application < Dry::System::Container"
        puts "  ├── import.rb     → Application.injector"
        puts "  └── ..."
        puts
        puts "  # Awesome 层可以使用 dry-system 注入依赖："
        puts "  # 例如，CLI 命令可以通过 dry-system 获取服务组件"
        puts "  # BaseCommand 可以使用 System::Import 声明依赖"
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "dry_system", "dry-system 依赖注入", Hello::Advance::DrySystem)
