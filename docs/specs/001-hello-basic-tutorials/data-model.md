# Data Model: Hello Basic Tutorials

**Phase**: 1 - Design & Contracts
**Date**: 2025-04-30
**Branch**: 001-hello-basic-tutorials

## Entity Overview

The hello-ruby gem is primarily a CLI library with educational modules. The data model focuses on structural entities (modules, registries, configuration) rather than domain data entities.

---

## Core Infrastructure Entities

### 1. Hello::System::Application (DI Container)

| Attribute         | Type              | Description                                |
| ----------------- | ----------------- | ------------------------------------------ |
| root              | Pathname          | Project root directory (Hello::ROOT)       |
| log_dir           | String            | Log file directory                         |
| component_dirs    | ComponentDir[]    | Auto-registration directories              |
| plugins           | Symbol[]          | [:logging, :env, :zeitwerk]                |

**Relationships**:
- Uses `Dry::System::Container` base class
- Provides `Hello::System::Import` injector
- Auto-registers components matching hello.commands.* / hello.components.*

**State**: Immutable after configuration (dry-system container)

**Validation**: None (dry-system handles internally)

---

### 2. Hello::TopicRegistry (Topic Discovery)

| Attribute         | Type              | Description                                |
| ----------------- | ----------------- | ------------------------------------------ |
| topics            | Hash<String, Hash> | Registered topics (key: "tier/name")     |
| mutex             | Mutex             | Thread synchronization lock               |

**Methods**:
- `register(tier, name, description, callable)` - Register topic
- `lookup(tier, name)` → Hash or nil - Find topic
- `list(tier)` → Array<Hash> - Topics in tier
- `list_all` → Array<Hash> - All topics sorted
- `run(tier, name)` - Execute topic handler

**Relationships**:
- Each topic has callable (Module with .run or Proc)
- CLI uses TopicRegistry for discovery

**State**: Mutable (topics Hash grows during load)

**Validation**:
- Warns on duplicate registration (does not raise)
- Raises NotFoundError if topic missing on run
- Raises ArgumentError if callable lacks .run/.call

---

### 3. Hello::Configuration (App Config)

| Attribute         | Type              | Default        | Description                    |
| ----------------- | ----------------- | -------------- | ------------------------------ |
| log_level         | Symbol            | :info          | Logging verbosity              |
| database_url      | String            | "sqlite::memory:" | DB connection string       |
| verbose           | Boolean           | false          | Detailed output flag           |

**Relationships**: None (standalone config class)

**State**: Mutable (attr_accessor on all attributes)

**Validation**:
- `validate!` raises ConfigurationError if log_level not in [:debug, :info, :warn, :error]

---

### 4. Hello::Error (Exception Hierarchy)

| Exception Class      | Parent        | Use Case                            |
| -------------------- | ------------- | ----------------------------------- |
| Hello::Error         | StandardError | Base class for all custom errors    |
| Hello::NotFoundError | Error         | Topic or component not found        |
| Hello::ConfigurationError | Error    | Configuration validation failure    |
| Hello::ValidationError | Error      | Input validation failure            |

**Relationships**: StandardError inheritance chain

**State**: Immutable (exception classes)

---

### 5. Hello::Cli (Thor CLI)

| Command        | Arguments      | Options       | Description                    |
| -------------- | -------------- | ------------- | ------------------------------ |
| hello          | [NAME]         | -             | Greeting message               |
| version        | -              | -             | Display gem version            |
| play           | TIER [TOPIC]   | --detail, -d  | Run topic(s) with optional debug |
| basic          | [TOPIC]        | -             | Shortcut to play("basic", ...) |
| advance        | [TOPIC]        | -             | Shortcut to play("advance", ...) |
| awesome        | [TOPIC]        | -             | Shortcut to play("awesome", ...) |

**Relationships**:
- Uses TopicRegistry.lookup and TopicRegistry.run
- inherits from Thor

**State**: Stateless (CLI instance per command)

**Validation**:
- `exit_on_failure?` returns true (exits on unknown command)
- Validates tier in [:basic, :advance, :awesome]

---

## Sample Module Entities

### 6. Hello::Basic::VariablesSample (Topic Module Pattern)

| Method               | Returns        | Description                    |
| -------------------- | -------------- | ------------------------------ |
| self.variable_binding | Hash           | Variable binding demo          |
| self.reference_sharing | Hash          | Object reference sharing demo  |
| self.constant_binding | Hash          | Constants demo                 |
| self.run             | nil (puts output) | CLI orchestration          |

**Relationships**:
- Registered with TopicRegistry as "basic/variables"
- Part of Hello::Basic namespace

**State**: Stateless (module with class methods)

**Validation**: None (educational examples)

---

### 7. Hello::Advance::MetaprogrammingSample (Topic Module Pattern)

| Method                    | Returns        | Description                         |
| ------------------------- | -------------- | ----------------------------------- |
| self.define_method_demo   | Object         | Dynamic method definition           |
| self.method_missing_demo  | Object         | Ghost methods pattern               |
| self.class_eval_demo      | Class          | Class context evaluation            |
| self.run                  | nil            | CLI orchestration                   |

**Relationships**:
- Registered with TopicRegistry as "advance/metaprogramming"
- May use dry-system Import for DI examples

---

### 8. Hello::Awesome::SinatraSample (Web Framework Pattern)

| Class/Module        | Type           | Description                    |
| ------------------- | -------------- | ------------------------------ |
| MemoryTaskStore     | Class          | In-memory task storage         |
| TaskApp             | Class (mock Sinatra) | REST API simulation        |

**Relationships**:
- Registered with TopicRegistry as "awesome/sinatra"
- Demonstrates REST patterns without real Sinatra gem

---

## Tier Entities

### 9. Hello::Basic (Tier Namespace)

| Attribute         | Value           |
| ----------------- | --------------- |
| topic_count       | 15              |
| loader_file       | basic_sample.rb |
| directory         | lib/hello/basic/ |

**Topics**: variables, strings, arrays, hashes, control_flow, methods, classes, modules, blocks_procs, file_io, exceptions, numbers, symbols, regex, file_management

---

### 10. Hello::Advance (Tier Namespace)

| Attribute         | Value           |
| ----------------- | --------------- |
| topic_count       | 10              |
| loader_file       | advance_sample.rb |
| directory         | lib/hello/advance/ |

**Topics**: enumerable, metaprogramming, async_await, database, error_handling, testing, dry_system, cli_advanced, threads_fibers, performance

---

### 11. Hello::Awesome (Tier Namespace)

| Attribute         | Value           |
| ----------------- | --------------- |
| topic_count       | 5               |
| loader_file       | awesome.rb      |
| directory         | lib/hello/awesome/ |

**Topics**: sinatra, hanami, grape, sidekiq, falcon

---

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Hello::ROOT (Pathname)                    │
│                     Project Root Directory Constant              │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                  lib/hello.rb (Entry Point)                      │
│   Loads: version, system, errors, config, registry, cli, loaders │
└─────────────────────────────────────────────────────────────────┘
                                │
                ┌───────────────┼───────────────┐
                ▼               ▼               ▼
┌───────────────────┐ ┌───────────────────┐ ┌───────────────────┐
│ Hello::System::*  │ │ Hello::TopicReg.  │ │   Hello::Cli      │
│   (DI Container)  │ │  (Thread-safe)    │ │   (Thor CLI)      │
│                   │ │                   │ │                   │
│ Application       │ │ topics: Hash      │ │ Commands:         │
│ Import            │ │ mutex: Mutex      │ │ hello/version     │
│                   │ │                   │ │ play/basic/etc    │
└───────────────────┘ └───────────────────┘ └───────────────────┘
                                │               │
                                │               │
                                │               ▼
                                │       ┌───────────────────┐
                                │       │ TopicRegistry.run │
                                │       │ (tier, name)      │
                                │       └───────────────────┘
                                │               │
                                ▼               ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Tier Loaders                                  │
│  basic_sample.rb → requires 15 Basic::*Sample modules           │
│  advance_sample.rb → requires 10 Advance::*Sample modules        │
│  awesome.rb → requires 5 Awesome::*Sample modules               │
└─────────────────────────────────────────────────────────────────┘
                                │
                ┌───────────────┼───────────────┐
                ▼               ▼               ▼
┌───────────────────┐ ┌───────────────────┐ ┌───────────────────┐
│   Hello::Basic    │ │  Hello::Advance   │ │  Hello::Awesome   │
│   15 Topics       │ │   10 Topics       │ │    5 Topics       │
│                   │ │                   │ │                   │
│ VariablesSample   │ │ EnumerableSample  │ │ SinatraSample     │
│ StringsSample     │ │ Metaprogramming   │ │ HanamiSample      │
│ ...               │ │ ...               │ │ ...               │
└───────────────────┘ └───────────────────┘ └───────────────────┘
        │                   │                   │
        ▼                   ▼                   ▼
┌─────────────────────────────────────────────────────────────────┐
│               Each Topic Module Pattern                          │
│  module Hello::Tier::TopicSample                                │
│    def self.concept_method_1 → Hash (unit-testable)             │
│    def self.concept_method_2 → Hash                              │
│    def self.run → orchestration (CLI entry)                     │
│  end                                                             │
│  TopicRegistry.register("tier", "topic", "desc", Module)         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Flow

1. **Gem Load**:
   - exe/hello requires lib/hello.rb
   - hello.rb loads: version → system → errors → config → registry → cli → loaders
   - Tier loaders require all *_sample.rb files
   - Each sample file registers with TopicRegistry at load time

2. **CLI Execution**:
   - User runs `hello basic variables`
   - Thor parses command → Hello::Cli.basic("variables")
   - basic calls play("basic", "variables")
   - play calls TopicRegistry.lookup("basic", "variables")
   - TopicRegistry.run retrieves callable (VariablesSample)
   - VariablesSample.run executes, calls concept methods

3. **Thread Safety**:
   - Multiple threads can call TopicRegistry.register safely
   - Mutex.synchronize protects topics Hash modifications
   - Lookup and run are thread-safe reads

---

## Validation Rules

| Entity              | Validation                                          |
| -------------------- | --------------------------------------------------- |
| Configuration        | log_level ∈ [:debug, :info, :warn, :error]          |
| TopicRegistry        | callable.respond_to?(:run) OR callable.respond_to?(:call) |
| Cli                  | tier ∈ ["basic", "advance", "awesome"]               |
| Topic Module         | Has self.run method, registers at file bottom       |

---

## Migration Impact

| Entity                     | Before (lib/hello_ruby/)          | After (lib/hello/)                |
| -------------------------- | --------------------------------- | --------------------------------- |
| Entry Point                | lib/hello_ruby.rb                 | lib/hello.rb                      |
| System Container           | hello_ruby.commands/* paths       | hello.commands/* paths            |
| TopicRegistry              | lib/hello_ruby/topic_registry.rb  | lib/hello/topic_registry.rb       |
| Cli                        | lib/hello_ruby/cli.rb             | lib/hello/cli.rb                  |
| Basic Loader               | lib/hello_ruby/basic_sample.rb    | lib/hello/basic_sample.rb         |
| Sample Files               | lib/hello/*_sample.rb (existing)  | lib/hello/*_sample.rb (preserved) |
| exe/hello                  | require "hello_ruby"              | require "hello"                   |