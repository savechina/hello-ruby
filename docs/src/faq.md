# 常见问题 FAQ

## 入门相关

### Q: 如何安装 Ruby 3.2+？

推荐使用 [rbenv](https://github.com/rbenv/rbenv) 管理 Ruby 版本：

```bash
# 安装 rbenv
brew install rbenv ruby-build
rbenv install 3.2.1
rbenv global 3.2.1
```

或者使用 [mise-en-place](https://mise.jdx.dev/)：

```bash
mise use ruby@3.2.1
```

### Q: `bundle install` 失败怎么办？

1. 确认 Ruby 版本 ≥ 3.2.0: `ruby -v`
2. 检查 `.ruby-version` 文件是否与安装版本匹配
3. 尝试 `gem update --system` 升级 RubyGems
4. 删除 `Gemfile.lock` 后重新 `bundle install`

### Q: CLI 命令 `hello` 找不到？

确认已运行 `bundle install` 安装所有依赖。运行方式：

```bash
bundle exec hello version
```

如果希望全局使用，可运行 `bundle binstubs hello` 创建 binstub。

## 学习相关

### Q: 没有编程基础可以从这里开始吗？

可以。Basic 层级从零开始，按照顺序学习即可。每个主题都是独立的，但按顺序学习效果最佳。

### Q: 学完 Basic 就能做什么？

掌握 Basic 后，你可以：
- 编写自动化脚本
- 理解大多数 Ruby gem 的源码结构
- 开始学习 Advance 级别的元编程、并发等主题

### Q: Advance 和 Awesome 有什么区别？

- **Advance** — 学习 Ruby 的高级特性和工程工具（RSpec、Sequel、dry-system）
- **Awesome** — 生产环境级别的应用架构（Web 服务、消息队列、Docker 部署）

### Q: 可以和 The Ruby Programming Language 或 Ruby Koans 配合使用吗？

可以。本项目的结构化教程与经典材料互补。推荐搭配：
- [Ruby Koans](http://rubykoans.com/) — 动手练习
- [Ruby-Doc.org](https://ruby-doc.org/) — API 参考
- [TryRuby](https://ruby-lang.org/en/documentation/quickstart/) — 在线练习

## 技术问题

### Q: 如何贡献内容？

1. Fork 仓库
2. 创建分支 `feat/add-topic-TOPIC_NAME`
3. 编写 topic 代码 + 对应的 mdBook 文档
4. 提交 PR

详见 [贡献指南](./CONTRIBUTING.md)。

### Q: 如何在本地预览 mdBook 文档？

```bash
cargo install mdbook
cd docs
mdbook serve --open
```

> 💡 **提示**: mdBook 支持实时预览。编辑任何 .md 文件后自动刷新。

### Q: 项目使用什么 Ruby 版本？

`.ruby-version` 指定为 `3.2.1`。gemspec 要求 `>= 3.2.0`。

### Q: 为什么选择 Thor 作为 CLI 框架？

Thor 是 Ruby 生态中最流行的 CLI 框架之一。它提供：
- 子命令自动注册
- 类型化选项解析
- 内置帮助生成
- 与 Rails、Vagrant 等大型项目相同的技术栈

### Q: 这个项目与 hello-rust 是什么关系？

两者由同一作者开发，遵循相似的三层级教学结构（Basic → Advance → Awesome）和 mdBook 文档体系。hello-ruby 是 Ruby 语言版本。
