# Hello Ruby — Ruby 语言入门到精通

[English](README.md) | 简体中文

[**Hello Ruby 教程**](https://renyan.org/hello/ruby) | [**GitHub Pages**](https://savechina.github.io/hello-ruby/)

学习 Ruby 编程语言的综合性样例工程与教程，包含从基础语法到高级应用的完整教程和可运行代码示例。

## 🚀 快速开始

```bash
# 克隆项目
git clone https://github.com/savechina/hello-ruby.git
cd hello-ruby

# 安装依赖
bin/setup

# 运行教程
hello

# 运行所有基础示例
hello basic

# 运行指定主题
hello basic variables
hello advance metaprogramming

# 进入交互式控制台
bin/console
```

## 📦 项目模块

### Basic — 基础入门（15 个主题）

Ruby 核心语法和概念入门，适合初学者：

| 文件 | 主题 | 内容 |
|------|------|------|
| [概述](docs/src/basic/basic-overview.md) | 基础入门概览 | 学习路径、主题导航 |
| [variables.rb](docs/src/basic/variables.md) | 变量与作用域 | 局部/实例/类/全局变量、动态类型、常量 |
| [strings.rb](docs/src/basic/strings.md) | 字符串操作 | 插值、方法链、frozen_string_literal、Heredoc |
| [arrays.rb](docs/src/basic/arrays.md) | 数组 | 创建、索引、map/select/reduce、迭代器 |
| [hashes.rb](docs/src/basic/hashes.md) | 哈希 | 符号键、dig/merge、transform_values |
| [control_flow.rb](docs/src/basic/control-flow.md) | 控制流 | if/unless、case/when、循环、next/break |
| [methods.rb](docs/src/basic/methods.md) | 方法定义与调用 | 默认参数、关键字参数、splat、块捕获 |
| [classes.rb](docs/src/basic/classes.md) | 类与对象 | initialize、attr_*、类方法、继承 |
| [modules.rb](docs/src/basic/modules.md) | 模块与混入 | include/extend/prepend、module_function |
| [blocks_procs.rb](docs/src/basic/blocks-procs.md) | 块与 Proc | Block/Proc/Lambda、return 差异、回调模式 |
| [file_io.rb](docs/src/basic/file-io.md) | 文件 I/O | File.open、Pathname、Dir.glob、CSV |
| [exceptions.rb](docs/src/basic/exceptions.md) | 异常处理 | rescue/ensure/retry、自定义异常、else 块 |
| [numbers.rb](docs/src/basic/numbers.md) | 数字与数值运算 | Integer 任意精度、Float、BigDecimal、Rational |
| [symbols.rb](docs/src/basic/symbols.md) | 符号 | object_id 唯一性、哈希键惯例、内存影响 |
| [regex.rb](docs/src/basic/regex.md) | 正则表达式 | 字面量、修饰符、捕获组、gsub/scan |
| [file_management.rb](docs/src/basic/file-management.md) | 文件管理 | Dir、FileTest、Pathname API、临时目录 |
| [阶段复习](docs/src/basic/review-basic.md) | 基础复习 | 知识整合、综合练习 |

### Advance — 高级进阶（10 个主题）

深入 Ruby 高级特性和工程生态：

| 文件 | 主题 | 内容 |
|------|------|------|
| [概述](docs/src/advance/advance-overview.md) | 高级进阶概览 | 学习路径、主题导航 |
| [async_await.rb](docs/src/advance/async-await.md) | 并发模型 | Thread、Fiber、Ractor（Ruby 3+） |
| [metaprogramming.rb](docs/src/advance/metaprogramming.md) | 元编程 | define_method、method_missing、eval 家族 |
| [enumerable.rb](docs/src/advance/enumerable.md) | Enumerable 深度探索 | lazy、自定义 Enumerable、chunk_while、grep_v |
| [database.rb](docs/src/advance/database.md) | 数据库与 ORM | Sequel 连接、模型定义、迁移、查询链 |
| [error_handling.rb](docs/src/advance/error-handling.md) | 错误处理模式 | Result 单子、安全导航异常链 |
| [testing.rb](docs/src/advance/testing.md) | 测试模式 RSpec | describe/let/matchers、doubles、FactoryBot |
| [dry_system.rb](docs/src/advance/dry-system.md) | dry-system DI | 容器 setup、自动注册、Import mixin |
| [cli_advanced.rb](docs/src/advance/cli-advanced.md) | Thor CLI 高级用法 | class_option、subcommand、参数解析 |
| [threads_fibers.rb](docs/src/advance/threads-fibers.md) | 线程与协程 | GVL、Queue、Mutex、Fiber.yield、Ractor 消息传递 |
| [performance.rb](docs/src/advance/performance.md) | 性能优化 | Benchmark、ObjectSpace、GC.stat、内存优化 |
| [阶段复习](docs/src/advance/review-advance.md) | 高级复习 | 知识整合、服务设计练习 |

### Awesome — 精选实战（生产级，5 个主题）

生产环境级别的应用架构和工程实践：

| 模块 | 内容 | 核心技术 |
|------|------|----------|
| [Sinatra](docs/src/awesome/sinatra.md) | 轻量级 REST 微框架 | Sinatra::Base、Sequel ORM、Rack::Test CRUD |
| [Hanami](docs/src/awesome/hanami.md) | 干净架构现代框架 | dry-struct 实体、Repository 模式、dry-validation |
| [Grape](docs/src/awesome/grape.md) | REST API 专用框架 | 版本管理、参数验证、错误处理 |
| [Sidekiq](docs/src/awesome/sidekiq.md) | 后台任务处理系统 | Worker 类、队列管理、重试策略 |
| [Falcon](docs/src/awesome/falcon.md) | 高性能异步 Web 服务器 | Async/Fiber 并发、HTTP/2、Rack 兼容应用 |

## 🛠️ 技术栈

- **Ruby 3.2+**（rbenv 管理）
- **CLI 框架**: Thor ~> 1.1
- **依赖注入**: dry-system, dry-struct, dry-events, dry-monitor
- **ORM**: Sequel ~> 5.54 + SQLite3
- **类型检查**: Sorbet（静态） + Steep（渐进式）
- **代码规范**: RuboCop 1.50+（6 个插件）
- **测试**: RSpec 3.0+ + FactoryBot + SimpleCov
- **配置**: config gem + dotenv
- **CI**: GitHub Actions

## 📋 项目结构

```
hello-ruby/
├── bin/
│   ├── setup              # 安装脚本（bundle install）
│   └── console            # 交互式 Ruby 控制台（IRB）
├── config/
│   └── settings.yml       # 应用配置
├── exe/
│   └── hello              # CLI 入口
├── lib/
│   ├── hello.rb           # Gem 主入口
│   └── hello/
│       ├── version.rb     # 语义化版本号
│       ├── errors.rb      # 自定义异常类
│       ├── configuration.rb
│       ├── topic_registry.rb  # 主题注册表
│       ├── cli.rb         # Thor CLI 入口
│       ├── command.rb     # BaseCommand
│       ├── system/        # dry-system DI
│       │   ├── container.rb
│       │   └── import.rb
│       ├── basic.rb       # Basic 层加载器
│       ├── basic/         # 15 个基础主题
│       ├── advance.rb     # Advance 层加载器
│       ├── advance/       # 10 个进阶主题
│       └── awesome.rb     # Awesome 层加载器
├── spec/
│   ├── spec_helper.rb     # RSpec 配置 + SimpleCov
│   ├── hello_spec.rb      # Gem 冒烟测试
│   ├── basic/             # Basic 层测试
│   └── factories/
├── docs/                  # mdBook 教程文档
│   ├── book.toml
│   └── src/
│       ├── basic/         # Basic 章节
│       ├── advance/       # Advance 章节
│       └── awesome/       # Awesome 章节
├── .github/
│   └── workflows/
│       └── ruby.yml       # CI：RuboCop → Sorbet → RSpec
├── hello.gemspec          # Gem 规范
├── Gemfile
├── Rakefile
├── .rubocop.yml
├── Steepfile
└── README.md
```

## 📖 在线教程

- 🌐 **官方教程**: [renyan.org/hello/ruby](https://renyan.org/hello/ruby)
- 📚 **GitHub Pages**: [savechina.github.io/hello-ruby](https://savechina.github.io/hello-ruby/)

本地预览文档：

```bash
cd docs
mdbook serve --open
```

## 📝 License

MIT License
