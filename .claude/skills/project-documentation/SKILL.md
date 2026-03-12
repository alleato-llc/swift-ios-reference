---
name: project-documentation
description: Defines the required documentation structure for every project. Covers root-level files (README, CONTRIBUTING, LICENSE, SECURITY, CLAUDE.md) and docs/ directory (architecture, testing, database, migrations, release, security design, how-to, and per-feature docs). Use when creating a new project or adding features.
version: 1.0.0
---

# Project Documentation

Every project must include a standard set of documentation. Root-level files serve public/contributor-facing purposes. The `docs/` directory contains detailed internal documentation.

## Required structure

```
README.md                    High-level overview, quickstart
CONTRIBUTING.md              Developer workflow, branching, PR process, commit conventions
LICENSE.md                   License
SECURITY.md                  Vulnerability reporting policy (GitHub convention)
CLAUDE.md                    Agent context, references docs/

docs/
├── ARCHITECTURE.md          System architecture, component design, package layout
├── TESTING.md               Testing strategy, test types, conventions
├── DATABASE.md              SwiftData schema, model relationships
├── MIGRATIONS.md            Schema versioning strategy
├── RELEASE.md               Release process, versioning, App Store submission
├── SECURITY.md              App security design, data protection, keychain usage
├── HOW_TO.md                Setup guide, configuration, troubleshooting
└── feature/
    └── FEATURE_N.md         Per-feature deep dives
```

## Root-level files

### README.md
- Project name and one-sentence description
- Prerequisites
- Quickstart (build, run, test)
- High-level architecture overview
- Project structure (directory tree)
- Link to `docs/` for detailed documentation

### CONTRIBUTING.md
- How to set up the development environment
- Branching strategy and PR process
- Commit conventions (conventional commits if applicable)
- How to add new features/skills
- Project conventions (naming, structure, testing)

### LICENSE.md
- Full license text
- Choose appropriate license for the project

### SECURITY.md (root)
- How to report security vulnerabilities
- Supported versions
- Response timeline expectations
- This is the **public-facing** security policy (GitHub surfaces it in the Security tab)

### CLAUDE.md
- Agent context for Claude Code
- Project overview, build commands, architecture summary
- References to `docs/` for detailed documentation
- Lists available skills

## docs/ files

### ARCHITECTURE.md
- System overview diagram or description
- Component responsibilities and interactions (Views, ViewModels, Repositories, Clients, Calculators)
- Domain model overview
- Key design decisions and rationale
- Package structure (Core, Services, TestSupport)
- Technology choices and why

### TESTING.md
- Testing strategy (unit vs integration, when to use which)
- How to run tests (`swift test`, `xcodebuild test`)
- Test infrastructure (in-memory SwiftData, test doubles)
- Test conventions (naming, location, assertions)
- Coverage expectations

### DATABASE.md
- SwiftData model overview (`@Model` entities, properties, types)
- Entity relationships (`@Relationship`, delete rules)
- Enum-as-String storage pattern
- Key queries and their purpose (`FetchDescriptor`, `#Predicate`)

### MIGRATIONS.md
- Migration strategy (VersionedSchema + SchemaMigrationPlan)
- How to create a new migration
- Migration naming conventions
- Lightweight vs custom migration stages
- Migration testing strategy
- Common pitfalls

### RELEASE.md
- Release process (manual or automated)
- Versioning strategy (semver)
- App Store submission process
- How to verify a release
- Troubleshooting failed releases

### SECURITY.md (docs/)
- Data protection and encryption
- Keychain usage for sensitive data
- Network security (certificate pinning, TLS)
- Dependency security scanning
- This is the **internal** security design doc, distinct from root SECURITY.md

### HOW_TO.md
- Detailed setup instructions (step-by-step)
- Configuration options
- Common operations and workflows
- Gotchas and known quirks
- Troubleshooting guide (symptoms -> causes -> solutions)
- FAQ

### Feature docs (docs/feature/FEATURE_N.md)

Each feature gets its own document. Use a descriptive filename (e.g., `RECIPE_BROWSING.md`, not `FEATURE_1.md`).

Required sections:

```markdown
# Feature Name

## What
Brief description of the feature and its business purpose.

## How

### User flow
Step-by-step from the user's perspective (tap, navigate, etc.).

### Data flow
How data moves through the system (View -> ViewModel -> Repository -> SwiftData).

## Architecture

### Design decisions
Key choices made and why.

### Core models
Domain entities involved in this feature.

### Core types
ViewModel, repository, client protocols relevant to this feature.

### File organization
Which files implement this feature and where they live.

## Configuration
Feature flags, environment-based settings.

## Dependencies
What other features or services this feature depends on.

## Testing
How to test this feature — which test files, what scenarios are covered,
how to add new test cases.

## Maintenance
Operational concerns — common failure modes.

## Limitations
Known limitations, edge cases, future improvements.
```

## When to create/update docs

| Event | Action |
|---|---|
| New project | Create all root files and docs/ structure |
| New feature | Add `docs/feature/FEATURE_NAME.md` |
| Schema change | Update `DATABASE.md` and `MIGRATIONS.md` |
| Architecture change | Update `ARCHITECTURE.md` |
| New test pattern | Update `TESTING.md` |
| Release process change | Update `RELEASE.md` |
| Security change | Update `docs/SECURITY.md` |

## Conventions

- Docs describe what exists — never document aspirational features
- Keep docs close to code — update docs in the same PR as the code change
- CLAUDE.md is the entry point — it should reference docs/ for details, not duplicate them
- Feature docs are the most valuable — they answer "how does X work?"
- README is for newcomers — keep it focused on getting started, not deep architecture
- Documentation files use uppercase names with `.md` extension
- Do not create documentation unless explicitly requested or required by a feature change

## Checklist

When creating or updating documentation, verify:

- [ ] All root-level files exist (README, CONTRIBUTING, LICENSE, SECURITY, CLAUDE.md)
- [ ] docs/ directory has all required files
- [ ] New features have a corresponding `docs/feature/` document
- [ ] Schema changes are reflected in DATABASE.md and MIGRATIONS.md
- [ ] CLAUDE.md references docs/ without duplicating content
- [ ] Feature docs follow the required template sections
