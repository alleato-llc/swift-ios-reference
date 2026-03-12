# Architecture

## Overview

RecipePlanner uses MVVM with protocol-based dependency injection, organized into three local Swift packages plus the main app target.

## Package Structure

| Package | Contents | Dependencies |
|---|---|---|
| **RecipePlannerCore** | Domain models, enums, extensions | SwiftData |
| **RecipePlannerServices** | Repository protocols, SwiftData implementations, calculators, clients | RecipePlannerCore |
| **RecipePlannerTestSupport** | Test doubles, factory helpers | RecipePlannerCore, RecipePlannerServices |

The main `RecipePlanner` app target depends on Core and Services. The test target depends on TestSupport.

## Component Mapping

| Component | Pattern | Responsibilities |
|---|---|---|
| **View** | Thin SwiftUI view | Layout and user interaction only. No business logic. Binds to a ViewModel. |
| **ViewModel** | `@Observable @MainActor` class | Owns state, calls repository/service methods, exposes computed properties for the view. |
| **Repository** | Protocol + SwiftData implementation | Data access. Protocol is the contract; `SwiftData*` classes are the implementations. |
| **Client** | Protocol + HTTP/stub implementation | External API boundary. Protocol defines the contract; implementations wrap network calls. |
| **Calculator** | Stateless `enum` with static methods | Pure computation. No state, no side effects. |

## Dependency Injection

`DependencyContainer` is a `@MainActor` struct that constructs all concrete implementations given a `ModelContext`. Views receive dependencies through their view models, which accept protocol-typed repositories and clients via initializer injection.

```
DependencyContainer
  -> SwiftDataRecipeRepository (as RecipeRepository)
  -> SwiftDataMealPlanRepository (as MealPlanRepository)
  -> StubNutritionClient (as NutritionClient)
```

## Data Flow

```
View -> ViewModel -> Repository (protocol) -> SwiftData
                  -> Calculator (pure functions)
                  -> Client (protocol) -> Network
```

Views observe ViewModel properties via `@Observable`. ViewModels call async repository methods and update their published state. Calculators are invoked for derived computations (e.g., shopping list aggregation).

## SwiftData Persistence

Models are annotated with `@Model` and stored in the app's default SwiftData container. Enums are persisted as `String` raw values to maintain SwiftData compatibility. Relationships use `@Relationship` with appropriate delete rules.

## Error Handling

ViewModels use an `ErrorPresenter` helper to surface errors to the UI. Repository and client errors are caught in ViewModel methods, logged via `OSLog`, and presented to the user through alert bindings.
