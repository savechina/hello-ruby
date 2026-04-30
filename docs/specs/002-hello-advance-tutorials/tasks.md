# Tasks: Hello Advance Tutorials

**Input**: Design documents from `/docs/specs/002-hello-advance-tutorials/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, quickstart.md

**Tests**: REQUIRED per constitution Principle II (Test-First Development) and FR-010

**Organization**: Tasks grouped by user story for independent implementation and testing

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Parallelizable (different files, no dependencies)
- **[Story]**: User story label (US1-US6)
- Exact file paths included

## Path Conventions

- **Project**: Ruby gem at repository root
- **Source**: `lib/hello/advance/*.rb`
- **Tests**: `spec/advance/*.rb`
- **Fixtures**: `spec/fixtures/*`
- **Docs**: `docs/src/advance/*.md`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add optional gem dependencies and create test fixtures

- [ ] T001 Add optional gems to Gemfile development group (ruby-openai >= 8.0, sys-proctable >= 1.0, mmap-ruby >= 1.0, parallel >= 1.22, benchmark-ips >= 2.10, memory_profiler >= 1.0, dotenv ~> 3.0)
- [ ] T002 [P] Create spec/fixtures/sample.csv with test data (name,age,city columns)
- [ ] T003 [P] Create spec/fixtures/sample.json with test data (users array)
- [ ] T004 [P] Create spec/fixtures/sample.yaml with test data (database config)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: No changes needed - existing infrastructure preserved

**⚠️ NOTE**: TopicRegistry, Thor CLI, and dry-system DI are preserved without modification per FR-007, FR-011. No foundational tasks required.

**Checkpoint**: Foundation ready (existing) - user story implementation can begin immediately

---

## Phase 3: User Story 1 - LLM Integration (Priority: P1) 🎯 MVP

**Goal**: Ruby learners access modern AI integration examples with OpenAI/Ollama patterns

**Independent Test**: Run `bundle exec hello advance llm` and verify API client setup, prompt patterns, streaming response demonstrations

### Test for User Story 1 (Test-First)

- [ ] T005 [US1] Create smoke test spec/advance/llm_spec.rb (expect { LlmSample.run }.not_to raise_error)

### Implementation for User Story 1

- [ ] T006 [US1] Create lib/hello/advance/llm_sample.rb module with file header (typed: true, frozen_string_literal: true, require "dotenv/load")
- [ ] T007 [US1] Implement LlmSample.dotenv_setup concept method (ENV.fetch pattern, .env file demonstration)
- [ ] T008 [US1] Implement LlmSample.client_initialization concept method (OpenAI.configure, OpenAI::Client.new)
- [ ] T009 [US1] Implement LlmSample.prompt_construction concept method (message arrays, system/user roles, ERB template example)
- [ ] T010 [US1] Implement LlmSample.streaming_responses concept method (stream: proc, chunk parsing, real-time output)
- [ ] T011 [US1] Implement LlmSample.error_handling_patterns concept method (Faraday::TimeoutError, ClientError, exponential backoff)
- [ ] T012 [US1] Implement LlmSample.run orchestration method calling all concept methods with Chinese section headers
- [ ] T013 [US1] Add TopicRegistry.register("advance", "llm", "LLM 集成", LlmSample) at file end
- [ ] T014 [US1] Run bundle exec rspec spec/advance/llm_spec.rb and verify smoke test passes

**Checkpoint**: User Story 1 complete - `hello advance llm` runs and demonstrates LLM patterns

---

## Phase 4: User Story 2 - System Programming (Priority: P1)

**Goal**: Ruby learners understand system-level programming with Process.spawn, signals, process info

**Independent Test**: Run `bundle exec hello advance system_programming` and verify Process.spawn, IO.popen, Signal.trap demonstrations

### Test for User Story 2 (Test-First)

- [ ] T015 [US2] Create smoke test spec/advance/system_programming_spec.rb (expect { SystemProgrammingSample.run }.not_to raise_error)

### Implementation for User Story 2

- [ ] T016 [US2] Create lib/hello/advance/system_programming_sample.rb module with file header (typed: true, frozen_string_literal: true)
- [ ] T017 [US2] Implement SystemProgrammingSample.process_spawn_demo concept method (Process.spawn, PID tracking, wait)
- [ ] T018 [US2] Implement SystemProgrammingSample.io_popen_demo concept method (IO.popen, command execution, pipe reading)
- [ ] T019 [US2] Implement SystemProgrammingSample.signal_handling concept method (Signal.trap, SIGINT/SIGTERM handling)
- [ ] T020 [US2] Implement SystemProgrammingSample.process_info_collection concept method (Sys::ProcTable.all, process attributes)
- [ ] T021 [US2] Implement SystemProgrammingSample.environment_management concept method (ENV access, modification, process environment)
- [ ] T022 [US2] Implement SystemProgrammingSample.run orchestration method calling all concept methods
- [ ] T023 [US2] Add TopicRegistry.register("advance", "system_programming", "系统编程", SystemProgrammingSample)
- [ ] T024 [US2] Run bundle exec rspec spec/advance/system_programming_spec.rb and verify smoke test passes

**Checkpoint**: User Story 2 complete - `hello advance system_programming` runs and demonstrates system patterns

---

## Phase 5: User Story 3 - Memory Mapping (Priority: P1)

**Goal**: Ruby learners learn high-performance file access patterns with mmap

**Independent Test**: Run `bundle exec hello advance memory_mapping` and verify mmap usage and performance comparisons

### Test for User Story 3 (Test-First)

- [ ] T025 [US3] Create smoke test spec/advance/memory_mapping_spec.rb (expect { MemoryMappingSample.run }.not_to raise_error)

### Implementation for User Story 3

- [ ] T026 [US3] Create lib/hello/advance/memory_mapping_sample.rb module with file header (typed: true, frozen_string_literal: true, require "mmap-ruby")
- [ ] T027 [US3] Implement MemoryMappingSample.mmap_basic_read concept method (Mmap.new, advise, each_line, unmap)
- [ ] T028 [US3] Implement MemoryMappingSample.mmap_read_write concept method ("rw" mode, sub!, msync, munmap)
- [ ] T029 [US3] Implement MemoryMappingSample.mmap_ipc_pattern concept method (fork, shared memory IPC, 8.7x speedup demonstration)
- [ ] T030 [US3] Implement MemoryMappingSample.performance_comparison concept method (Benchmark.bm, mmap vs File.read timing)
- [ ] T031 [US3] Implement MemoryMappingSample.error_handling concept method (fixed-size map errors, cleanup patterns)
- [ ] T032 [US3] Implement MemoryMappingSample.run orchestration method calling all concept methods
- [ ] T033 [US3] Add TopicRegistry.register("advance", "memory_mapping", "内存映射", MemoryMappingSample)
- [ ] T034 [US3] Run bundle exec rspec spec/advance/memory_mapping_spec.rb and verify smoke test passes

**Checkpoint**: User Story 3 complete - `hello advance memory_mapping` runs and demonstrates mmap patterns

---

## Phase 6: User Story 4 - Parallel Processing (Priority: P2)

**Goal**: Ruby learners explore parallel processing patterns with GVL awareness

**Independent Test**: Run `bundle exec hello advance parallel` and verify Parallel.map, thread pools, GVL limitation demonstrations

### Test for User Story 4 (Test-First)

- [ ] T035 [US4] Create smoke test spec/advance/parallel_spec.rb (expect { ParallelSample.run }.not_to raise_error)

### Implementation for User Story 4

- [ ] T036 [US4] Create lib/hello/advance/parallel_sample.rb module with file header (typed: true, frozen_string_literal: true, require "parallel")
- [ ] T037 [US4] Implement ParallelSample.parallel_map_processes concept method (in_processes: N, CPU-bound tasks)
- [ ] T038 [US4] Implement ParallelSample.parallel_map_threads concept method (in_threads: N, I/O-bound tasks)
- [ ] T039 [US4] Implement ParallelSample.gvl_limitations_demo concept method (GVL explanation, Ruby vs Python threading)
- [ ] T040 [US4] Implement ParallelSample.benchmark_comparison concept method (sequential vs threads vs processes timing)
- [ ] T041 [US4] Implement ParallelSample.error_propagation concept method (exception handling in workers, rescue patterns)
- [ ] T042 [US4] Implement ParallelSample.run orchestration method calling all concept methods
- [ ] T043 [US4] Add TopicRegistry.register("advance", "parallel", "并行计算", ParallelSample)
- [ ] T044 [US4] Run bundle exec rspec spec/advance/parallel_spec.rb and verify smoke test passes

**Checkpoint**: User Story 4 complete - `hello advance parallel` runs and demonstrates GVL patterns

---

## Phase 7: User Story 5 - Advanced Performance Measurement (Priority: P2)

**Goal**: Ruby learners access advanced benchmarking beyond basic Benchmark module

**Independent Test**: Run `bundle exec hello advance performance` with expanded examples showing benchmark-ips and memory_profiler

### Test for User Story 5 (Test-First)

- [ ] T045 [US5] Verify existing spec/advance/performance_spec.rb covers expanded module (no new test needed - existing)

### Implementation for User Story 5 (Expand Existing)

- [ ] T046 [US5] Add require "benchmark-ips" and require "memory_profiler" to lib/hello/advance/performance_sample.rb
- [ ] T047 [US5] Implement PerformanceSample.benchmark_ips_demo concept method (Benchmark.ips, iterations-per-second, warmup)
- [ ] T048 [US5] Implement PerformanceSample.memory_profiler_demo concept method (MemoryProfiler.report, allocation tracking)
- [ ] T049 [US5] Implement PerformanceSample.objectspace_deep_analysis concept method (ObjectSpace.trace_object_allocations, class breakdown)
- [ ] T050 [US5] Implement PerformanceSample.gc_tuning_examples concept method (GC.configure, heap growth, tuning parameters)
- [ ] T051 [US5] Add new concept method calls to existing PerformanceSample.run method
- [ ] T052 [US5] Run bundle exec rspec spec/advance/performance_spec.rb and verify smoke test passes

**Checkpoint**: User Story 5 complete - `hello advance performance` runs with expanded benchmarking examples

---

## Phase 8: User Story 6 - Data Processing Scripting (Priority: P2)

**Goal**: Ruby learners master data processing scripting patterns demonstrating Ruby's advantages

**Independent Test**: Run `bundle exec hello advance data_processing` and verify CSV/JSON/YAML handling, one-liner patterns

### Test for User Story 6 (Test-First)

- [ ] T053 [US6] Create smoke test spec/advance/data_processing_spec.rb (expect { DataProcessingSample.run }.not_to raise_error)

### Implementation for User Story 6

- [ ] T054 [US6] Create lib/hello/advance/data_processing_sample.rb module with file header (typed: true, frozen_string_literal: true)
- [ ] T055 [US6] Implement DataProcessingSample.csv_parsing_generation concept method (CSV.read, CSV.parse, CSV.open, headers)
- [ ] T056 [US6] Implement DataProcessingSample.json_yaml_transforms concept method (JSON.parse/generate, YAML.load/dump, format conversion)
- [ ] T057 [US6] Implement DataProcessingSample.text_pipeline_patterns concept method (grep-like filter, awk-like field extraction, pipe patterns)
- [ ] T058 [US6] Implement DataProcessingSample.one_liner_patterns concept method (ruby -e examples, quick transformations)
- [ ] T059 [US6] Implement DataProcessingSample.ruby_vs_python_bash concept method (readability comparison, equivalent commands)
- [ ] T060 [US6] Implement DataProcessingSample.run orchestration method calling all concept methods
- [ ] T061 [US6] Add TopicRegistry.register("advance", "data_processing", "数据处理脚本", DataProcessingSample)
- [ ] T062 [US6] Run bundle exec rspec spec/advance/data_processing_spec.rb and verify smoke test passes

**Checkpoint**: User Story 6 complete - `hello advance data_processing` runs and demonstrates scripting advantages

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and quality gates

- [ ] T063 [P] Create docs/src/advance/llm.md Chinese documentation chapter (500+ chars, 3 examples, 3 questions)
- [ ] T064 [P] Create docs/src/advance/system-programming.md Chinese documentation chapter
- [ ] T065 [P] Create docs/src/advance/memory-mapping.md Chinese documentation chapter
- [ ] T066 [P] Create docs/src/advance/parallel.md Chinese documentation chapter
- [ ] T067 [P] Create docs/src/advance/data-processing.md Chinese documentation chapter
- [ ] T068 Run bundle exec rubocop lib/hello/advance/*.rb and verify zero offenses
- [ ] T069 Run bundle exec srb tc lib/hello/advance/*.rb and verify zero type errors
- [ ] T070 Run bundle exec rspec spec/advance/ and verify all 16 specs pass (10 existing + 6 new)
- [ ] T071 Run bundle exec hello advance and verify all modules execute without error
- [ ] T072 Update AGENTS.md Advance Tier table with 6 new modules (llm, system_programming, memory_mapping, parallel, data_processing)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - Gemfile and fixtures
- **Foundational (Phase 2)**: None - existing infrastructure preserved
- **User Stories (Phase 3-8)**: Can start immediately after Setup
  - All user stories are independent (no cross-story dependencies)
  - P1 stories (US1, US2, US3) recommended first
  - P2 stories (US4, US5, US6) can proceed after P1 or in parallel
- **Polish (Phase 9)**: Depends on all user stories complete

### User Story Dependencies

| Story  | Dependencies | Can Parallelize With |
|--------|--------------|---------------------|
| US1    | Setup only   | US2, US3, US4, US5, US6 |
| US2    | Setup only   | US1, US3, US4, US5, US6 |
| US3    | Setup only   | US1, US2, US4, US5, US6 |
| US4    | Setup only   | US1, US2, US3, US5, US6 |
| US5    | Setup only   | US1, US2, US3, US4, US6 |
| US6    | Setup only   | US1, US2, US3, US4, US5 |

### Within Each User Story

1. Test spec FIRST (must fail initially)
2. Module file creation
3. Concept methods (can parallelize if different helper files)
4. run orchestration method
5. TopicRegistry registration
6. Test verification (must pass)

---

## Parallel Opportunities

### Setup Phase Parallel
```bash
# All fixtures can be created simultaneously:
T002 (sample.csv) || T003 (sample.json) || T004 (sample.yaml)
```

### User Stories Parallel (After Setup)
```bash
# All 6 user stories can be implemented simultaneously:
US1 (llm) || US2 (system_programming) || US3 (memory_mapping) || US4 (parallel) || US5 (performance) || US6 (data_processing)
```

### Documentation Parallel
```bash
# All 5 documentation chapters can be written simultaneously:
T063 (llm.md) || T064 (system-programming.md) || T065 (memory-mapping.md) || T066 (parallel.md) || T067 (data-processing.md)
```

---

## Implementation Strategy

### MVP First (P1 Stories)

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 3: User Story 1 - LLM (T005-T014)
3. **STOP and VALIDATE**: Run `hello advance llm`
4. Complete Phase 4: User Story 2 - System Programming (T015-T024)
5. Complete Phase 5: User Story 3 - Memory Mapping (T025-T034)
6. **VALIDATE**: All P1 stories work independently

### Incremental Delivery

1. Setup → Fixtures and gems ready
2. US1 → `hello advance llm` → Deploy/Demo
3. US2 → `hello advance system_programming` → Deploy/Demo
4. US3 → `hello advance memory_mapping` → Deploy/Demo
5. US4 → `hello advance parallel` → Deploy/Demo
6. US5 → `hello advance performance` (expanded) → Deploy/Demo
7. US6 → `hello advance data_processing` → Deploy/Demo
8. Polish → Documentation and quality gates

---

## Summary

| Metric                    | Count |
|---------------------------|-------|
| **Total Tasks**           | 72    |
| **Setup Tasks**           | 4     |
| **Foundational Tasks**    | 0 (preserved) |
| **US1 Tasks**             | 10    |
| **US2 Tasks**             | 10    |
| **US3 Tasks**             | 10    |
| **US4 Tasks**             | 10    |
| **US5 Tasks**             | 8     |
| **US6 Tasks**             | 10    |
| **Polish Tasks**          | 10    |
| **Parallel Opportunities**| 17 tasks marked [P] |
| **Test Tasks**            | 6 (test-first per constitution) |

**MVP Scope**: Phase 1-3 (Setup + US1 LLM Integration) = 14 tasks

---

## Notes

- All modules follow `*_sample.rb` naming (FR-007)
- All modules register with clean keys (FR-008)
- All modules have 3-5 concept methods (FR-009)
- All test specs are smoke tests (FR-010, constitution Principle II)
- Existing infrastructure preserved - no TopicRegistry/CLI changes
- Manual commit required per constitution (no auto-commits)