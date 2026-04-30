# dry-system 依赖注入

在大型 Ruby 项目中，对象之间的依赖关系会变得越来越复杂。服务层依赖仓储层，仓储层依赖数据库连接，控制器依赖多个服务。如果这些依赖都是手动创建的，代码很快会变得难以维护。`dry-system` 是 dry-rb 系列中的依赖注入框架，它用容器管理对象的创建和注入，让你的代码保持清晰和可测试。

dry-system 的哲学与传统 Rails 的全局状态模型不同。它强调显式依赖、不可变配置、和惰性加载。学完这一章你会理解为什么现代 Ruby 项目越来越多地使用 `dry-system` 替代 Rails 内置的 autoload。

运行 `hello advance dry_system` 可以查看完整演示代码。

## 容器设置

依赖注入的核心是一个容器。容器负责管理所有组件的创建和生命周期：

```ruby
require "dry/system/container"

class Application < Dry::System::Container
  config.root = Pathname("/path/to/app")

  # 定义组件目录
  config.component_dirs.add "lib/services" do |dir|
    dir.auto_register = true
  end

  config.component_dirs.add "lib/repositories" do |dir|
    dir.auto_register = true
  end
end
```

容器定义了从哪里加载组件和如何加载。`component_dirs` 声明了组件所在的目录。每个目录可以有自己的注册规则，比如 `auto_register = true` 表示自动按命名约定注册。

在 Hello Ruby 项目中，容器已经定义好了。你可以在 Awesome 层看到完整的容器配置。

## 自动注册（Auto-registration）

自动注册是 dry-system 最强大的特性。它会扫描指定目录，根据文件路径和类名的命名约定自动注册组件：

```
lib/services/
├── email_service.rb        → class EmailService    → 注册为 'email_service'
├── user_service.rb         → class UserService     → 注册为 'user_service'
└── payment_service.rb      → class PaymentService  → 注册为 'payment_service'

lib/repositories/
├── user_repo.rb            → class UserRepo        → 注册为 'user_repo'
└── post_repo.rb            → class PostRepo        → 注册为 'post_repo'
```

注册后的组件通过容器访问：

```ruby
# 访问已注册的组件
email_svc = Application["email_service"]
user_repo = Application["user_repo"]

# 组件是单例的，容器中只有一份实例
email_svc2 = Application["email_service"]
email_svc.object_id == email_svc2.object_id  # true
```

命名约定是干系系统自动注册的基础：

- 文件名用 snake_case，类名用 PascalCase
- 目录名映射为命名空间路径
- 组件的键名等于 `snake_case(文件名)`，不含扩展名

自动注册不需要手动写配置。你只需要在正确的目录下放置文件，容器会自动发现并注册它。

## Provider：管理外部资源

组件通常是纯 Ruby 对象，但有些资源需要外部管理，比如数据库连接、HTTP 客户端、日志配置。Provider 允许你在容器启动和关闭时执行自定义逻辑：

```ruby
Application.register_provider :database do
  start do
    # 容器启动时执行
    target.use :sequel, url: "postgres://localhost/myapp"
  end

  stop do
    # 容器关闭时执行
    target[:database]&.disconnect
  end
end

Application.register_provider :logger do
  start do
    target.register("logger", Logger.new($stdout))
  end
end
```

注册 Provider 后，组件可以通过容器键访问对应资源：

```ruby
Application["database"]      # Sequel 数据库连接
Application["logger"]        # Logger 实例
```

Provider 与自动注册的区别在于：自动注册是基于文件发现的，Provider 是手动注册的。Provider 适合管理那些不需要对应 Ruby 文件的资源。

## Import Mixin：注入依赖

注入依赖的最常见方式是使用 `Import` mixin。它把容器中注册的组件以方法形式注入到类中：

```ruby
# 定义 Import mixin
module Import
  extend Application.injector
end

# 在具体类中使用
class CreateUserService
  extend Import["user_repo", "email_service", "logger"]

  def call(attrs)
    user = user_repo.create(attrs)
    email_service.welcome(user)
    logger.info("Created user: #{user.email}")
    user
  end
end
```

`Import["key1", "key2"]` 在类上定义了 `self.key1` 和 `self.key2` 方法，它们从容器中解析对应组件并缓存。这意味着：

- 依赖是显式声明的。看类定义就知道它依赖什么
- 依赖是从容器中解析的，不需要手动 new
- 组件是单例的，多次调用 `key1` 返回同一实例

在实际项目中，你会把 Import 定义为项目的标准依赖注入方式：

```ruby
# lib/hello/system/import.rb
module Hello
  module System
    module Import
      extend Application.injector
    end
  end
end
```

然后所有服务类都用 `extend Import[...]` 声明依赖。这种模式让依赖关系透明且可测试。

## 在测试中使用容器

依赖注入的最大好处之一是测试。你可以用 test double 替换容器中的真实组件：

```ruby
RSpec.describe CreateUserService do
  let(:user_repo) { instance_double(UserRepo, create: user) }
  let(:email_service) { instance_double(EmailService, welcome: true) }
  let(:logger) { instance_double(Logger, info: nil) }

  let(:service) do
    CreateUserService.new(
      container: double(
        "email_service" => email_service,
        "logger" => logger
      )
    ).tap { |s| s.define_singleton_method(:user_repo) { user_repo } }
  end

  it "creates user and sends email" do
    service.call(name: "Alice", email: "alice@example.com")
    expect(email_service).to have_received(:welcome).with(user)
  end
end
```

在测试中替换容器组件，你就不需要真正连接数据库或发送真实邮件。每个测试只验证当前类的逻辑，隔离了外部依赖。这是单元测试的核心原则。

## 与 Hello Ruby 项目的集成

在 Hello Ruby 的 Awesome 层，dry-system 容器是整体架构的支柱：

```
lib/hello/
├── system/
│   ├── container.rb    → Application < Dry::System::Container
│   ├── import.rb       → Application.injector
│   └── provider/
│       └── database.rb → 数据库 Provider
├── services/
│   ├── create_user.rb
│   └── send_email.rb
└── repositories/
    └── user_repo.rb
```

CLI 命令通过 System::Import 注入服务组件：

```ruby
class CreateUserCommand
  extend Hello::System::Import["create_user", "logger"]

  def execute(name:, email:)
    result = create_user.call(name: name, email: email)
    logger.info("User created: #{result.email}")
    result
  end
end
```

这种设计让命令对象本身不包含业务逻辑，只是调度各个服务。业务逻辑在服务中，服务通过依赖注入获得所需的协作组件。

## 本章要点

- **容器**（Container）管理所有组件的创建和生命周期
- **自动注册** 按文件名和类名约定自动注册组件，免去手动配置
- **Provider** 用于管理外部资源（数据库连接、日志等），支持 start/stop 生命周期
- **Import mixin** 将容器中的组件以方法形式注入到类中
- 依赖声明是显式的：`extend Import["key1", "key2"]` 清楚地列出依赖
- 依赖注入让测试变得简单：用 test double 替换容器中的真实组件
- 在 Hello Ruby 项目中，Awesome 层使用 dry-system 构建完整的 DI 架构
- 运行 `hello advance dry_system` 查看完整 DI 模式演示
