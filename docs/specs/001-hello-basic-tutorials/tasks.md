# Tasks: Hello Basic Tutorials

**Input**: Design documents from `/docs/specs/001-hello-basic-tutorials/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/cli-schema.md, quickstart.md

**Tests**: This is a refactoring task. Tests exist and should be verified after each phase.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- **Ruby gem**: `lib/` at repository root
- **Entry point**: `exe/hello`
- **Tests**: `spec/`
- **Docs**: `docs/src/`

---

## Phase 1: Setup (Backup & Preparation)

**Purpose**: Prepare for safe refactoring with rollback capability

- [ ] T001 Verify current git state is clean (no uncommitted changes)
- [ ] T002 Create backup branch: `git branch backup-pre-merge`
- [ ] T003 Document current file count: `find lib/hello lib/hello_ruby -name "*.rb" | wc -l`
- [ ] T004 Run baseline tests: `bundle exec rspec --format documentation`
- [ ] T005 Run baseline lint: `bundle exec rubocop`
- [ ] T006 Capture current TopicRegistry state: run `hello basic variables` to verify working

---

## Phase 2: Foundational (Infrastructure Migration)

**Purpose**: Move lib/hello_ruby infrastructure INTO lib/hello/ - MUST complete before user stories

**⚠️ CRITICAL**: All infrastructure files must be in lib/hello/ before sample file consolidation

### Infrastructure Files (Preserve without modification)

- [ ] T007 [P] Copy lib/hello_ruby/version.rb to lib/hello/version.rb
- [ ] T008 [P] Copy lib/hello_ruby/errors.rb to lib/hello/errors.rb
- [ ] T009 [P] Copy lib/hello_ruby/configuration.rb to lib/hello/configuration.rb
- [ ] T010 [P] Copy lib/hello_ruby/topic_registry.rb to lib/hello/topic_registry.rb
- [ ] T011 [P] Copy lib/hello_ruby/command.rb to lib/hello/command.rb
- [ ] T012 [P] Copy lib/hello_ruby/cli.rb to lib/hello/cli.rb
- [ ] T013 Copy lib/hello_ruby/system/ directory to lib/hello/system/ (container.rb, import.rb)

### Entry Point Rename

- [ ] T014 Create lib/hello.rb entry point (rename from lib/hello_ruby.rb)
  - Update require paths: `require_relative "hello/version"` (not hello_ruby/version)
  - Update ROOT constant reference
  - Maintain require order: version, system, errors, configuration, topic_registry, command, cli, tier loaders

### Container Path Update (dry-system)

- [ ] T015 Update lib/hello/system/container.rb component registration paths
  - Change: `hello_ruby.commands.*` → `hello.commands.*`
  - Change: `hello_ruby.components.*` → `hello.components.*`
  - Update config.root to use Hello::ROOT

### Executable Update

- [ ] T016 Update exe/hello to require "hello" (not "hello_ruby")

### Loader File Migration

- [ ] T017 Copy lib/hello_ruby/basic_sample.rb to lib/hello/basic_sample.rb
  - Update require_relative paths: `"basic/variables_sample"` (remove ../hello/)
- [ ] T018 Create lib/hello/advance_sample.rb (new file)
  - Require all 10 advance sample files: enumerable_sample, metaprogramming_sample, etc.
- [ ] T019 Update lib/hello_ruby/awesome.rb to lib/hello/awesome.rb
  - Update require_relative paths: `"awesome/sinatra_sample"` (remove ../hello/)

### Verify Infrastructure

- [ ] T020 Run `bundle exec hello version` to verify entry point works
- [ ] T021 Run `bundle exec rubocop lib/hello.rb lib/hello/system/container.rb`

**Checkpoint**: lib/hello.rb entry point works, infrastructure files in lib/hello/

---

## Phase 3: User Story 1 - Clear Project Structure (Priority: P1) 🎯 MVP

**Goal**: Eliminate duplicate topic files, each tier has single directory for sample files

**Independent Test**: Verify no duplicate topic files exist - `find lib/hello lib/hello_ruby -name "*sample.rb"` should return only lib/hello/* paths

### Remove Duplicate Files

- [ ] T022 [US1] Remove lib/hello_ruby/basic/ directory (15 puts-based files without _sample suffix)
- [ ] T023 [US1] Remove lib/hello_ruby/advance/ directory (10 puts-based files without _sample suffix)
- [ ] T024 [US1] Remove lib/hello_ruby.rb (old entry point, replaced by lib/hello.rb)
- [ ] T025 [US1] Remove lib/hello_ruby/basic_sample.rb (moved to lib/hello/basic_sample.rb)
- [ ] T026 [US1] Remove lib/hello_ruby/awesome.rb (moved to lib/hello/awesome.rb)
- [ ] T027 [US1] Remove lib/hello_ruby/basic.rb (loader for old puts-based files)
- [ ] T028 [US1] Remove lib/hello_ruby/advance.rb (loader for old puts-based files)
- [ ] T029 [US1] Remove lib/hello_ruby/system.rb (old system loader)
- [ ] T030 [US1] Remove empty lib/hello_ruby/ directory if exists

### Verify Structure

- [ ] T031 [US1] Verify file count: `find lib/hello -name "*_sample.rb" | wc -l` should be 30
- [ ] T032 [US1] Verify no duplicates: `find lib/hello_ruby -name "*.rb"` should return nothing
- [ ] T033 [US1] List lib/hello/ structure: confirm basic/, advance/, awesome/ subdirectories exist

**Checkpoint**: lib/hello_ruby/ directory removed, all sample files only in lib/hello/

---

## Phase 4: User Story 2 - Real Runnable Sample Code (Priority: P1)

**Goal**: All 30 sample files contain real executable Ruby code (not puts-based code strings)

**Independent Test**: Run each topic via CLI and verify actual Ruby operations occur

### Verify Sample Files (Already Exist in lib/hello/)

- [ ] T034 [P] [US2] Run `bundle exec hello basic variables` - verify real variable binding operations
- [ ] T035 [P] [US2] Run `bundle exec hello basic strings` - verify actual string methods
- [ ] T036 [P] [US2] Run `bundle exec hello basic arrays` - verify real array operations
- [ ] T037 [P] [US2] Run `bundle exec hello advance metaprogramming` - verify define_method, method_missing
- [ ] T038 [P] [US2] Run `bundle exec hello advance database` - verify in-memory ORM simulation
- [ ] T039 [P] [US2] Run `bundle exec hello awesome sinatra` - verify REST API simulation

### Verify TopicRegistry Keys (Clean without _sample suffix)

- [ ] T040 [US2] Check TopicRegistry.register calls in lib/hello/basic/variables_sample.rb
  - Should use: `register("basic", "variables", ...)` (not "variables_sample")
- [ ] T041 [US2] Verify CLI command works: `hello basic variables` (clean key)

### Verify All Topics Registered

- [ ] T042 [US2] Run `bundle exec hello basic` - verify all 15 topics execute
- [ ] T043 [US2] Run `bundle exec hello advance` - verify all 10 topics execute
- [ ] T044 [US2] Run `bundle exec hello awesome` - verify all 5 topics execute

**Checkpoint**: All 30 topics execute successfully with real Ruby code

---

## Phase 5: User Story 3 - CLI Functionality Preservation (Priority: P2)

**Goal**: CLI commands continue working after refactoring

**Independent Test**: Run all CLI subcommands and verify successful execution

### Verify Thor CLI Commands

- [ ] T045 [P] [US3] Test `bundle exec hello hello Ruby` - greeting command
- [ ] T046 [P] [US3] Test `bundle exec hello version` - version display
- [ ] T047 [P] [US3] Test `bundle exec hello play basic variables --detail` - detail option
- [ ] T048 [P] [US3] Test `bundle exec hello basic` - shortcut command (run all)
- [ ] T049 [P] [US3] Test `bundle exec hello advance metaprogramming` - shortcut command
- [ ] T050 [P] [US3] Test `bundle exec hello awesome sinatra` - shortcut command

### Verify CLI Error Handling

- [ ] T051 [US3] Test `bundle exec hello basic nonexistent` - should show NotFoundError with available topics
- [ ] T052 [US3] Test `bundle exec hello play invalid variables` - should show Invalid tier error

### Verify Thor Auto-generated Help

- [ ] T053 [US3] Test `bundle exec hello help` - verify all commands listed
- [ ] T054 [US3] Test `bundle exec hello help basic` - verify basic subcommand help

**Checkpoint**: All CLI commands functional, error handling preserved

---

## Phase 6: Test Migration

**Purpose**: Update test file paths from spec/hello_ruby/ to spec/hello/

- [ ] T055 [P] Move spec/hello_ruby_spec.rb to spec/hello_spec.rb
- [ ] T056 [P] Move spec/hello_ruby/version_spec.rb to spec/hello/version_spec.rb
- [ ] T057 [P] Move spec/hello_ruby/configuration_spec.rb to spec/hello/configuration_spec.rb
- [ ] T058 [P] Move spec/hello_ruby/topic_registry_spec.rb to spec/hello/topic_registry_spec.rb
- [ ] T059 [P] Move spec/hello_ruby/cli_spec.rb to spec/hello/cli_spec.rb
- [ ] T060 Update spec/spec_helper.rb require paths: `require "hello"` (not "hello_ruby")
- [ ] T061 Update all test files' require_relative paths: `"hello/version"` (not hello_ruby/version)
- [ ] T062 Remove empty spec/hello_ruby/ directory if exists
- [ ] T063 Run `bundle exec rspec` - verify all tests pass
- [ ] T064 Run `bundle exec rspec spec/hello/` - verify new structure tests

**Checkpoint**: All tests pass with new file structure

---

## Phase 7: User Story 4 - Documentation Alignment (Priority: P3)

**Goal**: Documentation references correct file locations

**Independent Test**: Check docs/src/ chapters reference lib/hello/ paths

### Update Documentation

- [ ] T065 [P] [US4] Update docs/src/about-hello.md - reference lib/hello.rb entry point
- [ ] T066 [P] [US4] Update docs/src/getting-started.md - require "hello" instead of "hello_ruby"
- [ ] T067 [P] [US4] Update docs/src/basic/variables.md - file path: lib/hello/basic/variables_sample.rb
- [ ] T068 [P] [US4] Update docs/src/basic/strings.md - file path: lib/hello/basic/strings_sample.rb
- [ ] T069 [P] [US4] Update docs/src/advance/metaprogramming.md - file path: lib/hello/advance/metaprogramming_sample.rb
- [ ] T070 [P] [US4] Update docs/src/awesome/sinatra.md - file path: lib/hello/awesome/sinatra_sample.rb
- [ ] T071 [US4] Update README.md - project structure section reflects lib/hello/
- [ ] T072 [US4] Update AGENTS.md - Active Technologies reflects merged structure

### Verify Documentation Links

- [ ] T073 [US4] Check docs/src/SUMMARY.md - all chapter links work
- [ ] T074 [US4] Run `mdbook build docs/` - verify book builds successfully

**Checkpoint**: Documentation reflects new lib/hello/ structure

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final cleanup and verification

- [ ] T075 Run `bundle exec rubocop` - zero offenses across all files
- [ ] T076 Run `bundle exec srb tc` - Sorbet type checking passes
- [ ] T077 Run `bundle exec rspec` - all tests pass
- [ ] T078 Run `bundle exec hello basic advance awesome` - all 30 topics execute
- [ ] T079 Verify file count reduction: from 55 duplicate files to 30 unique samples (45% reduction)
- [ ] T080 Update CHANGELOG.md - document merge refactoring
- [ ] T081 Run quickstart.md validation: `bin/setup && bundle exec hello version`
- [ ] T082 Clean up any remaining backup branches or temporary files
- [ ] T083 Final git status check: verify only lib/hello/, spec/hello/, exe/hello changes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - start immediately
- **Foundational (Phase 2)**: Depends on Setup - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational completion
  - US1 (Clear Structure): Must complete before US2/US3/US4
  - US2 (Runnable Code): Depends on US1 (files must be in correct location)
  - US3 (CLI): Depends on US1 + US2 (structure stable)
  - US4 (Docs): Depends on US1 (final structure known)
- **Test Migration (Phase 6)**: Can run parallel with US3/US4
- **Polish (Phase 8)**: Depends on all phases complete

### User Story Dependencies

- **User Story 1 (P1)**: Foundation for all others - MUST complete first
- **User Story 2 (P1)**: Verifies US1 result - depends on US1
- **User Story 3 (P2)**: Verifies CLI - depends on US1 + US2
- **User Story 4 (P3)**: Updates docs - depends on US1 (know final structure)

### Parallel Opportunities

- **Setup (Phase 1)**: T003, T004, T005 can run in parallel
- **Foundational (Phase 2)**: T007-T012 (6 infrastructure copies) can run in parallel
- **US2 (Phase 4)**: T034-T039 (6 topic runs) can run in parallel
- **US3 (Phase 5)**: T045-T053 (9 CLI tests) can run in parallel
- **Test Migration (Phase 6)**: T055-T059 (5 test file moves) can run in parallel
- **US4 (Phase 7)**: T065-T070 (6 doc updates) can run in parallel

---

## Parallel Example: Foundational Phase

```bash
# Launch all infrastructure file copies in parallel:
Task: "Copy lib/hello_ruby/version.rb to lib/hello/version.rb"
Task: "Copy lib/hello_ruby/errors.rb to lib/hello/errors.rb"
Task: "Copy lib/hello_ruby/configuration.rb to lib/hello/configuration.rb"
Task: "Copy lib/hello_ruby/topic_registry.rb to lib/hello/topic_registry.rb"
Task: "Copy lib/hello_ruby/command.rb to lib/hello/command.rb"
Task: "Copy lib/hello_ruby/cli.rb to lib/hello/cli.rb"

# Then sequentially:
Task: "Copy lib/hello_ruby/system/ directory"
Task: "Create lib/hello.rb entry point"
```

---

## Parallel Example: User Story 3 CLI Tests

```bash
# Launch all CLI command tests in parallel:
Task: "Test hello hello Ruby"
Task: "Test hello version"
Task: "Test hello play basic variables --detail"
Task: "Test hello basic"
Task: "Test hello advance metaprogramming"
Task: "Test hello awesome sinatra"
Task: "Test hello help"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2)

1. Complete Phase 1: Setup (backup and baseline)
2. Complete Phase 2: Foundational (infrastructure migration)
3. Complete Phase 3: User Story 1 (eliminate duplicates)
4. Complete Phase 4: User Story 2 (verify runnable code)
5. **STOP and VALIDATE**: Verify `hello basic variables` works, tests pass
6. Ready for incremental delivery

### Incremental Delivery

1. Setup + Foundational → lib/hello.rb works
2. Add US1 + US2 → Structure clean, all topics runnable
3. Add US3 → CLI fully functional
4. Add Test Migration + US4 → Tests pass, docs aligned
5. Add Polish → Production-ready

### Refactoring Safety Strategy

1. **Backup First**: Create backup branch before any file moves
2. **Baseline Tests**: Run full test suite to capture current state
3. **Incremental Moves**: Move one component at a time, test after each
4. **Rollback Ready**: If tests fail, restore from backup branch
5. **Verify After Each Phase**: Don't proceed until current phase passes

---

## Notes

- This is a refactoring task, not new feature implementation
- Tests exist and should pass after each phase
- Constitution forbids automatic commits - manual review required
- [P] tasks = different files, can run simultaneously
- Stop at any checkpoint to validate independently
- Priority order: US1 → US2 → US3 → US4 (dependencies flow this way)
- Total file reduction: 55 duplicates → 30 unique samples (45% reduction)

---

## Task Count Summary

| Phase     | Task Count | Parallel Tasks |
| --------- | ---------- | -------------- |
| Setup     | 6          | 3              |
| Foundational | 21      | 6              |
| US1       | 13         | 0              |
| US2       | 11         | 6              |
| US3       | 10         | 9              |
| Test Migration | 10     | 5              |
| US4       | 10         | 6              |
| Polish    | 9          | 0              |
| **Total** | **80**     | **30**         |

**MVP Scope**: Phase 1-4 (Setup + Foundational + US1 + US2) = 51 tasks