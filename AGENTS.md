# AGENTS.md — Hello Ruby Architecture Guide

## Project Overview

**Hello Ruby** is a Ruby learning tutorial project that combines the gem engineering patterns from **zenspace/ruby** with the tiered learning structure from **hello-rust**. It provides a comprehensive set of runnable examples and tutorials for learning Ruby from basic syntax to production-grade applications.

The project is structured as a standard Ruby gem with a CLI application, organized into three learning tiers: **Basic** → **Advance** → **Awesome**.

## Tier Structure

### Basic Tier (15 Topics)

Beginner-friendly Ruby fundamentals. Each topic is a self-contained module in `lib/hello/basic/`.

| # | Module | File | Status |
|---|--------|------|--------|
| 1 | Variables | `basic/variables_sample.rb` | ✅ Initial |
| 2 | Strings | `basic/strings_sample.rb` | ✅ Initial |
| 3 | Arrays | `basic/arrays_sample.rb` | ✅ Initial |
| 4 | Hashes | `basic/hashes_sample.rb` | ✅ Initial |
| 5 | Control Flow | `basic/control_flow_sample.rb` | ✅ Initial |
| 6 | Methods | `basic/methods_sample.rb` | ✅ Initial |
| 7 | Classes | `basic/classes_sample.rb` | ✅ Initial |
| 8 | Modules | `basic/modules_sample.rb` | ✅ Initial |
| 9 | Blocks & Procs | `basic/blocks_procs_sample.rb` | ✅ Initial |
| 10 | File I/O | `basic/file_io_sample.rb` | ✅ Initial |
| 11 | Exceptions | `basic/exceptions_sample.rb` | ✅ Initial |
| 12 | Numbers | `basic/numbers_sample.rb` | ✅ Initial |
| 13 | Symbols | `basic/symbols_sample.rb` | ✅ Initial |
| 14 | Regular Expressions | `basic/regex_sample.rb` | ✅ Initial |
| 15 | File Management | `basic/file_management_sample.rb` | ✅ Initial |

### Advance Tier (10 Topics)

Intermediate to advanced Ruby concepts and ecosystem tools.

| # | Module | File | Status |
|---|--------|------|--------|
| 1 | Enumerables | `advance/enumerable.rb` | ✅ Initial |
| 2 | Metaprogramming | `advance/metaprogramming.rb` | ✅ Initial |
| 3 | Async & Concurrency | `advance/async_await.rb` | ✅ Initial |
| 4 | Database & ORM | `advance/database.rb` | ✅ Initial |
| 5 | Error Handling | `advance/error_handling.rb` | ✅ Initial |
| 6 | Testing | `advance/testing.rb` | ✅ Initial |
| 7 | DI with dry-system | `advance/dry_system.rb` | ✅ Initial |
| 8 | CLI Advanced | `advance/cli_advanced.rb` | ✅ Initial |
| 9 | Threads & Fibers | `advance/threads_fibers.rb` | ✅ Initial |
| 10 | Performance | `advance/performance.rb` | ✅ Initial |

### Awesome Tier (Production Grade)

Real-world application patterns using industry-standard tools: Rails, Sidekiq, REST APIs, authentication, Docker deployment. These examples depend on the full production gem stack.

## Code Conventions

### frozen_string_literal

Every `.rb` file MUST start with:

```ruby
# frozen_string_literal: true
```

This is enforced by RuboCop's `Style/FrozenStringLiteralComment` rule.

### Sorbet Sigils

Type-annotated files use Sorbet sigils as the first line (before `frozen_string_literal`):

```ruby
# typed: true
# frozen_string_literal: true
```

| Sigil | Usage |
|-------|-------|
| `false` | Non-type-checked files (scripts, simple configs) |
| `true` | Most library code — basic type checking |
| `strict` | Core domain models, public APIs |
| `strong` | Never used — too restrictive for Ruby |

Use `# typed: ignore` only when temporarily bypassing type checking with a FIXME comment.

### Rubocop Rules

- Follow the standard RuboCop configuration (`.rubocop.yml`)
- Use double quotes for strings (RuboCop `Style/StringLiterals`)
- 2-space indentation
- Max line length: 120 characters
- Use `snake_case` for methods/variables, `PascalCase` for classes/modules, `SCREAMING_SNAKE_CASE` for constants

### Double Quotes

All strings use double quotes (`"`), not single quotes (`'`), unless the string contains no interpolations or escape sequences and style consistency demands single quotes (per RuboCop auto-correct).

## Topic Registry Pattern

Each topic module MUST implement a consistent interface:

```ruby
# typed: true
# frozen_string_literal: true

module Hello
  module Basic  # Or Advance / Awesome
    # TopicName — Chinese description
    module TopicName
      def self.run
        puts "=== 主题演示 ==="
        # Example code here
      end
    end
  end
end

# Self-registration at file bottom
TopicRegistry.register("basic", "topic_name", "中文描述", Hello::Basic::TopicName)
```

### Key Requirements

- **Class/module design**: Each topic is a module under `Hello::Basic`/`Hello::Advance`
- **`self.run` method**: Class method entry point for CLI execution
- **No instances**: Topics are executed via `self.run`, not instantiated
- **Self-contained**: Each topic should be runnable independently via `exe/hello` or `hello``
- **Auto-registration**: Each file calls `TopicRegistry.register` at module load time

## CLI Architecture

The CLI is built with **Thor** (or GLI) and follows this structure:

```
hello                    # Main CLI entry point
├── hello basic          # Run all basic examples
├── hello basic TOPIC    # Run basic/TOPIC module
├── hello advance        # Run all advance examples
├── hello awesome        # Run awesome examples
├── hello search QUERY   # Search topics
└── hello version        # Show version
```

### CLI Conventions

- Use subcommands for tiers: `basic`, `advance`, `awesome`
- Use arguments for specific topics: `hello basic variables`
- Default behavior (no args): show help / run all basic examples
- All CLI output should include tier and module context in prompts

## DI with dry-system

For the Awesome tier and any production-grade code, use **dry-system** for dependency injection:

```ruby
# config/application.rb
require "dry/system/container"

module Hello
  class Container < Dry::System::Container
    configure do |config|
      config.root = Pathname(__dir__).parent
      config.component_dirs.add "lib"
    end
  end
end
```

### DI Rules

- Use `dry-system` for the Awesome tier (production examples)
- Use `dry-struct` for value objects and configuration structs
- Use `dry-monads` for functional error handling (`Result`, `Maybe`)
- Use `dry-validation` for input validation schemas
- **Never** use `dry-system` in Basic tier — keep those examples plain and simple
- Advance tier may use dry-monads for error handling examples

## Testing Conventions

### File Location

```
spec/
├── spec_helper.rb          # RSpec configuration
├── hello_spec.rb      # Gem-level smoke tests
├── basic/                  # Basic tier tests
│   ├── variables_spec.rb
│   ├── strings_spec.rb
│   └── ...
├── advance/                # Advanced tier tests
│   └── ...
├── awesome/                # Production-grade tests
│   └── ...
└── factories/              # FactoryBot definitions
    └── .keep
```

### Test Structure

```ruby
# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Variables module" do
  it "executes without error" do
    expect { Variables.run }.not_to raise_error
  end

  # Additional examples for specific concepts
  describe ".example_one" do
    it "demonstrates concept" do
      expect { Variables.example_one }.not_to raise_error
    end
  end
end
```

### Key Rules

- Every topic MUST have at least one test: `it "executes without error"`
- Use nested `describe` for individual example methods
- Basic tier tests: smoke tests only (run without error)
- Advance tier tests: can include assertions on return values
- Awesome tier tests: full integration tests with factories, mocks, etc.
- Use `factory_bot_rails` for test data in Awesome tier
- Run coverage via `COVERAGE=true bundle exec rspec`

## Anti-Patterns

### ❌ What NOT to Do

1. **Don't use classes for basic topics** — Use modules with `module_function`. Classes add unnecessary complexity for example code.
2. **Don't add dependencies to Basic tier** — Basic topics should use only Ruby stdlib. External gems appear in Advance/Awesome tiers only.
3. **Don't skip `frozen_string_literal`** — Every file without exception.
4. **Don't use single quotes** — Double quotes for consistency.
5. **Don't create shared utilities across tiers** — Each tier is conceptually independent. If code is duplicated, it's because the tiers target different audiences.
6. **Don't put production code in Basic/Advance** — Save frameworks, DI, and production patterns for the Awesome tier.
7. **Don't use global variables** — Use `module_function` or explicit dependency passing.
8. **Don't suppress Sorbet types** — Use `# typed: strict` for public interfaces. Only use `# typed: false` for generated files.
9. **Don't hard-code paths** — Use `Pathname(__dir__)` or `__dir__` for relative paths.
10. **Don't use `puts` in library code** — Use `logger` (via `dry-logger` or Rails logger in Awesome tier). `puts` is only for Basic/Advance tutorial examples.

### ✅ What TO Do

1. **Keep topics self-contained** — Each topic should run independently
2. **Use descriptive method names** — `variable_binding` not `ex1`
3. **Add comments explaining concepts** — The code IS the tutorial
4. **Use `if __FILE__ == $PROGRAM_NAME`** for direct execution in topics
5. **Register all topics** in the TOPIC_REGISTRY for CLI discoverability
6. **Write tests first** — at minimum a smoke test
7. **Use `dry-monads` Result** for error handling in Awesome tier
8. **Use `dry-struct`** for configuration and data transfer objects
9. **Use `dry-validation`** for input schemas
10. **Follow the tier boundaries** — don't cross-pollinate concepts

## Active Technologies
- Ruby 3.2+ (rbenv managed, per .ruby-version) (001-hello-basic-tutorials)
- SQLite3 (in-memory for examples, file-based for Awesome tier database simulations) (001-hello-basic-tutorials)

## Recent Changes
- 001-hello-basic-tutorials: Added Ruby 3.2+ (rbenv managed, per .ruby-version)
