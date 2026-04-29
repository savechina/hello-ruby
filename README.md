# Hello Ruby — Ruby 语言入门到精通

 English | [简体中文](README_zh.md)

[**Hello Ruby Tutorial**](https://renyan.org/hello/ruby) | [**GitHub Pages**](https://savechina.github.io/hello-ruby/)

A comprehensive sample project and tutorial for learning the Ruby programming language, from basic syntax to advanced production-grade applications.

这是学习 Ruby 编程语言的综合性样例工程与教程，包含从基础语法到高级应用的完整教程和可运行代码示例。

## 📖 Online Tutorial / 在线教程

- 🌐 **Official Tutorial**: [renyan.org/hello/ruby](https://renyan.org/hello/ruby)
- 📚 **GitHub Pages**: [savechina.github.io/hello-ruby](https://savechina.github.io/hello-ruby/)

## 🚀 Quick Start

```bash
# Clone the project
git clone https://github.com/savechina/hello-ruby.git
cd hello-ruby

# Setup
bin/setup

# Run the tutorial
hello

# Run basic examples
hello basic

# Run interactive console
bin/console
```

## 📦 Project Modules

### Basic — 基础入门 (15 Topics)

Core Ruby syntax and concepts for beginners:

涵盖 Ruby 核心语法和概念，适合初学者：

| Module | 模块 | Content | 内容 |
|--------|------|---------|------|
| [Variables](docs/src/basic/variables.md) | 变量与表达式 | Variable binding, mutability, basic expressions | 变量绑定、可变性、基本表达式 |
| [Strings](docs/src/basic/strings.md) | 字符串 | String manipulation, interpolation, encoding | 字符串操作、插值、编码 |
| [Numbers](docs/src/basic/numbers.md) | 数字 | Integers, floats, decimals, arithmetic | 整数、浮点数、decimal、算术运算 |
| [Collections](docs/src/basic/collections.md) | 集合 | Array, Hash, Set basics | 数组、哈希、集合基础 |
| [Control Flow](docs/src/basic/control_flow.md) | 流程控制 | if/unless, case/when, loops, iterators | 条件判断、循环、迭代器 |
| [Methods](docs/src/basic/methods.md) | 方法 | Method definition, parameters, return values | 方法定义、参数、返回值 |
| [Blocks & Procs](docs/src/basic/blocks_procs.md) | 代码块与过程 | Blocks, Procs, Lambdas, closures | 代码块、Proc、Lambda、闭包 |
| [Classes](docs/src/basic/classes.md) | 类与对象 | Class definition, instances, accessors | 类定义、实例、访问器 |
| [Inheritance](docs/src/basic/inheritance.md) | 继承 | Superclass, subclass, override, super | 父类、子类、方法重写、super |
| [Modules](docs/src/basic/modules.md) | 模块与混入 | Module mixins, namespaces, extend vs include | 模块混入、命名空间、extend vs include |
| [Symbols](docs/src/basic/symbols.md) | 符号 | Symbol internals, string vs symbol usage | 符号内部原理、字符串 vs 符号 |
| [I/O](docs/src/basic/io.md) | 输入输出 | STDIN, STDOUT, file I/O basics | 标准输入输出、文件操作基础 |
| [Regular Expressions](docs/src/basic/regex.md) | 正则表达式 | Pattern matching, capture groups, Regexp | 模式匹配、捕获组、正则表达式 |
| [Exceptions](docs/src/basic/exceptions.md) | 异常处理 | Rescue, raise, ensure, custom exceptions | rescue、raise、ensure、自定义异常 |
| [File Management](docs/src/basic/file_management.md) | 文件管理 | Dir, File, Pathname, FileTest | Dir、File、Pathname、FileTest |

### Advance — 高级进阶 (10 Topics)

Deep dive into advanced Ruby features and ecosystem:

深入 Ruby 高级特性和生态系统：

| Module | 模块 | Content | 内容 |
|--------|------|---------|------|
| [Enumerables](docs/src/advance/enumerables.md) | 可枚举对象 | Enumerable, each, map, select, reduce | Enumerable、each、map、select、reduce |
| [Metaprogramming](docs/src/advance/metaprogramming.md) | 元编程 | define_method, method_missing, instance_eval | define_method、method_missing、instance_eval |
| [Threads & Fibers](docs/src/advance/threads_fibers.md) | 线程与协程 | GVL, Thread, Fiber, Ractor (Ruby 3+) | GVL、Thread、Fiber、Ractor |
| [Database & ORM](docs/src/advance/database.md) | 数据库与 ORM | ActiveRecord, migrations, associations | ActiveRecord、迁移、关联关系 |
| [Web Framework](docs/src/advance/web.md) | Web 框架 | Rails, Sinatra, Rack, middleware | Rails、Sinatra、Rack、中间件 |
| [Testing](docs/src/advance/testing.md) | 测试 | RSpec, Minitest, FactoryBot, mocks | RSpec、Minitest、FactoryBot、mock |
| [Serialization](docs/src/advance/serialization.md) | 序列化 | JSON, YAML, Marshal, MessagePack | JSON、YAML、Marshal、MessagePack |
| [Gem Development](docs/src/advance/gem_dev.md) | Gem 开发 | Gem building, publishing, versioning | Gem 构建、发布、版本号管理 |
| [Dependency Management](docs/src/advance/bundler.md) | 依赖管理 | Bundler, Gemfile, version constraints | Bundler、Gemfile、版本约束 |
| [Performance](docs/src/advance/performance.md) | 性能优化 | Benchmark, profiling, memory, JIT | Benchmark、性能分析、内存、JIT |

### Awesome — 精选实战 (Production Grade)

Production-grade service framework and real-world applications:

生产级服务框架与真实应用场景：

| Module | 模块 | Content | 内容 |
|--------|------|---------|------|
| [Awesome Overview](docs/src/awesome/awesome_overview.md) | 实战概览 | Service framework, DI, CLI tools | 服务框架、依赖注入、CLI 工具 |
| [Background Jobs](docs/src/awesome/background_jobs.md) | 后台任务 | Sidekiq, Active Job, queues | Sidekiq、Active Job、任务队列 |
| [API Design](docs/src/awesome/api_design.md) | API 设计 | REST, JSON API, GraphQL | REST、JSON API、GraphQL |
| [Authentication](docs/src/awesome/authentication.md) | 认证授权 | JWT, OAuth2, Devise | JWT、OAuth2、Devise |
| [Deployment](docs/src/awesome/deployment.md) | 部署 | Docker, Capistrano, CI/CD | Docker、Capistrano、CI/CD |

## 🛠️ Tech Stack

- **Ruby 3.2+**
- **Web Framework**: Rails 7, Sinatra
- **Database**: SQLite3 (dev), PostgreSQL (prod), ActiveRecord ORM
- **Testing**: RSpec, FactoryBot, SimpleCov
- **Type Checking**: Sorbet ( RBI type signatures )
- **Linting**: RuboCop
- **Dependency Management**: Bundler
- **Job Queue**: Sidekiq
- **CLI Framework**: Thor / GLI

## 📋 Project Structure

```
hello-ruby/
├── bin/
│   ├── setup              # Setup script (bundle install)
│   └── console            # Interactive Ruby console (IRB)
├── config/
│   └── settings.yml       # Application configuration
├── exe/
│   └── hello_ruby         # CLI entry point
├── lib/
│   ├── hello_ruby.rb      # Main gem entry point
│   ├── hello_ruby/
│   │   ├── version.rb     # Version constant
│   │   ├── basic/         # Basic tier modules (15 topics)
│   │   │   ├── variables.rb
│   │   │   ├── strings.rb
│   │   │   ├── numbers.rb
│   │   │   ├── collections.rb
│   │   │   ├── control_flow.rb
│   │   │   ├── methods.rb
│   │   │   ├── blocks_procs.rb
│   │   │   ├── classes.rb
│   │   │   ├── inheritance.rb
│   │   │   ├── modules.rb
│   │   │   ├── symbols.rb
│   │   │   ├── io.rb
│   │   │   ├── regex.rb
│   │   │   ├── exceptions.rb
│   │   │   └── file_management.rb
│   │   ├── advance/       # Advanced tier modules (10 topics)
│   │   │   ├── enumerables.rb
│   │   │   ├── metaprogramming.rb
│   │   │   ├── threads_fibers.rb
│   │   │   ├── database.rb
│   │   │   ├── web.rb
│   │   │   ├── testing.rb
│   │   │   ├── serialization.rb
│   │   │   ├── gem_dev.rb
│   │   │   ├── bundler.rb
│   │   │   └── performance.rb
│   │   └── awesome/       # Production-grade modules
│   └── tasks/             # Rake tasks
├── spec/
│   ├── spec_helper.rb
│   ├── hello_ruby_spec.rb
│   ├── basic/             # Basic tier tests
│   ├── advance/           # Advanced tier tests
│   ├── awesome/           # Production-grade tests
│   └── factories/         # FactoryBot definitions
├── app/                   # Rails app directory (if web mode)
├── db/                    # Database migrations & SQLite3 file
├── docs/                  # Tutorial documentation
│   └── src/
│       ├── basic/         # Basic topic docs
│       ├── advance/       # Advanced topic docs
│       └── awesome/       # Awesome topic docs
├── .github/
│   └── workflows/
│       └── ruby.yml       # CI/CD workflow
└── Gemfile
```

## 📝 License

MIT License
