<!--
SYNC IMPACT REPORT
==================
Version Change: 1.1.1 → 1.2.0 (MINOR: Complete Ruby technology stack adaptation from Rust)
Modified Principles:
  - I. Code Quality (NON-NEGOTIABLE) → Ruby Idioms & Code Quality (NON-NEGOTIABLE)
    Rubocop replaces cargo clippy; Sorbet replaces Rust type safety; frozen_string_literal
    and Ruby 3.2+ idioms replace Rust 2024 edition patterns.
  - II. Test-First Development (NON-NEGOTIABLE) → RSpec + FactoryBot-based testing
    RSpec replaces cargo test; FactoryBot replaces mockall; simplecov replaces tarpaulin.
  - III. User Experience Consistency → CLI & UX Consistency
    Thor CLI replaces clap; JSON output flag added; config/dotenv for configuration.
  - IV. Performance Requirements → Performance & Reliability
    Ruby lazy enumeration replaces unbounded channel patterns; Sequel connection pooling;
    N+1 query prevention; GVL awareness; ruby-prof/stackprof for profiling.
  - V. SDD Harness Engineering → Quality gates adapted for Ruby
    `bundle exec rubocop` + `bundle exec srb tc` + `bundle exec rake spec` replace
    `cargo clippy` + `cargo fmt` + `cargo test`.
Added Sections:
  - Technology Stack: Ruby-specific dependencies (dry-system, Sequel, Thor, Sorbet, Steep)
  - Type System guidance (Sorbet `typed:` sigils + Steep gradual typing)
  - Linting & Formatting standards (Rubocop 1.50+ with 6 plugins)
  - Ruby Profiling tooling (ruby-prof, stackprof, memory_profiler, benchmark-ips)
  - Development LSP tooling (ruby-lsp, solargraph)
Removed Sections:
  - All Rust-specific content: cargo clippy/fmt, Tokio, Axum, Tonic, SQLx, Diesel,
    proptest, criterion, mockall, tracing, serde, protoc, mdBook, clap, Rust 2024 edition
Templates Requiring Updates: None (SDD workflow templates are language-agnostic)
Follow-up TODOs:
  - TODO(create-rubocop-config): Generate .rubocop.yml from constitution standards if project lacks one
  - TODO(create-sorbet-config): Add sorbet/config with appropriate typed: defaults
  - TODO(ci-pipeline): Set up GitHub Actions CI with rubocop + srb tc + rspec stages
  - TODO(template-rust-examples): Add Ruby-specific examples to .specify/templates/ where relevant
==================
-->

# Hello Ruby Constitution

## Core Principles

### I. Ruby Idioms & Code Quality (NON-NEGOTIABLE)

All code MUST prioritize clarity, maintainability, and idiomatic Ruby patterns.

**Requirements:**
- Follow Ruby 3.2+ features and idiomatic patterns
- Zero Rubocop offenses (`bundle exec rubocop`) — all rules enforced or explicitly allowed with justification
- Maximum line length: 120 characters
- Double quotes for strings (`EnforcedStyle: double_quotes`)
- `frozen_string_literal: true` magic comment at the top of all Ruby source files
- Sorbet `typed:` sigils on all files (minimum `typed: false`, target `typed: true` or higher)
- No monkey-patching core library classes without documented justification and peer review
- YARD documentation on all public APIs with examples
- Prefer keyword arguments over positional options hashes for methods with 3+ parameters
- Use `private_class_method`, `module_function` appropriately for visibility control

**Rationale:** Ruby's flexibility makes disciplined style paramount. Students learn from what they see.
Poor idiomatic usage compounds as learners replicate anti-patterns.

**Quality Gates:**
- `bundle exec rubocop` MUST pass with zero offenses
- `bundle exec srb tc` (Sorbet) MUST pass with zero type errors on `typed: true` files
- `bundle exec steep check` MUST pass where Steep gradual typing is configured
- All `TODO` and `FIXME` comments MUST have associated issues

### II. Test-First Development (NON-NEGOTIABLE)

Test-driven development is mandatory for all new features and bug fixes.

**Requirements:**
- Tests written and approved BEFORE implementation begins
- Red-Green-Refactor cycle strictly enforced
- RSpec test suite for all business logic (target: >80% coverage via simplecov)
- FactoryBot factories for all model/spec fixtures
- Integration tests for all CLI command behaviors and Sequel database interactions
- Performance benchmarks for algorithmic code paths (using `benchmark-ips`)

**Rationale:** Tests serve as executable specifications and living documentation. They catch regressions
and validate learning outcomes.

**Testing Tiers:**
1. **Unit Tests**: Fast, isolated, comprehensive (target: thousands of examples, <10s total)
2. **Integration Tests**: CLI command flows, Sequel database interactions, configuration loading
3. **End-to-End Tests**: Full system workflows using `gstack` browser automation
4. **Performance Tests**: Benchmark critical paths, detect regressions

**Anti-Patterns:**
- Pending specs (`xit` or `pending`) without documented reasons and tracking issues
- Tests that only pass in specific environments without explicit setup/teardown
- Stubbing internal implementation details instead of public interfaces
- Test order dependency — each spec MUST be independently runnable

### III. CLI & UX Consistency

All user-facing interfaces MUST provide intuitive, consistent, and accessible experiences.

**Requirements:**
- CLI interfaces: Thor-based command structure with consistent option parsing, helpful `--help` output
- Configuration: Sensible defaults via `config` gem, `.env` override support via `dotenv`
- Output: Human-friendly table/list output with `--json` option for machine-readable format
- Error Messages: Actionable, specific, include context and remediation steps
- Response Times: <100ms for CLI operations, <1s for complex queries

**Documentation Language Standards:**
- **Primary Language**: Chinese (Simplified) with English technical terms in parentheses
  - Example: 块 (block), 模块 (module), 元编程 (metaprogramming)
- **Writing Style**: Plain language, avoid academic jargon
- **Content Requirements**:
  - Minimum 500 Chinese characters per chapter
  - At least 3 executable code examples
  - At least 3 knowledge checkpoint questions
  - GitHub links to all source code examples

**UX Principles:**
- **Discoverability**: Every command accessible via `--help` or documentation
- **Predictability**: Consistent naming conventions, option order, and output formats
- **Recoverability**: Clear error messages with suggested fixes, no silent failures
- **Accessibility**: Terminal output readable on both light and dark themes

**gstack Integration:**
- Use `/browse` for manual UX validation before deployment
- Use `/qa` for automated accessibility testing
- Use `/design-review` for visual consistency audits

### IV. Performance & Reliability

All code MUST meet defined performance standards and resource constraints.

**Requirements:**
- Memory: No unbounded array/hash growth, explicit limits on collection transformations
- CPU: Prefer lazy enumeration (`Enumerable#lazy`) over eager collection materialization
- I/O: Streaming for large file operations (no full materialization in memory)
- Database: Sequel connection pooling (max 4 connections), prepared statements, N+1 query prevention
- Network: Retry with exponential backoff, circuit breaker for downstream services
- GVL Awareness: Use non-blocking I/O for concurrent operations

**Performance Standards:**
- CLI commands: <1s warm start, <3s cold start
- Database queries: <10ms average latency, p95 <50ms
- Memory footprint: <100MB for CLI tools, <500MB for long-running services
- Object allocations: <10,000 objects per request/command cycle for typical operations

**Performance Anti-Patterns:**
- `sleep()` in polling loops (use reactive patterns or event-driven architecture)
- Synchronous HTTP requests in concurrent contexts (use `async` or `concurrent-ruby`)
- Unbounded array growth via `<<` in tight loops (use `map`, `filter_map`, or lazy enumerators)
- `Marshal.load` on untrusted data (security and reliability risk)
- N+1 query patterns with Sequel ORM (use `.eager` or `.graph` for associations)

**Profiling Requirements:**
- Use `ruby-prof` or `stackprof` for CPU profiling before optimization
- Use `memory_profiler` for allocation hotspots
- Use `benchmark-ips` for throughput measurement, track regressions in CI
- Document performance characteristics in AGENTS.md

### V. SDD Harness Engineering

Specification Driven Development (SDD) workflows MUST follow the **8-Phase Development Lifecycle**
with triple quality gates (Metis + Momus + GStack).

**Development Phases:**

**Phase 0: Product Strategy & Requirements**
- `/office-hours` — Product discovery (YC 6-question forcing framework)
- `/plan-ceo-review` — Scope challenge (4 modes: SCOPE EXPANSION/SELECTIVE/HOLD/REDUCTION)
- `/speckit.specify` — Generate feature specifications
- **Quality Gate**: Metis intent analysis + Momus spec review (>=8/10)

**Phase 1: Technical Architecture & Design**
- `/speckit.plan` — Technical design with constitution check
- `/plan-eng-review` — Engineering review (architecture/data flow/performance)
- `/design-consultation` + `/plan-design-review` — Design system (UI projects)
- **Quality Gate**: Metis deep planning + Momus plan review (>=8/10)

**Phase 2: Task Decomposition**
- `/speckit.tasks` — Granular task breakdown (<4hr per task)
- `/speckit.analyze` — Cross-artifact consistency analysis
- **Quality Gate**: No CRITICAL/HIGH inconsistencies

**Phase 3: Quality Checklists**
- `/speckit.checklist` — Multi-domain checklists (test/security/ux/performance/code-quality/architecture/ai-safety)
- **Quality Gate**: 100% checklist coverage

**Phase 4: Implementation**
- `/speckit.implement` — Test-first execution with task delegation
- **Quality Gate**: `bundle exec rubocop` + `bundle exec srb tc` + `bundle exec rake spec` all pass
- **Manual Review**: Changes MUST be manually reviewed before commit
- **Manual Commit**: ALL commits MUST be manually committed and pushed by user
- **Prohibited**: NO automatic commits or pushes to remote repositories

**Phase 5: Testing & Validation**
- `bundle exec rake spec && bundle exec rspec --format documentation` — Automated testing
- `/review` — Pre-landing PR review
- `/qa` — End-to-end QA testing with browser automation
- **Quality Gate**: 100% tests pass + no CRITICAL issues

**Phase 6: Delivery & Release**
- `/document-release` — Update all documentation
- `/ship` — Merge, version bump, create PR (with user approval)
- **Quality Gate**: All quality gates passed
- **Manual Verification**: User MUST verify all changes before deployment

**Phase 7: Retrospective**
- `/retro` — Engineering retro with trend analysis
- **Output**: Improvement action items for next iteration

**Triple Quality Gates:**

| Gate | Role | Timing | Purpose |
|------|------|--------|---------|
| **Metis** | Pre-planning consultant | Before each phase | Intent analysis, ambiguity detection, AI failure prediction, routing strategy |
| **Momus** | Post-delivery reviewer | After each phase | Clarity/verifiability/completeness/context evaluation, AI failure mode detection |
| **GStack** | Professional specialist | During execution | Domain-specific expertise (CEO review, eng review, design review, QA, PR review) |

**Skill Integration Matrix:**

| Phase | Speckit Commands | GStack Skills | OhMyOpenCode Agents |
|-------|------------------|---------------|---------------------|
| Phase 0 | `specify` | `office-hours`, `plan-ceo-review` | `metis`, `librarian` |
| Phase 1 | `plan` | `plan-eng-review`, `design-consultation`, `plan-design-review` | `metis`, `oracle`, `explore` |
| Phase 2 | `tasks`, `analyze` | - | `metis`, `momus` |
| Phase 3 | `checklist` | - | `momus` |
| Phase 4 | `implement` | - | `task()` delegation |
| Phase 5 | - | `review`, `qa`, `browse` | `momus` |
| Phase 6 | - | `document-release`, `ship` | `momus` |
| Phase 7 | - | `retro` | `momus` |

**Workflow Requirements:**
- Feature specifications via `/speckit.specify` (mandatory for all features)
- Implementation plans via `/speckit.plan` (mandatory before coding)
- Constitution check at Phase 1 (verify all 5 principles)
- Test-first development enforced in Phase 4
- All quality gates MUST pass before proceeding to next phase
- Document all decisions in `docs/specs/{N}-{feature}/`
- **Manual Control**: User MUST manually review, commit, and push all changes

**Workflow Enforcement:**
- No direct commits to `main` branch (use feature branches with PRs)
- All PRs MUST reference a spec document in `docs/specs/`
- All code changes MUST have corresponding test updates
- Breaking changes MUST update version according to semver and migration guide
- **CRITICAL**: NO automatic commits or pushes - user maintains full control

**Automation Standards:**
- CI pipeline: Bundle -> Lint -> Type Check -> Test -> Benchmark -> Deploy
- Deployment: Automated via GitHub Actions, rollback procedures documented
- Monitoring: Structured logging, metrics collection, error tracking
- Incident Response: Runbooks in `docs/runbooks/`, on-call rotation documented
- **Manual Gates**: User approval required at all deployment stages

**Tool Stack:**
- **Speckit Framework**: 8-phase SDD workflow (`specify`, `plan`, `tasks`, `analyze`, `checklist`, `implement`)
- **GStack Skills**: Quality automation (`office-hours`, `plan-ceo-review`, `plan-eng-review`, `design-consultation`, `plan-design-review`, `review`, `qa`, `browse`, `ship`, `retro`)
- **OhMyOpenCode Agents**: Triple quality gates (`metis` pre-planning, `momus` post-review, `oracle` architecture, `explore` codebase, `librarian` external research)
- **Ruby Tooling**: `rubocop`, `srb tc` (Sorbet), `steep check`, `rspec`, `ruby-prof`, `stackprof`, `memory_profiler`
- **Manual Commit Policy**: ALL commits require user review and manual execution

## Technology Stack

**Core:**
- Language: Ruby 3.2+ (rbenv managed)
- Gem: Standard gem structure with metadata (MFA required, homepage, source code URI, changelog URI)

**Type System:**
- Static: Sorbet (`srb tc`) with `typed:` sigils (target `typed: true` or higher)
- Gradual: Steep for `.rbs` type definitions and incremental adoption

**Linting & Formatting:**
- Rubocop 1.50.2+ with plugins:
  - rubocop-rspec (RSpec style enforcement)
  - rubocop-performance (Performance anti-patterns)
  - rubocop-rake (Rake task conventions)
  - rubocop-sequel (Sequel ORM patterns)
  - rubocop-sorbet (Sorbet type annotation style)
  - rubocop-thread_safety (Thread safety violations)
- Style: 120 char line limit, double quotes, frozen_string_literal enforced

**Testing:**
- Framework: RSpec 3.0+ with `--format documentation`
- Fixtures: FactoryBot for all model/spec fixtures
- Coverage: simplecov (target: >80%)

**Data Layer:**
- ORM: Sequel 5.54+ with SQLite3 adapter
- Connection pooling: Sequel thread-safe pool (max: 4)

**Framework Dependencies:**
- DI Container: dry-system, dry-struct, dry-events, dry-monitor
- Utilities: ActiveSupport 7.1.2+

**CLI:**
- Framework: Thor 1.1+ (commands, options, help generation)
- Configuration: config gem with dotenv override support

**Development Tooling:**
- LSP: ruby-lsp, solargraph
- Debug: debug gem, ruby-watchman for file monitoring
- Profiling: ruby-prof, stackprof, memory_profiler, benchmark-ips

**Build/CI:**
- CI: GitHub Actions (ruby.yml)
- CI Steps: `bundle install` -> `bundle exec rubocop` -> `bundle exec srb tc` -> `bundle exec rake spec`

## Development Workflow

### Feature Development Lifecycle

1. **Specification** (`/speckit.specify`)
   - Create feature spec in `docs/specs/<###-feature-name>/spec.md`
   - Define user stories, acceptance criteria, success metrics
   - Quality checklist validation

2. **Planning** (`/speckit.plan`)
   - Technical design document
   - Architecture decisions with rationale
   - Constitution check (verify compliance with all 5 principles)
   - Dependency analysis

3. **Implementation** (`/speckit.tasks` -> `/speckit.implement`)
   - Granular task breakdown (<4hr per task)
   - Test-first: Write specs -> specs fail -> implement -> specs pass
   - **Manual Review**: ALL changes MUST be manually reviewed
   - **Manual Commit**: User MUST execute all git commits
   - **Manual Push**: User MUST execute all git pushes
   - **Prohibited**: NO automatic commits or pushes

4. **Quality Assurance** (`/qa`)
   - Automated testing (unit, integration, e2e)
   - Visual validation (`/browse`, `/design-review`)
   - Performance benchmarks
   - Lint and type check (`rubocop`, `srb tc`, `steep check`)

5. **Review** (`/review`)
   - Pre-landing code review
   - Constitution compliance check
   - Performance regression check
   - Documentation completeness

6. **Deploy**
   - Merge to `main` via PR
   - Automated CI/CD pipeline
   - Post-deploy monitoring
   - **Manual approval required at all stages**

### Branch Strategy

- `main`: Production-ready code, protected
- `<###-feature-name>`: Feature branches (sequential numbering from speckit)
- All branches MUST have associated spec document
- **Manual Control**: User decides when to create branches and merge

### Commit Conventions

 **DO NOT COMMIT and PUSH**
 **DO NOT COMMIT and PUSH**
 **DO NOT COMMIT and PUSH**

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`

**Manual Commit Examples:**
```bash
# User manually reviews and commits
git add <files>
# git commit -m "feat(cli): Add Thor command for project scaffolding"
# git push origin main
```

**Prohibited:**
```bash
# DO NOT automatically commit or push
# git commit -m "auto: ..."  # FORBIDDEN
# git push origin main       # FORBIDDEN without user approval
```

## Governance

**Authority:**
This constitution supersedes all other development practices and guides.
In case of conflict with team conventions, constitution principles take precedence.

**Amendment Process:**
1. Propose amendment via GitHub issue with rationale
2. Architectural review for impact assessment
3. Team discussion and approval (consensus required)
4. Update constitution with version bump (MAJOR.MINOR.PATCH)
5. Propagate changes to all dependent templates and documentation
6. Announce changes to all contributors
7. **Manual Execution**: All constitutional amendments require manual user approval and commit

**Versioning Policy:**
- **MAJOR**: Backward incompatible principle removals or redefinitions
- **MINOR**: New principle/section added or materially expanded guidance
- **PATCH**: Clarifications, wording improvements, typo fixes

**Compliance Review:**
- All PRs MUST verify constitution compliance via `/review` command
- Complexity exceptions MUST be justified in PR description with architectural approval
- Violations of NON-NEGOTIABLE principles block merge
- **Manual Review**: User MUST verify all compliance checks before merge

**Runtime Guidance:**
- Use `AGENTS.md` for project-specific technical guidance
- Use `.specify/templates/` for workflow templates
- Use `docs/` for user-facing documentation

**Enforcement:**
- CI checks for linting, type checking, testing, security
- Mandatory code review for all changes
- Quarterly constitution review and update cycle
- **Manual Control**: User has final approval on all changes to main branch

---

**Version**: 1.2.0 | **Ratified**: 2026-04-03 | **Last Amended**: 2026-04-26
