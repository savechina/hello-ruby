# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 模块混入 — 实际运行的代码示例
    module ModulesSample
      # 预定义的模块（不在 run 内定义）
      module Loggable
        def log(msg)
          "[#{self.class.name}] #{msg}"
        end
      end

      module Serializable
        def to_json_like
          "{#{instance_variables.map { |v| "#{v}=#{instance_variable_get(v)}" }.join(", ")}}"
        end
      end

      module Timestamped
        attr_accessor :created_at
      end

      module Greetings
        module_function

        def hello
          "Hello from module_function"
        end

        def goodbye
          "Goodbye from module_function"
        end
      end

      module EnumerableMixin
        def initialize(data)
          @data = data
        end

        def each(&block)
          @data.each(&block)
        end
      end

      def self.run
        puts "=== 模块混入 ==="
        puts

        # 1. include — 模块方法成为实例方法
        klass_with_log = Class.new do
          include Loggable

          def do_work
            log("doing work")
          end
        end
        work_obj = klass_with_log.new
        log_result = work_obj.do_work
        puts "1. include (实例方法):"
        puts "   log('doing work') => #{log_result}"
        puts

        # 2. extend — 模块方法成为类方法
        klass_with_json = Class.new do
          extend Serializable
        end
        klass_with_json.instance_variable_set(:@foo, "bar")
        json_result = klass_with_json.to_json_like
        puts "2. extend (类方法):"
        puts "   klass.to_json_like => #{json_result}"
        puts

        # 3. prepend — 方法优先级高于原类
        klass_with_ts = Class.new do
          prepend Timestamped

          def initialize
            @created_at = "original"
          end
          attr_accessor :created_at
        end
        ts_obj = klass_with_ts.new
        ts_obj.created_at = "2024-01-01"
        puts "3. prepend (方法优先级):"
        puts "   created_at => #{ts_obj.created_at}"
        puts

        # 4. module_function
        puts "4. module_function:"
        puts "   Greetings.hello: #{Greetings.hello}"
        puts "   Greetings.goodbye: #{Greetings.goodbye}"
        puts

        # 5. Enumerable 混入
        enumerable_class = Class.new do
          include Enumerable
          include EnumerableMixin
        end
        enum_obj = enumerable_class.new(["alice@x.com", "BOB@Y.COM"])
        mapped = enum_obj.map { |s| s.upcase }
        found = enum_obj.find { |s| s.include?("@") }
        puts "5. Enumerable混入:"
        puts "   map(&:upcase): #{mapped.inspect}"
        puts "   find with '@': #{found}"
        puts

        # 6. 祖先链
        puts "6. 祖先链:"
        puts "   klass_with_log.ancestors: #{klass_with_log.ancestors.take(4).inspect}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "modules", "模块与混入", Hello::Basic::ModulesSample)
