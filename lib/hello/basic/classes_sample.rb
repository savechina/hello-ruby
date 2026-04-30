# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 类定义 — 实际运行的代码示例
    module ClassesSample
      # 顶层类定义（不在 def self.run 内定义类）
      class Person
        attr_reader :name, :age
        attr_accessor :email

        def initialize(name, age)
          @name = name
          @age = age
        end

        def greet
          "我叫 #{@name}，今年 #{@age} 岁。"
        end
      end

      class Employee < Person
        attr_reader :department

        def initialize(name, age, department)
          super(name, age)
          @department = department
        end

        def greet
          "#{super} 在 #{department} 部门工作。"
        end
      end

      class Counter
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

      def self.run
        puts "=== 类定义 ==="
        puts

        # 1. 实例化与 attr_*
        person = Person.new("Alice", 30)
        person.email = "alice@example.com"
        puts "1. attr_* 访问器:"
        puts "   greet: #{person.greet}"
        puts "   name (attr_reader): #{person.name}"
        puts "   email (attr_accessor): #{person.email}"
        puts

        # 2. 单例方法
        klass = Class.new do
          define_method(:greet) { "Hello" }
        end
        obj1 = klass.new
        obj2 = klass.new
        puts "2. 实例对象检查:"
        puts "   obj1.greet: #{obj1.greet}"
        puts "   obj1.class: #{obj1.class}"
        puts "   obj1.is_a?(Object): #{obj1.is_a?(Object)}"
        puts

        # 3. 类方法 vs 实例方法
        Counter.new
        Counter.new
        Counter.new
        Counter.increment
        puts "3. 类方法:"
        puts "   Counter.count => #{Counter.count}"
        puts

        # 4. 继承
        emp = Employee.new("Bob", 25, "Engineering")
        puts "4. 继承:"
        puts "   emp.greet: #{emp.greet}"
        puts "   emp.is_a?(Person): #{emp.is_a?(Person)}"
        puts "   Employee < Person: #{Employee < Person}"
        puts "   emp.name (from parent): #{emp.name}"
        puts

        # 5. 动态类创建
        dynamic_class = Class.new do
          define_method(:square) { |n| n**2 }
          define_method(:double) { |n| n * 2 }
        end
        dyn = dynamic_class.new
        puts "5. 动态类:"
        puts "   square(5): #{dyn.square(5)}"
        puts "   double(5): #{dyn.double(5)}"
        puts

        # 6. self 在不同上下文
        puts "6. self 上下文:"
        puts "   在类方法中 self = Counter (#{Counter})"
        inst_self = class << person; self; end
        puts "   单例类: #{inst_self}"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "classes", "类与对象", Hello::Basic::ClassesSample)
