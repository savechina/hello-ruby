# typed: true
# frozen_string_literal: true

module Hello
  # TopicRegistry — 主题注册表
  #
  # 类比 Rust 的 `inventory` crate：在模块加载时自动注册 topic 处理器。
  # 所有示例模块通过 TopicRegistry.register 将自身注册到全局表中，
  # CLI 的 `run` 命令通过 lookup 查找并执行对应 topic。
  #
  # 线程安全：使用 Mutex 保护内部哈希。
  class TopicRegistry
    @topics = {}
    @mutex  = Mutex.new

    class << self
      # 注册一个 topic 处理程序
      #
      # @param tier [String] 层级："basic" / "advance" / "awesome"
      # @param name [String] 主题名称，如 "variables" / "strings"
      # @param description [String] 中文描述
      # @param callable [Module, Proc] 可调用对象或包含 self.run 的模块
      def register(tier, name, description, callable)
        key = "#{tier}/#{name}"
        @mutex.synchronize do
          if @topics.key?(key)
            warn "[Warning] Topic '#{key}' is already registered, overwriting."
          end
          @topics[key] = {
            tier: tier,
            name: name,
            description: description,
            callable: callable
          }
        end
      end

      # 查找指定 topic
      #
      # @param tier [String] 层级
      # @param name [String] 主题名称
      # @return [Hash, nil] topic 信息或 nil
      def lookup(tier, name)
        @mutex.synchronize do
          @topics["#{tier}/#{name}"]
        end
      end

      # 列出指定层级下的所有 topic
      #
      # @param tier [String] 层级
      # @return [Array<Hash>] topic 列表
      def list(tier)
        @mutex.synchronize do
          @topics.values.select { |t| t[:tier] == tier }
        end
      end

      # 列出所有已注册 topic
      #
      # @return [Array<Hash>] 所有 topic 信息
      def list_all
        @mutex.synchronize do
          @topics.values.sort_by { |t| "#{t[:tier]}/#{t[:name]}" }
        end
      end

      # 运行指定 topic
      #
      # @param tier [String] 层级
      # @param name [String] 主题名称
      # @raise [NotFoundError] 当 topic 不存在时
      def run(tier, name)
        topic = lookup(tier, name)
        raise NotFoundError, "Topic '#{tier}/#{name}' not found" unless topic

        puts "== #{topic[:description]} =="
        puts
        handler = topic[:callable]
        if handler.respond_to?(:run)
          handler.run
        elsif handler.respond_to?(:call)
          handler.call
        else
          raise ArgumentError, "Topic handler must have .run or .call: #{handler}"
        end
        puts
      end
    end
  end
end
