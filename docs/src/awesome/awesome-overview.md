# 实战精选 (Awesome)

Awesome 层级展示生产环境级别的 Ruby 应用架构与工程实践。

## 本层级目标

- 理解真实项目中的依赖管理与 DI 模式
- 掌握 Web 服务、REST API、消息队列等生产架构
- 学习 Docker 部署与 CI/CD 流水线配置

## 与 Basic / Advance 的区别

| 维度 | Basic | Advance | Awesome |
|------|-------|---------|---------|
| 目标读者 | 初学者 | 中级开发者 | 高级工程师 |
| 代码复杂度 | 单一文件，stdlib | 多模块，少量 gem | 完整工程，生产 gem 栈 |
| 运行方式 | `hello basic TOPIC` | `hello advance TOPIC` | 独立服务/部署 |

## 内容规划

> 🔧 Awesome 层级内容正在建设中，包含以下主题：

- [ ] 数据库高级应用（连接池优化、迁移策略、复杂查询）
- [ ] 微服务架构（服务拆分、API 网关、服务发现）
- [ ] 依赖注入进阶（dry-system provider 定制、多环境配置）
- [ ] 消息队列（Sidekiq 集成、Redis 队列、重试策略）
- [ ] 模板引擎与视图渲染（ERB、Slim、布局系统）

## 运行前置要求

Awesome 层级示例需要完整的生产 gem 栈：

```bash
bundle install
bundle exec hello awesome
```

> 💡 **提示**: Awesome 层级当前为占位阶段。完成 Advance 层级后，可参考 [hello-rust Awesome 部分](https://github.com/savechina/hello-rust) 获取生产架构灵感。

## 继续学习

- 回顾: [高级进阶](../advance/review-advance.md)
- 反馈: 在 [GitHub Issues](https://github.com/savechina/hello-ruby/issues) 提出 Awesome 层级内容建议
