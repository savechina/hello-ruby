# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # 元编程
    # method_missing、define_method、class_eval/module_eval、send、const_get
    module Metaprogramming
      def self.run
        puts "=== 元编程 ==="
        puts

        # --- 1. def 与 class 都是表达式 ---
        puts "--- 一切皆动态 ---"
        # Ruby 的 def/class/module 都是普通表达式，可出现在方法体内
        def create_method(name, &block)
          define_method(name, &block)
        end
        # 注：define_method 需要在模块/类上下文中调用，
        # 这里展示概念，实际使用见下方
        puts "  Ruby 中 def/class/module 都是表达式，不是关键字"
        puts

        # --- 2. define_method — 动态定义方法 ---
        puts "--- define_method（动态定义方法） ---"
        klass_with_dynamic = Class.new do
          %w[dog cat bird].each do |animal|
            define_method("#{animal}_sound") do
              case animal
              when "dog"  then "汪！"
              when "cat"  then "喵！"
              when "bird" then "叽！"
              end
            end
          end
        end

        animal_klass = klass_with_dynamic.new
        puts "  dog_sound: #{animal_klass.dog_sound}"
        puts "  cat_sound: #{animal_klass.cat_sound}"
        puts "  bird_sound: #{animal_klass.bird_sound}"
        puts "  方法列表: #{animal_klass.methods.grep(/_sound$/).sort.join(", ")}"
        puts

        # --- 3. method_missing — 拦截未定义方法 ---
        puts "--- method_missing（方法拦截） ---"
        dynamic_hash = Class.new do
          def initialize
            @data = {}
          end

          def method_missing(name, *args)
            name_str = name.to_s
            if name_str.end_with?("=")
              # setter: obj.foo = value → @data[:foo] = value
              @data[name_str.chomp("=").to_sym] = args.first
            else
              # getter: obj.foo → @data[:foo]
              @data[name.to_sym]
            end
          end

          def respond_to_missing?(name, include_private = false)
            true
          end
        end

        dh = dynamic_hash.new
        dh.name = "Alice"
        dh.age = 30
        dh.city = "Shanghai"
        puts "  dh.name = #{dh.name}"
        puts "  dh.age = #{dh.age}"
        puts "  dh.city = #{dh.city}"
        puts "  dh.email = #{dh.email.inspect} （未定义返回 nil）"
        puts

        # --- 4. class_eval / module_eval — 在类上下文中执行代码 ---
        puts "--- class_eval（打开类修改） ---"
        klass = Class.new { attr_reader :value }
        klass.class_eval do
          define_method(:value_doubled) { value * 2 }
          def greet
            "Hello from class_eval!"
          end
        end
        instance = klass.new
        instance.instance_variable_set(:@value, 21)
        puts "  value_doubled: #{instance.value_doubled}"
        puts "  greet: #{instance.greet}"
        puts

        # --- 5. instance_eval — 在对象上执行代码 ---
        puts "--- instance_eval（单例方法） ---"
        obj = Object.new
        obj.define_singleton_method(:special_method) { @special }
        @special_value = "仅属于这个对象"
        obj.instance_variable_set(:@special, @special_value)
        puts "  obj.special_method: #{obj.special_method}"

        # 验证方法仅在此对象上可用
        other_obj = Object.new
        puts "  其他对象有 special_method? #{other_obj.respond_to?(:special_method)}"
        puts "  obj 单例类: #{class << obj; self; end}"
        puts

        # --- 6. send / public_send — 反射调用 ---
        puts "--- send（反射调用） ---"
        text = "hello world"
        puts "  text.send(:upcase) = #{text.send(:upcase)}"
        appended = text.send(:+, "!")
        puts "  text.send(:+, '!') = #{appended}"
        parts = text.send(:split, " ")
        joined = parts.join("-")
        puts "  text.send(:split, ' ').join('-') = #{joined}"

        str_klass = "test"
        str_klass.send(:reverse)
        puts "  send 也支持传符号给私有方法（谨慎使用）"
        # public_send 只调用 public 方法，更安全
        # 若调用私有方法会抛 NoMethodError
        puts

        # --- 7. const_get / const_set — 常量操作 ---
        puts "--- const_get（动态常量访问） ---"
        puts "  Object.const_get(:String).new(5.chr) = #{Object.const_get(:String).new("a")}"
        puts "  Math.const_get(:PI) = #{Math.const_get(:PI)}"
        puts "  File.const_get(:SEPARATOR) = #{File.const_get(:SEPARATOR).inspect}"
        puts

        # --- 8. 实际模式 — 链式 API ---
        puts "--- 链式 API 模式 ---"
        query = Class.new do
          def initialize
            @clauses = []
          end

          def select(table)
            @clauses << "SELECT * FROM #{table}"
            self  # 返回 self 以支持链式
          end

          def where(condition)
            @clauses << "WHERE #{condition}"
            self
          end

          def order(field, dir = "ASC")
            @clauses << "ORDER BY #{field} #{dir}"
            self
          end

          def to_sql
            @clauses.join(" ")
          end
        end

        sql = query.new.select("users").where("age > 18").order("name").to_sql
        puts "  #{sql}"
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "metaprogramming", "元编程", Hello::Advance::Metaprogramming)
