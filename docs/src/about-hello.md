# 关于 Hello Ruby

Hello Ruby 是一个面向 Ruby 3.2+ 的学习教程项目，目标是从零开始带你掌握 Ruby 语言的核心语法、高级特性和生产级开发能力。

这个项目适合三类人。第一类是完全没接触过 Ruby 的编程初学者。项目从变量、字符串、控制流这些最基础的概念讲起，每个概念都有独立的可运行代码。第二类是有其他语言经验想快速上手的开发者。Ruby 的语法简洁优雅，但它的元编程、块和 Proc、模块混入这些特性在其他语言中并不常见。这些内容在 Advance 部分会重点讲解。第三类是已经掌握基础想构建实际应用的开发者。Awesome 部分用 Rails、Sidekiq、dry-system 等技术栈展示如何搭建生产级项目。

## 项目结构

Hello Ruby 分为三个层级，每个层级面向不同阶段的学习需求。

**基础部分 (Basic)** 涵盖 15 个核心主题，包括变量、字符串、数组、哈希、控制流、方法、类、模块、块与 Proc、文件 I/O、异常处理等。这些都是 Ruby 语言的基石，学完这一部分你就可以写出完整的 Ruby 脚本。

**进阶部分 (Advance)** 包含 10 个高级主题，深入 Ruby 的并发模型、元编程、Enumerable 深度使用、数据库 ORM、错误处理模式、RSpec 测试、依赖注入、CLI 开发、性能优化等领域。学完这一部分你就能理解 Ruby 生态中大多数库的设计思路。

**实战精选 (Awesome)** 是生产级的实战内容，使用 Rails、Sidekiq、REST API 设计、认证授权、Docker 部署等工业级工具链。这部分内容依赖完整的 gem 栈，适合想要构建实际项目的开发者。

## CLI 快速上手

Hello Ruby 使用 Thor 构建了一个命令行工具 `hello`。安装项目后，你可以通过命令行直接运行任意教程模块：

```bash
# 查看所有可用命令
hello --help

# 运行全部基础示例
hello basic

# 运行单个高级主题
hello advance metaprogramming

# 搜索某个主题
hello search enumerable

# 查看版本
hello version
```

每个主题都是一个独立的 Ruby 模块，可以在不运行整个项目的情况下单独执行。这种设计让你可以聚焦于当前学习的概念，不被其他代码干扰。

## 技术栈

Hello Ruby 使用的技术栈与真实 Ruby 生产项目一致：

- **Ruby 3.2+** — 现代 Ruby，支持 Ractor、模式匹配等特性
- **Thor** — 命令行框架
- **RSpec** — 测试框架
- **RuboCop** — 代码规范检查
- **Sorbet** — 可选的类型检查
- **Bundler** — 依赖管理
- **Sequel** — ORM（进阶部分使用）
- **dry-system / dry-monads** — 函数式工具链（实战部分使用）

## 如何学习

建议按顺序学习 Basic → Advance → Awesome。每个部分都有对应的 mdBook 文档和可运行的 Ruby 代码。文档讲解概念，代码验证理解。你可以边读文档边在终端运行示例，这样学习效率最高。

如果你 Already 熟悉 Ruby 基础，可以直接跳到 Advance 部分。每个章节都是自包含的，不需要按顺序阅读。但元编程和并发模型这两章建议先读，它们是理解后续内容的基础。
