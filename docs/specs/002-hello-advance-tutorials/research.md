# Research Findings — Hello Advance Tutorials

**Feature**: 002-hello-advance-tutorials
**Date**: 2026-04-30
**Sources**: 5 parallel research agents (explore + librarian)

---

## 1. Advance Module Structure Pattern

### Decision
Use `class` pattern (consistent with `async_await_sample.rb`, `performance_sample.rb`) with helper classes after main class if needed.

### Rationale
- 3 of 10 advance modules use `class` (`AsyncAwaitSample`, `PerformanceSample`, `ThreadsFibersSample`)
- `class` pattern allows stateful helper classes
- Spec tests reference `Hello::Advance::NameSample.run` — works with both module and class

### Pattern Template
```ruby
# typed: true
# frozen_string_literal: true

require "benchmark"  # if needed

module Hello
  module Advance
    # 中文描述 — English description
    class TopicNameSample
      def self.run
        puts "=== 中文标题 ==="
        puts
        
        # --- 1. Concept 1 ---
        puts "--- 1. 中文概念 ---"
        concept_method_one
        puts
        
        # --- 2. Concept 2 ---
        puts "--- 2. 中文概念 ---"
        concept_method_two
        puts
        
        puts "=== 演示完成 ==="
      end
      
      def self.concept_method_one
        # Implementation with explanatory comments
      end
      
      def self.concept_method_two
        # Implementation with explanatory comments
      end
    end
  end
end

Hello::TopicRegistry.register("advance", "topic_name", "中文描述", Hello::Advance::TopicNameSample)
```

### Alternatives Considered
- `module` pattern (used in `MetaprogrammingSample`) — rejected: less flexible for helper classes
- Inline code only (no concept methods) — rejected: harder to test individual concepts

---

## 2. Test Spec Pattern

### Decision
Use minimal smoke test pattern with 9-line structure.

### Rationale
- All 10 advance specs use identical pattern
- Constitution requires smoke tests only for advance tier
- Pattern is simple, maintainable, and sufficient

### Pattern Template
```ruby
# frozen_string_literal: true

require "spec_helper"

RSpec.describe "TopicName module" do
  it "executes without error" do
    expect { Hello::Advance::TopicNameSample.run }.not_to raise_error
  end
end
```

### Alternatives Considered
- Nested describe blocks for concept methods — rejected: not used in existing advance specs
- Full integration tests — rejected: constitution specifies smoke tests for tutorials

---

## 3. ruby-openai Gem Usage

### Decision
Use `ruby-openai` gem (community, 3.2k+ stars) with dotenv for API key management.

### Rationale
- Most popular Ruby OpenAI client
- Supports streaming, function calling, JSON mode
- dotenv integration matches constitution Principle III
- OpenAI-compatible with Ollama (localhost:11434)

### Key Patterns

**Client Setup:**
```ruby
require "dotenv/load"

OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
  config.log_errors = true  # Dev only
end

client = OpenAI::Client.new
```

**Streaming:**
```ruby
client.chat(
  parameters: {
    model: "gpt-4o",
    messages: [{ role: "user", content: "Hello!" }],
    stream: proc do |chunk, _event|
      print chunk.dig("choices", 0, "delta", "content")
    end
  }
)
```

**Error Handling:**
```ruby
rescue Faraday::TimeoutError => e
  # Retry with exponential backoff
rescue Faraday::ClientError => e
  # 4xx errors - check API key, rate limits
rescue Faraday::ServerError => e
  # 5xx errors - retry
```

### Alternatives Considered
- Official `openai` gem (0.58) — rejected: less community adoption
- HTTP client only — rejected: reinventing patterns

---

## 4. Parallel Gem & GVL Patterns

### Decision
Demonstrate both `in_processes` (CPU-bound) and `in_threads` (I/O-bound) with GVL explanation.

### Rationale
- GVL limits Ruby thread parallelism for CPU-bound tasks
- Threads work for I/O-bound (GVL released during I/O wait)
- Processes bypass GVL for true CPU parallelism
- Ruby 3.0+ Ractors have individual GVLs (experimental)

### Key Patterns

**CPU-bound (Processes):**
```ruby
Parallel.map([1,2,3,4], in_processes: 4) do |n|
  n ** 2  # CPU work
end
```

**I/O-bound (Threads):**
```ruby
Parallel.map(urls, in_threads: 4) do |url|
  Net::HTTP.get(URI(url))  # I/O releases GVL
end
```

**Benchmark Comparison:**
```ruby
Benchmark.bm do |x|
  x.report("sequential") { ... }
  x.report("threads") { Parallel.map(..., in_threads: 4) { ... } }
  x.report("processes") { Parallel.map(..., in_processes: 4) { ... } }
end
```

### Alternatives Considered
- concurrent-ruby gem — rejected: more complex, Parallel gem is tutorial-friendly
- Raw Thread.new — rejected: no built-in result collection

---

## 5. mmap Gem Patterns

### Decision
Use `mmap-ruby` gem (modern fork) for file-backed memory mapping examples.

### Rationale
- mmap-ruby is actively maintained
- Demonstrates zero-copy file access
- Performance comparison vs File.read shows ~8.7x speedup for IPC
- stdlib alternative: `File.foreach` (streaming) but no mmap capability

### Key Patterns

**Basic Read:**
```ruby
require "mmap-ruby"

mmap = Mmap.new("file.txt", "r")
mmap.advise(Mmap::MADV_SEQUENTIAL)
mmap.each_line { |line| puts line }
mmap.unmap
```

**Read-Write:**
```ruby
mmap = Mmap.new("file.txt", "rw")
mmap.sub!(/pattern/, "replacement")  # In-place edit
mmap.msync  # Sync to disk
mmap.munmap
```

**IPC via mmap (8.7x faster than IO.pipe):**
```ruby
# Producer-consumer via shared memory
fork do
  1_000_000.times { |i| mmap[i * 3, 3] = "aa\n" }
end
# Consumer reads sequentially
```

### Alternatives Considered
- mmap2 gem (older) — rejected: less maintained
- File.read only — rejected: doesn't demonstrate memory mapping concept

---

## 6. TopicRegistry Registration Pattern

### Decision
Register at file end with clean key (no `_sample` suffix).

### Rationale
- All 10 advance modules follow this pattern
- CLI uses key for `hello advance llm` (not `llm_sample`)
- Chinese description in third argument

### Pattern
```ruby
Hello::TopicRegistry.register("advance", "llm", "LLM 集成", Hello::Advance::LlmSample)
```

### Key Naming Convention
| Module File                | Registry Key          | CLI Command                    |
| --------------------------- | --------------------- | ------------------------------- |
| `llm_sample.rb`              | `"llm"`               | `hello advance llm`            |
| `system_programming_sample.rb` | `"system_programming"` | `hello advance system_programming` |
| `data_processing_sample.rb`  | `"data_processing"`   | `hello advance data_processing` |

---

## 7. External Gem Dependencies

### Decision
Add to gemspec as optional development dependencies with loose constraints (`>= minimum`).

### Rationale
- Clarification Q3 answered: loose constraints for flexibility
- Learners install as needed (not required for basic execution)
- Documented in gemspec comments

### Gemspec Pattern
```ruby
# hello.gemspec
Gem::Specification.new do |spec|
  # ... standard metadata ...
  
  spec.add_development_dependency "ruby-openai", ">= 8.0"
  spec.add_development_dependency "parallel", ">= 1.22"
  spec.add_development_dependency "mmap-ruby", ">= 1.0"
  spec.add_development_dependency "benchmark-ips", ">= 2.10"
  spec.add_development_dependency "memory_profiler", ">= 1.0"
  spec.add_development_dependency "dotenv", "~> 3.0"
end
```

---

## 8. Documentation Language & Content Requirements

### Decision
Chinese primary with English technical terms, minimum 500 characters per chapter, 3 examples, 3 questions.

### Rationale
- Constitution Principle III mandates Chinese documentation
- Matches existing docs/src/basic/*.md pattern
- Minimum requirements from constitution section III

### Chapter Template
```markdown
# 主题名称 (Topic Name)

## 概述

[中文解释，至少500字]

## 示例

### 示例 1：基础用法
```ruby
# 代码示例
```

### 示例 2：进阶用法
```ruby
# 代码示例
```

### 示例 3：实战应用
```ruby
# 代码示例
```

## 知识检查

1. 问题一？
2. 问题二？
3. 问题三？

## 参考资源

- [链接]
```

---

## Summary

| Research Area                     | Decision Made                     | Key Pattern                           |
| --------------------------------- | --------------------------------- | ------------------------------------- |
| Module Structure                  | `class` with concept methods      | `def self.run` + `def self.concept_*` |
| Test Specs                        | Smoke tests (9-line)              | `expect { ... }.not_to raise_error`   |
| LLM Integration                   | ruby-openai + dotenv              | `OpenAI::Client.new` + streaming      |
| Parallel Processing               | Parallel gem + GVL demo           | `in_processes` vs `in_threads`        |
| Memory Mapping                    | mmap-ruby gem                     | `Mmap.new` + IPC patterns             |
| TopicRegistry                     | Clean key registration            | `"llm"` not `"llm_sample"`            |
| Gem Dependencies                  | Optional with loose constraints   | `>= minimum` in development group     |
| Documentation                     | Chinese primary + 3 examples      | 500 chars + 3 questions per chapter   |

**All NEEDS CLARIFICATION items resolved. Ready for Phase 1 design.**