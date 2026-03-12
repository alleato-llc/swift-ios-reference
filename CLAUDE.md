# CLAUDE.md

## Project Overview

Swift iOS reference project codifying best practices for Swift/SwiftUI applications — project structure, component design, testing patterns, and more. Skills are added incrementally as patterns are established.

This is one of several reference projects tracked by [engineering-standards](../engineering-standards/). See the skill matrix there for cross-project coverage, gaps, and priorities. When adding, removing, or renaming skills in this project, update the skill matrix in engineering-standards to stay in sync.

### Skill Versions

Skills follow semantic versioning defined in [engineering-standards](../engineering-standards/VERSIONING.md). The `version` field in each skill's frontmatter reflects which engineering-standards version this project implements. When updating a skill, bump the version to match engineering-standards and update the matrix.

## Build & Test

```bash
xcodegen generate                    # Generate .xcodeproj from project.yml
xcodebuild -scheme RecipePlanner \
  -destination 'platform=iOS Simulator,name=iPhone 16' build   # Build iOS app

cd Packages/RecipePlannerServices && swift test   # Run package tests

xcodebuild -scheme RecipePlanner \
  -destination 'platform=iOS Simulator,name=iPhone 16' test    # Run app-level tests

swiftlint lint                       # Lint
swiftformat --lint .                 # Check formatting
```

## Architecture

- **Domain**: Recipe/meal planning (browse recipes, plan meals, generate shopping lists)
- **UI framework**: SwiftUI with MVVM
- **Persistence**: SwiftData (`@Model` entities)
- **Reactivity**: `@Observable` (Observation framework, iOS 17+)
- **DI approach**: Constructor injection via protocols + `DependencyContainer`
- **Concurrency**: `async`/`await`, `@MainActor` for ViewModels only
- **Modularity**: Three local SPM packages (Core/Services/TestSupport)
- **Build system**: XcodeGen (`project.yml`), `.xcodeproj` gitignored
- **Min target**: iOS 17+

### Package Structure

| Package | Purpose |
|---------|---------|
| `RecipePlannerCore` | Domain models (`Recipe`, `Ingredient`, `MealPlan`), enums, extensions |
| `RecipePlannerServices` | Business logic, protocols, repository impls, calculators |
| `RecipePlannerTestSupport` | Shared test infrastructure (factories, fakes) |

### App Target Structure

- `RecipePlanner/App/` — Entry point, DependencyContainer, ContentView
- `RecipePlanner/ViewModels/` — `@Observable @MainActor` ViewModels
- `RecipePlanner/Views/` — SwiftUI views organized by feature (Recipe/, MealPlan/, Shopping/)
- `RecipePlanner/Components/` — Reusable UI components
- `RecipePlanner/Error.swift` — Error enum + ErrorPresenter

## Component Design

- **Views**: Thin — no business logic, bind to ViewModel state, forward user actions
- **ViewModels**: `@Observable @MainActor` — orchestrate workflows, own error presentation, constructor injection
- **Repositories**: Protocol + SwiftData impl — data access only, `FetchDescriptor` with `#Predicate`
- **Clients**: Protocol + HTTP impl — external boundary wrappers, one method per operation
- **Calculators**: Stateless enum with static methods — pure computation, no side effects
- **Directory size**: Max 7 `.swift` files per directory; split into subdirectories when exceeded
- **Method size**: Most 20–30 lines; orchestration up to 100

## Testing Patterns

- **Framework**: Swift Testing (`@Suite`, `@Test`, `#expect`, `#require`) — NOT XCTest
- **Unit tests**: Pure logic calculators, ViewModel tests with test doubles
- **Repository tests**: Real SwiftData with `ModelConfiguration(isStoredInMemoryOnly: true)`
- **Test doubles**: Protocol-conforming fakes in `RecipePlannerTestSupport` — fakes over mocks, `Test` prefix naming
- **Test factories**: `TestRecipeFactory` enum with static factory methods and sensible defaults
- **Test isolation**: Each test creates own data, random UUIDs, fresh in-memory SwiftData
- **Services tests**: Live in `Packages/RecipePlannerServices/Tests/`
- **App-level tests**: ViewModel tests in `RecipePlannerTests/`

## Documentation

Detailed documentation lives in `docs/`:
- `docs/ARCHITECTURE.md` — Package structure, MVVM pattern, DI, domain model
- `docs/TESTING.md` — Testing strategy, infrastructure, conventions
- `docs/DATABASE.md` — SwiftData models, relationships, enum storage
- `docs/MIGRATIONS.md` — Schema versioning approach
- `docs/RELEASE.md` — Release process
- `docs/SECURITY.md` — Security considerations
- `docs/HOW_TO.md` — Setup, configuration, common tasks
- `docs/feature/RECIPE_BROWSING.md` — Recipe browsing feature
- `docs/feature/MEAL_PLANNING.md` — Meal planning feature

## Conventions

- **Naming**: `*ViewModel` for view models, `*Repository` for data access, `*Client` for external boundaries, `*Calculator` for pure logic, `*View` for SwiftUI views
- **Protocols**: Plain domain names (`RecipeRepository`, `NutritionClient`)
- **Implementations**: Context-prefixed (`SwiftDataRecipeRepository`, `HttpNutritionClient`)
- **Test fakes**: Test-prefixed (`TestRecipeRepository`, `TestNutritionClient`)
- **Enums**: Stored as String rawValue in SwiftData for forward compatibility
- **Entities**: `createdAt` set once at init, `modifiedAt` updated by caller
- **`@MainActor`**: Only for ViewModels — services and models are non-isolated
- **Logging**: OSLog/Logger — never `print()`, subsystem `com.alleato.recipeplanner` + category
- **No business logic in UI layer** — Views bind to ViewModel state, forward user actions
- Swift 6.0

## Skills

Available skills in `.claude/skills/`:

### Production
- **project-structure** — Modular packages, directory layout, core/subdomain split
- **component-design** — Views, ViewModels, Repositories, Clients, Calculators
- **naming-conventions** — `*ViewModel`, `*Repository`, `*Client`, `*Calculator`, `*View`
- **entity-design** — SwiftData `@Model`, enum-as-String, createdAt/modifiedAt
- **inversion-of-control** — Protocols as contracts, constructor injection, DependencyContainer
- **error-handling** — Error enum with associated values, ErrorPresenter
- **view-architecture** — Thin SwiftUI views, `@Environment`, navigation patterns
- **concurrency** — `async`/`await`, `@MainActor`, `Task`, `Sendable`
- **state-management** — `@Observable`, `@State`, `@Environment`, `@Bindable`
- **persistence** — SwiftData `@Model`, `ModelContainer`, in-memory testing

### Project
- **project-documentation** — Required documentation structure

### Testing
- **adding-unit-tests** — Swift Testing for pure logic and ViewModels
- **test-data-isolation** — Random UUIDs, fresh data, factory helpers
- **testing-boundaries** — Protocol-conforming fakes, call capture, contract fidelity
- **adding-integration-tests** — ViewModel tests with test doubles, repository tests with in-memory SwiftData
- **schema-migrations** — SwiftData VersionedSchema, SchemaMigrationPlan, lightweight migrations
