# 基础入门 (Basic)

## 学习内容概览

欢迎来到 Ruby 编程之旅的第一站！**基础入门**部分将带你掌握 Ruby 的核心概念和编程风格。Ruby 是一门注重开发者幸福感的语言——它的语法优雅自然，读起来像英文，写起来像诗歌。

完成本部分学习后，你将具备用 Ruby 解决日常问题的能力，并为后续高级主题（元编程、并发、测试驱动开发）打下坚实基础。

## 你将学到什么

通过 15 个循序渐进的章节，你将掌握：

1. **变量与数据类型** — 理解 Ruby 的动态类型系统和五种变量作用域
2. **字符串与集合** — 熟练处理文本、数组、哈希，掌握 Ruby 最常用数据结构
3. **流程控制与方法** — 编写条件判断、循环和灵活可调用的方法
4. **类与对象** — 用面向对象的方式组织代码，设计清晰的对象接口
5. **模块与混入** — 用模块实现代码复用和横切关注点
6. **块与 Proc** — 理解 Ruby 最具特色的闭包和回调模式
7. **文件与异常** — 读写文件、处理错误、编写健壮的程序

## 章节列表

| # | 章节 | 说明 | 难度 | 预计时间 |
|---|------|------|------|---------|
| 1 | [变量与作用域](variables.md) | 局部变量、实例变量、类变量、全局变量、常量 | 🟢 简单 | 20 分钟 |
| 2 | [字符串操作](strings.md) | 插值、方法链、frozen_string_literal、Heredoc | 🟢 简单 | 30 分钟 |
| 3 | [数组](arrays.md) | 创建、索引增删、map/select/reduce、迭代器 | 🟢 简单 | 25 分钟 |
| 4 | [哈希](hashes.md) | 符号键、dig、merge、transform_values | 🟢 简单 | 25 分钟 |
| 5 | [控制流](control-flow.md) | if/case/unless、循环、迭代器、next/break | 🟢 简单 | 30 分钟 |
| 6 | [方法定义与调用](methods.md) | 默认参数、关键字参数、splat、块捕获 | 🟢 简单 | 25 分钟 |
| 7 | [类与对象](classes.md) | initialize、attr_*、类方法、继承 | 🟡 中等 | 30 分钟 |
| 8 | [模块与混入](modules.md) | include、extend、prepend、module_function | 🟡 中等 | 30 分钟 |
| 9 | [块与 Proc](blocks-procs.md) | Block、Proc、Lambda 的创建与差异 | 🟡 中等 | 35 分钟 |
| 10 | [文件 I/O](file-io.md) | File.open、Pathname、Dir.glob、CSV | 🟢 简单 | 25 分钟 |
| 11 | [异常处理](exceptions.md) | rescue、ensure、retry、raise、else 块 | 🟡 中等 | 30 分钟 |
| 12 | [数字与数值运算](numbers.md) | Integer 任意精度、Float 精度、BigDecimal、Rational | 🟢 简单 | 25 分钟 |
| 13 | [符号（Symbol）](symbols.md) | 符号内部原理、哈希键惯例、内存影响 | 🟡 中等 | 25 分钟 |
| 14 | [正则表达式](regex.md) | 字面量、修饰符、捕获组、gsub/scan | 🟡 中等 | 35 分钟 |
| 15 | [文件管理](file-management.md) | Dir、FileTest、Pathname、临时目录 | 🟢 简单 | 25 分钟 |

**总计**: 15 章 | **总时间**: 约 7 小时

## 学习路径

```
变量 → 字符串 → 数组 → 哈希 → 控制流 → 方法
                                        ↓
类 ←── 模块 ←── 块与 Proc ←── 文件 I/O ←── 异常
                                        ↓
数字 ←── 符号 ←── 正则 ←── 文件管理 → 🎓 阶段复习
```

## 前置要求

**无需 Ruby 基础！** 本部分从零开始教学。

建议具备：
- 基本编程概念（变量、循环、函数）
- Ruby 3.2+ 开发环境已安装

## 怎么用这个教程

每章都是可独立运行的代码模块。运行方式：

```bash
# 运行全部基础示例
hello basic

# 运行单个主题
hello basic variables

# 运行单个主题
hello basic strings
```

你也可以在 IRB 中交互式学习：

```bash
bin/console
```

## 学习检查点

完成本部分后，你应该能够：

- [ ] 区分局部变量、实例变量、类变量和全局变量
- [ ] 熟练使用字符串插值和字符串操作链
- [ ] 用 map/select/reduce 处理数组和哈希
- [ ] 编写带默认参数和关键字参数的方法
- [ ] 定义类、声明属性、实现继承
- [ ] 用 include/extend 混入模块功能
- [ ] 理解 Block、Proc、Lambda 的差异
- [ ] 读写文件并处理 CSV 数据
- [ ] 用 rescue/ensure 构建健壮的错误处理
- [ ] 使用正则表达式匹配和提取文本

## 实践建议

1. 每章的代码示例都要亲手敲一遍，不要只看不练
2. 修改示例中的值，观察输出变化
3. 尝试用刚学的知识解决简单的实际问题
4. 完成阶段复习的综合练习

## 下一步

完成基础入门后，继续学习 **高级进阶** 部分，你将深入：

- 元编程与动态代码生成
- 并发模型（Thread/Fiber/Ractor）
- ActiveRecord 数据库操作
- RSpec 测试驱动开发
- dry-system 依赖注入

准备好了吗？让我们开始 [变量与作用域](variables.md) 的学习！

---

## 术语表

| English | 中文 |
|---------|------|
| Variable | 变量 |
| Scope | 作用域 |
| Dynamic Typing | 动态类型 |
| Collection | 集合 |
| Control Flow | 控制流 |
| Method | 方法 |
| Class | 类 |
| Module | 模块 |
| Mixin | 混入 |
| Block | 代码块 |
| Closure | 闭包 |
| Pattern Matching | 模式匹配 |

---

> 💡 **提示**：Ruby 的设计哲学是 "最小惊讶原则"——大多数情况下，代码的表现会符合你的直觉信任它。
