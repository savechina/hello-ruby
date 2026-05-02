# typed: true
# frozen_string_literal: true

require "dry/system/container"
require "dry/auto_inject"
require "dry/container"

module Hello
  module Advance
    # DI 容器模式 — 模拟 dry-system 的自动注册、Provider、Import
    class DrySystemSample
      def self.run
        puts "=== DI 容器模式（模拟 dry-system） ==="
        puts

        # --- 1. 容器设置 & 组件注册 ---
        puts "--- 1. 容器与组件注册 ---"
        container = DIContainer.new

        container.register("config") { AppConfig.new(env: "development", debug: true) }
        container.register("logger") { MockLogger.new("app") }
        container.register("cache") { InMemoryCache.new(ttl: 300) }
        container.register("user_repo") { UserRepository.new }

        puts "  注册了 #{container.components.length} 个组件:"
        container.components.each do |name|
          puts "    - #{name}"
        end
        puts

        # --- 2. 依赖注入 ---
        puts "--- 2. 依赖注入 (Constructor Injection) ---"
        config = container.resolve("config")
        logger = container.resolve("logger")
        user_repo = container.resolve("user_repo")

        puts "  config.env = #{config.env}"
        puts "  config.debug = #{config.debug}"
        logs = logger.logs
        puts

        # --- 3. 服务层示例 ---
        puts "--- 3. 业务服务 (多依赖注入) ---"
        cache = container.resolve("cache")

        user_service = UserService.new(
          user_repo: user_repo,
          cache: cache,
          logger: logger
        )

        # Create user
        user = user_service.create_user(name: "Alice", email: "alice@example.com")
        puts "  创建用户: #{user.inspect}"

        # Find user (should hit cache on second call)
        user1 = user_service.find_user("alice@example.com")
        puts "  查找用户(第1次): #{user1.inspect}"

        user2 = user_service.find_user("alice@example.com")
        puts "  查找用户(第2次-缓存): #{user2.inspect}"

        puts "  缓存命中次数: #{cache.hit_count}"
        puts "  缓存未命中次数: #{cache.miss_count}"
        puts

        # --- 4. Provider: 资源注册模式 ---
        puts "--- 4. Provider 资源模式 ---"
        # Provider 管理带生命周期的资源（初始化/清理）
        provider = ResourceProvider.new

        db_mock = provider.start(:database) do
          MockDatabase.new(url: "sqlite::memory:")
        end
        puts "  资源启动: #{db_mock.class} (url: #{db_mock.url})"

        result = provider.with_resource(:database) do |db|
          db.query("SELECT * FROM users WHERE active = true")
        end
        puts "  资源使用: #{result.inspect}"

        provider.stop(:database)
        puts "  资源停止: #{db_mock.class}"
        puts

        # --- 5. Import Mixin ---
        puts "--- 5. Import Mixin 注入模式 (模拟) ---"
        # 模拟 dry-system 的 Import mixin
        # class CreateUserService
        #   extend Import['user_repo', 'email_service']
        # end

        creator = CreatorService.new(
          user_repo: container.resolve("user_repo"),
          email_service: container.resolve("logger") # 模拟用 logger 替代
        )
        creator.execute(name: "Eve", email: "eve@example.com")
        puts "  CreatorService 执行完成"
        puts

        # --- 6. 嵌套容器 ---
        puts "--- 6. 嵌套容器 ---"
        parent = DIContainer.new(name: "Parent")
        parent.register("shared_service") { "shared_resource" }

        child = parent.child("Child")
        child.register("child_service") { "child_resource" }

        puts "  parent['shared_service'] = #{parent.resolve("shared_service")}"
        puts "  child['shared_service'] = #{child.resolve("shared_service")} (继承自 parent)"
        puts "  child['child_service'] = #{child.resolve("child_service")}"

        begin
          parent.resolve("child_service")
        rescue KeyError => e
          puts "  parent['child_service'] → KeyError: #{e.message} (子级组件不可见)"
        end

        puts
        puts "=== DI 容器演示完成 ==="
        puts

        # --- 7. 真实 dry-system DI ---
        puts "--- 7. 真实 dry-system DI（使用 dry-system gem） ---"
        dry_system_real_demo
      end

      def self.dry_system_real_demo
        puts "  使用 dry-system gem 实现真实依赖注入"
        puts

        # 创建真实 dry-system Container
        container = RealDIContainer.new

        # dry-system 注册方式：使用 register 方法
        container.register(:config) { AppConfig.new(env: "production", debug: false) }
        container.register(:logger) { RealLogger.new("production") }
        container.register(:cache) { RealCache.new(ttl: 600) }

        puts "  注册组件:"
        puts "    - config (AppConfig)"
        puts "    - logger (RealLogger)"
        puts "    - cache (RealCache)"
        puts

        # 解析组件
        puts "  组件解析:"
        config = container.resolve(:config)
        logger = container.resolve(:logger)
        puts "    config.env = #{config.env}"
        puts "    logger.name = #{logger.logs.first ? 'initialized' : 'ready'}"
        puts

        # Import mixin 模式
        puts "  Import mixin 注入:"
        import = Dry::AutoInject(container)

        # 手动解析组件并注入
        service = RealUserService.new(
          config: container.resolve(:config),
          logger: container.resolve(:logger),
          cache: container.resolve(:cache)
        )
        puts "    创建 RealUserService (注入 config, logger, cache)"
        puts

        # 执行业务逻辑
        puts "  执行业务操作:"
        service.create_user("Alice", "alice@example.com")
        service.find_user("alice@example.com")
        service.find_user("alice@example.com")
        puts

        puts "  dry-system 特性:"
        puts "    - Dry::Container (轻量级容器)"
        puts "    - Dry::AutoInject (Import mixin)"
        puts "    - register/resolve 模式"
        puts "    - lazy loading (延迟加载)"
        puts "    - thread-safe (线程安全)"
        puts

        puts "=== 真实 dry-system 演示完成 ==="
      end
    end

    # --- 真实 dry-system Container ---
    class RealDIContainer < Dry::Container
      # 使用 Dry::Container (轻量级容器) 而非 Dry::System::Container
      # Dry::System::Container 需要完整项目结构，这里演示简化版本
    end

    # --- 真实组件实现 ---
    class RealLogger
      attr_reader :logs

      def initialize(name)
        @name = name
        @logs = []
      end

      def info(message)
        @logs << { level: :info, message: message, time: Time.now }
        puts "    [#{@name}] #{message}"
      end

      def error(message)
        @logs << { level: :error, message: message, time: Time.now }
      end
    end

    class RealCache
      attr_reader :hit_count, :miss_count

      def initialize(ttl:)
        @ttl = ttl
        @store = {}
        @hit_count = 0
        @miss_count = 0
      end

      def get(key)
        entry = @store[key]
        if entry && (Time.now - entry[:time]) <= @ttl
          @hit_count += 1
          entry[:value]
        else
          @miss_count += 1
          nil
        end
      end

      def set(key, value)
        @store[key] = { value: value, time: Time.now }
      end
    end

    class RealUserService
      attr_reader :config, :logger, :cache

      def initialize(config:, logger:, cache:)
        @config = config
        @logger = logger
        @cache = cache
        @users = {}
      end

      def create_user(name, email)
        @users[email] = { name: name, email: email, created_at: Time.now }
        @logger.info("Created user: #{email}")
        @users[email]
      end

      def find_user(email)
        cached = @cache.get("user:#{email}")
        if cached
          @logger.info("Cache hit for: #{email}")
          return cached
        end

        user = @users[email]
        if user
          @cache.set("user:#{email}", user)
          @logger.info("Found user (cached): #{email}")
        else
          @logger.info("User not found: #{email}")
        end
        user
      end
    end

    # --- DI 容器（教学示例）---

    # --- DI 容器 ---
    class DIContainer
      attr_reader :name, :components

      def initialize(name: "root")
        @name = name
        @components = {}
        @children = []
      end

      def register(name, &factory)
        @components[name] = { factory: factory, instance: nil }
      end

      def resolve(name)
        entry = @components[name]
        return entry[:instance] if entry && entry[:instance]

        # 尝试从父容器查找
        if entry.nil?
          raise KeyError, "Component '#{name}' not found in '#{@name}'"
        end

        entry[:instance] = entry[:factory].call
      end

      def child(name)
        ChildContainer.new(parent: self, name: name)
      end
    end

    class ChildContainer < DIContainer
      def initialize(parent:, name:)
        super(name: name)
        @parent = parent
      end

      def resolve(name)
        super
      rescue KeyError
        @parent.resolve(name)
      end
    end

    # --- Provider 资源模式 ---
    class ResourceProvider
      def initialize
        @resources = {}
      end

      def start(name, &block)
        @resources[name] = { instance: block.call, active: true }
        @resources[name][:instance]
      end

      def with_resource(name, &block)
        resource = @resources[name]
        raise "Resource '#{name}' not active" unless resource && resource[:active]
        block.call(resource[:instance])
      ensure
        # don't stop, just yield
      end

      def stop(name)
        resource = @resources.delete(name)
        resource && resource[:active] = false
      end
    end

    # --- 组件实现 ---
    class AppConfig
      attr_reader :env, :debug

      def initialize(env:, debug:)
        @env = env
        @debug = debug
      end
    end

    class MockLogger
      attr_reader :logs

      def initialize(name)
        @name = name
        @logs = []
      end

      def info(message)
        @logs << { level: :info, message: message, time: Time.now.to_s }
      end
    end

    class InMemoryCache
      attr_reader :hit_count, :miss_count

      def initialize(ttl:)
        @ttl = ttl
        @store = {}
        @hit_count = 0
        @miss_count = 0
      end

      def get(key)
        entry = @store[key]
        if entry && (Time.now - entry[:time]) <= @ttl
          @hit_count += 1
          entry[:value]
        else
          @miss_count += 1
          nil
        end
      end

      def set(key, value)
        @store[key] = { value: value, time: Time.now }
      end
    end

    class UserRepository
      def initialize
        @users = {}
        @next_id = 1
      end

      def create(attributes)
        id = @next_id
        @next_id += 1
        user = { id: id }.merge(attributes.merge(created_at: Time.now.to_s))
        @users[attributes[:email]] = user
        user
      end

      def find_by_email(email)
        @users[email]
      end
    end

    class MockDatabase
      attr_reader :url

      def initialize(url:)
        @url = url
      end

      def query(sql)
        { query: sql, rows: [{ id: 1, name: "Alice" }, { id: 2, name: "Bob" }] }
      end
    end

    # --- 服务层 ---
    class UserService
      def initialize(user_repo:, cache:, logger:)
        @user_repo = user_repo
        @cache = cache
        @logger = logger
      end

      def create_user(name:, email:)
        user = @user_repo.create(name: name, email: email)
        @logger.info("Created user #{email}")
        user
      end

      def find_user(email)
        cached = @cache.get("user:#{email}")
        return cached if cached

        user = @user_repo.find_by_email(email)
        @cache.set("user:#{email}", user) if user
        @logger.info("Found user #{email}")
        user
      end
    end

    class CreatorService
      def initialize(user_repo:, email_service:)
        @user_repo = user_repo
        @email_service = email_service
      end

      def execute(name:, email:)
        user = @user_repo.create(name: name, email: email)
        @email_service.info("Welcome email sent to #{email}")
        user
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "dry_system", "dry-system 依赖注入", Hello::Advance::DrySystemSample)
