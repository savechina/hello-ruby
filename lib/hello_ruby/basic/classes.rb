# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 类
    # 涵盖 initialize、属性声明、类方法/实例方法、self、类变量、继承
    module Classes
      def self.run
        puts "=== 类 ==="
        puts

        # --- 类定义 ---
        klass_define = <<~RUBY
          class Person
            attr_reader :name, :age
            attr_accessor :email

            def initialize(name, age)
              @name = name
              @age = age
            end
          end
        RUBY
        puts "类定义示例:\n#{klass_define}"

        # 动态定义并体验
        klass = Class.new do
          attr_reader :name, :age
          attr_accessor :email

          define_method(:initialize) do |name, age|
            @name = name
            @age = age
          end

          define_method(:greet) do
            "我叫 #{@name}，今年 #{@age} 岁。"
          end
        end

        person = klass.new("Alice", 30)
        person.email = "alice@example.com"
        puts "实例: #{person.greet} 邮箱: #{person.email}"
        puts

        # --- attr_* 系列 — 属性声明 ---
        # attr_reader  = 只读 (def name; @name; end)
        # attr_writer  = 只写 (def name=(v); @name = v; end)
        # attr_accessor = 读写（两者都有）
        puts "attr_reader: #{person.name}"
        person.email = "new@email.com"
        puts "attr_writer 后: #{person.email}"
        puts

        # --- 类方法 vs 实例方法 ---
        counter_class = Class.new do
          @@count = 0

          def self.increment
            @@count += 1
          end

          def self.count
            @@count
          end

          def initialize
            self.class.increment
          end
        end

        counter_class.new
        counter_class.new
        counter_class.new
        puts "类变量 @@count: #{counter_class.count}"
        puts "类方法调用: counter_class.increment → #{counter_class.increment}"
        puts

        # --- self 关键字 ---
        puts "在类方法中 self = #{counter_class}"
        # 实例中的 self
        obj_instance = klass.new("Bob", 25)
        # obj_instance.singleton_class 展示了单例类的存在
        obj_class = class << obj_instance; self; end
        puts "obj 的单例类: #{obj_class}"
        puts

        # --- 继承（单继承） ---
        dynamic_animal = Class.new do
          define_method(:speak) { "..." }
        end

        dynamic_dog = Class.new(dynamic_animal) do
          define_method(:speak) { "汪！" }
        end

        dynamic_cat = Class.new(dynamic_animal) do
          define_method(:speak) { "喵！" }
        end

        puts "继承:"
        puts "  dynamic_dog#speak: #{dynamic_dog.new.speak}"
        puts "  dynamic_cat#speak: #{dynamic_cat.new.speak}"
        puts "  dynamic_animal#speak: #{dynamic_animal.new.speak}"
        puts "  dynamic_dog < dynamic_animal? #{dynamic_dog < dynamic_animal}"
        puts "  cat.is_a?(animal)? #{dynamic_cat.new.is_a?(dynamic_animal)}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "classes", "类", Hello::Basic::Classes)
