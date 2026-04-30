# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    # 符号 — 实际运行的代码示例
    module SymbolsSample
      def self.run
        puts "=== 符号（Symbol）==="
        puts

        # 1. 符号的全局唯一性
        id1 = :foo.object_id
        id2 = :foo.object_id
        puts "1. Symbol global uniqueness:"
        puts "   :foo.object_id first:  #{id1}"
        puts "   :foo.object_id second: #{id2}"
        puts "   Same? #{id1 == id2}"
        puts

        # 2. 字符串 vs 符号
        s1 = "hello"
        s2 = "hello"
        puts "2. String vs Symbol:"
        puts "   \"hello\".object_id (s1): #{s1.object_id}"
        puts "   \"hello\".object_id (s2): #{s2.object_id}"
        puts "   same string object_id: #{s1.object_id == s2.object_id}"
        puts "   :hello.object_id always same: #{:hello.object_id == :hello.object_id}"
        puts

        # 3. 创建符号的方式
        method_name = :length
        dynamic = "user".to_sym
        key = "access"
        dynamic_sym = :"#{key}_token"
        puts "3. Symbol creation:"
        puts "   :length => #{method_name} (class: #{method_name.class})"
        puts "   'user'.to_sym => #{dynamic} (class: #{dynamic.class})"
        puts "   :\"#{key}_token\" => #{dynamic_sym} (class: #{dynamic_sym.class})"
        puts "   %i[foo bar]: #{%i[foo bar].inspect}"
        puts

        # 4. == vs eql? vs equal?
        str = "foo"
        sym = :foo
        puts "4. Equality:"
        puts "   :foo == :foo: #{:foo == :foo}"
        puts "   'foo' == 'foo'.dup: #{str == str.dup}"
        puts "   :foo == 'foo' (cross-type): #{sym == str}"
        puts "   :foo.eql?(:foo): #{:foo.eql?(:foo)}"
        puts "   :foo.eql?('foo'): #{:foo.eql?(str)}"
        puts "   :foo.equal?(:foo): #{:foo.equal?(:foo)}"
        puts

        # 5. 符号键 Hash
        user = { name: "Alice", age: 30, role: "admin" }
        puts "5. Symbol-keyed Hash:"
        puts "   user: #{user.inspect}"
        puts "   user[:name]: #{user[:name]}"
        puts "   user.fetch(:age): #{user.fetch(:age)}"
        puts "   user.fetch(:email, 'N/A'): #{user.fetch(:email, "N/A")}"
        puts "   user.key?(:role): #{user.key?(:role)}"
        puts "   user.key?(:missing): #{user.key?(:missing)}"
        puts

        # 6. 符号键 vs 字符串键
        mixed = { name: "Alice", "name" => "Bob" }
        puts "6. Symbol vs String keys (not interchangeable):"
        puts "   mixed[:name]: #{mixed[:name]}"
        puts "   mixed['name']: #{mixed['name']}"
        puts

        # 7. 旧式 vs 新式 Hash 语法
        old = { name: "Alice", age: 30 }
        new_syntax = { name: "Alice", age: 30 }
        puts "7. Hash syntax:"
        puts "   rocket: #{old.inspect}"
        puts "   new: #{new_syntax.inspect}"
        puts "   Equal? #{old == new_syntax}"
        puts

        # 8. String#freeze vs Symbol
        frozen_str = "immutable".freeze
        sym_imm = :immutable
        puts "8. String#freeze vs Symbol:"
        puts "   'immutable'.freeze.object_id: #{frozen_str.object_id}"
        puts "   :immutable.object_id: #{sym_imm.object_id}"
        puts "   'immutable'.freeze.frozen?: #{frozen_str.frozen?}"
        puts "   :immutable.frozen?: #{sym_imm.frozen?}"
        puts

        # 9. Symbol 增长
        count_before = Symbol.all_symbols.size
        100.times { |i| :"dynamic_sample_#{i}" }
        count_after = Symbol.all_symbols.size
        puts "9. Symbol table growth:"
        puts "   Before: #{count_before} symbols"
        puts "   After creating 100: #{count_after} symbols"
        puts "   Grew by: #{count_after - count_before}"
        puts

        # 10. 使用建议
        puts "10. Symbol vs String:"
        puts "   Hash keys: :user_status (Symbol)"
        puts "   Method refs: &:each (Symbol)"
        puts "   Enum values: :active (Symbol)"
        puts "   External data: params['name'] (String)"
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "symbols", "符号（Symbol）", Hello::Basic::SymbolsSample)
