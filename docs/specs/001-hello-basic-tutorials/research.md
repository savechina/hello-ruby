# Research: Hello Basic Tutorials Merge

**Phase**: 0 - Outline & Research
**Date**: 2025-04-30
**Branch**: 001-hello-basic-tutorials

## Research Tasks

All NEEDS CLARIFICATION items from spec were resolved during `/speckit.clarify` session. This research focuses on best practices and implementation patterns for Ruby gem refactoring.

---

## 1. Ruby Gem Directory Structure Patterns

### Decision

Use standard Ruby gem structure with lib/[gem_name].rb as entry point and lib/[gem_name]/ as namespace directory.

### Rationale

From RubyGems Patterns Guide:
> "Every gem you have installed gets its `lib` directory appended onto your `$LOAD_PATH`. This means any file on the top level of the `lib` directory could get required."

The entry file (lib/hello.rb) must match the primary namespace directory (lib/hello/). This prevents `$LOAD_PATH` pollution and avoids conflicts with stdlib gems.

### Alternatives Considered

| Alternative                              | Rejected Because                                           |
| ---------------------------------------- | ---------------------------------------------------------- |
| Keep lib/hello_ruby.rb as entry          | Directory renamed to lib/hello/, mismatch violates convention |
| Dual entry points (hello.rb + hello_ruby.rb) | Unnecessary complexity, single entry suffices              |
| Flat lib/ structure (no subdirectory)    | Violates namespace isolation, pollutes LOAD_PATH           |

### Implementation Pattern

```ruby
# lib/hello.rb (entry point)
require "pathname"

module Hello
  ROOT = Pathname.new(__dir__).parent.freeze
  
  require_relative "hello/version"
  require_relative "hello/system"
  require_relative "hello/errors"
  require_relative "hello/configuration"
  require_relative "hello/topic_registry"
  require_relative "hello/command"
  require_relative "hello/cli"
  
  # Tier loaders
  require_relative "hello/basic_sample"
  require_relative "hello/advance_sample"
  require_relative "hello/awesome"
end
```

---

## 2. Module Naming Conventions

### Decision

Use `*_Sample` suffix for module names (e.g., `VariablesSample`, `StringsSample`) matching file names `*_sample.rb`.

### Rationale

From Ruby Style Guide:
> "File names should be in snake_case matching the module/class name in PascalCase."

The `_sample` suffix distinguishes tutorial sample modules from infrastructure modules. Users see clean CLI commands (`hello basic variables`) while internal naming uses `VariablesSample`.

### Alternatives Considered

| Alternative                        | Rejected Because                                       |
| ---------------------------------- | ------------------------------------------------------ |
| Remove _sample suffix from modules | Losing distinction between samples and infrastructure  |
| Use Sample prefix (SampleVariables) | Non-standard Ruby naming, reverse of file pattern      |
| Use Demo suffix (VariablesDemo)    | Demo implies limited functionality, Sample is clearer  |

### Implementation Pattern

```ruby
# lib/hello/basic/variables_sample.rb
module Hello
  module Basic
    module VariablesSample
      def self.variable_binding
        # Unit-testable method
      end
      
      def self.run
        # CLI entry point
      end
    end
  end
end

Hello::TopicRegistry.register("basic", "variables", "变量绑定", Hello::Basic::VariablesSample)
```

---

## 3. Unit-Testable Method Pattern

### Decision

Organize sample modules with separate public class methods per concept (e.g., `self.variable_binding`, `self.variable_scope`) and a `self.run` orchestration method for CLI.

### Rationale

From Ruby Style Guide:
> "Prefer modules to classes with only class methods. Classes should be used only when it makes sense to create instances out of them."

This pattern enables:
- Granular unit testing via RSpec (each concept tested independently)
- TopicRegistry compatibility (modules with `.run` method)
- CLI preservation (no changes to Hello::Cli)
- Ruby convention compliance (no unnecessary instantiation)

### Alternatives Considered

| Alternative                      | Rejected Because                                     |
| -------------------------------- | ---------------------------------------------------- |
| Monolithic run with private helpers | Private methods cannot be directly unit tested       |
| Class-based with instance methods | Requires instantiation, violates Style Guide         |
| Procs/Lambdas for concepts        | Cannot register with TopicRegistry (needs .respond_to?(:run)) |

### Implementation Pattern

```ruby
# lib/hello/basic/strings_sample.rb
module Hello::Basic::StringsSample
  # Concept 1: String interpolation
  def self.string_interpolation
    name = "Ruby"
    interpolated = "Hello, #{name}!"
    { name: name, result: interpolated }
  end
  
  # Concept 2: Frozen strings
  def self.frozen_strings
    frozen = "literal".freeze
    dynamic = "dynamic"
    { frozen_id: frozen.object_id, frozen?: frozen.frozen? }
  end
  
  # CLI entry point (orchestrates concepts)
  def self.run
    puts "=== 字符串 ==="
    string_interpolation
    frozen_strings
  end
end
```

### Test Pattern

```ruby
# spec/hello/basic/strings_sample_spec.rb
RSpec.describe Hello::Basic::StringsSample do
  describe ".string_interpolation" do
    it "returns interpolated string" do
      result = Hello::Basic::StringsSample.string_interpolation
      expect(result[:result]).to eq("Hello, Ruby!")
    end
  end
  
  describe ".run" do
    it "executes without error" do
      expect { Hello::Basic::StringsSample.run }.not_to raise_error
    end
  end
end
```

---

## 4. dry-system DI Preservation

### Decision

Preserve dry-system container (System::Application) and Import mixin without modification, only update component registration paths from `hello_ruby.commands/*` to `hello.commands/*`.

### Rationale

From dry-system documentation:
> "dry-system provides a complete dependency injection solution for Ruby applications, including auto-registration, lazy loading, and container inheritance."

The Awesome tier uses dry-system for production-grade patterns. Preserving this infrastructure ensures:
- DI patterns remain available for Awesome tier
- Container plugins (logging, env, zeitwerk) continue functioning
- Import mixin pattern (`extend Hello::System::Import["component"]`) works unchanged

### Alternatives Considered

| Alternative                          | Rejected Because                                 |
| ------------------------------------ | ------------------------------------------------ |
| Remove dry-system (Basic tier only)  | Awesome tier needs DI for production patterns    |
| Replace with SimpleContainer pattern | Less powerful, loses auto-registration benefits  |
| Rewrite container in lib/hello/      | Unnecessary duplication, hello_ruby code works   |

### Implementation Pattern

```ruby
# lib/hello/system/container.rb (preserved)
module Hello
  module System
    class Application < Dry::System::Container
      use :logging
      use :env, inferrer: -> { ENV.fetch("RUBY_ENV", :development).to_sym }
      use :zeitwerk, debug: false

      configure do |config|
        config.root = Hello::ROOT
        config.log_dir = File.join(Hello::ROOT, "log")
        
        # Updated paths from hello_ruby.commands to hello.commands
        config.component_dirs.add "lib" do |dir|
          dir.auto_register = lambda do |component|
            identifier = component.identifier
            identifier.start_with?("hello.commands") ||
              identifier.start_with?("hello.components")
          end
        end
      end
    end
  end
end

# lib/hello/system/import.rb (preserved)
module Hello
  module System
    Import = Application.injector
  end
end
```

---

## 5. TopicRegistry Thread Safety

### Decision

Preserve TopicRegistry's Mutex-based thread safety without modification.

### Rationale

From Ruby concurrency best practices:
> "Global state modification in multi-threaded environments requires synchronization to prevent race conditions."

TopicRegistry uses a global Hash with Mutex for registration operations. Preserving this ensures:
- Thread-safe topic registration during gem load
- Safe lookup during CLI execution
- No race conditions in concurrent environments

### Implementation Pattern

```ruby
# lib/hello/topic_registry.rb (preserved)
module Hello
  class TopicRegistry
    @topics = {}
    @mutex = Mutex.new

    class << self
      def register(tier, name, description, callable)
        key = "#{tier}/#{name}"
        @mutex.synchronize do
          @topics[key] = { tier: tier, name: name, description: description, callable: callable }
        end
      end
      
      def lookup(tier, name)
        @mutex.synchronize { @topics["#{tier}/#{name}"] }
      end
      
      def run(tier, name)
        topic = lookup(tier, name)
        handler = topic[:callable]
        handler.respond_to?(:run) ? handler.run : handler.call
      end
    end
  end
end
```

---

## 6. Thor CLI Preservation

### Decision

Preserve Hello::Cli Thor class with all subcommands (hello, version, play, basic, advance, awesome) without modification.

### Rationale

Thor provides:
- Automatic --help generation
- Option parsing with type validation
- Subcommand routing
- Error handling for unknown commands

Preserving CLI ensures:
- User interface remains stable
- Shortcut commands (hello basic [topic]) work unchanged
- No breaking changes for existing users

### Implementation Pattern

```ruby
# lib/hello/cli.rb (preserved)
require "thor"

module Hello
  class Cli < Thor
    map "-v" => :version
    def self.exit_on_failure?; true; end

    desc "hello [NAME]", "向指定名称问好"
    def hello(name = "World")
      puts "Hello, #{name}! 👋"
    end

    desc "version", "显示当前版本号"
    def version
      puts "hello v#{Hello::VERSION}"
    end

    desc "basic [TOPIC]", "运行基础主题"
    def basic(topic = nil)
      play("basic", topic)
    end
    
    # Additional subcommands: advance, awesome, play...
  end
end
```

---

## 7. Loader File Migration

### Decision

Rename loader files from lib/hello_ruby/ to lib/hello/ and update require_relative paths.

### Rationale

Loader files orchestrate tier loading by requiring all sample files in a tier. Renaming ensures:
- Entry point (lib/hello.rb) finds loaders in correct location
- Consistent require paths within lib/hello/ namespace
- Single source of truth for tier loading

### Implementation Pattern

```ruby
# lib/hello/basic_sample.rb (renamed from hello_ruby/basic_sample.rb)
require_relative "basic/variables_sample"
require_relative "basic/strings_sample"
require_relative "basic/arrays_sample"
# ... 15 requires

# lib/hello/advance_sample.rb (to be created)
require_relative "advance/enumerable_sample"
require_relative "advance/metaprogramming_sample"
# ... 10 requires

# lib/hello/awesome.rb (preserved, path updated)
require_relative "awesome/sinatra_sample"
require_relative "awesome/hanami_sample"
# ... 5 requires
```

---

## 8. exe/hello Entry Point Update

### Decision

Update exe/hello to require "hello" instead of "hello_ruby".

### Rationale

The executable must match the renamed entry file. Ruby's require mechanism searches $LOAD_PATH for matching files.

### Implementation Pattern

```ruby
# exe/hello (updated)
#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "hello"  # Changed from "hello_ruby"

Hello::Cli.start
```

---

## Summary

| Research Area                  | Decision                                                |
| ------------------------------ | ------------------------------------------------------- |
| Directory Structure            | lib/hello.rb + lib/hello/ (standard gem pattern)        |
| Module Naming                  | *_Sample suffix (VariablesSample)                       |
| Method Pattern                 | Separate concept methods + self.run orchestration       |
| dry-system DI                  | Preserve container, update paths to hello.commands/*    |
| TopicRegistry                  | Preserve Mutex thread safety                            |
| Thor CLI                       | Preserve all subcommands unchanged                      |
| Loader Files                   | Rename to lib/hello/, update require_relative paths     |
| exe/hello                      | Update require "hello"                                  |

All decisions follow Ruby Style Guide, RubyGems Patterns, and dry-system best practices. No unresolved NEEDS CLARIFICATION items remain.