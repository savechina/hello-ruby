# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # 元编程 — define_method, method_missing, eval 的实战演示
    module MetaprogrammingSample
      def self.run
        puts "=== 元编程 — 动态代码生成与执行 ==="
        puts

        # --- 1. define_method — 动态生成方法 ---
        puts "--- 1. 动态生成方法 ---"
        api_class = Class.new(DynamicAPI)
        api_class.define_getter(:user_name) { "Alice" }
        api_class.define_getter(:user_age) { 30 }
        api_class.define_getter(:full_info) { "Alice, age 30" }

        api = api_class.new
        results = [:user_name, :user_age, :full_info].map do |method_sym|
          "#{method_sym} = #{api.send(method_sym)}"
        end
        puts "  动态生成方法调用:"
        results.each { |r| puts "    #{r}" }
        puts "  动态方法列表: #{api_class.public_instance_methods(false).sort.join(', ')}"
        puts

        # --- 2. method_missing — 属性容器 ---
        puts "--- 2. 属性容器（method_missing） ---"
        container = PropertyBag.new
        container.set(:host, "localhost")
        container.set(:port, 8080)
        container.set(:debug, true)

        puts "  设置属性:"
        container.each_key do |k|
          v = container.get(k)
          puts "    #{k}: #{v.inspect} (#{v.class})"
        end

        # 通过 method_missing 访问
        puts "  method_missing 访问:"
        puts "    container.host = #{container.host.inspect}"
        puts "    container.port = #{container.port.inspect}"
        puts "    container.debug = #{container.debug.inspect}"
        puts "    container.missing = #{container.missing.inspect} (不存在的属性)"
        puts

        # --- 3. class_eval — 运行时修改类 ---
        puts "--- 3. 运行时类扩展（class_eval） ---"
        base_class = Class.new do
          attr_accessor :data

          def initialize(data = {})
            @data = data
          end
        end

        base_class.class_eval do
          define_method(:to_json) { JSON.generate(@data) }
          define_method(:merge!) { |other| @data.merge!(other.data) }
          define_method(:keys) { @data.keys }
          define_method(:values) { @data.values }
        end

        obj1 = base_class.new(a: 1, b: 2)
        obj2 = base_class.new(c: 3, d: 4)
        obj1.merge!(obj2)
        puts "  动态添加方法并执行:"
        puts "    to_json = #{obj1.to_json}"
        puts "    keys = #{obj1.keys.inspect}"
        puts "    values = #{obj1.values.inspect}"
        puts

        # --- 4. instance_eval — 单例方法 ---
        puts "--- 4. 单例对象（instance_eval） ---"
        obj_a = Object.new
        obj_b = Object.new

        obj_a.instance_eval do
          @secret = "only in obj_a"
          def secret; @secret; end
        end

        puts "  obj_a.secret = #{obj_a.secret}"
        puts "  obj_b 有 secret? #{obj_b.respond_to?(:secret)}"
        puts "  obj_a 单例类: #{obj_a.singleton_class}"
        puts "  单例方法: #{obj_a.singleton_methods.inspect}"
        puts

        # --- 5. const_get / const_set — 动态常量 ---
        puts "--- 5. 动态常量操作 ---"
        Object.const_set("DYNAMIC_CONST", 42)
        value = Object.const_get(:DYNAMIC_CONST)
        puts "  const_set + const_get: DYNAMIC_CONST = #{value}"

        pi_value = Math.const_get(:PI)
        puts "  Math.const_get(:PI) = #{pi_value}"
        file_sep = File.const_get(:SEPARATOR)
        puts "  File.const_get(:SEPARATOR) = #{file_sep.inspect}"

        constants = Object.constants.grep(/^DY/)
        puts "  匹配 /^DY/ 的常量: #{constants.inspect}"
        puts

        # --- 6. respond_to_missing — 鸭子类型 ---
        puts "--- 6. 鸭子类型接口 ---"
        shape = ShapeLike.new(width: 10, height: 5)
        puts "  ShapeLike 接口检查:"
        puts "    respond_to?(:area) = #{shape.respond_to?(:area)}"
        puts "    respond_to?(:perimeter) = #{shape.respond_to?(:perimeter)}"
        puts "    respond_to?(:volume) = #{shape.respond_to?(:volume)}"
        puts "    area = #{shape.area}"
        puts "    perimeter = #{shape.perimeter}"
        puts

        # --- 7. 方法别名链 ---
        puts "--- 7. 方法包装/别名链 ---"
        wrapped = TimedWrapper.new
        result = wrapped.timed_sum(10_000)
        puts "  包装方法: timed_sum(10000) = #{result[:result]}, time = #{result[:seconds].round(6)}s"

        puts
        puts "=== 元编程演示完成 ==="
      end
    end

    class DynamicAPI
      def self.define_getter(name, &block)
        define_method(name, &block)
      end
    end

    class PropertyBag
      def initialize
        @properties = {}
      end

      def set(key, value)
        @properties[key.to_sym] = value
      end

      def get(key)
        @properties[key.to_sym]
      end

      def each_key(&block)
        @properties.each_key(&block)
      end

      def method_missing(method_name, *args)
        if @properties.key?(method_name)
          @properties[method_name]
        else
          nil
        end
      end

      def respond_to_missing?(_method_name, _include_private = false)
        true
      end
    end

    class ShapeLike
      def initialize(width:, height:)
        @width = width
        @height = height
      end

      def area
        @width * @height
      end

      def perimeter
        2 * (@width + @height)
      end

      def respond_to_missing?(method_name, _include_private = false)
        %i[area perimeter].include?(method_name)
      end

      def method_missing(method_name, *args)
        if %i[area perimeter].include?(method_name)
          send(method_name)
        else
          super
        end
      end
    end

    class TimedWrapper
      def timed_sum(n)
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        result = (1..n).sum
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
        { result: result, seconds: elapsed }
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "metaprogramming", "元编程", Hello::Advance::MetaprogrammingSample)
