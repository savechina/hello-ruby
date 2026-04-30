# Implementation Plan: Hello Advance Tutorials

**Branch**: `002-hello-advance-tutorials` | **Date**: 2026-04-30 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/docs/specs/002-hello-advance-tutorials/spec.md`

## Summary

Add 6 advance topic modules to hello-ruby covering LLM integration, system programming, memory mapping, parallel computing, advanced benchmarking, and data processing scripting patterns. Each module follows established TopicRegistry pattern with 3-5 concept methods, smoke test specs, and Chinese documentation chapters.

## Technical Context

**Language/Version**: Ruby 3.2+ (rbenv managed per .ruby-version)
**Primary Dependencies**: Thor ~> 1.1 (CLI), dry-system (DI), ruby-openai >= 6.0, parallel >= 1.22, mmap >= 1.0, benchmark-ips >= 2.10, memory_profiler >= 1.0, sys-proctable >= 1.0, dotenv ~> 3.0
**Storage**: SQLite3 in-memory (existing), spec/fixtures/ for sample data files
**Testing**: RSpec 3.0+ (smoke tests: `expect { Module.run }.not_to raise_error`)
**Target Platform**: macOS/Linux (Ruby cross-platform)
**Project Type**: CLI library/gem (tutorial examples)
**Performance Goals**: <1s CLI execution per topic, streaming patterns for large data
**Constraints**: Zero external gem requirements for basic execution (optional gems documented), smoke tests only (no live API calls)
**Scale/Scope**: 6 modules (~18-30 concept methods), 6 test specs, 6 documentation chapters

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Ruby Idioms & Code Quality (NON-NEGOTIABLE)

| Requirement                        | Status  | Notes                                        |
| ---------------------------------- | ------- | -------------------------------------------- |
| frozen_string_literal: true        | ✅ PASS | All new modules must include                 |
| typed: true Sorbet sigil           | ✅ PASS | All new modules must include                 |
| Double quotes for strings          | ✅ PASS | Follow RuboCop `EnforcedStyle: double_quotes` |
| Max line length: 120 characters    | ✅ PASS | RuboCop enforced                             |
| Zero RuboCop offenses              | ✅ PASS | `bundle exec rubocop` must pass              |
| YARD docs on public APIs           | ⚠️ TODO | Add YARD comments to concept methods         |

### Principle II: Test-First Development (NON-NEGOTIABLE)

| Requirement                        | Status  | Notes                                        |
| ---------------------------------- | ------- | -------------------------------------------- |
| Tests written BEFORE implementation| ✅ PASS | Smoke specs first, then implement            |
| RSpec test suite                   | ✅ PASS | spec/advance/*.rb follows existing pattern   |
| Smoke tests (execute without error)| ✅ PASS | `expect { Module.run }.not_to raise_error`   |

### Principle III: CLI & UX Consistency

| Requirement                        | Status  | Notes                                        |
| ---------------------------------- | ------- | -------------------------------------------- |
| Thor-based CLI structure           | ✅ PASS | Existing cli.rb handles `hello advance TOPIC` |
| Chinese documentation primary      | ✅ PASS | docs/src/advance/*.md in Chinese             |
| Minimum 500 chars per chapter      | ⚠️ TODO | Documentation task                            |

### Principle IV: Performance & Reliability

| Requirement                        | Status  | Notes                                        |
| ---------------------------------- | ------- | -------------------------------------------- |
| <1s CLI execution                  | ✅ PASS | Topic modules are demonstration code         |
| No unbounded growth                | ✅ PASS | Streaming patterns for large data            |
| GVL awareness                      | ✅ PASS | parallel_sample.rb demonstrates GVL limits    |

### Principle V: SDD Harness Engineering

| Requirement                        | Status  | Notes                                        |
| ---------------------------------- | ------- | -------------------------------------------- |
| Manual commit control              | ✅ PASS | Constitution forbids auto-commits            |
| Feature branch workflow            | ✅ PASS | Branch 002-hello-advance-tutorials created   |

**Gate Status**: ✅ PASS — All NON-NEGOTIABLE requirements satisfied or tracked as TODO.

## Project Structure

### Documentation (this feature)

```text
docs/specs/002-hello-advance-tutorials/
├── plan.md              # This file (/speckit.plan output)
├── research.md          # Phase 0 output (external gem patterns)
├── data-model.md        # Phase 1 output (concept method inventory)
├── quickstart.md        # Phase 1 output (implementation guide)
└── tasks.md             # Phase 2 output (/speckit.tasks - NOT created yet)
```

### Source Code (repository root)

```text
lib/hello/
├── advance/
│   ├── llm_sample.rb              # FR-001: LLM integration
│   ├── system_programming_sample.rb  # FR-002: Process/Signal/Sys
│   ├── memory_mapping_sample.rb      # FR-003: mmap patterns
│   ├── parallel_sample.rb            # FR-004: Parallel gem
│   ├── performance_sample.rb         # FR-005: EXPAND existing
│   ├── data_processing_sample.rb     # FR-006: CSV/JSON/YAML scripting
│   └── [existing 10 modules preserved]
├── topic_registry.rb               # FR-007: Registry pattern (preserved)
└── cli.rb                          # FR-011: Thor CLI (preserved)

spec/
├── advance/
│   ├── llm_spec.rb                  # FR-010: Smoke test
│   ├── system_programming_spec.rb   # FR-010: Smoke test
│   ├── memory_mapping_spec.rb       # FR-010: Smoke test
│   ├── parallel_spec.rb             # FR-010: Smoke test
│   ├── performance_spec.rb          # FR-010: EXPAND existing
│   └── data_processing_spec.rb      # FR-010: Smoke test
├── fixtures/
│   ├── sample.csv                   # FR-012: CSV test data
│   ├── sample.json                  # FR-012: JSON test data
│   └── sample.yaml                  # FR-012: YAML test data
└── [existing specs preserved]

docs/src/advance/
├── llm.md                            # SC-005: Chinese chapter
├── system-programming.md             # SC-005: Chinese chapter
├── memory-mapping.md                 # SC-005: Chinese chapter
├── parallel.md                       # SC-005: Chinese chapter
├── performance.md                    # SC-005: EXPAND existing
├── data-processing.md                # SC-005: Chinese chapter
└ [existing docs preserved]
```

**Structure Decision**: Single project structure (Option 1). New modules integrate into existing `lib/hello/advance/` with preserved TopicRegistry and CLI infrastructure.

## Module Design Patterns

### Pattern Template (from existing modules)

```ruby
# typed: true
# frozen_string_literal: true

module Hello
  module Advance
    # [中文描述] — [English description]
    module TopicNameSample
      def self.run
        puts "=== [中文标题] ==="
        puts
        
        # --- 1. [Concept 1] ---
        puts "--- 1. [中文概念] ---"
        concept_method_one
        puts
        
        # --- 2. [Concept 2] ---
        puts "--- 2. [中文概念] ---"
        concept_method_two
        puts
        
        # [3-5 concept methods...]
        
        puts "=== [中文标题] 完成 ==="
      end
      
      def self.concept_method_one
        # Implementation with explanatory comments
      end
      
      def self.concept_method_two
        # Implementation with explanatory comments
      end
      
      # [3-5 unit-testable concept methods]
    end
  end
end

Hello::TopicRegistry.register("advance", "topic_name", "中文描述", Hello::Advance::TopicNameSample)
```

### Test Spec Pattern (from existing specs)

```ruby
# frozen_string_literal: true

require "spec_helper"

RSpec.describe "[Topic] module" do
  it "executes without error" do
    expect { Hello::Advance::TopicNameSample.run }.not_to raise_error
  end
end
```

### TopicRegistry Registration Pattern

```ruby
# At end of each *_sample.rb file:
Hello::TopicRegistry.register("advance", "clean_key", "中文描述", Hello::Advance::TopicNameSample)

# Key naming: "llm" not "llm_sample", "data_processing" not "data_processing_sample"
```

## Concept Method Inventory (Preliminary)

### Module 1: llm_sample.rb (3-5 concepts)

| Concept # | Method Name              | Description (Chinese)              | External Dep |
| --------- | ------------------------ | ---------------------------------- | ------------ |
| 1         | `dotenv_setup`             | API 密钥管理 (dotenv)              | dotenv       |
| 2         | `openai_client_demo`       | OpenAI 客户端设置                  | ruby-openai  |
| 3         | `prompt_patterns`          | Prompt 工程模式                    | -            |
| 4         | `streaming_responses`      | 流式响应处理                       | ruby-openai  |
| 5         | `error_handling`           | API 错误处理                       | -            |

### Module 2: system_programming_sample.rb (3-5 concepts)

| Concept # | Method Name              | Description (Chinese)              | External Dep |
| --------- | ------------------------ | ---------------------------------- | ------------ |
| 1         | `process_spawn_demo`       | 进程创建 (Process.spawn)           | -            |
| 2         | `io_popen_demo`            | 管道通信 (IO.popen)                | -            |
| 3         | `signal_handling`          | 信号处理 (Signal.trap)             | -            |
| 4         | `process_info`             | 进程信息 (Sys::ProcTable)          | sys-proctable |
| 5         | `env_management`           | 环境变量管理                       | -            |

### Module 3: memory_mapping_sample.rb (3-5 concepts)

| Concept # | Method Name              | Description (Chinese)              | External Dep |
| --------- | ------------------------ | ---------------------------------- | ------------ |
| 1         | `mmap_setup`               | mmap gem 安装与设置                | mmap         |
| 2         | `file_backed_memory`       | 文件映射内存                       | mmap         |
| 3         | `large_file_processing`    | 大文件处理模式                     | mmap         |
| 4         | `performance_comparison`   | mmap vs File.read 性能对比         | benchmark    |
| 5         | `error_handling`           | mmap 错误处理                      | -            |

### Module 4: parallel_sample.rb (3-5 concepts)

| Concept # | Method Name              | Description (Chinese)              | External Dep |
| --------- | ------------------------ | ---------------------------------- | ------------ |
| 1         | `parallel_map_demo`        | Parallel.map 基础用法              | parallel     |
| 2         | `thread_pool_patterns`     | 线程池模式                         | -            |
| 3         | `gvl_limitations`          | GVL 限制演示                       | -            |
| 4         | `io_vs_cpu_bound`          | I/O vs CPU 密集型对比              | benchmark    |
| 5         | `error_propagation`        | 并行错误传播                       | parallel     |

### Module 5: performance_sample.rb (EXPAND - add 3-5 concepts)

| Concept # | Method Name              | Description (Chinese)              | External Dep |
| --------- | ------------------------ | ---------------------------------- | ------------ |
| +1        | `benchmark_ips_demo`       | benchmark-ips 高精度测量           | benchmark-ips |
| +2        | `memory_profiler_demo`     | 内存分配追踪                       | memory_profiler |
| +3        | `objectspace_analysis`     | ObjectSpace 深度分析               | -            |
| +4        | `gc_tuning`                | GC 调优示例                        | -            |
| +5        | `regression_detection`     | 性能回归检测                       | benchmark-ips |

### Module 6: data_processing_sample.rb (3-5 concepts)

| Concept # | Method Name              | Description (Chinese)              | External Dep |
| --------- | ------------------------ | ---------------------------------- | ------------ |
| 1         | `csv_parsing`              | CSV 解析与生成                     | stdlib CSV   |
| 2         | `json_yaml_transforms`     | JSON/YAML 转换                     | stdlib JSON/YAML |
| 3         | `text_pipelines`           | 文本管道 (grep/awk-like)           | -            |
| 4         | `one_liner_patterns`       | Ruby -e 单行模式                   | -            |
| 5         | `ruby_vs_python_bash`      | Ruby vs Python/Bash 对比           | -            |

## External Gem Dependencies

| Gem                | Minimum Version | Module Used        | Gemspec Entry                         |
| ------------------ | --------------- | ------------------ | ------------------------------------- |
| ruby-openai        | >= 6.0          | llm_sample.rb        | Optional (development/group)          |
| sys-proctable      | >= 1.0          | system_programming   | Optional (development/group)          |
| mmap               | >= 1.0          | memory_mapping       | Optional (development/group)          |
| parallel           | >= 1.22         | parallel             | Optional (development/group)          |
| benchmark-ips      | >= 2.10         | performance (expand) | Optional (development/group)          |
| memory_profiler    | >= 1.0          | performance (expand) | Optional (development/group)          |
| dotenv             | ~> 3.0          | llm_sample.rb        | Optional (API key management)         |

**Gemspec Strategy**: Add to `development_group` or document in README as "optional dependencies for advance examples". Loose version constraints (>= minimum) per clarification Q3.

## Complexity Tracking

> **No violations requiring justification.** All modules follow existing patterns without architectural changes.

| Metric                     | Value              |
| -------------------------- | ------------------ |
| New modules                | 5 (plus 1 expand)  |
| New concept methods        | ~18-30             |
| New test specs             | 5 (plus 1 expand)  |
| New doc chapters           | 5 (plus 1 expand)  |
| External gem dependencies  | 7 (optional)       |
| Infrastructure changes     | 0 (preserved)      |

## Implementation Phases

### Phase 0: Research (This Document)

**Status**: IN PROGRESS — Waiting for background research agents.

**Research Tasks**:
1. ✅ Advance module patterns (local codebase) — explored
2. ✅ Test spec patterns (local codebase) — explored
3. ⏳ ruby-openai best practices — librarian agent running
4. ⏳ Parallel gem patterns — librarian agent running
5. ⏳ mmap gem patterns — librarian agent running

### Phase 1: Design & Contracts

**Deliverables**:
- `data-model.md`: Concept method inventory with signatures
- `quickstart.md`: Implementation guide for developers
- Agent context update: Add new technologies to AGENTS.md

### Phase 2: Tasks Generation (via /speckit.tasks)

**NOT created by /speckit.plan** — Use `/speckit.tasks` command next.

## Risks & Mitigations

| Risk                              | Mitigation                                         |
| --------------------------------- | -------------------------------------------------- |
| LLM API mock complexity           | Use simple mock responses, document dotenv pattern |
| Platform-specific system behavior | Document macOS/Linux differences, skip cross-platform tests |
| mmap gem availability             | Document installation, show fallback patterns      |
| GVL misconceptions                | Clear educational examples comparing I/O vs CPU    |
| Large file test data              | Use spec/fixtures/ with small samples, document scaling |

## Success Validation

| Criterion                         | Validation Method                                  |
| --------------------------------- | -------------------------------------------------- |
| SC-001: 6 modules runnable        | `hello advance llm`, `hello advance parallel`, etc. |
| SC-002: Coverage 95%+             | Module count comparison with hello-rust            |
| SC-003: Tests passing             | `bundle exec rspec spec/advance/`                  |
| SC-004: Pattern compliance        | RuboCop + Sorbet checks                            |
| SC-005: Documentation complete    | mdBook build, character count validation           |