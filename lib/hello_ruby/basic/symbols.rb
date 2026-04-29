# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 符号（Symbol）
    # 涵盖符号内部原理、字符串 vs 符号、哈希键、冻结常量
    module Symbols
      def self.run
        puts "=== 符号（Symbol）==="
        puts

        # 1. 什么是 Symbol？"内部化"的字符串
        # Ruby 会为每个唯一的符号名分配一个全局唯一的 ID
        # 同一个符号名无论在哪里创建，object_id 永远相同
        puts "--- Symbol 的基本特性 ---"
        puts ":foo.object_id  第1次: #{:foo.object_id}"
        puts ":foo.object_id  第2次: #{:foo.object_id}"
        puts "同一个符号的 object_id 永远相同: #{:foo.object_id == :foo.object_id}"
        puts

        # 字符串则不同 — 每次创建都是新对象
        puts "--- String 的对比 ---"
        s1 = "hello"
        s2 = "hello"
        # "hello".object_id 第1次: #{s1.object_id}
        # "hello".object_id 第2次: #{s2.object_id}
        # 同样内容的字符串 object_id 不同: #{s1.object_id == s2.object_id}
        puts "\"hello\".object_id (s1): #{s1.object_id}"
        puts "\"hello\".object_id (s2): #{s2.object_id}"
        puts "同样内容的字符串 object_id 不同: #{s1.object_id == s2.object_id}"
        puts

        # 2. 创建符号的方式
        puts "--- 创建符号的方式 ---"
        # 方式1: 冒号前缀（最常见）
        method_name = :length
        puts "冒号前缀 (:length): #{method_name}"

        # 方式2: 字符串转符号
        dynamic = "user".to_sym
        puts "\"user\".to_sym: #{dynamic}"

        # 方式3: 动态创建（允许非标准命名）
        key = "access"
        dynamic_symbol = :"#{key}_token"
        puts "动态符号 (:\"#{key}_token\"): #{dynamic_symbol}"

        # 方式4: 数组批量转
        %i[foo bar baz].each do |sym|
          # 每个 %i[] 元素都是 Symbol 而非 String 类型
          puts "  %i[] 创建: #{sym.inspect} (#{sym.class})"
        end
        puts

        # 3. == vs eql? vs equal?
        # == 比较内容（类型可以不同）
        # eql? 比较内容 + 类型（Hash 键比较时使用）
        # equal? 比较对象身份（同一内存地址）
        puts "--- 相等性比较 ---"
        str = "foo"
        sym = :foo
        puts ":foo == :foo  (符号): #{:foo == :foo}"
        puts "\"foo\" == \"foo\" (字符串): #{str == str.dup}"
        puts ":foo == \"foo\" (跨类型 ==): #{sym == str}"
        puts ":foo.eql?(:foo): #{:foo.eql?(:foo)}"
        puts ":foo.eql?(\"foo\"): #{:foo.eql?(str)}"
        puts ":foo.equal?(:foo): #{:foo.equal?(:foo)}"
        puts "  equal? 比较内存地址（同一对象才为 true）"
        puts

        # 4. Symbols 作为 Hash 键 — Ruby 惯例
        puts "--- 符号作为 Hash 键 ---"
        user = {name: "Alice", age: 30, role: "admin"}
        puts "使用符号键创建 Hash: #{user}"

        # 取值：[] 和 fetch
        puts "user[:name]: #{user[:name]}"
        puts "user.fetch(:age): #{user.fetch(:age)}"

        # fetch 带默认值（比 [] 更安全）
        puts "user.fetch(:email, \"N/A\"): #{user.fetch(:email, "N/A")}"
        # user.fetch(:email) 会抛 KeyError — 不存在时直接报错
        # puts "user.fetch(:email): #{user.fetch(:email)}"

        # 检查键是否存在
        puts "user.key?(:role): #{user.key?(:role)}"
        puts "user.key?(:missing): #{user.key?(:missing)}"

        # 符号键 vs 字符串键（它们不互通！）
        mixed = {:name => "Alice", "name" => "Bob"}
        puts "符号键取值 [:name]: #{mixed[:name]}"
        puts "字符串键取值 [\"name\"]: #{mixed["name"]}"
        puts "  注意：:name 和 \"name\" 在 Hash 中是两个不同的键！"
        puts

        # 5. 旧式 vs 新式 Hash 语法
        puts "--- Hash 语法演变 ---"
        old_style = {:name => "Alice", :age => 30} # 火箭语法（rocket syntax）
        new_style = {name: "Alice", age: 30}       # Ruby 1.9+ JSON-like 语法
        puts "旧式（火箭语法）: #{old_style}"
        puts "新式（JSON 风格）: #{new_style}"
        puts "两者等价: #{old_style == new_style}"
        puts

        # 6. freeze 与 Symbol 的区别
        # Symbol 本身不可变（immutable）且全局唯一
        # String#freeze 也能让字符串不可变，但不会共享对象
        puts "--- freeze vs Symbol ---"
        frozen_str = "immutable".freeze
        symbol = :immutable
        puts "\"immutable\".freeze.object_id: #{frozen_str.object_id}"
        puts ":immutable.object_id: #{symbol.object_id}"
        puts "frozen_str.frozen?: #{frozen_str.frozen?}"
        puts ":immutable.frozen?: #{symbol.frozen?}"
        puts "冻结字符串不能修改内容，但与 Symbol 不是同一个对象"
        puts "Symbol 天然冻结且全局唯一，不需要 .freeze"
        puts

        # 7. Symbol.all_symbols 与内存影响
        # 注意：Symbol 不会被垃圾回收（在 Ruby 3.2 之前）
        # 大量动态创建 Symbol 会导致内存泄漏
        puts "--- Symbol.all_symbols 与内存 ---"
        count_before = Symbol.all_symbols.size
        puts "当前符号总数: #{count_before}"

        # 演示动态创建符号（实际项目中应谨慎使用！）
        100.times do |i|
          :"dynamic_#{i}"
        end
        count_after = Symbol.all_symbols.size
        puts "增加 100 个动态符号后总数: #{count_after}"
        puts "增长: #{count_after - count_before}"

        # Ruby 3.2+ 增加了符号垃圾回收功能
        # 但最佳实践仍然是：只在已知键名时使用 Symbol
        # 运行时接收的外部输入（如用户参数、API 数据）应使用 String
        puts

        # 8. 何时使用 Symbol vs String？
        puts "--- 使用建议 ---"
        puts "使用 Symbol: 哈希键、方法名、固定标识符"
        puts "  :user_status     ✅ 哈希键（惯例）"
        puts "  :each            ✅ 方法名引用（&:method）"
        puts "  :red             ✅ 枚举值"
        puts
        puts "使用 String: 外部输入、用户数据、动态内容"
        puts "  params[:name]    ✅ 获取值（符号键）"
        puts "  params[\"name\"]  ✅ 获取值（字符串键）"
        puts "  params.fetch(\"name\") ✅ Web 框架中常见"
        puts
        puts "经验法则：内部标识符用 Symbol，外部数据用 String"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "symbols", "符号（Symbol）", Hello::Basic::Symbols)
