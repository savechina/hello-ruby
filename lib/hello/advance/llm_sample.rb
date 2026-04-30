# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    class LlmSample
      def self.run
        puts "=== LLM 集成 — API 调用与对话管理 ==="
        puts

        dotenv_setup
        client_initialization
        prompt_construction
        streaming_responses
        error_handling_patterns

        puts "=== LLM 集成演示完成 ==="
      end

      def self.dotenv_setup
        puts "--- 1. API 密钥管理 (dotenv) ---"
        puts "  使用 dotenv 从 .env 文件加载 API 密钥"
        puts
        puts "  # .env 文件内容 (不要提交到 git!):"
        puts "  OPENAI_ACCESS_TOKEN=sk-your-key-here"
        puts "  OPENAI_ORGANIZATION_ID=org-your-org-id"
        puts
        puts "  # 代码中安全访问:"
        puts "  require 'dotenv/load'"
        puts "  api_key = ENV.fetch('OPENAI_ACCESS_TOKEN')"
        puts
        puts "  ✓ 避免硬编码密钥，使用环境变量"
        puts
      end

      def self.client_initialization
        puts "--- 2. OpenAI 客户端设置 ---"
        puts "  ruby-openai gem 提供简洁的客户端接口"
        puts
        puts "  # 安装 gem:"
        puts "  gem install ruby-openai  # 或 bundle add ruby-openai"
        puts
        puts "  # 配置客户端:"
        puts "  OpenAI.configure do |config|"
        puts "    config.access_token = ENV.fetch('OPENAI_ACCESS_TOKEN')"
        puts "    config.log_errors = true  # 仅开发环境"
        puts "  end"
        puts
        puts "  client = OpenAI::Client.new"
        puts
        puts "  # Ollama 本地 LLM (OpenAI 兼容):"
        puts "  ollama = OpenAI::Client.new(uri_base: 'http://localhost:11434')"
        puts
        puts "  ✓ 配置一次，全局复用"
        puts
      end

      def self.prompt_construction
        puts "--- 3. 提示词工程模式 ---"
        puts "  消息数组结构：system/user/assistant 角色"
        puts
        puts "  # 基础对话:"
        puts "  messages = ["
        puts "    { role: 'system', content: '你是 Ruby 编程专家' },"
        puts "    { role: 'user', content: '解释 Ruby blocks' }"
        puts "  ]"
        puts
        puts "  # 多轮对话 (追加历史):"
        puts "  messages << { role: 'assistant', content: 'Blocks 是闭包...' }"
        puts "  messages << { role: 'user', content: '给我一个例子' }"
        puts
        puts "  # ERB 模板动态生成:"
        puts "  template = <<~PROMPT"
        puts "    请审查这段 <%= lang %> 代码:"
        puts "    ```<%= lang %>"
        puts "    <%= code %>"
        puts "    ```"
        puts "  PROMPT"
        puts
        puts "  ✓ 结构化消息，便于维护"
        puts
      end

      def self.streaming_responses
        puts "--- 4. 流式响应处理 ---"
        puts "  实时输出，改善用户体验"
        puts
        puts "  # 流式 chat completion:"
        puts "  client.chat("
        puts "    parameters: {"
        puts "      model: 'gpt-4o',"
        puts "      messages: [{ role: 'user', content: '讲一个故事' }],"
        puts "      stream: proc do |chunk, _event|"
        puts "        content = chunk.dig('choices', 0, 'delta', 'content')"
        puts "        print content if content"
        puts "      end"
        puts "    }"
        puts "  )"
        puts
        puts "  # 包含 usage 统计:"
        puts "  stream_options: { include_usage: true }"
        puts
        puts "  ✓ 实时输出，无需等待完整响应"
        puts
      end

      def self.error_handling_patterns
        puts "--- 5. API 错误处理 ---"
        puts "  重试机制与错误分类"
        puts
        puts "  # 错误类型:"
        puts "  Faraday::TimeoutError   # 超时 - 重试"
        puts "  Faraday::ClientError    # 4xx - 检查密钥/参数"
        puts "  Faraday::ServerError    # 5xx - 重试"
        puts
        puts "  # 指数退避重试:"
        puts "  retries = 0"
        puts "  begin"
        puts "    client.chat(...)"
        puts "  rescue Faraday::TimeoutError"
        puts "    retries += 1"
        puts "    sleep(2 ** retries)  # 2s, 4s, 8s..."
        puts "    retry if retries < 3"
        puts "    raise 'Max retries exceeded'"
        puts "  rescue Faraday::ClientError => e"
        puts "    status = e.response[:status]"
        puts "    case status"
        puts "    when 401; raise '认证失败 - 检查 API 密钥'"
        puts "    when 429; raise '速率限制 - 请稍后重试'"
        puts "    end"
        puts "  end"
        puts
        puts "  ✓ 分类处理，优雅降级"
        puts
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "llm", "LLM 集成", Hello::Advance::LlmSample)