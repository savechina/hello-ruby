# Thor CLI 高级用法

Hello Ruby 的命令行工具基于 Thor 构建。Thor 是 Ruby 生态中最流行的 CLI 框架之一，Rails 的命令行也是用 Thor 实现的。这一章带你深入了解 Thor 的高级功能，包括全局选项、命令专属选项、子命令注册、参数解析和自定义帮助。

掌握 Thor 后，你可以为自己的 Ruby 项目构建功能完整的命令行工具。运行 `hello advance cli_advanced` 可以查看完整演示代码。

## class_option vs method_option

Thor 提供两种选项声明方式：`class_option` 和 `method_option`。理解两者的区别是构建复杂 CLI 的第一步。

`class_option` 定义一个类内所有命令共享的选项。适合全局配置项，比如 `--verbose` 和 `--config`：

```ruby
class MyCLI < Thor
  class_option :verbose, type: :boolean, default: false,
                desc: "显示详细信息"
  class_option :config, aliases: ["-c"],
                desc: "指定配置文件路径"

  desc "build", "构建项目"
  def build
    puts "verbose: #{options[:verbose]}"
    puts "config: #{options[:config]}"
  end

  desc "deploy", "部署项目"
  def deploy
    puts "verbose: #{options[:verbose]}"
    # class_option 在所有命令中都可用
  end
end
```

`method_option` 只影响单个命令。适合命令专属的配置项：

```ruby
class MyCLI < Thor
  desc "build [INPUT]", "构建项目"
  method_option :output, aliases: ["-o"], default: "./dist",
                desc: "输出目录"
  method_option :minify, type: :boolean, default: false,
                desc: "压缩输出文件"
  method_option :format, aliases: ["-f"], default: "esm",
                enum: ["esm", "cjs"],
                desc: "输出格式"
  def build(input = ".")
    puts "输入: #{input}"
    puts "输出: #{options[:output]}"
    puts "压缩: #{options[:minify]}"
    puts "格式: #{options[:format]}"
  end
end
```

调用方式：

```bash
mycli build --output ./out --minify --format esm
mycli build -o ./out -f cjs
mycli --verbose build -o ./out
```

规则很简单：全局共享的用 `class_option`，单个命令专属的用 `method_option`。

## 选项类型

Thor 支持多种选项类型，每种类型有不同的解析行为：

```ruby
class AppCLI < Thor
  # string（默认类型）— 接受任意字符串
  method_option :name, type: :string
  # 用法: --name Alice

  # boolean — 标志位，无需值
  method_option :verbose, type: :boolean, default: false
  # 用法: --verbose（启用） 或 --no-verbose（禁用）

  # numeric — 数字类型，自动转换
  method_option :port, type: :numeric, default: 3000
  # 用法: --port 8080

  # hash — 键值对
  method_option :headers, type: :hash
  # 用法: --headers key1=value1 --headers key2=value2

  # array — 数组，可多次出现
  method_option :files, type: :array
  # 用法: --files a.txt --files b.txt --files c.txt

  # default — 允许 nil，nil 不转默认值
  method_option :timeout, type: :default
  # 用法: --timeout（nil） 或 --timeout 30（30）
end
```

`enum` 约束选项只能取特定值。这对于有固定选项的场景非常有用，Thor 会自动校验：

```ruby
method_option :env, enum: ["dev", "staging", "prod"], default: "dev"
# 如果传入 --env test，Thor 会自动报错并显示有效值
```

所有选项都在 `options` hash 中访问，例如 `options[:verbose]`、`options[:config]`。

## Subcommands：子命令注册

当命令数量增长时，把所有方法放在一个类中会变得臃肿。Thor 的 `register` 允许你将子命令拆分到独立的类中：

```ruby
class AppCLI < Thor
  register(UserCommands, "user", "user [CMD]", "用户管理相关命令")
  register(BuildCommands, "build", "build [CMD]", "构建工具相关命令")
end

class UserCommands < Thor
  desc "create NAME EMAIL", "创建用户"
  def create(name, email)
    puts "创建用户: #{name} <#{email}>"
  end

  desc "delete ID", "删除用户"
  def delete(id)
    puts "删除用户: #{id}"
  end
end

class BuildCommands < Thor
  desc "production", "构建生产版本"
  def production
    puts "构建生产版本..."
  end

  desc "development", "构建开发版本"
  def development
    puts "构建开发版本..."
  end
end
```

注册后，用户可以这样调用：

```bash
app user create Alice alice@example.com
app build production
app user delete 42
```

`register` 的四个参数分别是：子命令类、子命令名、横幅描述、简短描述。这种方式让 CLI 的结构保持清晰，每个子命令类只关心自己的命令。

## 参数解析

Thor 支持多种参数模式：位置参数、剩余参数（splat）、必须参数。

```ruby
class DeployCLI < Thor
  # 位置参数 — 按顺序映射
  desc "transfer FROM TO AMOUNT", "转账"
  def transfer(from, to, amount)
    puts "从 #{from} 转 #{amount} 到 #{to}"
  end

  # 剩余参数（splat）— 收集所有剩余参数
  desc "add FILES...", "添加文件"
  def add(*files)
    files.each { |f| puts "添加: #{f}" }
  end

  # 必须参数 — 没有默认值 = 必填
  desc "create NAME EMAIL", "创建用户"
  def create(name, email)
    # 缺少参数时 Thor 自动报错并显示帮助
    puts "创建: #{name} <#{email}>"
  end

  # 可选参数 — 有默认值
  desc "greet [NAME]", "打招呼"
  def greet(name = "World")
    puts "Hello, #{name}!"
  end
end
```

调用方式：

```bash
app transfer alice bob 100
app add file1.txt file2.txt file3.txt
app create Alice alice@example.com
app greet Ruby      # Hello, Ruby!
app greet           # Hello, World!
```

参数也可以通过 `args` 数组访问。Thor 自动把位置参数映射为方法参数，不需要手动解析。

## 帮助与文档

Thor 自动生成 `--help` 输出。你需要提供的是命令描述和长描述：

```ruby
class MyCLI < Thor
  desc "build [INPUT]", "构建项目"
  long_desc <<-DESC
    将指定目录中的源代码构建为可部署的产物。

    默认输出到 ./dist 目录，可以用 --output 自定义。

    支持的格式: esm, cjs, iife。默认 esm。

    示例:
      mycli build
      mycli build ./src -o ./out --minify
      mycli build --format cjs --verbose
  DESC

  method_option :output, aliases: ["-o"], default: "./dist"
  def build(input = ".")
  end

  # 自定义横幅
  banner "mycli build [OPTIONS]"

  # 短选项映射
  map "-T" => :tasks

  # 隐藏命令（不出现在 --help 中）
  # 使用 method_option 的 hidden: true 或 desc nil
end
```

生成的帮助输出：

```bash
$ mycli --help
Commands:
  mycli build [INPUT]        # 构建项目

$ mycli help build           # 查看 build 命令的详细帮助（显示 long_desc）
```

`desc` 提供简短描述，出现在命令列表中。`long_desc` 提供详细文档，只有在单独查看某个命令的帮助时才显示。`map` 创建短选项别名。

## 最佳实践

构建 CLI 工具时遵循以下原则：

1. **每个命令一个方法**，保持方法体简洁。超过 30 行的逻辑应该抽离到独立的服务类。
2. **用 class_option 共享全局选项**，如 `--verbose`、`--config`、`--dry-run`。这些选项几乎在每个命令中都需要。
3. **用 method_option 定义命令专属选项**，避免无关选项污染其他命令。
4. **复杂命令抽离为独立类**，通过 `register` 挂载。一个类管理一组相关的命令。
5. **设置 exit_on_failure? = true**。确保未知子命令或参数错误时程序退出而不是静默忽略。
6. **自定义版本命令**。Thor 的默认 `--version` 输出不够自定义，建议用 `desc "version"` 重写。
7. **所有用户输入都校验**。如果参数必须是数字、枚举值或文件路径，在方法内部校验而不是依赖 Thor 的默认行为。

## 本章要点

- **class_option** 定义类内所有命令共享的选项
- **method_option** 定义单个命令专属的选项
- 选项类型包括 string、boolean、numeric、hash、array，每种有不同的解析行为
- **register** 将子命令注册到独立的类中，保持代码组织清晰
- 参数模式包括位置参数、剩余参数（splat）、必须参数和可选参数
- desc + long_desc 生成 `--help` 和 `thor help COMMAND` 的文档输出
- 每个命令保持方法体简洁，复杂逻辑抽离到服务类
- 运行 `hello advance cli_advanced` 查看完整 Thor 高级用法演示
