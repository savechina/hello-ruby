# LLM 集成 (Large Language Model Integration)

## 概述

LLM 集成是现代应用程序开发的关键技能。Ruby 通过 `ruby-openai` gem 提供了简洁的 OpenAI API 接口，同时也支持 Ollama 本地 LLM 的 OpenAI 兼容接口。本章节将介绍如何在 Ruby 中安全地管理 API 密钥、构建提示词、处理流式响应，以及实现健壮的错误处理机制。

核心要点：
- **API 密钥管理**：使用 dotenv 环境变量，避免硬编码
- **客户端配置**：全局配置一次，复用客户端实例
- **提示词工程**：结构化消息数组，支持多轮对话
- **流式响应**：实时输出，改善用户体验
- **错误处理**：分类异常，指数退避重试

## 示例

### 示例 1：安全的 API 密钥管理

```ruby
# .env 文件（不要提交到 git！）
OPENAI_ACCESS_TOKEN=sk-your-key-here
OPENAI_ORGANIZATION_ID=org-your-org-id

# 代码中安全访问
require 'dotenv/load'
api_key = ENV.fetch('OPENAI_ACCESS_TOKEN')
# KeyError 如果密钥未设置会抛出异常，防止空密钥调用
```

### 示例 2：客户端初始化与 Ollama 兼容

```ruby
require 'ruby-openai'

# OpenAI 配置
OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_ACCESS_TOKEN')
  config.log_errors = true  # 仅开发环境
end

client = OpenAI::Client.new

# Ollama 本地 LLM（OpenAI 兼容）
ollama = OpenAI::Client.new(uri_base: 'http://localhost:11434')
# 无需 API 密钥，本地运行
```

### 示例 3：流式响应处理

```ruby
client.chat(
  parameters: {
    model: 'gpt-4o',
    messages: [{ role: 'user', content: '讲一个故事' }],
    stream: proc do |chunk, _event|
      content = chunk.dig('choices', 0, 'delta', 'content')
      print content if content  # 实时打印
    end,
    stream_options: { include_usage: true }  # 包含 token 统计
  }
)
```

## 知识检查

1. 为什么不应该在代码中硬编码 API 密钥？正确的管理方式是什么？
2. 如何使用 Ollama 本地 LLM 替代 OpenAI API？需要哪些配置变更？
3. 流式响应相比等待完整响应有什么优势？如何处理流式输出？

## 参考资源

- [ruby-openai GitHub](https://github.com/alexrudall/ruby-openai)
- [OpenAI API 文档](https://platform.openai.com/docs)
- [Ollama 官网](https://ollama.ai)
- [dotenv gem](https://github.com/bkeepers/dotenv)