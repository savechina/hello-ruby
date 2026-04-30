# Data Model — Hello Advance Tutorials

**Feature**: 002-hello-advance-tutorials
**Date**: 2026-04-30

---

## Module Inventory

### 1. LlmSample

| Concept # | Method Name                | Description (Chinese)              | External Dep        | Signature                         |
| --------- | --------------------------- | ---------------------------------- | ------------------- | --------------------------------- |
| 1         | `dotenv_setup`               | API 密钥管理 (dotenv)              | dotenv              | `def self.dotenv_setup`             |
| 2         | `client_initialization`      | OpenAI 客户端设置                  | ruby-openai         | `def self.client_initialization`    |
| 3         | `prompt_construction`        | 提示词工程模式                     | -                   | `def self.prompt_construction`      |
| 4         | `streaming_responses`        | 流式响应处理                       | ruby-openai         | `def self.streaming_responses`      |
| 5         | `error_handling_patterns`    | API 错误处理                       | -                   | `def self.error_handling_patterns`  |

**TopicRegistry Key**: `"llm"`
**Chinese Description**: `"LLM 集成"`

---

### 2. SystemProgrammingSample

| Concept # | Method Name                | Description (Chinese)              | External Dep        | Signature                         |
| --------- | --------------------------- | ---------------------------------- | ------------------- | --------------------------------- |
| 1         | `process_spawn_demo`         | 进程创建 (Process.spawn)           | -                   | `def self.process_spawn_demo`       |
| 2         | `io_popen_demo`              | 管道通信 (IO.popen)                 | -                   | `def self.io_popen_demo`            |
| 3         | `signal_handling`            | 信号处理 (Signal.trap)              | -                   | `def self.signal_handling`          |
| 4         | `process_info_collection`    | 进程信息 (Sys::ProcTable)          | sys-proctable       | `def self.process_info_collection`  |
| 5         | `environment_management`     | 环境变量管理                       | -                   | `def self.environment_management`   |

**TopicRegistry Key**: `"system_programming"`
**Chinese Description**: `"系统编程"`

---

### 3. MemoryMappingSample

| Concept # | Method Name                | Description (Chinese)              | External Dep        | Signature                         |
| --------- | --------------------------- | ---------------------------------- | ------------------- | --------------------------------- |
| 1         | `mmap_basic_read`            | mmap 基础读取                      | mmap-ruby           | `def self.mmap_basic_read`          |
| 2         | `mmap_read_write`            | 文件读写映射                       | mmap-ruby           | `def self.mmap_read_write`          |
| 3         | `mmap_ipc_pattern`           | 进程间通信                         | mmap-ruby           | `def self.mmap_ipc_pattern`         |
| 4         | `performance_comparison`     | 性能对比 (vs File.read)            | benchmark           | `def self.performance_comparison`   |
| 5         | `error_handling`             | mmap 错误处理                      | -                   | `def self.error_handling`           |

**TopicRegistry Key**: `"memory_mapping"`
**Chinese Description**: `"内存映射"`

---

### 4. ParallelSample

| Concept # | Method Name                | Description (Chinese)              | External Dep        | Signature                         |
| --------- | --------------------------- | ---------------------------------- | ------------------- | --------------------------------- |
| 1         | `parallel_map_processes`     | 进程并行 (CPU密集型)               | parallel            | `def self.parallel_map_processes`   |
| 2         | `parallel_map_threads`       | 线程并行 (I/O密集型)               | parallel            | `def self.parallel_map_threads`     |
| 3         | `gvl_limitations_demo`       | GVL 限制演示                       | -                   | `def self.gvl_limitations_demo`     |
| 4         | `benchmark_comparison`       | 性能对比测试                       | benchmark           | `def self.benchmark_comparison`     |
| 5         | `error_propagation`          | 并行错误传播                       | parallel            | `def self.error_propagation`        |

**TopicRegistry Key**: `"parallel"`
**Chinese Description**: `"并行计算"`

---

### 5. PerformanceSample (EXPAND)

| Concept # | Method Name                | Description (Chinese)              | External Dep        | Signature                         |
| --------- | --------------------------- | ---------------------------------- | ------------------- | --------------------------------- |
| +1        | `benchmark_ips_demo`         | benchmark-ips 高精度测量           | benchmark-ips       | `def self.benchmark_ips_demo`       |
| +2        | `memory_profiler_demo`       | 内存分配追踪                       | memory_profiler     | `def self.memory_profiler_demo`     |
| +3        | `objectspace_deep_analysis`  | ObjectSpace 深度分析               | -                   | `def self.objectspace_deep_analysis`|
| +4        | `gc_tuning_examples`         | GC 调优示例                        | -                   | `def self.gc_tuning_examples`       |

**TopicRegistry Key**: `"performance"` (existing)
**Chinese Description**: `"性能优化"` (existing)

---

### 6. DataProcessingSample

| Concept # | Method Name                | Description (Chinese)              | External Dep        | Signature                         |
| --------- | --------------------------- | ---------------------------------- | ------------------- | --------------------------------- |
| 1         | `csv_parsing_generation`     | CSV 解析与生成                     | stdlib CSV          | `def self.csv_parsing_generation`   |
| 2         | `json_yaml_transforms`       | JSON/YAML 转换                     | stdlib JSON/YAML    | `def self.json_yaml_transforms`     |
| 3         | `text_pipeline_patterns`     | 文本管道 (grep/awk-like)           | -                   | `def self.text_pipeline_patterns`   |
| 4         | `one_liner_patterns`         | Ruby -e 单行模式                   | -                   | `def self.one_liner_patterns`       |
| 5         | `ruby_vs_python_bash`        | Ruby vs Python/Bash对比            | -                   | `def self.ruby_vs_python_bash`      |

**TopicRegistry Key**: `"data_processing"`
**Chinese Description**: `"数据处理脚本"`

---

## Test Spec Entities

### Test File Structure

| Test File                         | Module Tested                     | Pattern                              |
| ---------------------------------- | ---------------------------------- | ------------------------------------ |
| `spec/advance/llm_spec.rb`           | `Hello::Advance::LlmSample`          | Smoke test                           |
| `spec/advance/system_programming_spec.rb` | `Hello::Advance::SystemProgrammingSample` | Smoke test               |
| `spec/advance/memory_mapping_spec.rb`   | `Hello::Advance::MemoryMappingSample`   | Smoke test                           |
| `spec/advance/parallel_spec.rb`         | `Hello::Advance::ParallelSample`       | Smoke test                           |
| `spec/advance/performance_spec.rb`      | `Hello::Advance::PerformanceSample`    | (expand existing)                    |
| `spec/advance/data_processing_spec.rb`  | `Hello::Advance::DataProcessingSample` | Smoke test                           |

### Test Fixture Files

| Fixture File                    | Content Type    | Usage                              |
| -------------------------------- | --------------- | ---------------------------------- |
| `spec/fixtures/sample.csv`        | CSV data        | DataProcessingSample parsing demo  |
| `spec/fixtures/sample.json`       | JSON data       | DataProcessingSample transform demo |
| `spec/fixtures/sample.yaml`       | YAML data       | DataProcessingSample config demo   |

---

## Documentation Entities

### Chapter Files

| Chapter File                         | Chinese Title    | Examples | Questions |
| ------------------------------------- | ---------------- | -------- | --------- |
| `docs/src/advance/llm.md`              | LLM 集成          | 3+       | 3+        |
| `docs/src/advance/system-programming.md` | 系统编程          | 3+       | 3+        |
| `docs/src/advance/memory-mapping.md`    | 内存映射          | 3+       | 3+        |
| `docs/src/advance/parallel.md`          | 并行计算          | 3+       | 3+        |
| `docs/src/advance/data-processing.md`   | 数据处理脚本      | 3+       | 3+        |

---

## Relationships

```
Module → Test Spec (1:1)
  - Each module has exactly one smoke test spec

Module → Documentation Chapter (1:1)
  - Each module has exactly one Chinese documentation chapter

Module → TopicRegistry (N:1)
  - All modules register to single TopicRegistry instance

Module → External Gems (N:M)
  - LlmSample: ruby-openai, dotenv
  - SystemProgrammingSample: sys-proctable
  - MemoryMappingSample: mmap-ruby
  - ParallelSample: parallel
  - PerformanceSample (expand): benchmark-ips, memory_profiler
  - DataProcessingSample: stdlib only

Fixture Files → DataProcessingSample (3:1)
  - CSV, JSON, YAML fixtures used by data processing examples
```

---

## Validation Rules

1. **Module Naming**: MUST follow `*_sample.rb` pattern
2. **Class Naming**: MUST be `Hello::Advance::{CamelCase}Sample`
3. **Registry Key**: MUST NOT include `_sample` suffix
4. **Chinese Description**: MUST be provided for TopicRegistry
5. **Concept Methods**: MUST be 3-5 per module
6. **Test Pattern**: MUST use smoke test `expect { run }.not_to raise_error`
7. **Documentation**: MUST be Chinese primary, minimum 500 characters