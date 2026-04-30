# Feature Specification: Hello Basic Tutorials

**Feature Branch**: `001-hello-basic-tutorials`  
**Created**: 2025-04-30  
**Status**: Draft  
**Input**: User description: "hello ruby 教程，../hello-rust 样例代码及工程模块，实现ruby 教程，目前实现的代码存在重复 lib/hello lib/hello_ruby 重复，优化下实现真实的样例学习知识点代码，可运行"

## Clarifications

### Session 2025-04-30

- Q: Merge direction - lib/hello INTO lib/hello_ruby OR lib/hello_ruby INTO lib/hello? → A: Merge lib/hello_ruby infrastructure INTO lib/hello/, rename to hello, use dry-system architecture, each sample as unit-testable method
- Q: Method organization pattern for unit testing? → A: Option A - Separate methods per concept (self.variable_binding, self.variable_scope etc.) - follows Ruby Style Guide recommendation for modules with class methods, compatible with TopicRegistry, enables granular unit testing
- Q: File naming convention - keep _sample suffix or remove? → A: Keep _sample suffix everywhere: variables_sample.rb, strings_sample.rb (maintains consistency with current lib/hello pattern and distinguishes sample files from other infrastructure files)
- Q: TopicRegistry keys and CLI commands - include _sample suffix in keys? → A: Clean keys without _sample suffix: TopicRegistry.register("basic", "variables", ...) CLI: `hello basic variables` (user-friendly CLI commands independent of internal file naming)
- Q: Main entry point file after merge? → A: lib/hello.rb as main entry point (matches lib/hello/ directory, follows Ruby gem convention where entry file name matches primary namespace directory)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Clear Project Structure for Contributors (Priority: P1)

Ruby tutorial contributors and maintainers need a clear, non-duplicated directory structure so they can understand where to add new topics without confusion.

**Why this priority**: Without clear structure, contributors waste time navigating duplicate files and risk making changes in wrong locations. This is foundational to project maintainability.

**Independent Test**: Can be fully tested by examining the directory structure - if there are no duplicate topic files across lib/hello and lib/hello_ruby, and each tier has a single clear location for sample code, the requirement is satisfied.

**Acceptance Scenarios**:

1. **Given** the current duplicated structure (lib/hello and lib/hello_ruby both containing topic files), **When** refactoring is complete, **Then** each tier (basic, advance, awesome) has exactly ONE directory containing sample files
2. **Given** a contributor wants to add a new topic, **When** they examine the project structure, **Then** they can clearly identify where to place the new sample file without ambiguity
3. **Given** the refactored structure, **When** searching for a specific topic's implementation, **Then** there is exactly ONE file location for that topic

---

### User Story 2 - Real Runnable Sample Code for Learners (Priority: P1)

Ruby learners need real, executable sample code that demonstrates knowledge points through actual Ruby operations, not just puts statements printing code strings.

**Why this priority**: Learners need to see code that actually executes and produces results. Puts-based "fake" code does not demonstrate real Ruby behavior and fails to teach effectively.

**Independent Test**: Can be fully tested by running each topic via the CLI - if each topic executes real Ruby code (variable assignments, method calls, class definitions, etc.) and produces actual results rather than just printing code strings, the requirement is satisfied.

**Acceptance Scenarios**:

1. **Given** a learner runs `hello basic variables`, **When** the topic executes, **Then** the code demonstrates actual variable binding, scope, and mutability through real Ruby operations
2. **Given** a learner runs any basic tier topic, **When** the topic completes, **Then** real Ruby objects are created, methods are called, and results are computed (not just puts statements)
3. **Given** a learner runs any advance tier topic, **When** the topic executes, **Then** the code performs real operations (e.g., actual metaprogramming, real thread creation, actual benchmarking)

---

### User Story 3 - CLI Functionality Preservation (Priority: P2)

Tutorial users need the CLI to continue working after refactoring so they can still run topics independently.

**Why this priority**: The CLI is the primary interface for running tutorials. Breaking it would render the project unusable for learners.

**Independent Test**: Can be fully tested by running `hello basic [topic]`, `hello advance [topic]`, and `hello awesome [topic]` for all topics - if all commands execute successfully, the requirement is satisfied.

**Acceptance Scenarios**:

1. **Given** the refactored structure, **When** running `hello basic variables`, **Then** the command executes successfully and displays real variable operations
2. **Given** the refactored structure, **When** running `hello advance [any topic]`, **Then** all 10 advance topics execute successfully
3. **Given** the refactored structure, **When** running `hello awesome [any topic]`, **Then** all 5 awesome topics execute successfully
4. **Given** the refactored structure, **When** running `hello basic` without topic argument, **Then** all basic topics run in sequence

---

### User Story 4 - Documentation Alignment (Priority: P3)

Tutorial readers need documentation that accurately references the refactored code structure so they can find and understand the actual code implementations.

**Why this priority**: Documentation helps learners understand concepts, but misaligned docs cause confusion. However, this is secondary to actual code functionality.

**Independent Test**: Can be fully tested by checking each documentation chapter's code references - if all references point to the correct file locations and match the actual code behavior, the requirement is satisfied.

**Acceptance Scenarios**:

1. **Given** documentation chapters in docs/src/basic/, **When** examining code references, **Then** all file paths and code examples match the actual refactored structure
2. **Given** documentation chapters in docs/src/advance/, **When** examining code references, **Then** all code examples accurately describe what the real sample code does

---

### Edge Cases

- What happens when old lib/hello_ruby files are removed? The topic registry must still find modules in the new location (lib/hello/)
- How does the system handle the transition from HelloRuby namespace to Hello namespace? All module references must be updated consistently (current system already uses Hello namespace)
- What happens to existing tests that reference old file paths? Test file paths must be updated to match new structure (spec/hello_ruby/ → spec/hello/)
- How does the system handle loader files (basic_sample.rb, advance_sample.rb)? These must be renamed to lib/hello/ directory and updated to require from correct locations
- What happens to dry-system component registration paths? Must be updated from hello_ruby.commands/hello_ruby.components to hello.commands/hello.components
- How does exe/hello find the entry point? Must be updated to require "hello" instead of "hello_ruby"

---

## Merge Strategy Principles

### Priority Order (Highest to Lowest)

1. **P1: Infrastructure Preservation** - ALL lib/hello_ruby system components MUST be preserved without modification (System::Application, TopicRegistry, Cli, Configuration, Errors, VERSION, ROOT)
2. **P2: Entry Point Rename** - Rename lib/hello_ruby.rb → lib/hello.rb, update exe/hello to require "hello"
3. **P3: Sample File Consolidation** - Keep ALL lib/hello/*_sample.rb files, remove lib/hello_ruby/basic/*.rb and lib/hello_ruby/advance/*.rb (puts-based duplicates)
4. **P4: Loader File Migration** - Rename lib/hello_ruby/basic_sample.rb → lib/hello/basic_sample.rb, create lib/hello/advance_sample.rb
5. **P5: CLI & Registry Updates** - Update TopicRegistry keys, CLI subcommands to use clean names ("variables" not "variables_sample")
6. **P6: Test Migration** - Update spec/hello_ruby/ → spec/hello/, update all test require paths
7. **P7: Documentation Update** - Update docs to reflect new structure, file paths, and code examples

### Non-Goals (Out of Scope)

- Adding new topics to any tier (preserve existing 30 topics)
- Refactoring sample code logic (only refactor structure/naming)
- Changing dry-system container configuration
- Adding new CLI commands beyond existing set
- Modifying awesome tier web framework simulations

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST eliminate duplicate topic files - each topic should exist in exactly ONE directory location
- **FR-002**: System MUST merge lib/hello_ruby infrastructure INTO lib/hello/ and rename directory to hello/ (following user's merge direction decision)
- **FR-002a**: System MUST preserve ALL lib/hello_ruby infrastructure components during merge (see FR-100 series for component details)

---

### Infrastructure Preservation Requirements (lib/hello_ruby Components)

The following lib/hello_ruby infrastructure MUST be preserved and merged into lib/hello/:

#### FR-100: System Infrastructure (dry-system DI)

- **FR-101**: System MUST preserve `Hello::System::Application` container (dry-system 1.2+)
- **FR-102**: Container MUST continue using: `use :logging`, `use :env`, `use :zeitwerk` plugins
- **FR-103**: Container MUST maintain component_dirs auto-registration for `hello.commands.*` and `hello.components.*`
- **FR-104**: System MUST preserve `Hello::System::Import` injector mixin for dependency injection
- **FR-105**: Import pattern MUST remain functional: `extend Hello::System::Import["component_name"]`

#### FR-110: TopicRegistry (Topic Discovery)

- **FR-111**: System MUST preserve `Hello::TopicRegistry` class with thread-safe Mutex protection
- **FR-112**: TopicRegistry MUST maintain methods: `register`, `lookup`, `list`, `list_all`, `run`
- **FR-113**: Registration pattern MUST remain: `register(tier, name, description, callable)`
- **FR-114**: TopicRegistry MUST support both `.run` and `.call` callable interfaces

#### FR-120: CLI (Thor Framework)

- **FR-121**: System MUST preserve `Hello::Cli` Thor-based CLI with subcommands
- **FR-122**: CLI MUST maintain commands: `hello`, `version`, `play`, `basic`, `advance`, `awesome`
- **FR-123**: CLI MUST preserve `exit_on_failure?` behavior (exit on unknown subcommands)
- **FR-124**: CLI MUST maintain shortcut subcommands: `hello basic [topic]`, `hello advance [topic]`, `hello awesome [topic]`
- **FR-125**: CLI MUST preserve detail option: `hello play basic variables --detail`

#### FR-130: Configuration

- **FR-131**: System MUST preserve `Hello::Configuration` class
- **FR-132**: Configuration MUST maintain attributes: `log_level`, `database_url`, `verbose`
- **FR-133**: Configuration MUST preserve DEFAULTS constant and `validate!` method

#### FR-140: Error Hierarchy

- **FR-141**: System MUST preserve `Hello::Error` base class (StandardError inheritance)
- **FR-142**: System MUST preserve error classes: `NotFoundError`, `ConfigurationError`, `ValidationError`

#### FR-150: Core Infrastructure Files

- **FR-151**: System MUST preserve `Hello::VERSION` constant (lib/hello/version.rb)
- **FR-152**: System MUST preserve `Hello::ROOT` constant (Pathname to project root)
- **FR-153**: Main entry point MUST be renamed from lib/hello_ruby.rb to lib/hello.rb
- **FR-154**: Entry point MUST maintain require order: version, system, errors, configuration, topic_registry, command, cli, tier loaders

---

- **FR-003**: All sample files MUST contain real executable Ruby code that demonstrates knowledge points through actual operations
- **FR-004**: Each sample file MUST use the naming convention `*_sample.rb` (e.g., variables_sample.rb, strings_sample.rb) to distinguish sample files from infrastructure/core files
- **FR-004a**: Module names MUST use PascalCase matching file names: VariablesSample, StringsSample (variables_sample.rb → VariablesSample module)
- **FR-005**: System MUST maintain the TopicRegistry pattern so CLI can discover and run all topics
- **FR-005a**: System MUST preserve dry-system DI architecture from lib/hello_ruby/system/ (container.rb, import.rb)
- **FR-006**: Each sample file MUST register itself with TopicRegistry at module load time using `Hello::TopicRegistry.register(tier, topic_name, description, module)`
- **FR-006a**: TopicRegistry topic_name MUST be clean without _sample suffix (e.g., "variables", not "variables_sample") for user-friendly CLI commands
- **FR-006b**: CLI command pattern MUST be: `hello [tier] [topic]` where topic name matches TopicRegistry key (e.g., `hello basic variables`)
- **FR-007**: CLI commands MUST continue to work after refactoring - `hello basic [topic]`, `hello advance [topic]`, `hello awesome [topic]`
- **FR-008**: System MUST preserve the tier structure: basic (15 topics), advance (10 topics), awesome (5 topics)
- **FR-009**: Each sample file MUST follow the module pattern: `module Hello::Basic::TopicSample` with individual unit-testable methods (not just a single `run` method)
- **FR-009a**: Each knowledge point MUST be demonstrated in a separate public class method that can be independently tested (e.g., `def self.variable_binding`, `def self.variable_scope`, etc.)
- **FR-009b**: Each sample module MUST follow Ruby Style Guide recommendation: use modules with class methods, NOT classes requiring instantiation
- **FR-009c**: Each sample module MUST maintain `def self.run` as CLI entry point that orchestrates all concept methods
- **FR-010**: System MUST remove or deprecate old puts-based code files in lib/hello_ruby/basic/ and lib/hello_ruby/advance/
- **FR-011**: Documentation MUST be updated to reflect the new file structure and actual code behavior
- **FR-012**: Tests MUST be updated to reference correct file paths and module names

### Key Entities

#### Core Infrastructure Entities (from lib/hello_ruby)

- **System::Application**: dry-system DI container with logging, env, zeitwerk plugins. Manages component auto-registration and dependency injection
- **System::Import**: DI injector mixin. Usage: `extend Hello::System::Import["component_name"]`
- **TopicRegistry**: Thread-safe central registry with Mutex. Maps tier, topic name, description, and callable module for CLI discovery
- **Cli**: Thor-based CLI with subcommands (hello, version, play, basic, advance, awesome). Entry point: exe/hello
- **Configuration**: Application config class with log_level, database_url, verbose attributes and validate! method
- **Error**: Base exception class (StandardError). Hierarchy: NotFoundError, ConfigurationError, ValidationError
- **VERSION**: Semantic version constant (e.g., "0.1.0")
- **ROOT**: Pathname constant pointing to project root directory

#### Tutorial Entities (from lib/hello)

- **Sample File**: A Ruby file containing real executable code demonstrating a specific Ruby knowledge point. Located in lib/hello/[tier]/[topic]_sample.rb (e.g., lib/hello/basic/variables_sample.rb)
- **Topic Module**: A Ruby module (e.g., Hello::Basic::VariablesSample) that encapsulates sample code with unit-testable concept methods and `self.run` entry point
- **Tier**: A learning level (basic, advance, awesome) containing multiple related topics
- **Tier Loader**: A loader file (e.g., lib/hello/basic_sample.rb) that requires all sample files for a tier

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Duplicate topic files are eliminated - from 55 duplicate files to 30 unique sample files (45% reduction in topic-related files)
- **SC-002**: All 30 sample files contain real executable code - verified by running each topic and checking that actual Ruby operations occur (no puts-based code strings)
- **SC-003**: CLI functionality preserved - 100% of CLI commands (30 topics + 3 tier commands) execute successfully after refactoring
- **SC-004**: Project structure clarity improved - contributors can identify topic file locations without ambiguity (single directory per tier)
- **SC-005**: Topic registry functioning - all 30 topics remain discoverable and runnable via CLI
- **SC-006**: Tests passing - all existing tests updated and passing with new file structure
- **SC-007**: Documentation accuracy - all documentation chapters reference correct file locations and describe actual code behavior

## Assumptions

### Infrastructure Preservation Assumptions

- lib/hello_ruby infrastructure is well-designed and production-ready - ALL components will be preserved during merge
- dry-system DI architecture is the target pattern for Awesome tier and production-grade code
- TopicRegistry's thread-safe Mutex pattern is correct and will be maintained
- Thor CLI structure with subcommands is user-friendly and will be preserved
- Error hierarchy follows Ruby best practices (StandardError inheritance) and will be maintained
- Configuration pattern provides flexibility for future enhancements

### Code Migration Assumptions

- All 30 *_sample.rb files in lib/hello/ are already implemented with real executable code and will be preserved
- The old files in lib/hello_ruby/basic/ and lib/hello_ruby/advance/ (without _sample suffix) contain puts-based code and will be removed or deprecated
- The Hello namespace is the correct namespace for all modules (not HelloRuby)
- The CLI entry point exe/hello will be updated to require lib/hello.rb instead of lib/hello_ruby.rb
- Existing loader files will be renamed: lib/hello_ruby/basic_sample.rb → lib/hello/basic_sample.rb, etc.
- The hello-rust project pattern (single clear directory per tier with real executable code) is the target design
- Contributors understand Ruby module namespace conventions (Hello::Basic::TopicSample)
- Learners will run tutorials via CLI, not by directly executing individual Ruby files

### Testing Assumptions

- Each concept method in sample modules can be tested independently via RSpec
- Tests will be updated to reference correct file paths: spec/hello/basic/variables_sample_spec.rb
- TopicRegistry.register calls can be verified in tests by checking registry state

## Post-Implementation Enhancements

Cross-project coverage analysis (hello-ruby vs hello-rust vs hello-python) identified 5 recommended advance topics to align hello-ruby's coverage with hello-rust's depth. These are documented in [future-enhancements.md](./future-enhancements.md) and include:

- **P1 Topics**: LLM integration, system programming, memory mapping
- **P2 Topics**: Parallel computing, advanced benchmarking

Estimated effort: ~2.5 days (human) / ~45 min (CC+gstack)
