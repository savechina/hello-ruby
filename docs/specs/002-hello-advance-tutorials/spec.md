# Feature Specification: Hello Advance Tutorials

**Feature Branch**: `002-hello-advance-tutorials`
**Created**: 2026-04-30
**Status**: Draft
**Input**: Add 6 advance topics to hello-ruby to match hello-rust coverage depth (85% → 95%) and highlight Ruby's scripting advantages

## Clarifications

### Session 2026-04-30

- Q: How should LLM API keys/secrets be handled in examples? → A: Environment variables via dotenv (.env file pattern)
- Q: How many concept methods should each module contain? → A: 3-5 concept methods per module (balanced coverage)
- Q: What version constraints for external gems in gemspec? → A: Loose constraints (>= minimum version) for flexibility
- Q: What language for documentation chapters? → A: Chinese primary with English technical terms (per constitution)
- Q: Where should sample data files for data_processing be located? → A: spec/fixtures/ directory (RSpec convention)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ruby Learners Access Modern AI Integration Examples (Priority: P1)

Ruby learners want to understand how to integrate LLM capabilities into their applications. They need runnable examples demonstrating OpenAI/Ollama API patterns, prompt engineering, and streaming responses.

**Why this priority**: LLM integration is a critical modern skill. hello-rust has comprehensive ollama_sample.rs coverage, and Ruby developers need equivalent examples to build AI-powered applications.

**Independent Test**: Can be fully tested by running `hello advance llm` and verifying output demonstrates API client usage, prompt patterns, and response handling. Delivers AI integration capability.

**Acceptance Scenarios**:

1. **Given** learner runs `hello advance llm`, **When** module executes, **Then** examples demonstrate OpenAI client setup, prompt construction, and response parsing
2. **Given** learner runs specific llm concepts, **When** calling concept methods directly, **Then** each method returns example output with explanatory comments

---

### User Story 2 - Ruby Learners Understand System-Level Programming (Priority: P1)

Ruby learners want to understand process management, signal handling, and system information collection. They need runnable examples for DevOps/tooling applications.

**Why this priority**: System programming is essential for building CLI tools, background workers, and infrastructure automation. hello-rust has sysinfo_sample.rs and process_sample.rs coverage.

**Independent Test**: Can be fully tested by running `hello advance system_programming` and verifying examples demonstrate Process.spawn, signal handling, and system info collection.

**Acceptance Scenarios**:

1. **Given** learner runs `hello advance system_programming`, **When** module executes, **Then** examples show Process.spawn, IO.popen, Signal.trap, and Sys::ProcTable patterns
2. **Given** learner explores specific system concepts, **When** running concept methods, **Then** each demonstrates a distinct system programming capability

---

### User Story 3 - Ruby Learners Learn High-Performance File Access Patterns (Priority: P1)

Ruby learners want to understand memory-mapped file I/O for large file processing. They need runnable examples demonstrating mmap patterns and performance comparisons.

**Why this priority**: Memory mapping is critical for processing large files efficiently. hello-rust has memmap_sample.rs demonstrating zero-copy file access.

**Independent Test**: Can be fully tested by running `hello advance memory_mapping` and verifying mmap gem usage, performance benchmarks, and large file patterns.

**Acceptance Scenarios**:

1. **Given** learner runs `hello advance memory_mapping`, **When** module executes, **Then** examples demonstrate mmap gem usage, file-backed memory, and performance comparisons
2. **Given** learner runs mmap benchmarks, **When** comparing mmap vs File.read, **Then** output shows measurable performance difference for large files

---

### User Story 4 - Ruby Learners Explore Parallel Processing Patterns (Priority: P2)

Ruby learners want to understand parallel processing for CPU-bound tasks. They need runnable examples demonstrating Parallel gem usage, thread pools, and GVL limitations.

**Why this priority**: Parallel computing is important for performance optimization. hello-rust has rayon_sample.rs for data parallelism. Ruby has GVL limitations that affect parallelism strategy.

**Independent Test**: Can be fully tested by running `hello advance parallel` and verifying Parallel gem patterns, thread pool examples, and benchmark comparisons.

**Acceptance Scenarios**:

1. **Given** learner runs `hello advance parallel`, **When** module executes, **Then** examples show Parallel.map, each_with_index, and thread pool patterns
2. **Given** learner runs parallel benchmarks, **When** comparing parallel vs sequential, **Then** output demonstrates when parallelism helps (I/O-bound) vs when GVL limits gains (CPU-bound)

---

### User Story 5 - Ruby Learners Access Advanced Performance Measurement (Priority: P2)

Ruby learners want to understand advanced benchmarking beyond basic Benchmark module. They need runnable examples for benchmark-ips, memory profiling, and GC tuning.

**Why this priority**: Accurate performance measurement requires tools beyond basic Benchmark. hello-rust has comprehensive benchmarking coverage. Current performance_sample.rb covers only basic patterns.

**Independent Test**: Can be fully tested by running `hello advance performance` with expanded examples showing benchmark-ips, memory_profiler, and ObjectSpace patterns.

**Acceptance Scenarios**:

1. **Given** learner runs `hello advance performance`, **When** module executes, **Then** expanded examples demonstrate benchmark-ips, memory_profiler, and ObjectSpace analysis
2. **Given** learner runs memory profiling examples, **When** analyzing allocations, **Then** output shows memory leak detection patterns

---

### User Story 6 - Ruby Learners Master Data Processing Scripting Patterns (Priority: P2)

Ruby learners want to understand Ruby's advantages as a scripting language for data processing tasks. They need runnable examples demonstrating text processing, CSV/JSON/YAML handling, one-liner patterns, and comparison with Python/Bash approaches.

**Why this priority**: Ruby excels at data processing scripting with readable syntax, powerful Enumerable methods, and flexible text manipulation. This differentiates Ruby from Python and Bash for ad-hoc data tasks.

**Independent Test**: Can be fully tested by running `hello advance data_processing` and verifying examples demonstrate text pipelines, format conversions, one-liner patterns, and Ruby vs Python/Bash comparisons.

**Acceptance Scenarios**:

1. **Given** learner runs `hello advance data_processing`, **When** module executes, **Then** examples show CSV parsing/generation, JSON/YAML transformations, text filtering (grep-like), and field extraction (awk-like)
2. **Given** learner runs one-liner examples, **When** executing Ruby -e patterns, **Then** output demonstrates quick data transformations without full scripts
3. **Given** learner runs comparison examples, **When** comparing Ruby vs Python/Bash, **Then** output highlights Ruby's readability and flexibility advantages

---

### Edge Cases

- What happens when LLM API is unavailable or rate-limited? Module should demonstrate error handling patterns.
- How does system programming behave differently on macOS vs Linux? Platform-specific notes should be documented.
- What happens when mmap gem is not installed? Module should show installation instructions and fallback patterns.
- How does parallel module handle exceptions in worker threads? Error propagation patterns should be demonstrated.
- What happens when input file is malformed (invalid CSV/JSON)? Graceful error handling with specific parse error messages should be demonstrated.
- How do one-liner examples handle very large input streams? Streaming patterns vs in-memory loading should be documented.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide `lib/hello/advance/llm_sample.rb` module with OpenAI/Ollama integration examples using dotenv for API key management
- **FR-002**: System MUST provide `lib/hello/advance/system_programming_sample.rb` module with Process/Signal/Sys patterns
- **FR-003**: System MUST provide `lib/hello/advance/memory_mapping_sample.rb` module with mmap gem examples
- **FR-004**: System MUST provide `lib/hello/advance/parallel_sample.rb` module with Parallel gem patterns
- **FR-005**: System MUST expand `lib/hello/advance/performance_sample.rb` with benchmark-ips and memory_profiler examples
- **FR-006**: System MUST provide `lib/hello/advance/data_processing_sample.rb` module demonstrating Ruby scripting advantages for data processing (CSV, JSON, YAML, text pipelines, one-liners)
- **FR-007**: All modules MUST follow `*_sample.rb` naming convention
- **FR-008**: All modules MUST register via TopicRegistry with clean keys (e.g., "llm" not "llm_sample", "data_processing" not "data_processing_sample")
- **FR-009**: All modules MUST implement `self.run` orchestration method calling 3-5 unit-testable concept methods per module
- **FR-010**: All modules MUST have corresponding test specs in `spec/advance/`
- **FR-011**: CLI MUST support `hello advance llm`, `hello advance system_programming`, `hello advance data_processing`, etc.
- **FR-012**: Sample data files for data processing examples MUST be located in `spec/fixtures/` following RSpec conventions

### Key Entities

- **Topic Module**: Module under `Hello::Advance` with `self.run` entry point and TopicRegistry.register call
- **Concept Method**: Unit-testable method demonstrating single concept (e.g., `llm_client_setup`, `process_spawn_example`)
- **External Gem**: Optional dependency with loose version constraints (>= minimum) documented in gemspec (ruby-openai, sys-proctable, mmap, parallel, benchmark-ips, dotenv)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 6 new advance topic modules added and runnable via CLI
- **SC-002**: Coverage alignment: hello-ruby 85% → 95%+ (exceeding hello-rust depth with Ruby-specific scripting advantages)
- **SC-003**: All 6 modules have test specs passing (smoke tests: executes without error)
- **SC-004**: Each module follows established pattern from 001-hello-basic-tutorials (TopicRegistry, *_sample.rb, self.run)
- **SC-005**: Documentation chapters added for each topic in `docs/src/advance/` in Chinese (Simplified) with English technical terms, minimum 500 characters per chapter, at least 3 executable examples and 3 checkpoint questions

## Assumptions

- Learners have Ruby 3.2+ environment (rbenv managed per .ruby-version)
- External gems (ruby-openai, mmap, parallel, benchmark-ips, dotenv) are optional dependencies learners install as needed
- LLM examples demonstrate patterns using dotenv for API keys; tests use mocked responses (no live API calls)
- Platform-specific behavior (macOS vs Linux) documented but not tested across platforms
- Existing lib/hello/ infrastructure (TopicRegistry, dry-system DI, Thor CLI) preserved without modification
- Test specs are smoke tests (execute without error) following basic tier pattern
- Data processing examples use Ruby stdlib (CSV, JSON, YAML modules) without external gem dependencies
- Sample data files (CSV, JSON, YAML) stored in `spec/fixtures/` directory for test reuse
