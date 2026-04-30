# CLI Interface Contract

**Phase**: 1 - Design & Contracts
**Date**: 2025-04-30
**Branch**: 001-hello-basic-tutorials

## CLI Command Schema

This document defines the Thor-based CLI interface contract for hello-ruby gem.

---

## Command Definitions

### hello [NAME]

| Property      | Value                    |
| ------------- | ------------------------ |
| Command       | `hello [NAME]`           |
| Arguments     | NAME (optional, default: "World") |
| Options       | None                     |
| Output        | Human-friendly greeting  |
| Exit Code     | 0 (success)              |

**Example**:
```bash
$ hello
Hello, World! 👋
欢迎进入 Ruby 世界！

$ hello Ruby
Hello, Ruby! 👋
欢迎进入 Ruby 世界！
```

---

### version

| Property      | Value                    |
| ------------- | ------------------------ |
| Command       | `version`                |
| Arguments     | None                     |
| Options       | None                     |
| Alias         | `-v`                     |
| Output        | Semantic version string  |
| Exit Code     | 0 (success)              |

**Example**:
```bash
$ hello version
hello v0.1.0

$ hello -v
hello v0.1.0
```

---

### play TIER [TOPIC]

| Property      | Value                              |
| ------------- | ---------------------------------- |
| Command       | `play TIER [TOPIC]`                |
| Arguments     | TIER (required), TOPIC (optional)  |
| Options       | `--detail`, `-d` (boolean, default: false) |
| Output        | Topic execution results            |
| Exit Code     | 0 (success), 1 (topic not found)   |

**Arguments**:
- TIER ∈ {basic, advance, awesome}
- TOPIC: topic name without _sample suffix (e.g., "variables")

**Options**:
- `--detail` / `-d`: Show debug information before execution

**Behavior**:
- If TOPIC omitted: run all topics in TIER sequentially
- If TOPIC provided: run specific topic
- On missing TOPIC: print available topics in TIER, exit 1

**Example**:
```bash
$ hello play basic variables
=== 变量绑定与可变性 ===
[output...]

$ hello play basic variables --detail
[DEBUG] 准备运行: 变量绑定与可变性
[DEBUG] 层级: basic, 主题: variables
=== 变量绑定与可变性 ===
[output...]

$ hello play basic
[runs all 15 basic topics sequentially]

$ hello play basic nonexistent
错误：找不到 'basic/nonexistent'
可用的 basic 主题：
  variables  —  变量绑定与可变性
  strings    —  字符串
  ...
```

---

### basic [TOPIC]

| Property      | Value                              |
| ------------- | ---------------------------------- |
| Command       | `basic [TOPIC]`                    |
| Arguments     | TOPIC (optional)                   |
| Options       | None                               |
| Behavior      | Shortcut to `play basic TOPIC`     |
| Output        | Topic execution results            |
| Exit Code     | 0 (success), 1 (topic not found)   |

**Example**:
```bash
$ hello basic
[runs all 15 basic topics]

$ hello basic variables
=== 变量绑定与可变性 ===
[output...]
```

---

### advance [TOPIC]

| Property      | Value                              |
| ------------- | ---------------------------------- |
| Command       | `advance [TOPIC]`                  |
| Arguments     | TOPIC (optional)                   |
| Options       | None                               |
| Behavior      | Shortcut to `play advance TOPIC`   |
| Output        | Topic execution results            |
| Exit Code     | 0 (success), 1 (topic not found)   |

**Example**:
```bash
$ hello advance metaprogramming
=== 元编程 ===
[output...]
```

---

### awesome [TOPIC]

| Property      | Value                              |
| ------------- | ---------------------------------- |
| Command       | `awesome [TOPIC]`                  |
| Arguments     | TOPIC (optional)                   |
| Options       | None                               |
| Behavior      | Shortcut to `play awesome TOPIC`   |
| Output        | Topic execution results            |
| Exit Code     | 0 (success), 1 (topic not found)   |

**Example**:
```bash
$ hello awesome sinatra
=== Sinatra Web 框架 ===
[output...]
```

---

## Error Handling Contract

### NotFoundError

| Property      | Value                              |
| ------------- | ---------------------------------- |
| Trigger       | Topic lookup fails                 |
| Message       | "错误：找不到 '{tier}/{topic}'"    |
| Recovery      | Print available topics in tier     |
| Exit Code     | 1                                  |

**Output Format**:
```
错误：找不到 'basic/nonexistent'

可用的 basic 主题：
  variables  —  变量绑定与可变性
  strings    —  字符串
  arrays     —  数组
  ...
```

---

### Invalid Tier Error

| Property      | Value                              |
| ------------- | ---------------------------------- |
| Trigger       | TIER not in {basic, advance, awesome} |
| Message       | "错误：未知层级 '{tier}'，可选: basic, advance, awesome" |
| Exit Code     | 1                                  |

**Output Format**:
```
错误：未知层级 'invalid'，可选: basic, advance, awesome
```

---

## Output Format Contract

### Topic Execution Output

Each topic follows this format:

```
=== {Chinese Description} ===

[Concept method output...]

[Concept method output...]
```

**Example**:
```
=== 变量绑定与可变性 ===

1. 变量绑定:
   name = "Ruby"
   version = 3.4
   greeting = "Hello, Ruby!"

2. 引用共享:
   original after mutate: "hello world"
   alias_ref after mutate: "hello world"
   Same object? true

3. Rebinding:
   a rebind: "second"
   b unaffected: "first"
   Same object? false
```

---

### Help Output

Thor auto-generates help from command descriptions:

```bash
$ hello help
Commands:
  hello hello [NAME]     # 向指定名称问好（默认 'World'）
  hello help [COMMAND]   # Describe available commands or one specific command
  hello version          # 显示当前版本号
  hello play TIER TOPIC  # 运行指定层级和主题的代码示例
  hello basic [TOPIC]    # 运行所有基础主题，或运行指定主题
  hello advance [TOPIC]  # 运行所有进阶主题，或运行指定主题
  hello awesome [TOPIC]  # 运行所有实战主题，或运行指定主题
```

---

## Topic Registry Contract

### Registration API

| Method        | Signature                                |
| ------------- | ---------------------------------------- |
| register      | `register(tier, name, description, callable)` |

**Parameters**:
- `tier`: String ∈ {basic, advance, awesome}
- `name`: String (kebab-case, no _sample suffix)
- `description`: String (Chinese description)
- `callable`: Module with .run method OR Proc with .call

**Registration Key**: `"{tier}/{name}"`

---

### Lookup API

| Method        | Signature                   | Returns            |
| ------------- | --------------------------- | ------------------ |
| lookup        | `lookup(tier, name)`        | Hash or nil        |
| list          | `list(tier)`                | Array<Hash>        |
| list_all      | `list_all`                  | Array<Hash> sorted |

**Hash Structure**:
```ruby
{
  tier: "basic",
  name: "variables",
  description: "变量绑定与可变性",
  callable: Hello::Basic::VariablesSample
}
```

---

### Execution API

| Method        | Signature                   | Behavior                    |
| ------------- | --------------------------- | --------------------------- |
| run           | `run(tier, name)`           | Execute callable.run or callable.call |

**Execution Flow**:
1. Lookup topic by tier/name
2. Raise NotFoundError if nil
3. Check callable.respond_to?(:run) OR callable.respond_to?(:call)
4. Execute callable.run or callable.call
5. Output formatted results

---

## Topic Naming Convention

| Aspect         | Convention               | Example                    |
| -------------- | ------------------------ | -------------------------- |
| File name      | *_sample.rb suffix       | variables_sample.rb        |
| Module name    | *Sample suffix           | VariablesSample            |
| Registry key   | No suffix                | "variables" (not "variables_sample") |
| CLI argument   | No suffix                | hello basic variables      |

**Rationale**: Users see clean names in CLI, internal files use _sample suffix for distinction.

---

## Contract Summary

| Contract Element      | Specification                              |
| --------------------- | ------------------------------------------ |
| CLI Framework         | Thor 1.1+                                  |
| Entry Point           | exe/hello                                  |
| Main Class            | Hello::Cli                                 |
| Commands              | 6: hello, version, play, basic, advance, awesome |
| Error Handling        | NotFoundError, ArgumentError, exit on failure |
| Output Format         | Chinese descriptions with formatted output |
| Thread Safety         | TopicRegistry uses Mutex                   |
| Topic Discovery       | Self-registration at file load             |
| Topic Keys            | "tier/name" (no _sample suffix)            |