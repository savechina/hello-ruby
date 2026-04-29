# 高级进阶

完成了 Basic 部分的学习后，你已经掌握了 Ruby 的核心语法。现在该进入 Advance 部分了，这里的内容会让你对 Ruby 的理解从"会写代码"升级到"理解 Ruby 的设计思想"。

Advance 部分涵盖 10 个主题，每个主题都深入 Ruby 的一个高级领域。这些内容不是孤立的知识点，而是彼此关联的体系。比如元编程是理解 Rails 魔法的基础，并发模型是构建高性能服务的前提，测试和依赖注入是生产级项目不可或缺的环节。

## 学习内容概览

| # | 主题 | 核心内容 | 运行命令 |
|---|------|---------|---------|
| 1 | [并发模型：Thread/Fiber/Ractor](./async-await.md) | 三种并发原语、GVL、消息传递 | `hello advance async_await` |
| 2 | [元编程](./metaprogramming.md) | method_missing、define_method、class_eval、open classes | `hello advance metaprogramming` |
| 3 | [Enumerable 深度探索](./enumerable.md) | 自定义 Enumerable、惰性求值、高级遍历方法 | `hello advance enumerable` |
| 4 | [数据库与 ORM](./database.md) | Sequel 连接、模型、迁移、关联、查询 | `hello advance database` |
| 5 | [错误处理模式](./error-handling.md) | Result monad、safe navigation、异常层级 | `hello advance error_handling` |
| 6 | [测试模式 RSpec](./testing.md) | describe/context/it、shared examples、mock/stub | `hello advance testing` |
| 7 | [dry-system 依赖注入](./dry-system.md) | 容器、自动注册、Provider、Import mixin | `hello advance dry_system` |
| 8 | [Thor CLI 高级用法](./cli-advanced.md) | class_option、subcommands、参数解析 | `hello advance cli_advanced` |
| 9 | [线程与协程](./threads-fibers.md) | GVL 详解、Thread 生命周期、Fiber 管道、Ractor | `hello advance threads_fibers` |
| 10 | [性能优化](./performance.md) | Benchmark、GC 统计、对象分配分析、惰性求值 | `hello advance performance` |

阅读本部分时，建议先理解每个主题的设计动机，再学习具体 API。Ruby 的设计哲学是"让程序员快乐"，每个高级特性背后都有明确的场景需求。理解了"Why"，使用"How"就会自然很多。

学完这 10 个主题后，你可以完成阶段复习，综合运用元编程、DI 和测试来设计一个小服务。复习章节会引导你将零散的知识点串联成完整的工程能力。
