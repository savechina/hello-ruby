# Quickstart — Hello Advance Tutorials Implementation

**Feature**: 002-hello-advance-tutorials
**Date**: 2026-04-30

---

## Prerequisites

- Ruby 3.2+ (rbenv managed)
- Existing hello-ruby repository on branch `002-hello-advance-tutorials`
- Completed `/speckit.clarify` and `/speckit.plan` workflows

---

## Implementation Order

### Phase 1: Create Test Specs (Test-First)

```bash
# Create test files FIRST (constitution Principle II)
touch spec/advance/llm_spec.rb
touch spec/advance/system_programming_spec.rb
touch spec/advance/memory_mapping_spec.rb
touch spec/advance/parallel_spec.rb
touch spec/advance/data_processing_spec.rb

# Create fixture files
mkdir -p spec/fixtures
touch spec/fixtures/sample.csv
touch spec/fixtures/sample.json
touch spec/fixtures/sample.yaml
```

### Phase 2: Create Module Files

```bash
# Create module source files
touch lib/hello/advance/llm_sample.rb
touch lib/hello/advance/system_programming_sample.rb
touch lib/hello/advance/memory_mapping_sample.rb
touch lib/hello/advance/parallel_sample.rb
touch lib/hello/advance/data_processing_sample.rb

# Note: performance_sample.rb EXISTS - edit to expand
```

### Phase 3: Create Documentation Chapters

```bash
# Create Chinese documentation
touch docs/src/advance/llm.md
touch docs/src/advance/system-programming.md
touch docs/src/advance/memory-mapping.md
touch docs/src/advance/parallel.md
touch docs/src/advance/data-processing.md
```

---

## Module Implementation Pattern

### Step 1: File Header

```ruby
# typed: true
# frozen_string_literal: true

require "dotenv/load"  # If needed for module
```

### Step 2: Module Structure

```ruby
module Hello
  module Advance
    # 中文描述 — English description
    class TopicNameSample
      def self.run
        puts "=== 中文标题 ==="
        puts
        
        concept_method_one
        concept_method_two
        # ... 3-5 concept methods
        
        puts "=== 演示完成 ==="
      end
      
      # Concept methods with explanatory comments
      def self.concept_method_one
        puts "--- 1. 中文概念名 ---"
        # Demo code with comments
        puts
      end
      
      def self.concept_method_two
        puts "--- 2. 中文概念名 ---"
        # Demo code with comments
        puts
      end
    end
  end
end
```

### Step 3: TopicRegistry Registration

```ruby
# At END of file (line ~170-200)
Hello::TopicRegistry.register("advance", "topic_name", "中文描述", Hello::Advance::TopicNameSample)
```

---

## Test Spec Implementation Pattern

```ruby
# frozen_string_literal: true

require "spec_helper"

RSpec.describe "TopicName module" do
  it "executes without error" do
    expect { Hello::Advance::TopicNameSample.run }.not_to raise_error
  end
end
```

---

## External Gem Integration

### Add to Gemfile (Optional Dependencies)

```ruby
group :development, :test do
  gem "ruby-openai", ">= 8.0"
  gem "sys-proctable", ">= 1.0"
  gem "mmap-ruby", ">= 1.0"
  gem "parallel", ">= 1.22"
  gem "benchmark-ips", ">= 2.10"
  gem "memory_profiler", ">= 1.0"
  gem "dotenv", "~> 3.0"
end
```

### Install Gems

```bash
bundle install
```

---

## CLI Verification

```bash
# Verify each module runs
bundle exec hello advance llm
bundle exec hello advance system_programming
bundle exec hello advance memory_mapping
bundle exec hello advance parallel
bundle exec hello advance performance  # (expanded)
bundle exec hello advance data_processing

# Run all advance modules
bundle exec hello advance
```

---

## Quality Gates (Constitution Compliance)

### RuboCop Check

```bash
bundle exec rubocop lib/hello/advance/*.rb
# MUST pass with zero offenses
```

### Sorbet Type Check

```bash
bundle exec srb tc lib/hello/advance/*.rb
# MUST pass with zero type errors
```

### RSpec Tests

```bash
bundle exec rspec spec/advance/
# MUST pass all smoke tests
```

---

## Documentation Requirements

### Chinese Chapter Structure

```markdown
# 主题名称 (Topic Name)

## 概述

[至少500中文字符，解释主题概念]

## 示例

### 示例 1：基础用法
```ruby
[可执行代码示例]
```

### 示例 2：进阶用法
```ruby
[可执行代码示例]
```

### 示例 3：实战应用
```ruby
[可执行代码示例]
```

## 知识检查

1. [问题一]
2. [问题二]
3. [问题三]

## 参考资源

- [相关链接]
```

---

## Sample Fixture Content

### sample.csv

```csv
name,age,city
Alice,30,Beijing
Bob,25,Shanghai
Carol,35,Guangzhou
```

### sample.json

```json
{
  "users": [
    {"name": "Alice", "age": 30},
    {"name": "Bob", "age": 25}
  ],
  "total": 2
}
```

### sample.yaml

```yaml
database:
  host: localhost
  port: 5432
  name: hello_ruby
```

---

## Implementation Checklist

- [ ] Create 5 new test spec files
- [ ] Create 5 new module source files
- [ ] Expand performance_sample.rb (add 4 concept methods)
- [ ] Create spec/fixtures/*.csv, *.json, *.yaml
- [ ] Create 5 documentation chapters (Chinese)
- [ ] Add external gems to Gemfile (development group)
- [ ] Run `bundle exec rubocop` — must pass
- [ ] Run `bundle exec srb tc` — must pass
- [ ] Run `bundle exec rspec spec/advance/` — must pass
- [ ] Run `bundle exec hello advance TOPIC` for each new module
- [ ] Update AGENTS.md with new technology references

---

## Estimated Effort

| Module                    | Concept Methods | Estimated Time |
| ------------------------- | --------------- | -------------- |
| llm_sample.rb              | 5               | 2 hours        |
| system_programming_sample.rb | 5            | 1.5 hours      |
| memory_mapping_sample.rb    | 5               | 1.5 hours      |
| parallel_sample.rb          | 5               | 1.5 hours      |
| performance_sample.rb (expand) | 4            | 1 hour         |
| data_processing_sample.rb   | 5               | 1.5 hours      |
| Test specs (6)              | -               | 0.5 hours      |
| Documentation (5 chapters)  | -               | 2 hours        |
| **Total**                    | **29 concepts** | **~10 hours**  |

---

## Next Steps

After completing implementation:

1. Run `/speckit.tasks` to generate task breakdown
2. Run `/speckit.implement` to execute tasks
3. Run `/review` for pre-landing code review
4. **Manual commit** (constitution forbids auto-commits)
5. Run `/ship` to create PR