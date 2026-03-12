---
name: project-structure
description: Modular packages with domain-oriented organization and 7-file directory limit
version: 1.0.0
---

# Project Structure

## Package Layout

Three Swift packages plus the app target. Dependency flows one direction: App -> Services -> Core.

```
RecipePlanner/
  App/
    RecipePlannerApp.swift
    DependencyContainer.swift
  ViewModels/
  Views/
    RecipeList/
    RecipeDetail/
    MealPlan/
  Components/
Packages/
  RecipePlannerCore/         # Pure models, no dependencies
  RecipePlannerServices/     # Business logic, protocols, implementations
  RecipePlannerTestSupport/  # Fakes, factories, test helpers
```

## Package Responsibilities

### RecipePlannerCore

Pure value types and model definitions. No business logic, no external dependencies.

```swift
// Package.swift targets
.target(name: "RecipePlannerCore")
```

Contains: `@Model` entities, enums, shared types, DTOs.

### RecipePlannerServices

Protocols, business logic, and production implementations. Depends only on Core.

```swift
.target(
    name: "RecipePlannerServices",
    dependencies: ["RecipePlannerCore"]
)
```

Contains: repository protocols, client protocols, calculators, service implementations.

### RecipePlannerTestSupport

Test fakes, factories, and helpers. Depends on both Core and Services.

```swift
.target(
    name: "RecipePlannerTestSupport",
    dependencies: ["RecipePlannerCore", "RecipePlannerServices"]
)
```

Contains: `TestRecipeRepository`, `RecipeFactory`, assertion helpers.

## App Target Structure

```
App/                  # App entry point, dependency wiring
ViewModels/           # @Observable view models
Views/
  RecipeList/         # Feature-specific views
  RecipeDetail/
  MealPlan/
Components/           # Reusable UI components (cards, badges, inputs)
```

## Rules

- **7-file directory limit**: When a directory exceeds 7 files, evaluate whether to split into subdirectories by feature or subdomain.
- **Domain-oriented naming**: Directories named after domain concepts (`MealPlan/`, `ShoppingList/`), not technology (`Network/`, `Database/`).
- **One public type per file**: File name matches the primary type it contains.
- **No circular dependencies**: Package dependency graph is strictly `App -> Services -> Core`. TestSupport sits alongside, never imported by production code.
- **Feature directories under Views/**: Each feature gets its own subdirectory. Shared UI goes in `Components/`.

## Adding a New Feature

1. Models in `RecipePlannerCore`. 2. Protocols + impls in `RecipePlannerServices`. 3. Test fakes in `RecipePlannerTestSupport`. 4. ViewModel in `ViewModels/`. 5. Views in `Views/{FeatureName}/`. 6. Wire in `DependencyContainer`.

## Anti-Patterns

- Business logic in the app target instead of Services package.
- Importing `RecipePlannerTestSupport` in production code.
- `Utilities/` or `Helpers/` grab-bag directories.
