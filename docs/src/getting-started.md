# 快速开始

## 安装 Ruby 3.2+

Hello Ruby 需要 Ruby 3.2 或更高版本。推荐使用 `rbenv` 管理 Ruby 版本，这样可以在不同项目之间灵活切换。

macOS 用户可以用 Homebrew 安装 rbenv：

```bash
brew install rbenv ruby-build

# 初始化 rbenv（按照提示将以下内容加入 shell 配置文件）
rbenv init

# 安装 Ruby 3.2
rbenv install 3.2.0
rbenv global 3.2.0

# 验证安装
ruby --version
# 输出: ruby 3.2.x
```

Linux 用户也可以通过 rbenv 或 `asdf` 安装 Ruby。Windows 用户推荐使用 WSL2 环境。

如果你不想用 rbenv，也可以直接用系统包管理器安装 Ruby，但版本可能不是最新的 3.2。你可以用 `ruby -v` 检查当前版本。

## 安装项目依赖

克隆项目后，进入目录安装 gems：

```bash
git clone https://github.com/savechina/hello-ruby.git
cd hello-ruby

# 运行设置脚本
bin/setup
# 这个脚本等同于 bundle install

# 确认依赖安装成功
bundle check
```

`bin/setup` 会执行 `bundle install` 安装所有需要的 gems，包括 Thor（CLI 框架）、RSpec（测试）、Sequel（ORM）、dry-system（依赖注入）等。

## 验证安装

安装完成后，运行 `hello` 命令验证：

```bash
# 查看帮助
hello --help

# 运行全部基础示例
hello basic

# 运行单个主题
hello advance enumerable

# 搜索主题
hello search 元编程

# 查看版本
hello version
```

如果 `hello basic` 能正常运行并输出各个模块的结果，说明安装成功。如果遇到问题，检查 Ruby 版本是否为 3.2+，以及 `bundle install` 是否无报错完成。

## 项目结构一览

```
hello-ruby/
├── bin/
│   ├── setup              # 安装脚本
│   └── console            # 交互式 Ruby 控制台
├── config/
│   └── settings.yml       # 应用配置
├── exe/
│   └── hello_ruby         # CLI 入口
├── lib/
│   ├── hello_ruby.rb      # Gem 入口
│   └── hello_ruby/
│       ├── basic/         # 基础层（15 个主题）
│       ├── advance/       # 进阶层（10 个主题）
│       └── awesome/       # 实战层（生产级）
├── spec/
│   ├── spec_helper.rb
│   ├── basic/             # 基础层测试
│   ├── advance/           # 进阶层测试
│   └── awesome/           # 实战层测试
├── docs/
│   └── src/               # mdBook 教程文档
│       ├── SUMMARY.md     # 目录结构
│       ├── basic/         # 基础层文档
│       ├── advance/       # 进阶层文档
│       └── awesome/       # 实战层文档
└── Gemfile
```

`lib/hello_ruby/` 下的每个 Ruby 文件对应一个教程主题。这些文件都是可独立运行的模块，包含丰富的注释和示例代码。`docs/src/` 下的 md 文件是配套的文字教程，讲解概念和背后的设计思想。

## 文档和 CLI 配合使用

最佳的学习方式是文档和 CLI 配合使用：

1. **先读文档。** 打开 mdBook 教程，阅读当前章节的概念讲解。文档会解释每个特性"是什么"以及"为什么这样设计"。

2. **再运行代码。** 在终端运行对应的 CLI 命令，比如 `hello advance metaprogramming`。观察控制台输出，验证你对概念的理解。

3. **修改代码再运行。** 进入 `lib/hello_ruby/advance/` 找到对应的 Ruby 文件，修改其中的代码再运行。通过动手改代码，你会对这些概念有更深入的理解。

4. **跑测试。** 修改代码后用 `bundle exec rspec` 运行测试。如果测试通过说明你的理解是正确的。如果测试失败就去看看测试期望什么行为，这是另一种学习方式。

用这种方式，一个主题一个主题地推进，你会逐步建立起对 Ruby 语言的系统认知。
