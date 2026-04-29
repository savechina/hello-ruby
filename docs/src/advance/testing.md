# 测试模式 RSpec

测试是确保代码质量的核心手段。Ruby 生态中最主流的测试框架是 RSpec。它的语法高度接近自然语言，用 `describe` 组织测试、`context` 区分场景、`it` 描述行为。这一章带你从基础结构到高级技巧，全面掌握 RSpec 的使用方式。

注意：这一章讲解的是 RSpec 的语法和设计模式。代码以示例形式展示，实际运行需要 rspec gem。运行 `hello advance testing` 查看完整示例代码。

## describe / context / it：测试结构

RSpec 的测试代码由三个层级组成。`describe` 定义测试目标（通常是一个类或方法），`context` 描述前置条件或场景，`it` 描述具体期望的行为：

```ruby
RSpec.describe User do
  context "when creating a new user" do
    it "requires a name" do
      user = User.new(name: nil)
      expect(user.valid?).to be false
    end

    it "generates a unique ID" do
      user = User.new(name: "Alice")
      expect(user.id).to be_a(Integer)
    end
  end

  context "when the user already exists" do
    it "does not create a duplicate" do
      User.create!(name: "Alice")
      expect {
        User.create!(name: "Alice")
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
```

这种结构的威力在于文档性。任何人读测试代码，即使不了解实现细节，也能知道 User 类在所有场景下应该有什么行为。描述性文字是第一优先级：`it "..."` 中的字符串是测试的文档。

嵌套 `context` 也是支持的。如果某个行为需要多层条件才能触发，可以用嵌套 context 表达：

```ruby
RSpec.describe Order do
  context "when payment fails" do
    context "and the user has credits" do
      it "fallbacks to credits" do
        order = create(:order, payment_method: :failed)
        order.process!
        expect(order.reload.status).to eq("paid_by_credits")
      end
    end
  end
end
```

## let / let!：延迟和即时赋值

`let` 和 `let!` 用于在测试中定义辅助变量。两者的区别在于执行时机：

```ruby
RSpec.describe User do
  # let：懒加载，首次调用时才执行，结果会被缓存
  let(:user) { User.create(name: "Alice") }

  # let!：立即执行（在每个 example 的 setup 阶段）
  let!(:admin) { User.create(name: "Admin", role: :admin) }

  it "reuses the same user object" do
    expect(user.id).to eq(user.id)  # 缓存保证同一对象
  end

  it "admin is already created" do
    # let! 确保 admin 在 it 块执行前已创建
    expect(User.find_by(role: :admin)).to eq(admin)
  end
end
```

何时用 `let!`？当你需要在 it 块执行前就把数据写入数据库时。比如测试关联查询，需要确保关联数据存在。何时用 `let`？当你只需要一个值而不需要副作用时。大多数情况下 `let` 就够了。

## before / after hooks

hooks 在所有 or 部分 example 执行前后运行。RSpec 支持以下 hooks：

```ruby
RSpec.describe FileProcessor do
  before(:suite) do
    # 整个测试套件运行一次
    setup_global_config
  end

  before(:context) do
    # 每个 describe/context 运行一次
    @shared_resource = allocate_shared_resource
  end

  before(:each) do
    # 每个 example 运行前
    @file = Tempfile.new("test")
  end

  after(:each) do
    # 每个 example 运行后
    @file.close
    @file.unlink
  end

  after(:context) do
    # 每个 describe/context 运行一次
    release_shared_resource(@shared_resource)
  end
end
```

`before(:each)` 是最常用的，它保证每个 example 都有干净的初始状态。`after` 块用于清理资源，即使 example 抛出异常也会执行。

## Shared Examples：共享示例

当多个类实现了相同的行为接口时，用 `shared_examples` 定义测试模板，避免重复代码：

```ruby
RSpec.shared_examples "a sortable collection" do
  it "sorts in ascending order" do
    expect(collection.sort).to eq(collection.sort.reverse.reverse)
  end

  it "returns self when already sorted" do
    sorted = collection.sort
    expect(sorted.sort).to eq(sorted)
  end

  it "handles empty collection" do
    empty_collection = described_class.new([])
    expect(empty_collection.sort).to be_empty
  end
end

RSpec.describe Array do
  include_examples "a sortable collection" do
    let(:collection) { [3, 1, 2] }
  end
end

RSpec.describe Set do
  include_examples "a sortable collection" do
    let(:collection) { Set[3, 1, 2] }
  end
end
```

`shared_examples` 定义了通用行为模板。`include_examples` 在每个具体类中实例化这个模板，传入 `let(:collection)` 提供具体的数据集。这样新增加的集合类只需 include 就能自动获得完整的排序测试。

## subject：被测试对象

`subject` 定义了当前测试上下文的"主角"。`is_expected` 是 `expect(subject)` 的简写：

```ruby
RSpec.describe Array do
  subject { [1, 2, 3] }

  it { is_expected.to have(3).items }
  it { is_expected.to contain_exactly(1, 2, 3) }

  describe "#first" do
    subject { super().first }
    it { is_expected.to eq(1) }
  end
end

# 具名 subject
RSpec.describe User do
  subject(:admin) { User.new(name: "Admin", role: :admin) }

  it { is_expected.to be_admin }
  it "has all permissions" do
    expect(admin.permissions).to include(:read, :write, :delete)
  end
end
```

具名 `subject(:name)` 会在例子中生成一个同名的辅助方法。你可以用 `name` 或 `subject` 访问它。这比每次写 `user =` 更简洁。

## 常用匹配器

匹配器是 RSpec 的核心。`expect(x).to matcher` 是最常见的断言模式：

```ruby
# 值相等
expect(value).to eq(42)           # 用 == 比较
expect(value).to eql(42)          # 用 eql? 比较（类型也相同）

# 真值判断
expect(value).to be true           # 严格等于 true
expect(value).to be_truthy         # 非 nil 和非 false
expect(value).to be false
expect(value).to be_nil

# 类型检查
expect(value).to be_a(Integer)
expect(value).to be_an(String)
expect(value).to be_a_kind_of(Numeric)

# 集合匹配
expect([1, 2, 3]).to include(2)
expect([1, 2, 3]).to match_array([3, 2, 1])  # 顺序无关
expect({a: 1, b: 2}).to include(a: 1)

# 字符串匹配
expect("hello world").to match(/world/)
expect("hello").to start_with("hel")
expect("hello").to end_with("lo")

# 状态变化
expect { user.destroy }.to change(User, :count).by(-1)
expect { user.save }.to change(user, :valid?).from(false).to(true)

# 异常捕获
expect { 1 / 0 }.to raise_error(ZeroDivisionError)
expect { 1 / 0 }.to raise_error("divided by 0")

# 浮点数容差
expect(Math::PI).to be_within(0.001).of(3.14159)

# 输出捕获
expect { puts "hello" }.to output("hello\n").to_stdout
```

## Mock & Stub：测试替身

测试替身用于隔离外部依赖。RSpec 提供了 double、instance_double、spy 等多种替身类型：

```ruby
# double：基本替身
email_svc = double("EmailService")
allow(email_svc).to receive(:send).and_return(true)
email_svc.send("hello@ruby.dev")  # 返回 true，不真正发邮件

# instance_double：类型安全的替身
# 会验证 send 方法确实存在于 EmailService 类上
email_svc = instance_double("EmailService")
allow(email_svc).to receive(:send).with("hello@ruby.dev").and_return(true)

# spy：验证调用
api = spy("Api")
api.fetch("/users")
expect(api).to have_received(:fetch).with("/users")

# stub_chain：链式 stub（尽量不用，代码味道）
allow(User).to receive_message_chain(:where, :active, :count).and_return(5)
```

最佳实践：

- 优先使用 `instance_double`，它会在编译时验证方法名是否正确
- 用 `spy` 代替 `double` 来验证调用。spy 允许先调用后验证，代码逻辑更自然
- 只 stub 外部依赖（网络、数据库、文件系统）。测试自己的代码时，尽量用真实对象
- 避免 `receive_message_chain`。链式 stub 意味着你的类依赖了太多内部结构，应该用 `delegate` 或引入中间层

## FactoryBot 集成

在需要大量测试数据的场景，手动创建对象很繁琐。FactoryBot 提供了一套声明式的测试数据工厂：

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { "Alice" }
    email { "alice@example.com" }
    age { 25 }
    role { :user }

    # trait 定义变体
    trait :admin do
      role { :admin }
    end

    trait :inactive do
      active { false }
    end

    # 关联
    after(:create) do |user|
      create_list(:post, 3, user: user)
    end
  end
end

# 使用工厂
user = create(:user)                    # 创建一个用户
admin = create(:user, :admin)           # 使用 admin trait
inactive_admin = build(:user, :admin, :inactive)  # build 不持久化
many_users = create_list(:user, 10)     # 批量创建
```

`create` 持久化到数据库，`build` 只在内存中。测试中尽量用 `build` 减少数据库 I/O。只有当需要测试关联查询或数据库层面的约束时才用 `create`。

## 本章要点

- **describe/context/it** 是 RSpec 的三层结构，描述"在什么场景下期望什么行为"
- **let** 懒加载缓存，**let!** 立即执行用于数据准备
- **before/after hooks** 在 example 前后执行 setup 和清理
- **shared_examples** 定义可复用的行为测试模板
- **subject** 定义被测试对象，`is_expected` 是它的简写
- **匹配器** 覆盖等值、类型、集合、字符串、状态变化、异常、输出等场景
- **double/instance_double/spy** 是测试替身的三种主要形式
- **FactoryBot** 提供声明式的测试数据工厂，支持 trait 和关联
- 运行 `hello advance testing` 查看完整 RSpec 模式示例
