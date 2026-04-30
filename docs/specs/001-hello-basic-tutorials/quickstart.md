# Quickstart: Hello Basic Tutorials

**Phase**: 1 - Design & Contracts  
**Date**: 2025-04-30  
**Branch**: 001-hello-basic-tutorials

## Developer Setup Guide

This guide helps developers set up the hello-ruby project after the merge refactoring.

---

## Prerequisites

- **Ruby**: 3.2+ (managed via rbenv, rvm, or mise)
- **Bundler**: 2.4+
- **Git**: For version control

---

## Quick Setup (5 minutes)

### 1. Clone and Install

```bash
# Clone the repository
git clone https://github.com/savechina/hello-ruby.git
cd hello-ruby

# Checkout feature branch (for development)
git checkout 001-hello-basic-tutorials

# Install dependencies
bin/setup
```

### 2. Verify Installation

```bash
# Run CLI
bundle exec hello version
# Output: hello v0.1.0

# Run a topic
bundle exec hello basic variables
# Output: === 变量绑定与可变性 ===

# Run all basic topics
bundle exec hello basic
```

---

## Project Structure After Merge

```
hello-ruby/
├── bin/
│   ├── setup              # Installation script
│   └── console            # Interactive Ruby console (IRB)
│
├── exe/
│   └── hello              # CLI entry point
│
├── lib/
│   ├── hello.rb           # Main entry (renamed from hello_ruby.rb)
│   └── hello/
│       ├── version.rb
│       ├── errors.rb
│       ├── configuration.rb
│       ├── topic_registry.rb
│       ├── cli.rb
│       ├── system/
│       │   ├── container.rb    # dry-system DI
│       │   └── import.rb
│       ├── basic_sample.rb     # Tier loader
│       ├── advance_sample.rb
│       ├── awesome.rb
│       ├── basic/              # 15 sample files
│       ├── advance/            # 10 sample files
│       └── awesome/            # 5 sample files
│
├── spec/
│   ├── spec_helper.rb
│   ├── hello_spec.rb
│   ├── hello/
│   │   ├── basic/
│   │   ├── advance/
│   │   └── awesome/
│   └── factories/
│
├── docs/
│   └── src/               # mdBook documentation
│
├── .rubocop.yml           # RuboCop configuration
├── Steepfile              # Steep type checking config
├── Gemfile
├── hello.gemspec
└── Rakefile
```

---

## Development Workflow

### Running Topics

```bash
# Basic tier
bundle exec hello basic variables
bundle exec hello basic strings
bundle exec hello basic              # All 15 topics

# Advance tier
bundle exec hello advance metaprogramming
bundle exec hello advance            # All 10 topics

# Awesome tier
bundle exec hello awesome sinatra
bundle exec hello awesome            # All 5 topics
```

### Running Tests

```bash
# All tests
bundle exec rspec

# Specific tier
bundle exec rspec spec/hello/basic/

# Coverage
COVERAGE=true bundle exec rspec

# Documentation format
bundle exec rspec --format documentation
```

### Linting and Type Checking

```bash
# RuboCop (zero offenses required)
bundle exec rubocop

# Sorbet type checking
bundle exec srb tc

# Steep gradual typing
bundle exec steep check
```

---

## Adding a New Topic

### 1. Create Sample File

```bash
# Create file in appropriate tier
touch lib/hello/basic/new_topic_sample.rb
```

### 2. Implement Module

```ruby
# lib/hello/basic/new_topic_sample.rb
# typed: true
# frozen_string_literal: true

module Hello
  module Basic
    module NewTopicSample
      # Unit-testable concept methods
      def self.concept_one
        result = "example"
        { output: result }
      end
      
      def self.concept_two
        # Another concept
      end
      
      # CLI entry point
      def self.run
        puts "=== New Topic ==="
        concept_one
        concept_two
      end
    end
  end
end

# Self-registration (clean key, no _sample suffix)
Hello::TopicRegistry.register("basic", "new_topic", "新主题", Hello::Basic::NewTopicSample)
```

### 3. Add to Loader

```ruby
# lib/hello/basic_sample.rb
require_relative "basic/new_topic_sample"  # Add this line
```

### 4. Create Test

```ruby
# spec/hello/basic/new_topic_sample_spec.rb
RSpec.describe Hello::Basic::NewTopicSample do
  describe ".concept_one" do
    it "returns example result" do
      result = Hello::Basic::NewTopicSample.concept_one
      expect(result[:output]).to eq("example")
    end
  end
  
  describe ".run" do
    it "executes without error" do
      expect { Hello::Basic::NewTopicSample.run }.not_to raise_error
    end
  end
end
```

### 5. Verify

```bash
# Test
bundle exec rspec spec/hello/basic/new_topic_sample_spec.rb

# Lint
bundle exec rubocop lib/hello/basic/new_topic_sample.rb

# Run
bundle exec hello basic new_topic
```

---

## Testing a Topic Module

### Unit Testing Concept Methods

```ruby
# spec/hello/basic/strings_sample_spec.rb
RSpec.describe Hello::Basic::StringsSample do
  describe ".string_interpolation" do
    it "returns interpolated string" do
      result = Hello::Basic::StringsSample.string_interpolation
      expect(result).to be_a(Hash)
      expect(result[:result]).to include("Ruby")
    end
  end
  
  describe ".frozen_strings" do
    it "demonstrates frozen string behavior" do
      result = Hello::Basic::StringsSample.frozen_strings
      expect(result[:frozen?]).to be true
    end
  end
  
  describe ".run" do
    it "orchestrates all concepts" do
      expect { Hello::Basic::StringsSample.run }.not_to raise_error
    end
  end
end
```

---

## Using dry-system DI (Awesome Tier)

```ruby
# lib/hello/awesome/my_service_sample.rb
module Hello
  module Awesome
    class MyServiceSample
      extend Hello::System::Import["logger"]
      
      def self.run
        logger.info "Running MyService"
        # ...
      end
    end
  end
end
```

---

## Troubleshooting

### Topic Not Found

```bash
# Check TopicRegistry registration
bundle exec console

# In IRB:
Hello::TopicRegistry.list("basic").map { |t| t[:name] }
# => ["variables", "strings", "arrays", ...]
```

### RuboCop Errors

```bash
# Auto-correct safe fixes
bundle exec rubocop --auto-correct

# Check specific file
bundle exec rubocop lib/hello/basic/variables_sample.rb
```

### Type Errors (Sorbet)

```bash
# Check specific file
bundle exec srb tc lib/hello/basic/variables_sample.rb

# Update type signatures
bundle exec srb rbi update
```

---

## Key Files Reference

| File                      | Purpose                              |
| ------------------------- | ------------------------------------ |
| lib/hello.rb              | Main entry point, loads all modules  |
| lib/hello/topic_registry.rb | Thread-safe topic discovery        |
| lib/hello/cli.rb          | Thor CLI commands                    |
| lib/hello/basic_sample.rb | Basic tier loader (15 requires)      |
| exe/hello                 | CLI executable                       |
| spec/hello_spec.rb        | Gem smoke tests                      |
| .rubocop.yml              | RuboCop configuration                |

---

## Quality Gates Checklist

Before committing changes:

- [ ] `bundle exec rubocop` passes (zero offenses)
- [ ] `bundle exec srb tc` passes (zero type errors)
- [ ] `bundle exec rspec` passes (all tests)
- [ ] New topics registered in TopicRegistry
- [ ] YARD docs added for public methods
- [ ] frozen_string_literal comment on all files
- [ ] typed: sigil on all files

---

## Next Steps

1. Review spec.md for feature requirements
2. Review data-model.md for entity relationships
3. Review contracts/cli-schema.md for CLI interface
4. Run `/speckit.tasks` to generate implementation tasks
5. Execute tasks via `/speckit.implement`