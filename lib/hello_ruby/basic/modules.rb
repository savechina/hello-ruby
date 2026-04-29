# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 模块定义前移（避免在 def self.run 内定义）
    module Loggable
      def log(msg)
        puts "  [LOG] #{self.class.name}: #{msg}"
      end
    end

    module Serializable
      def to_json_like
        "{instance_variables: #{instance_variables.map(&:to_s)}}"
      end
    end

    module Timestamped
      attr_accessor :created_at
    end

    # Greetings 演示 module_function
    module Greetings
      module_function

      def hello
        "Hello from module_function"
      end

      def goodbye
        "Goodbye from module_function"
      end
    end

    # EnumerableMixin — 提供 Enumerable 行为的模块
    module EnumerableMixin
      def initialize(data)
        @data = data
      end

      def each(&block)
        @data.each(&block)
      end
    end

    module Modules
      def self.run
        puts "=== 模块 ==="
        puts

        # 1. include — 模块方法成为实例方法
        klass_with_log = Class.new do
          include Loggable
          def do_something
            log("doing something")
          end
        end

        obj = klass_with_log.new
        obj.do_something
        puts

        # 2. extend — 模块方法成为类方法
        klass_with_json = Class.new do
          extend Serializable
        end

        klass_with_json.instance_variable_set(:@foo, "bar")
        puts "extend: #{klass_with_json.to_json_like}"
        puts

        # 3. prepend
        klass_with_ts = Class.new do
          prepend Timestamped
          def initialize
            @created_at = "原始实例值"
          end
          attr_accessor :created_at
        end

        ts_obj = klass_with_ts.new
        ts_obj.created_at = "2024-01-01"
        puts "prepend attr: #{ts_obj.created_at}"
        puts

        # 4. module_function
        puts "module_function 模式:"
        puts "  Greetings.hello: #{Greetings.hello}"
        puts "  Greetings.goodbye: #{Greetings.goodbye}"
        puts

        # 5. include Enumerable
        # 5. include Enumerable
        user_class = Class.new do
          include Enumerable
          include EnumerableMixin
        end
        user = user_class.new(["alice@email.com", "BOB@EMAIL.COM"])
        puts "Enumerable (include):"
        puts "  user.map(&:upcase): #{user.map(&:upcase).inspect}"
        puts "  user.find { |s| s.include?('@') }: #{user.find { |s| s.include?("@") }}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "modules", "模块与混入", Hello::Basic::Modules)
