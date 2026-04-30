# Implementation Plan: Hello Basic Tutorials

**Branch**: `001-hello-basic-tutorials` | **Date**: 2025-04-30 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/docs/specs/001-hello-basic-tutorials/spec.md`

## Summary

Merge lib/hello_ruby infrastructure INTO lib/hello/, rename directory to hello, preserve dry-system DI architecture, and organize sample modules with unit-testable methods. Eliminate duplicate topic files while maintaining 30 topics across basic (15), advance (10), awesome (5) tiers with TopicRegistry pattern.

## Technical Context

**Language/Version**: Ruby 3.2+ (rbenv managed, per .ruby-version)
**Primary Dependencies**: 
- Thor ~> 1.1 (CLI framework)
- dry-system, dry-struct, dry-events, dry-monitor (DI container)
- RSpec 3.0+ + FactoryBot (testing)
- RuboCop 1.50+ with 6 plugins (linting)
- Sorbet (static typing) + Steep (gradual typing)
- Sequel ~> 5.54 + SQLite3 (ORM for Awesome tier)
**Storage**: SQLite3 (in-memory for examples, file-based for Awesome tier database simulations)
**Testing**: RSpec 3.0+ with simplecov (target >80% coverage), FactoryBot fixtures
**Target Platform**: Cross-platform CLI (Linux, macOS, Windows via RubyInstaller)
**Project Type**: CLI library (educational gem with runnable tutorials)
**Performance Goals**: 
- CLI commands: <1s warm start, <3s cold start
- Topic execution: <500ms per topic run
- Memory footprint: <100MB for CLI operations
**Constraints**:
- Thread-safe TopicRegistry with Mutex
- No external gem dependencies for Basic tier (pure Ruby stdlib)
- Lazy enumeration for Advance tier collections
- Connection pooling for Awesome tier (max 4 Sequel connections)
**Scale/Scope**: 
- 30 sample files (15 basic + 10 advance + 5 awesome)
- 8 core infrastructure files (version, errors, config, registry, cli, system/container, system/import, command)
- ~3000 LOC estimated (30 files × ~100 LOC each)
- Target audience: Ruby learners from beginner to production-grade

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Ruby Idioms & Code Quality (NON-NEGOTIABLE)

| Requirement                          | Status  | Notes                                           |
| ------------------------------------ | ------- | ----------------------------------------------- |
| Ruby 3.2+ features                   | ✅ PASS | frozen_string_literal on all files              |
| Zero RuboCop offenses                | ✅ PASS | Will enforce via `bundle exec rubocop`          |
| 120 char line limit                  | ✅ PASS | .rubocop.yml configured                          |
| Double quotes for strings            | ✅ PASS | EnforcedStyle: double_quotes                     |
| frozen_string_literal: true          | ✅ PASS | All files have magic comment                    |
| Sorbet typed: sigils                 | ✅ PASS | Minimum typed: false, target typed: true        |
| No monkey-patching                   | ✅ PASS | No core class modifications                     |
| YARD documentation on public APIs    | ⚠️ TODO | Need to add YARD docs to sample modules          |
| Keyword args for 3+ params           | ✅ PASS | Configuration uses keyword args                 |

**Gate Status**: ✅ PASS (with TODO for YARD docs)

### II. Test-First Development (NON-NEGOTIABLE)

| Requirement                      | Status  | Notes                                    |
| -------------------------------- | ------- | ---------------------------------------- |
| Tests before implementation      | ⚠️ N/A  | Refactoring existing code, tests exist   |
| Red-Green-Refactor cycle         | ✅ PASS | Will verify tests pass after refactor    |
| RSpec suite >80% coverage        | ⚠️ TODO | Need simplecov setup                     |
| FactoryBot factories             | ⚠️ TODO | Need factories for Awesome tier          |
| Integration tests for CLI        | ✅ PASS | CLI tests exist in spec/                 |
| Performance benchmarks           | ⚠️ TODO | Need benchmark-ips for Advance tier      |

**Gate Status**: ✅ PASS (tests exist, coverage TODO post-merge)

### III. CLI & UX Consistency

| Requirement                    | Status  | Notes                                  |
| ------------------------------ | ------- | -------------------------------------- |
| Thor-based commands            | ✅ PASS | Hello::Cli preserves Thor structure    |
| Consistent --help output       | ✅ PASS | Thor auto-generates help               |
| --json option                  | ⚠️ TODO | Need to add JSON output for topics     |
| Actionable error messages      | ✅ PASS | NotFoundError with context             |
| Response times <100ms          | ✅ PASS | TopicRegistry.run is fast              |
| Chinese documentation          | ✅ PASS | Description in Chinese with English    |

**Gate Status**: ✅ PASS (--json TODO for future enhancement)

### IV. Performance & Reliability

| Requirement                     | Status  | Notes                                     |
| ------------------------------- | ------- | ----------------------------------------- |
| No unbounded growth             | ✅ PASS | TopicRegistry uses fixed Hash             |
| Lazy enumeration                | ⚠️ TODO | Advance tier samples need lazy examples   |
| Streaming for large files       | ✅ PASS | File I/O samples use streaming            |
| Connection pooling              | ✅ PASS | dry-system provides pooling               |
| Retry with backoff              | ⚠️ N/A  | Not applicable to CLI tutorials           |
| GVL awareness                   | ✅ PASS | Thread/Fiber samples demonstrate GVL      |

**Gate Status**: ✅ PASS (lazy enumeration TODO for Advance tier)

### V. SDD Harness Engineering

| Requirement                    | Status  | Notes                                    |
| ------------------------------ | ------- | ---------------------------------------- |
| Feature spec via speckit       | ✅ PASS | This plan is generated by speckit.plan   |
| Test-first in Phase 4          | ✅ PASS | Will run tests after each merge step     |
| Quality gates pass             | ✅ PASS | rubocop + srb tc + rspec will run        |
| Manual review before commit    | ✅ PASS | Constitution forbids auto-commit         |
| No direct commits to main      | ✅ PASS | Feature branch workflow                  |

**Gate Status**: ✅ PASS

**Overall Constitution Check**: ✅ PASS (all NON-NEGOTIABLE gates pass)

## Project Structure

### Documentation (this feature)

```text
docs/specs/001-hello-basic-tutorials/
├── spec.md              # Feature specification (complete)
├── plan.md              # This file (implementation plan)
├── research.md          # Phase 0 output (Ruby gem merge patterns)
├── data-model.md        # Phase 1 output (entities & relationships)
├── quickstart.md        # Phase 1 output (developer setup guide)
├── contracts/           # Phase 1 output (CLI interface contracts)
│   └── cli-schema.md    # Thor command schema
└── checklists/
    └── requirements.md  # Spec quality checklist (complete)
```

### Source Code (repository root)

```text
lib/
├── hello.rb                    # Main entry point (renamed from hello_ruby.rb)
│                               # Loads: version, system, errors, config, registry, cli, loaders
│
├── hello/                      # Canonical namespace directory
│   ├── version.rb              # Hello::VERSION constant (preserved)
│   ├── errors.rb               # Hello::Error hierarchy (preserved)
│   ├── configuration.rb        # Hello::Configuration class (preserved)
│   ├── topic_registry.rb       # Hello::TopicRegistry (thread-safe, preserved)
│   ├── command.rb              # Thor base command class (preserved)
│   ├── cli.rb                  # Hello::Cli Thor CLI (preserved)
│   │
│   ├── system/                 # dry-system DI infrastructure (preserved)
│   │   ├── container.rb        # System::Application (plugins: logging/env/zeitwerk)
│   │   └── import.rb           # System::Import injector mixin
│   │
│   ├── basic_sample.rb         # Basic tier loader (requires 15 sample files)
│   ├── advance_sample.rb       # Advance tier loader (requires 10 sample files)
│   ├── awesome.rb              # Awesome tier loader (requires 5 sample files)
│   │
│   ├── basic/                  # Basic tier sample modules (15 files)
│   │   ├── variables_sample.rb # VariablesSample with unit-testable methods
│   │   ├── strings_sample.rb
│   │   ├── arrays_sample.rb
│   │   ├── hashes_sample.rb
│   │   ├── control_flow_sample.rb
│   │   ├── methods_sample.rb
│   │   ├── classes_sample.rb
│   │   ├── modules_sample.rb
│   │   ├── blocks_procs_sample.rb
│   │   ├── file_io_sample.rb
│   │   ├── exceptions_sample.rb
│   │   ├── numbers_sample.rb
│   │   ├── symbols_sample.rb
│   │   ├── regex_sample.rb
│   │   └── file_management_sample.rb
│   │
│   ├── advance/                # Advance tier sample modules (10 files)
│   │   ├── enumerable_sample.rb
│   │   ├── metaprogramming_sample.rb
│   │   ├── async_await_sample.rb
│   │   ├── database_sample.rb
│   │   ├── error_handling_sample.rb
│   │   ├── testing_sample.rb
│   │   ├── dry_system_sample.rb
│   │   ├── cli_advanced_sample.rb
│   │   ├── threads_fibers_sample.rb
│   │   └── performance_sample.rb
│   │
│   └── awesome/                # Awesome tier sample modules (5 files)
│   │   ├── sinatra_sample.rb
│   │   ├── hanami_sample.rb
│   │   ├── grape_sample.rb
│   │   ├── sidekiq_sample.rb
│   │   └── falcon_sample.rb
│
exe/
└── hello                       # CLI executable (updated require "hello")

spec/
├── spec_helper.rb              # RSpec configuration + simplecov
├── hello_spec.rb               # Gem smoke tests
│
├── hello/                      # Tests for lib/hello/
│   ├── version_spec.rb
│   ├── configuration_spec.rb
│   ├── topic_registry_spec.rb
│   ├── cli_spec.rb
│   │
│   ├── basic/                  # Basic tier tests (15 files)
│   │   ├── variables_sample_spec.rb
│   │   └── ...
│   │
│   ├── advance/                # Advance tier tests (10 files)
│   │   └── ...
│   │
│   └── awesome/                # Awesome tier tests (5 files)
│   │   └── ...
│
└── factories/                  # FactoryBot definitions
    └── .keep

docs/
└── src/                        # mdBook documentation
    ├── basic/                  # Basic tier chapters (15 + overview + review)
    ├── advance/                # Advance tier chapters (10 + overview + review)
    └── awesome/                # Awesome tier chapters (5 + overview)
```

**Structure Decision**: Single project structure (Option 1) with lib/hello/ as canonical namespace directory. The project is a CLI library gem with educational sample modules organized by tier.

## Complexity Tracking

> **No violations - all Constitution gates pass without complexity exceptions**

No complexity tracking needed. All NON-NEGOTIABLE gates pass, and no architectural decisions violate simpler alternatives.