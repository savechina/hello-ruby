# 数据库与 ORM

没有哪个现代 Web 应用不操作数据库。Ruby 生态中有两个主要的 ORM 框架：ActiveRecord（Rails 的默认选择）和 Sequel（更灵活的替代方案）。这两个都基于相同的核心模式：连接管理、模型定义、迁移系统、链式查询接口。学习任何一个，另一个都能快速上手。

这一章以 Sequel 为例讲解 Ruby ORM 的核心概念。即使你主要使用 ActiveRecord，理解这些底层模式也能帮助你写出更好的数据库代码。

运行 `hello advance database` 可以查看完整演示代码。

## 运行示例

本章节的代码可以通过 CLI 运行完整演示：

```bash
hello advance database  # 查看 Sequel ORM 完整演示
```

演示包含两部分：
1. **内存模拟**（Section 1-6）：MemoryDatabase 展示 ORM 内部实现模式，帮助理解 Ruby 如何封装数据库操作
2. **真实 Sequel**（Section 7）：Sequel.sqlite + Schema + CRUD + 查询链 + 事务，生产级用法参考

建议先运行演示代码，再看文档理解原理。

## 数据库连接

ORM 的第一步是建立与数据库的连接。Sequel 支持 SQLite、PostgreSQL、MySQL、MSSQL 等多种数据库，连接接口一致：

```ruby
require "sequel"

# SQLite 内存数据库（开发测试用）
DB = Sequel.connect("sqlite::memory:")

# PostgreSQL 生产连接
DB = Sequel.connect(
  adapter: "postgres",
  host: "localhost",
  database: "myapp",
  user: "app_user",
  password: "secret",
  max_connections: 20,
  pool_timeout: 5
)

# SQLite 文件数据库
DB = Sequel.connect("sqlite:///myapp.db")
```

Sequel 的 `connect` 方法返回一个 `Database` 对象，所有后续的表和查询操作都通过这个对象进行。它内置了连接池管理，自动处理多线程序列化和空闲连接回收。

## 迁移：版本化的数据库结构

在真实项目中，数据库结构不是一次性定义完的。你需要随着业务需求的增长，逐步调整表结构。迁移（Migration）就是版本管理系统，每个迁移文件代表一次结构变更：

```ruby
# 创建 users 表
DB.create_table :users do
  primary_key :id
  String :name, null: false
  String :email, unique: true
  Integer :age
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
end

# 创建 posts 表，关联 users
DB.create_table :posts do
  primary_key :id
  String :title, null: false
  Text :content
  foreign_key :user_id, :users, null: false
  DateTime :published_at
  index :user_id
  index :published_at
end
```

注意这里定义的约束：`null: false` 保证字段不为空，`unique: true` 防止重复，`foreign_key` 建立表间关联，`index` 加速查询。这些都是数据库层面的安全保障，即使应用层有 bug 也不会破坏数据完整性。

在 Sequel 项目中，迁移通常用独立的迁移文件管理，类似 Rails 的 `db/migrate/` 目录。`sequel -m migrations/` 命令可以执行所有待运行的迁移。

## 模型定义

模型是 ORM 的核心。每个模型类对应一个数据库表，实例对应一行记录：

```ruby
class User < Sequel::Model
  # 关联声明
  one_to_many :posts

  # 验证规则
  validates_presence :name
  validates_format /\A[\w.]+@[\w.]+\z/, :email
  validates_integer :age
  validates_min_length 3, :name

  # 自定义回调
  before_create { self.created_at = Time.now }
  after_save { |obj| puts "用户 #{name} 已保存" }

  # 自定义范围
  def self.active
    where { created_at > Time.now - 30 * 86400 }
  end

  def self.by_age_range(min, max)
    where { age >= min && age <= max }
  end
end

class Post < Sequel::Model
  many_to_one :user
  validates_presence :title

  def self.recent(limit = 10)
    where { published_at > Time.now - 7 * 86400 }
      .order(Sequel.desc(:published_at))
      .limit(limit)
  end
end
```

Sequel::Model 提供了完整的 ORM 能力：`has_many` / `belongs_to` 等价物（`one_to_many` / `many_to_one`）、验证、回调、作用域、实例方法和类方法。

模型继承关系也是支持的：

```ruby
class Admin < User
  one_to_many :moderated_posts, class: :Post
end
```

## CRUD 操作

模型的实例方法提供了完整的增删改查接口：

```ruby
# 创建
user = User.create(name: "Alice", email: "alice@example.com", age: 30)
puts user.id  # 自动生成的主键

# 读取：多种方式
user = User[1]                       # 通过主键查找
user = User.first(name: "Alice")      # 条件查找第一条
users = User.where(age: 25..35)        # 条件查找多条
users = User.where { age > 25 }        # 块语法（更灵活）

# 更新
user.update(age: 31)                   # 批量更新
user.update_columns(name: "Alice2")    # 跳过验证和回调

# 删除
user.destroy                           # 执行回调后删除
user.delete                            # 直接删除，跳过回调
```

`create` 内部调用 `new + save`，`update` 内部调用赋值 + `save`。如果你需要更细粒度的控制，可以手动拆分这些步骤：

```ruby
user = User.new(name: "Bob", email: "bob@example.com")
user.age = 25
user.save  # 执行验证和回调
```

## 链式查询接口

ORM 的查询接口是可链式的。每次查询方法返回一个新的 Relation 对象，不修改原始数据，只在最终取值时执行 SQL：

```ruby
# 基础查询
User.where(active: true).limit(10)

# 块语法查询（支持任意 Ruby 表达式）
User.where { age > 18 }.order(:name).select(:name, :email)

# 关联查询
User.join(:posts).group(:user_id).having { count(Sequel[:id]) > 5 }

# 模式匹配查询
User.select { name.lowercase.like "alice" }

# 预加载关联（避免 N+1 问题）
User.eager(:posts).where(id: 1)
```

注意最后一个例子中的 `eager`。如果加载 100 个用户然后访问每个用户的 `posts`，不做预加载会产生 101 条 SQL 查询（1 条查用户 + 100 条查帖子）。`eager` 会让 ORM 用 `IN` 查询批量加载所有关联，减少到 2 条 SQL。这就是经典的 N+1 查询问题的解决方案。

关联查询还支持更复杂的链式：

```ruby
# 深度预加载
Post.eager(:user, comments: :author).where(published: true)

# 自定义关联过滤
User.eager_loaded_posts.where_posts(active: true)
```

## 关联关系

Sequel 支持四种关联类型，覆盖了几乎所有数据库关系场景：

```ruby
class User < Sequel::Model
  many_to_one :profile   # has_one：一对一，外键在 profile 表
  one_to_many :posts     # has_many：一对多
  one_to_one :setting    # has_one：一对一
  many_to_many :tags     # has_many through：多对多
end

class Post < Sequel::Model
  many_to_one :user      # belongs_to：属于某个用户
  one_to_many :comments  # 一对多评论
end
```

关联方法自动生成一系列便捷方法：

```ruby
user = User[1]

# 读取关联
user.posts              # 返回 Post 对象数组
user.posts_dataset      # 返回 Relation，可以继续链式查询

# 创建关联
user.add_post(title: "Hello", content: "...")
user.create_post(title: "Hello")

# 删除关联
user.remove_post(some_post)
user.remove_all_posts
```

预加载关联使用 `eager` 或 `eager_load`。两者的区别是 `eager` 用 `IN` 子查询分两次取数，`eager_load` 用 `JOIN` 一次取数。数据量小时 `eager_load` 更快，关联多时 `eager` 更省内存。

## 连接池

ORM 的数据库连接是稀缺资源。Sequel 内置连接池自动管理连接的生命周期：

```ruby
DB = Sequel.connect(
  adapter: "postgres",
  host: "localhost",
  database: "myapp",
  max_connections: 20,     # 池中最大连接数
  pool_timeout: 5,         # 获取连接超时秒数
  idle_timeout: 300,       # 空闲连接超时秒数
  after_connect: proc { |conn|
    conn.run "SET statement_timeout = '5s'"
  }
)
```

连接池中每个连接在同一时刻只能被一个线程使用。当线程完成数据库操作后，连接自动归还池中供其他线程复用。如果池中所有连接都被占用，新请求等待 `pool_timeout` 秒，抛出超时异常。

## 本章要点

- **Sequel.connect** 建立数据库连接，内置连接池管理
- **create_table** 定义表结构，支持主键、外键、索引、约束
- **Model 类** 继承 `Sequel::Model`，提供 CRUD、验证、回调、作用域
- **链式查询** 返回 `Relation`，按需执行 SQL，可组合
- **关联声明** `one_to_many` / `many_to_one` / `one_to_one` / `many_to_many`
- **eager** 预加载关联，防止 N+1 查询问题
- 连接池自动管理连接复用，`max_connections` 和 `pool_timeout` 控制资源
- 运行 `hello advance database` 查看完整示例
