# Future Enhancements — Hello Ruby Advance Coverage Expansion

**Feature**: 001-hello-basic-tutorials (Post-Implementation Analysis)
**Generated**: 2026-04-30
**Source**: Cross-project coverage analysis (hello-ruby vs hello-rust vs hello-python)
**Context**: Analysis conducted after refactoring completion to identify coverage gaps

---

## P1: HIGH Priority — Advance Coverage Expansion

### 1. LLM Integration Sample

**What**: Add `lib/hello/advance/llm_sample.rb` demonstrating Ruby LLM integration patterns.

**Why**: hello-rust has `ollama_sample.rs` covering modern AI workflows. Ruby developers need equivalent examples for building AI-powered applications.

**Pros**: Enables Ruby developers to integrate LLM capabilities; matches hello-rust coverage; demonstrates HTTP client patterns with OpenAI/Ollama APIs.

**Cons**: Requires external gem dependency (ruby-openai or HTTP client); LLM responses are non-deterministic making tests harder.

**Context**: hello-rust covers Ollama integration with async patterns. Ruby equivalent should show:
- OpenAI API client usage (ruby-openai gem)
- Ollama local LLM integration
- Prompt engineering patterns
- Response parsing and error handling
- Streaming vs non-streaming responses

**Effort**: M (human: 1 day / CC: ~15 min)
**Priority**: P1
**Depends on**: None
**Blocked by**: None

---

### 2. System Programming Sample

**What**: Add `lib/hello/advance/system_programming_sample.rb` demonstrating Ruby process management and system info collection.

**Why**: hello-rust has `sysinfo_sample.rs` and `process_sample.rs`. Ruby has equivalent capabilities via stdlib (`Process`, `IO.popen`, `sys-proctable` gem) but no tutorial coverage.

**Pros**: Completes system-level programming coverage; useful for DevOps/tooling applications; matches hello-rust depth.

**Cons**: Platform-specific behavior (Linux vs macOS vs Windows); some features require external gems.

**Context**: Coverage gap identified in cross-project analysis. Topics to include:
- Process spawning (`Process.spawn`, `IO.popen`, `system`)
- Child process management (PID tracking, signals)
- System info collection (`Sys::ProcTable` gem, `Etc` module)
- Environment variables and process configuration
- Signal handling (`Signal.trap`)
- Process monitoring and control

**Effort**: S (human: 4 hours / CC: ~10 min)
**Priority**: P1
**Depends on**: None
**Blocked by**: None

---

### 3. Memory Mapping Sample

**What**: Add `lib/hello/advance/memory_mapping_sample.rb` demonstrating Ruby's mmap capabilities for file-based memory operations.

**Why**: hello-rust has `memmap_sample.rs`. Ruby has `mmap` gem and `IO#mmap` patterns for high-performance file access, but no tutorial coverage.

**Pros**: Performance optimization patterns; useful for large file processing; matches hello-rust system programming depth.

**Cons**: Platform-dependent mmap behavior; requires external `mmap` gem; error handling complex.

**Context**: hello-rust demonstrates zero-copy file access with memmap2 crate. Ruby equivalent:
- `mmap` gem usage for file-backed memory
- Large file processing without loading entire content
- Memory-mapped IPC patterns
- Performance comparison (mmap vs File.read)

**Effort**: S (human: 4 hours / CC: ~10 min)
**Priority**: P1
**Depends on**: None
**Blocked by**: None

---

## P2: MEDIUM Priority — Advance Coverage Expansion

### 4. Parallel Computing Sample

**What**: Add `lib/hello/advance/parallel_sample.rb` demonstrating Ruby parallel processing patterns.

**Why**: hello-rust has `rayon_sample.rs` for data parallelism. Ruby has `Parallel` gem and thread-based parallelism, but no focused tutorial.

**Pros**: Performance patterns for CPU-bound tasks; matches hello-rust rayon coverage; demonstrates thread pool patterns.

**Cons**: Ruby GVL limits true parallelism; may overlap with existing threads_fibers_sample.rb.

**Context**: Topics to include:
- `Parallel` gem usage (map, each, each_with_index)
- Thread pool patterns
- Work distribution strategies
- GVL limitations and when parallelism helps
- Benchmark comparison (parallel vs sequential)

**Effort**: S (human: 4 hours / CC: ~10 min)
**Priority**: P2
**Depends on**: threads_fibers_sample.rb (existing)
**Blocked by**: None

---

### 5. Advanced Benchmarking Sample

**What**: Expand `lib/hello/advance/performance_sample.rb` to include `benchmark-ips` and memory profiling patterns.

**Why**: hello-rust has comprehensive benchmarking coverage. Ruby has `benchmark-ips` gem and `memory_profiler` gem but current performance_sample.rb only covers basic Benchmark module.

**Pros**: More accurate performance measurement; memory leak detection patterns; matches hello-rust depth.

**Cons**: Requires additional gems; current performance_sample.rb exists (expand rather than new file).

**Context**: Expansion topics:
- `benchmark-ips` for iterations-per-second benchmarks
- `memory_profiler` gem for memory allocation tracking
- `ObjectSpace` memory analysis patterns
- GC tuning examples
- Performance regression detection patterns

**Effort**: XS (human: 2 hours / CC: ~5 min) — expansion of existing file
**Priority**: P2
**Depends on**: performance_sample.rb (existing)
**Blocked by**: None

---

## Summary

| # | Topic | Priority | Effort | Status |
|---|-------|----------|--------|--------|
| 1 | LLM Integration | P1 | M | TODO |
| 2 | System Programming | P1 | S | TODO |
| 3 | Memory Mapping | P1 | S | TODO |
| 4 | Parallel Computing | P2 | S | TODO |
| 5 | Advanced Benchmarking | P2 | XS | TODO |

**Total estimated effort**: M+S+S+S+XS = ~2.5 days (human) / ~45 min (CC)

---

## Notes

- These enhancements result from cross-project coverage analysis comparing hello-ruby with hello-rust and hello-python
- hello-ruby currently has 85% coverage vs hello-rust's 95% after 001-hello-basic-tutorials refactoring
- Adding these 5 topics would bring hello-ruby to ~95% coverage alignment
- All topics follow existing `*_sample.rb` naming convention and TopicRegistry pattern established in 001-hello-basic-tutorials
- Recommend creating new feature branch `002-advance-coverage-expansion` for implementation
- Spec reference: [spec.md](./spec.md) — Post-Implementation Enhancements section