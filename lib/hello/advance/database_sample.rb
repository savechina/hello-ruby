# typed: true
# frozen_string_literal: true

require "json"
require "sequel"

module Hello
  module Advance
    # 数据库 ORM 模式 — 模拟 Sequel/ActiveRecord 的查询、模型、关联
    class DatabaseSample
      def self.run
        puts "=== 数据库 ORM 模式（内存模拟） ==="
        puts

        # --- 1. Schema 定义 & 迁移 ---
        puts "--- 1. Schema 定义 & 迁移 ---"
        db = MemoryDatabase.new

        db.create_table(:users) do |t|
          t.primary_key(:id)
          t.column(:name, :string, null: false)
          t.column(:email, :string, unique: true)
          t.column(:age, :integer)
          t.column(:active, :boolean, default: true)
          t.timestamp(:created_at)
        end

        db.create_table(:posts) do |t|
          t.primary_key(:id)
          t.column(:title, :string, null: false)
          t.column(:content, :text)
          t.foreign_key(:user_id, :users)
          t.column(:published, :boolean, default: false)
          t.timestamp(:created_at)
        end

        puts "  表结构:"
        db.tables.each do |table_name|
          schema = db.schema(table_name)
          columns = schema[:columns].map { |c| "#{c[:name]}:#{c[:type]}" }.join(", ")
          puts "    #{table_name}(#{columns})"
        end
        puts

        # --- 2. CRUD 操作 ---
        puts "--- 2. CRUD 操作 ---"
        user1 = db[:users].create(name: "Alice", email: "alice@example.com", age: 30)
        user2 = db[:users].create(name: "Bob", email: "bob@example.com", age: 25)
        user3 = db[:users].create(name: "Carol", email: "carol@example.com", age: 35, active: false)

        puts "  INSERT 3 条用户记录: #{db[:users].count} 条"
        puts "    #{user1.inspect}"
        puts "    #{user2.inspect}"
        puts "    #{user3.inspect}"

        post1 = db[:posts].create(title: "Ruby Tutorial", content: "Learn Ruby...", user_id: user1[:id], published: true)
        post2 = db[:posts].create(title: "Metacode", content: "Meta magic...", user_id: user1[:id], published: true)
        post3 = db[:posts].create(title: "Draft", content: "WIP", user_id: user2[:id], published: false)

        puts "  INSERT 3 篇文章: #{db[:posts].count} 条"
        puts

        # --- 3. 查询构建器 ---
        puts "--- 3. 链式查询构建器 ---"
        results = db[:users].where(active: true).order(:name).all
        puts "  活跃用户按名字排序:"
        results.each { |u| puts "    #{u[:name]} (age: #{u[:age]})" }

        results = db[:users].where("age > ?", 28).select(:name, :age).all
        puts "  age > 28 (仅 name, age):"
        results.each { |u| puts "    #{u[:name]}, #{u[:age]}" }

        count = db[:users].where(active: true).count
        puts "  活跃用户数: #{count}"
        puts

        # --- 4. 关联关系 ---
        puts "--- 4. 关联查询 ---"
        user_posts = db[:posts].where(user_id: user1[:id], published: true).order(:title).all
        puts "  Alice 的已发表文章:"
        user_posts.each { |p| puts "    #{p[:title]}" }

        posts_with_users = db[:posts].join(:users, id: :user_id).select(:posts__title, :users__name).all
        puts "  文章 + 作者 (join):"
        posts_with_users.each do |row|
          puts "    '#{row[:title]}' by #{row[:name]}"
        end
        puts

        # --- 5. 聚合 ---
        puts "--- 5. 聚合操作 ---"
        avg_age = db[:users].where(active: true).average(:age)
        puts "  活跃用户平均年龄: #{avg_age}"

        max_age = db[:users].maximum(:age)
        puts "  最大年龄: #{max_age}"

        posts_per_user = db[:posts].group(:user_id).count
        puts "  每用户文章数: #{posts_per_user.inspect}"
        puts

        # --- 6. 事务 ---
        puts "--- 6. 事务模拟 ---"
        begin
          db.transaction do
            db[:users].create(name: "Eve", email: "eve@example.com", age: 28)
            db[:users].create(name: "Frank", email: "frank@example.com", age: 32)
          end
          puts "  事务提交成功: #{db[:users].count} users"

          db.transaction do
            db[:users].create(name: "Grace", email: "grace@example.com", age: 29)
            raise "模拟回滚"
          end
        rescue StandardError
          puts "  事务回滚: 仍然 #{db[:users].count} users"
        end

        puts
        puts "=== ORM 演示完成 ==="
        puts

        # --- 7. Sequel/SQLite3 真实数据库 ---
        puts "--- 7. Sequel/SQLite3 真实数据库 ---"
        sequel_demo
      end

      def self.sequel_demo
        puts "  使用 Sequel ORM + SQLite3 内存数据库"
        puts

        # 创建内存数据库连接
        db = Sequel.sqlite

        # Schema 定义
        db.create_table :users do
          primary_key :id
          String :name, null: false
          String :email, unique: true
          Integer :age
          TrueClass :active, default: true
          DateTime :created_at
        end

        db.create_table :posts do
          primary_key :id
          String :title, null: false
          Text :content
          foreign_key :user_id, :users
          TrueClass :published, default: false
          DateTime :created_at
        end

        puts "  表结构:"
        db.tables.each do |table_name|
          columns = db.schema(table_name).map { |c| "#{c.first}:#{c.last[:type]}" }.join(", ")
          puts "    #{table_name}(#{columns})"
        end
        puts

        # CRUD 操作
        puts "  --- CRUD 操作 ---"
        users = db[:users]
        user1 = users.insert(name: "Alice", email: "alice@example.com", age: 30)
        user2 = users.insert(name: "Bob", email: "bob@example.com", age: 25)
        user3 = users.insert(name: "Carol", email: "carol@example.com", age: 35, active: false)

        puts "  INSERT 3 条用户记录: #{users.count} 条"
        puts "    #{users.where(id: user1).first}"
        puts "    #{users.where(id: user2).first}"
        puts "    #{users.where(id: user3).first}"

        posts = db[:posts]
        posts.insert(title: "Ruby Tutorial", content: "Learn Ruby...", user_id: user1, published: true)
        posts.insert(title: "Metacode", content: "Meta magic...", user_id: user1, published: true)
        posts.insert(title: "Draft", content: "WIP", user_id: user2, published: false)

        puts "  INSERT 3 篇文章: #{posts.count} 条"
        puts

        # 链式查询
        puts "  --- 链式查询 ---"
        results = users.where(active: true).order(:name).all
        puts "  活跃用户按名字排序:"
        results.each { |u| puts "    #{u[:name]} (age: #{u[:age]})" }

        results = users.where { age > 28 }.select(:name, :age).all
        puts "  age > 28 (仅 name, age):"
        results.each { |u| puts "    #{u[:name]}, #{u[:age]}" }

        count = users.where(active: true).count
        puts "  活跃用户数: #{count}"
        puts

        # 关联查询
        puts "  --- 关联查询 ---"
        user_posts = posts.where(user_id: user1, published: true).order(:title).all
        puts "  Alice 的已发表文章:"
        user_posts.each { |p| puts "    #{p[:title]}" }

        posts_with_users = posts.join(:users, id: :user_id).select(Sequel[:posts][:title], Sequel[:users][:name]).all
        puts "  文章 + 作者 (join):"
        posts_with_users.each do |row|
          puts "    '#{row[:title]}' by #{row[:name]}"
        end
        puts

        # 聚合
        puts "  --- 聚合操作 ---"
        avg_age = users.where(active: true).avg(:age)
        puts "  活跃用户平均年龄: #{avg_age.round(2)}"

        max_age = users.max(:age)
        puts "  最大年龄: #{max_age}"

        posts_per_user = posts.group_and_count(:user_id).all
        puts "  每用户文章数: #{posts_per_user.inspect}"
        puts

        # 事务
        puts "  --- 事务 ---"
        db.transaction do
          users.insert(name: "Eve", email: "eve@example.com", age: 28)
          users.insert(name: "Frank", email: "frank@example.com", age: 32)
        end
        puts "  事务提交成功: #{users.count} users"

        begin
          db.transaction do
            users.insert(name: "Grace", email: "grace@example.com", age: 29)
            raise Sequel::Rollback
          end
        rescue Sequel::Rollback
          puts "  事务回滚: 仍然 #{users.count} users"
        end

        puts
        puts "=== Sequel 真实数据库演示完成 ==="
        db.disconnect
      end
    end

    # --- 内存数据库引擎（教学示例）---
    class MemoryDatabase
      def initialize
        @tables = {}
        @mutex = Mutex.new
      end

      def create_table(name, &block)
        schema_builder = SchemaBuilder.new
        block.call(schema_builder)
        @tables[name] = {
          schema: schema_builder.schema,
          data: [],
          next_id: 1
        }
      end

      def tables
        @tables.keys
      end

      def schema(name)
        @tables.dig(name, :schema)
      end

      def [](name)
        TableProxy.new(self, name)
      end

      def transaction(&block)
        @mutex.synchronize(&block)
      end
    end

    class SchemaBuilder
      attr_reader :schema

      def initialize
        @schema = { columns: [] }
      end

      def primary_key(name)
        @schema[:columns] << { name: name, type: :integer, primary_key: true }
      end

      def column(name, type, **options)
        @schema[:columns] << { name: name, type: type }.merge(options)
      end

      def foreign_key(name, target)
        @schema[:columns] << { name: name, type: :integer, foreign_key: target }
      end

      def timestamp(name)
        @schema[:columns] << { name: name, type: :timestamp, default: :now }
      end
    end

    class TableProxy
      def initialize(db, table_name)
        @db = db
        @table_name = table_name
        @conditions = []
        @ordering = nil
        @selection = nil
        @grouping = nil
        @_join_tables = []
      end

      def where(condition = nil, *args)
        return self if condition.nil?
        if condition.is_a?(Hash)
          condition.each do |key, value|
            @conditions << { column: key, operator: :eq, value: value }
          end
        elsif condition.is_a?(String)
          @conditions << { raw: condition, args: args }
        end
        self
      end

      def select(*columns)
        @selection = columns.length > 1 ? columns : columns.first
        self
      end

      def order(column)
        @ordering = column
        self
      end

      def join(table_name, **on_condition)
        @_join_tables << { table: table_name, on: on_condition }
        self
      end

      def group(column)
        @grouping = column
        self
      end

      def all
        schema = @db.schema(@table_name)
        rows = @db.instance_variable_get(:@tables)[@table_name][:data]

        filtered = rows.filter do |row|
          @conditions.all? { |c| matches_condition?(row, c) }
        end

        filtered = filtered.sort_by { |r| r[@ordering] } if @ordering
        filtered = apply_joins(filtered) unless @_join_tables.empty?

        if @grouping
          return filtered.group_by { |r| r[@grouping] }
        end

        if @selection
          filtered.map do |row|
            if @selection.is_a?(Symbol)
              {@selection => row[@selection] }
            elsif @selection.is_a?(Array)
              @selection.to_h do |col|
                simple_key = col.to_s.include?("__") ? col.to_s.split("__", 2).last.to_sym : col
                [simple_key, row[col]]
              end
            else
              row
            end
          end
        else
          filtered.map(&:dup)
        end
      end

      def create(attributes)
        table = @db.instance_variable_get(:@tables)[@table_name]
        id = table[:next_id]
        table[:next_id] += 1

        schema = @db.schema(@table_name)
        defaults = schema[:columns].filter_map { |c| [c[:name], c[:default]] if c[:default] && c[:default] != :now }.to_h

        record = { id: id }.merge(defaults.compact).merge(attributes)
        record[:created_at] = Time.now.to_s
        table[:data] << record
        record
      end

      def find(id)
        rows = @db.instance_variable_get(:@tables)[@table_name][:data]
        rows.find { |r| r[:id] == id }
      end

      def count
        result = all
        result.is_a?(Hash) ? result.transform_values { |v| v.is_a?(Array) ? v.length : v } : result.length
      end

      def average(column)
        values = all.map { |r| r[column] }.compact
        return 0 if values.empty?
        values.sum.fdiv(values.length).round(2)
      end

      def maximum(column)
        all.map { |r| r[column] }.compact.max
      end

      private

      def matches_condition?(row, condition)
        if condition[:raw]
          # simple numeric comparison: "age > ?"
          raw = condition[:raw]
          match = raw.match(/(\w+)\s*([><=!]+)\s*\?/)
          return false unless match
          col = match[1].to_sym
          op = match[2]
          val = condition[:args].first
          (row[col] || 0).send(op.to_sym, val)
        else
          (row[condition[:column]] || :unset) == condition[:value]
        end
      end

      def apply_joins(rows)
        rows.map do |row|
          new_keys = {}
          row.each_key do |k|
            next if k.to_s.include?("__")
            new_keys["#{@table_name}__#{k}".to_sym] = row[k]
          end
          row.merge!(new_keys)
          @_join_tables.each do |join_spec|
            join_rows = @db[join_spec[:table]].all
            fk_col = join_spec[:on].values.first
            pk_col = join_spec[:on].keys.first
            matching = join_rows.find { |jr| jr[pk_col] == row[fk_col] }
            matching&.each do |k, v|
              row["#{join_spec[:table]}__#{k}".to_sym] = v
            end
          end
          row
        end
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "database", "数据库与 ORM", Hello::Advance::DatabaseSample)
