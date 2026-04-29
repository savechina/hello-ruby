# 阶段复习：高级进阶

完成所有 Advance 章节后，你已经掌握了 Ruby 的核心高级特性。这一章不是新的知识点，而是带你把前面学过的内容串联起来，综合运用元编程、依赖注入、测试等技能，从零设计并实现一个小服务。

复习的目的是检验学习成果。如果你能独立完成本章的所有练习，说明你已经准备好进入 Awesome 层面的实战了。

## 复习目标

构建一个用户注册服务，综合运用以下技能。

1. 使用元编程动态生成验证规则
2. 使用 dry-system 的依赖注入模式管理服务依赖
3. 使用 RSpec 编写完整的单元测试
4. 使用 Thor 构建命令行接口
5. 合理处理错误和异常

## 练习一：元编程验证器

从元编程章节我们知道 `method_missing` 和 `class_eval` 可以实现声明式 DSL。实现一个 `Validator` 类，支持如下语法：

```ruby
class UserValidator
  extend ValidatorDSL

  requires :name, String
  requires :email, String
  validates_length :name, min: 2, max: 50
  validates_format :email, /@/

  def validate(attrs)
    errors = []
    self.class.validation_rules.each do |rule|
      error = rule.call(attrs)
      errors << error if error
    end
    errors.empty? ? nil : errors
  end
end

validator = UserValidator.new
result = validator.validate(name: "Al", email: "invalid")
puts result  # 包含两个错误信息
```

提示：`ValidatorDSL` 用 `extended` 回调注入 `requires`、`validates_length` 等类方法。这些方法收集规则存储到 `@validation_rules` 数组中。

验证点：
- `extended` 回调正确注入 DSL 方法
- 验证规则按声明顺序保存和执行
- 每个规则返回错误信息或 nil
- 最终 `validate` 汇总所有错误

## 练习二：依赖注入

为练习一的验证器添加依赖注入。假设 `UserValidator` 依赖一个日志记录器：

```ruby
module Import
  # 从你的容器中注入
  extend Application.injector
end

class CreateUser
  extend Import["validator", "logger", "storage"]

  def call(attrs)
    errors = validator.validate(attrs)
    return { success: false, errors: errors } if errors

    user = storage.create(attrs)
    logger.info("用户已创建: #{user[:name]}")
    { success: true, user: user }
  end
end
```

要求：
- `Import` mixin 注入三个依赖：`validator`、`logger`、`storage`
- `CreateUser` 不包含任何 new 调用，所有依赖从容器注入
- 调用流程：验证 → 存储 → 日志 → 返回结果

验证点：
- Import 的方法正确解析容器中的组件
- CreateUser 的调用结果正确区分成功和失败两种情况
- 日志记录只在创建成功时执行

## 练习三：测试驱动

为 `CreateUser` 编写 RSpec 测试。使用 `instance_double` 创建测试替身：

```ruby
RSpec.describe CreateUser do
  let(:validator) { instance_double(UserValidator) }
  let(:logger) { instance_double(Logger) }
  let(:storage) { instance_double(Storage) }
  let(:service) { CreateUser.new(container: double("validator" => validator, "logger" => logger, "storage" => storage)) }

  context "当输入有效时" do
    before do
      allow(validator).to receive(:validate).with({name: "Alice"}).and_return(nil)
      allow(storage).to receive(:create).with({name: "Alice"}).and_return({id: 1, name: "Alice"})
      allow(logger).to receive(:info)
    end

    it "创建用户并返回成功结果" do
      result = service.call(name: "Alice")
      expect(result[:success]).to be true
      expect(result[:user][:id]).to eq(1)
      expect(logger).to have_received(:info).with(/用户已创建/)
    end
  end

  context "当输入无效时" do
    before do
      allow(validator).to receive(:validate).with({name: ""}).and_return(["name 不能为空"])
    end

    it "返回错误且不创建用户" do
      result = service.call(name: "")
      expect(result[:success]).to be false
      expect(result[:errors]).to eq(["name 不能为空"])
      expect(storage).not_to have_received(:create)
    end
  end
end
```

验证点：
- 分别测试成功路径和失败路径
- 用 `instance_double` 而非普通 `double`，获得类型安全
- 用 `have_received` spy 模式验证副作用
- 失败路径确认 `storage.create` 没有被调用

## 练习四：Thor CLI

为服务添加命令行接口：

```ruby
class UserCLI < Thor
  class_option :verbose, type: :boolean, default: false

  desc "create NAME EMAIL", "创建用户"
  method_option :email, required: true, desc: "用户邮箱"
  def create(name)
    email = options[:email]
    result = create_user.call(name: name, email: email)

    if result[:success]
      puts "用户创建成功: #{result[:user][:name]}"
    else
      puts "创建失败:"
      result[:errors]&.each { |e| puts "  - #{e}" }
    end
  end

  desc "list", "列出所有用户"
  def list
    users = storage.list
    users.each { |u| puts "  #{u[:id]}: #{u[:name]} <#{u[:email]}>" }
  end
end
```

运行方式：

```bash
user-cli create Alice --email alice@example.com
user-cli --verbose list
```

验证点：
- `class_option` 定义全局的 `--verbose` 选项
- `method_option` 定义命令专属选项
- 位置参数 `name` 是必填的
- 错误输出格式清晰，每条错误一行

## 练习五：错误处理

为整个服务添加健壮的错误处理：

```ruby
class RegisterService
  extend Import["validator", "logger", "storage"]

  def call(attrs)
    validate(attrs).bind do |valid_attrs|
      save(valid_attrs)
    end
  rescue => e
    logger.error("注册服务异常: #{e.message}")
    { success: false, error: "服务内部错误" }
  end

  def validate(attrs)
    errors = validator.validate(attrs)
    errors ? failure(errors) : success(attrs)
  end

  def save(attrs)
    user = storage.with_transaction { storage.create(attrs) }
    success(user)
  rescue StorageError => e
    logger.error("存储失败: #{e.message}")
    failure(["保存用户失败，请稍后重试"])
  end
end
```

验证点：
- 顶层 `rescue` 捕获所有未预期的异常，返回通用错误信息
- `validate` 用 Result monad 模式处理验证失败
- `save` 只捕获 `StorageError`，不捕获所有异常
- 所有错误路径都有日志记录

## 综合评分标准

完成所有练习后，对照以下标准自评：

| 维度 | 合格 | 优秀 |
|------|------|------|
| 元编程 | DSL 方法能正确收集验证规则 | 规则支持嵌套、组合，可复用 |
| DI 设计 | 所有依赖通过 Import 注入 | 容器配置清晰，Provider 管理外部资源 |
| 测试覆盖 | 成功路径和失败路径都有测试 | 边界情况和异常路径也有测试 |
| CLI 设计 | 选项和参数正确解析 | 帮助文档完整，用户体验友好 |
| 错误处理 | 外部异常有顶层 catch | 分层错误处理，每层职责清晰 |

如果你的所有维度都达到"优秀"标准，你已经具备了进入 Awesome 层的能力。Awesome 层会用干系系统构建一个完整的生产级项目，包括 Rails 控制器、Sidekiq 后台任务、REST API、Docker 部署。那些内容会在这里的基础之上，进一步展示工业级的 Ruby 工程实践。
