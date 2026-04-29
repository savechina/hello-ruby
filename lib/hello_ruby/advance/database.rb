# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # 数据库与 ORM
    # Sequel ORM 模式：连接、模型、查询、关联、连接池
    module Database
      def self.run
        puts "=== 数据库与 ORM（Sequel 模式） ==="
        puts

        # Sequel 是 Ruby 生态中最灵活的 ORM
        # 以下演示其核心模式（使用内存 SQLite）

        # --- 1. 数据库连接 ---
        puts "--- 数据库连接 ---"
        puts "  # 连接 SQLite 内存数据库"
        puts '  DB = Sequel.connect("sqlite::memory:")'
        # 模拟连接（实际代码需要 Sequel gem）
        puts "  → 支持 SQLite、PostgreSQL、MySQL、MSSQL..."
        puts

        # --- 2. 迁移（Migration） ---
        puts "--- 迁移 ---"
        puts "  # create_table 定义了表结构"
        puts "  DB.create_table :users do"
        puts "    primary_key :id"
        puts "    String :name, null: false"
        puts "    String :email, unique: true"
        puts "    Integer :age"
        puts "    DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP"
        puts "  end"
        puts
        puts "  DB.create_table :posts do"
        puts "    primary_key :id"
        puts "    String :title, null: false"
        puts "    Text :content"
        puts "    foreign_key :user_id, :users, null: false"
        puts "    DateTime :published_at"
        puts "  end"
        puts

        # --- 3. 模型（Model） ---
        puts "--- 模型定义 ---"
        puts "  # Sequel::Model 提供了 ActiveRecord 风格的 API"
        puts "  class User < Sequel::Model"
        puts "    one_to_many :posts"
        puts "    validates_presence :name"
        puts "    validates_format /\A[\w.]+@[\w.]+\z/, :email"
        puts "  end"
        puts
        puts "  class Post < Sequel::Model"
        puts "    many_to_one :user"
        puts "    validates_presence :title"
        puts "  end"
        puts

        # --- 4. CRUD 操作 ---
        puts "--- CRUD 操作 ---"
        puts "  # 创建"
        puts "  user = User.create(name: 'Alice', email: 'alice@example.com', age: 30)"
        puts "  # 读取"
        puts "  user = User[1]              # 通过主键查询（等价于 User.find(1)）"
        puts "  users = User.where(age: 25..35).order(:name)  # 条件查询 + 排序"
        puts "  # 更新"
        puts "  user.update(age: 31)"
        puts "  # 删除"
        puts "  user.destroy"
        puts

        # --- 5. 链式查询接口 ---
        puts "--- 链式查询（Query Interface） ---"
        queries = [
          'User.where(active: true).limit(10)',
          'User.where { age > 18 }.order(:name).select(:name, :email)',
          'User.join(:posts).group(:user_id).having { count(Sequel[:id]) > 5 }',
          'User.select { name.lowercase.like "alice" }',
          "User.eager(:posts).where(id: 1)"       # 预加载关联，避免 N+1
        ]
        queries.each_with_index do |q, i|
          puts "  #{i + 1}. #{q}"
        end
        puts

        # --- 6. 关联关系 ---
        puts "--- 关联 ---"
        associations = [
          "many_to_one :user        # belongs_to (外键在本表)",
          "one_to_many :posts       # has_many",
          "one_to_one :profile      # has_one",
          "many_to_many :tags       # has_many through",
          "eager(:posts, :comments) # 预加载所有关联"
        ]
        associations.each { |a| puts "  #{a}" }
        puts

        # --- 7. 连接池 ---
        puts "--- 连接池 ---"
        puts "  # Sequel 内置连接池（线程安全）"
        puts "  DB = Sequel.connect("
        puts "    adapter: 'postgres',"
        puts "    host: 'localhost',"
        puts "    database: 'myapp',"
        puts "    max_connections: 20,"
        puts "    pool_timeout: 5"
        puts "  )"
        puts "  → 自动管理连接生命周期，线程安全复用"
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "database", "数据库与 ORM", Hello::Advance::Database)
