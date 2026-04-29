# 术语表

## Basic 基础术语

| 英文 | 中文 | 说明 |
|------|------|------|
| Variable | 变量 | 存储数据的命名容器 |
| Local Variable | 局部变量 | 作用域限定在代码块内 |
| Instance Variable | 实例变量 | 以 `@` 开头，属于对象实例 |
| Class Variable | 类变量 | 以 `@@` 开头，类及其子类共享 |
| Global Variable | 全局变量 | 以 `$` 开头，全局可见 |
| Constant | 常量 | 以大写字母开头，值不应改变 |
| String | 字符串 | 字符序列 |
| Array | 数组 | 有序集合 |
| Hash | 哈希 | 键值对集合 |
| Method | 方法 | 可重复调用的代码块 |
| Block | 块 | 用 `{}` 或 `do...end` 包围的代码 |
| Class | 类 | 创建对象的蓝图 |
| Module | 模块 | 方法与常量的命名空间 |
| Symbol | 符号 | 内部化字符串，轻量标识符 |
| Scope | 作用域 | 变量可访问的范围 |

## Advance 进阶术语

| 英文 | 中文 | 说明 |
|------|------|------|
| Enumerable | 可枚举 | 提供迭代方法的模块 (map, select, reduce) |
| Metaprogramming | 元编程 | 运行时动态生成/修改代码 |
| Thread | 线程 | 操作系统级并发单元 |
| Fiber | 协程 | 轻量级协作式并发 |
| Ractor | Ractor | Ruby 3+ 的 Actor 模型并行 |
| GVL | 全局 VM 锁 | Ruby 限制同一时刻只有一个线程执行 |
| Mutex | 互斥锁 | 保护共享资源的同步原语 |
| Queue | 队列 | 线程安全的先进先出数据结构 |
| ORM | 对象关系映射 | 将数据库行映射为对象 |
| Dependency Injection | 依赖注入 | 将依赖关系外部化注入对象 |
| Result Monad | Result 单子 | 函数式错误处理模式 |
| Benchmark | 基准测试 | 测量代码性能的工具 |

## Awesome 实战术语

| 英文 | 中文 | 说明 |
|------|------|------|
| Container | 容器 | dry-system 的依赖注入容器 |
| Provider | 提供者 | dry-system 中注册组件的方式 |
| Component | 组件 | 自动注册的可注入对象 |
| Service | 服务 | 微服务架构中的独立部署单元 |
| Pool | 连接池 | 复用数据库连接以提高性能 |
| Migration | 迁移 | 数据库 schema 的版本控制变更 |
| CI/CD | 持续集成/部署 | 自动化构建、测试与部署流程 |
| Gem | 宝石/库 | Ruby 的包分发格式 |
