---
name: concurrency
description: Swift concurrency with async/await and MainActor isolation
version: 1.0.0
---

# Concurrency

Swift structured concurrency with `@MainActor` isolation for UI-bound code. No GCD.

## Actor isolation rules

| Component | Isolation | Why |
|-----------|-----------|-----|
| ViewModels | `@MainActor` | Publish state to SwiftUI views |
| Repository protocols | `@MainActor` | SwiftData `ModelContext` is main-actor bound |
| Repository implementations | `@MainActor` | Conform to `@MainActor` protocol |
| External client protocols | Non-isolated | Network calls are async, no UI dependency |
| Models (`@Model`) | Non-isolated | SwiftData manages thread safety internally |
| Services / Calculators | Non-isolated | Pure logic, no actor requirement |

## ViewModel pattern

ViewModels are `@Observable @MainActor`. Synchronous methods for SwiftData operations; `Task {}` for async work.

```swift
@Observable
@MainActor
final class RecipeListViewModel {
    private(set) var recipes: [Recipe] = []
    private(set) var isLoading = false

    let recipeRepository: any RecipeRepository

    init(recipeRepository: any RecipeRepository) {
        self.recipeRepository = recipeRepository
    }

    // Synchronous -- SwiftData operations on MainActor
    func loadRecipes() {
        isLoading = true
        defer { isLoading = false }
        do {
            recipes = try recipeRepository.fetchAll()
        } catch {
            // handle error
        }
    }
}
```

## Async client calls from ViewModel

Use `Task {}` to bridge from synchronous context to async. The task inherits `@MainActor` from the ViewModel.

```swift
@Observable
@MainActor
final class RecipeDetailViewModel {
    private(set) var nutrition: NutritionInfo?
    private let nutritionClient: any NutritionClient

    func loadNutrition(for ingredientName: String) {
        Task {
            do {
                nutrition = try await nutritionClient.fetchNutrition(for: ingredientName)
            } catch {
                // handle error
            }
        }
    }
}
```

## Protocol isolation

Repository protocols are `@MainActor` because SwiftData requires main-actor access.

```swift
@MainActor
public protocol RecipeRepository {
    func fetchAll() throws -> [Recipe]
    func save(_ recipe: Recipe) throws
    func delete(_ recipe: Recipe) throws
    func search(query: String) throws -> [Recipe]
}
```

External client protocols are non-isolated with async methods.

```swift
public protocol NutritionClient {
    func fetchNutrition(for ingredientName: String) async throws -> NutritionInfo
}
```

## Sendable conformance

- Value types (structs, enums) used across actor boundaries should conform to `Sendable`
- Test doubles for non-isolated async protocols use `@unchecked Sendable` when they have mutable state
- `@Model` classes are managed by SwiftData and do not need manual `Sendable`

```swift
public struct ShoppingItem: Sendable, Equatable {
    public let name: String
    public let totalQuantity: Double
    public let unit: MeasurementUnit
}
```

## Conventions

- No `DispatchQueue` -- use Swift concurrency exclusively
- No `@Sendable` closures where `Task {}` works
- `@MainActor` test functions when testing ViewModels or repositories
- Synchronous methods for SwiftData operations (they are already on `@MainActor`)
- `async throws` for network/external service calls
- Use `any Protocol` for existential protocol types in stored properties
