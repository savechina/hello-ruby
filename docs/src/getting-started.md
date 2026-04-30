# 快速开始

## 安装 Ruby

首先，你需要安装 Ruby 3.2 或更高版本。推荐使用 `rv`（Ruby Version manager）来管理 Ruby 版本，它比传统的 `rbenv` 更快更现代化。你也可以选择 `mise` 统一管理多语言版本。

### rv 安装（推荐）

`rv` 是一个极速的 Ruby 版本和项目管理器，用 Rust 编写。它不仅能管理 Ruby 版本，还能隔离管理项目 gems，性能远超 rbenv/asdf。

macOS 用户可以使用 Homebrew 安装：

```bash
$ brew install rv

# 设置自动版本切换 Shell 集成
$ rv shell zsh  # 或 bash / fish / nu

# 安装 Ruby 3.2
$ rv ruby install 3.2.1

# 验证安装
$ ruby --version
# ruby 3.2.1
```

Linux 用户可通过 Homebrew Linux 或独立安装脚本：

```bash
# 方式一：Homebrew
$ brew install rv

# 方式二：独立脚本
$ curl -LsSf https://rv.dev/install | sh

# 安装 Ruby 3.2
$ rv ruby install 3.2.1
$ ruby --version
```

Windows 用户（PowerShell 管理员模式）：

```powershell
> powershell -ExecutionPolicy Bypass -c "irm https://rv.dev/install.ps1 | iex"
# 注意：Windows 上使用 rvw 代替 rv（rv 是 PowerShell 内置别名）
> rvw ruby install 3.2.1
```

`rv` 的核心功能：
- **极速运行**：`rv run ruby` 或 `rvx rails new .` 直接运行任何 Ruby 命令
- **自动版本切换**：进入目录自动切换 `.ruby-version` 指定的版本
- **隔离 gem 环境**：`rv clean-install` 从 Gemfile.lock 隔离安装项目 gems
- **CLI 工具管理**：`rv tool install` 在独立环境中安装 gem CLI 工具
- **跨平台**：原生支持 macOS / Linux / Windows

### 备选：rbenv 安装

macOS 用户可以使用 Homebrew 安装 rbenv：

```bash
$ brew install rbenv ruby-build
$ rbenv init
# 按照提示将以下内容加入 shell 配置文件（~/.zshrc 或 ~/.bashrc）
# eval "$(rbenv init - zsh)"

$ rbenv install 3.2.1
$ rbenv global 3.2.1

# 验证安装
$ ruby --version
# ruby 3.2.1
```

### 备选：mise 安装

或者使用 `mise`（推荐，统一管理多语言版本）：

```bash
$ brew install mise
$ mise use ruby@3.2.1
$ ruby --version
```

### Linux 安装

Linux 用户也可以使用 `rv` 安装：

```bash
# 通过独立脚本
$ curl -LsSf https://rv.dev/install | sh
$ rv shell zsh

$ rv ruby install 3.2.1
$ ruby --version
```

或使用 `rbenv` / `asdf` 作为替代：

```bash
$ git clone https://github.com/rbenv/rbenv.git ~/.rbenv
$ cd ~/.rbenv && src/configure && make -C src
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
$ ~/.rbenv/bin/rbenv init
$ rbenv install 3.2.1
$ rbenv global 3.2.1
```

### Windows 安装

Windows 用户推荐使用 **WSL2**（Windows Subsystem for Linux）安装 Ubuntu，然后在 WSL2 中安装 `rv`：

```bash
# 在 WSL2 的 Ubuntu 中
$ curl -LsSf https://rv.dev/install | sh
$ rv shell zsh
$ rv ruby install 3.2.1
$ ruby --version
```

也可以直接使用 Windows 原生安装（PowerShell 管理员模式）：

```powershell
> powershell -ExecutionPolicy Bypass -c "irm https://rv.dev/install.ps1 | iex"
> rvw ruby install 3.2.1
```

> **注意**：Windows PowerShell 中 `rv` 是 `Remove-Variable` 的内置别名，需使用 `rvw` 代替。也可以使用 [RubyInstaller](https://rubyinstaller.org/) 项目直接安装。

## 克隆并设置项目

安装完成后，克隆 Hello Ruby 项目并安装依赖：

```bash
$ git clone https://github.com/savechina/hello-ruby.git
$ cd hello-ruby
```

这将在当前目录创建一个 `hello-ruby/` 项目文件夹，其中包含所有源代码、测试和文档。

进入项目目录：

```bash
$ cd hello-ruby
```

你应该会看到以下目录结构：

```
.
├── bin/
│   ├── setup              # 安装脚本
│   └── console            # 交互式控制台
├── exe/
│   └── hello              # CLI 入口
├── lib/
│   ├── hello.rb           # Gem 主入口
│   └── hello/
│       ├── version.rb
│       ├── basic/         # 15 个基础主题
│       ├── advance/       # 10 个进阶主题
│       └── awesome/       # 实战层
├── spec/
│   ├── spec_helper.rb
│   └── basic/
├── docs/
│   └── src/               # mdBook 教程文档
├── Gemfile
└── hello.gemspec
```

运行设置脚本安装所有依赖：

```bash
$ bin/setup
# 等同于 bundle install
# 安装 Thor、RSpec、Sequel、dry-system 等 gems
```

`Gemfile` 和 `hello.gemspec` 内容说明：

```ruby
# Gemfile
source "https://rubygems.org"
gemspec
```

```ruby
# hello.gemspec（核心部分）
Gem::Specification.new do |spec|
  spec.name          = "hello"
  spec.version       = Hello::VERSION
  spec.required_ruby_version = ">= 3.2.0"

  # 运行时依赖
  spec.add_dependency "thor", "~> 1.1"
  spec.add_dependency "dry-system", "~> 1.0"
  spec.add_dependency "sequel", "~> 5.54"
  # ...
end
```

- `[gemspec]` 定义了包的名称、版本、Ruby 版本要求和依赖关系。
- `[dependencies]` 部分定义了运行时需要的 gems。开发依赖（RSpec、RuboCop 等）通过 `Gemfile` 的 `group :development, :test` 加载。

## 编译和运行

安装完成后，运行 `hello` 命令验证：

```bash
# 查看所有可用命令
$ bundle exec hello --help

# 运行全部基础示例
$ bundle exec hello basic

# 运行指定主题
$ bundle exec hello advance metaprogramming
```

你会看到控制台的输出内容，展示各种 Ruby 概念的运行结果。

## 一个完整的 Ruby gem 项目结构

Bundler 推荐的 gem 目录结构如下：

- `hello.gemspec` — gem 规范文件，定义包的元数据和依赖
- `Gemfile` 和 `Gemfile.lock` — Bundler 依赖锁定
- `lib/` — 源代码放在这里
  - `lib/hello.rb` — gem 的入口文件
  - `lib/hello/` — 子模块和主题
- `exe/` — 可执行脚本（CLI 入口）
- `spec/` — 测试代码（RSpec）
  - `spec/spec_helper.rb` — 测试配置
  - `spec/basic/` — 基础层测试
- `docs/` — mdBook 教程文档
  - `docs/src/SUMMARY.md` — 目录结构
  - `docs/src/basic/` — 基础层文档
  - `docs/src/advance/` — 进阶层文档
- `bin/` — 开发辅助脚本
- `.github/workflows/` — CI/CD 配置

## 测试你的代码

> **良好的编程习惯：一定要写测试。**
> 下面先认识如何编写一个简单的单元测试。你可以参照样例编写自己的测试，逐步深入理解。

### 测试结构

RSpec 测试通常包含以下部分：

1. **描述块**：使用 `describe` 或 `context` 描述被测试的行为。
2. **测试用例**：使用 `it` 定义具体的测试场景。
3. **断言**：使用 `expect(...).to` 验证期望的行为。
4. **运行测试**：使用 `bundle exec rspec` 命令执行测试。

### 示例：基础测试

```ruby
# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Strings module" do
  it "executes without error" do
    expect { Hello::Basic::Strings.run }.not_to raise_error
  end
end
```

运行测试后，你会看到以下输出：

```bash
$ bundle exec rspec --format documentation

Randomized with seed 12345

Strings module
=== 字符串操作 ===

双引号（支持 \n 换行）: Hello
Ruby
插值: Ruby 当前版本 3.4
...
  executes without error

Finished in 0.003 seconds (files took 0.14 seconds to load)
1 example, 0 failures
```

说明测试通过了。如果测试失败，你会看到详细的错误信息：

```bash
$ bundle exec rspec --format documentation

Randomized with seed 54321

Strings module
  executes without error (FAILED - 1)

Failures:

  1) Strings module executes without error
     Failure/Error: expect { Strings.run }.not_to raise_error

       expected no Exception, got #<NameError: uninitialized constant Strings>
     # ./spec/basic/strings_spec.rb:7:in `block (2 levels) in <top (required)>'

Finished in 0.008 seconds (files took 0.15 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/basic/strings_spec.rb:6 # Strings module executes without error
```

> **测试失败时的调试方法：** 仔细阅读错误信息，定位出错的文件和行号。最好的方法是通过错误信息调试代码并解决这些问题，最终可以成功运行测试。这个过程能快速提升你的代码能力。

## 本地查看文档

Hello Ruby 使用 mdBook 编写文档。你可以在本地预览：

```bash
$ cd docs
$ mdbook serve --open
```

这将在浏览器中打开文档页面，支持实时预览。编辑任何 `.md` 文件后自动刷新。

> **经过上述简单旅程，我们已经对 Hello Ruby 有了初步了解。接下来，让我们深入探索 Ruby 的核心概念和特性。开始进入 Ruby 的世界旅行吧！**
