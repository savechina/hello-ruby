# Hello Ruby — Ruby 语言入门到精通

 English | [简体中文](README_zh.md)

[**Hello Ruby Tutorial**](https://renyan.org/hello/ruby) | [**GitHub Pages**](https://savechina.github.io/hello-ruby/)

A comprehensive sample project and tutorial for learning the Ruby programming language, from basic syntax to advanced production-grade applications.

这是一份学习 Ruby 编程语言的综合性样例工程与教程，包含从基础语法到高级应用的完整教程和可运行代码示例。

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

# Run specific topics
hello basic variables
hello advance metaprogramming

# Run interactive console
bin/console
```

## 📦 Project Modules

### Basic — 基础入门 (15 Topics)

Core Ruby syntax and concepts for beginners:

涵盖 Ruby 核心语法和概念，适合初学者：

| Module | 模块 | Content | 内容 |
|--------|------|---------|------|
| [Variables](docs/src/basic/variables.md) | 变量与表达式 | Variable types, scope, dynamic typing, constants |
| [Strings](docs/src/basic/strings.md) | 字符串 | Interpolation, methods, frozen_string_literal, heredocs |
| [Arrays](docs/src/basic/arrays.md) | 数组 | Array operations, iterators, map/select/reduce |
| [Hashes](docs/src/basic/hashes.md) | 哈希 | Symbol keys, dig/merge, nested access |
| [Control Flow](docs/src/basic/control-flow.md) | 控制流 | if/unless, case/when, loops, next/break |
| [Methods](docs/src/basic/methods.md) | 方法 | Default params, keyword args, splat, block capture |
| [Classes](docs/src/basic/classes.md) | 类与对象 | Attr accessors, class/instance methods, inheritance |
| [Modules](docs/src/basic/modules.md) | 模块与混入 | include/extend/prepend, module_function, Enumerable |
| [Blocks & Procs](docs/src/basic/blocks-procs.md) | 代码块与过程 | Block/Proc/Lambda, yield, callback patterns |
| [File I/O](docs/src/basic/file-io.md) | 文件 I/O | File operations, Pathname, Dir.glob, CSV |
| [Numbers](docs/src/basic/numbers.md) | 数字 | Integers (arbitrary precision), Float, BigDecimal, Rational |
| [Symbols](docs/src/basic/symbols.md) | 符号 | Symbol uniqueness, hash key convention, memory |
| [Regular Expressions](docs/src/basic/regex.md) | 正则表达式 | Pattern matching, capture groups, gsub/scan |
| [Exceptions](docs/src/basic/exceptions.md) | 异常处理 | rescue/ensure/retry, custom exceptions |
| [File Management](docs/src/basic/file-management.md) | 文件管理 | Dir, FileTest, Pathname, temporary directories |

### Advance — 高级进阶 (10 Topics)

Deep dive into advanced Ruby features and ecosystem:

深入 Ruby 高级特性和生态系统：

| Module | 模块 | Content | 内容 |
|--------|------|---------|------|
| [Async & Concurrency](docs/src/advance/async-await.md) | 并发模型 | Thread, Fiber, Ractor (Ruby 3+) |
| [Metaprogramming](docs/src/advance/metaprogramming.md) | 元编程 | define_method, method_missing, instance/class/module_eval |
| [Enumerables](docs/src/advance/enumerable.md) | 可枚举对象 | Lazy evaluation, minmax_by, chunk_while, grep_v |
| [Database & ORM](docs/src/advance/database.md) | 数据库与 ORM | Sequel connection, models, migrations, query chains |
| [Error Handling](docs/src/advance/error-handling.md) | 错误处理 | Result monads, safe navigation, exception chains |
| [Testing](docs/src/advance/testing.md) | 测试 | RSpec, matchers, doubles, FactoryBot integration |
| [DI with dry-system](docs/src/advance/dry-system.md) | 依赖注入 | Container setup, auto-registration, Import mixin |
| [CLI Advanced](docs/src/advance/cli-advanced.md) | Thor CLI | class_option, subcommands, argument parsing |
| [Threads & Fibers](docs/src/advance/threads-fibers.md) | 线程与协程 | GVL, Queue, Mutex, Fiber.yield, Ractor messaging |
| [Performance](docs/src/advance/performance.md) | 性能优化 | Benchmark, ObjectSpace, GC.stat, memory optimization |

### Awesome — Production Grade (5 Topics)

Real-world application patterns using industry-standard frameworks and tools:

| Module | 模块 | Content | 内容 |
|--------|------|---------|------|
| [Sinatra](docs/src/awesome/sinatra.md) | 微框架 | Sinatra::Base REST API, Sequel ORM, Rack::Test CRUD |
| [Hanami](docs/src/awesome/hanami.md) | 干净架构 | Entity (dry-struct), Repository pattern, dry-validation |
| [Grape](docs/src/awesome/grape.md) | REST API | Versioned API, param validation, error handling |
| [Sidekiq](docs/src/awesome/sidekiq.md) | 后台任务 | Worker classes, queue management, retry strategies |
| [Falcon](docs/src/awesome/falcon.md) | 异步服务 | Async/Fiber concurrency, HTTP/2, Rack-compatible apps |

## 🛠️ Tech Stack

- **Ruby 3.2+** (rbenv managed)
- **CLI Framework**: Thor ~> 1.1
- **Dependency Injection**: dry-system, dry-struct, dry-events, dry-monitor
- **ORM**: Sequel ~> 5.54 + SQLite3
- **Type Checking**: Sorbet (static) + Steep (gradual typing)
- **Linting**: RuboCop 1.50+ (6 plugins)
- **Testing**: RSpec 3.0+ + FactoryBot + SimpleCov
- **Configuration**: config gem + dotenv
- **CI**: GitHub Actions

## 📋 Project Structure

```
hello-ruby/
├── bin/
│   ├── setup              # Setup script (bundle install)
│   └── console            # Interactive Ruby console (IRB)
├── config/
│   └── settings.yml       # Application configuration
├── exe/
│   └── hello              # CLI entry point
├── lib/
│   ├── hello.rb           # Main gem entry point
│   └── hello/
│       ├── version.rb     # Semantic version
│       ├── errors.rb      # Custom error classes
│       ├── topic_registry.rb  # Topic registry
│       ├── cli.rb         # Thor CLI entry
│       ├── system/        # dry-system DI
│       │   ├── container.rb
│       │   └── import.rb
│       ├── basic/         # Basic tier (15 topics)
│       ├── advance/       # Advance tier (10 topics)
│       └── awesome/       # Production-grade modules
├── spec/
│   ├── spec_helper.rb     # RSpec config + SimpleCov
│   ├── hello_spec.rb      # Gem smoke tests
│   └── basic/
├── docs/                  # mdBook tutorial docs
│   └── src/
│       ├── basic/         # Basic chapters
│       ├── advance/       # Advance chapters
│       └── awesome/       # Awesome chapters
├── .github/workflows/ruby.yml  # CI: RuboCop → Sorbet → RSpec
├── hello.gemspec
├── Gemfile
├── Rakefile
├── .rubocop.yml
└── Steepfile
```

Preview docs locally:

```bash
cd docs
mdbook serve --open
```

## 📝 License

MIT License
