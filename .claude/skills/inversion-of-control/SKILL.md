---
name: inversion-of-control
description: Protocols as contracts with constructor injection via DependencyContainer
version: 1.0.0
---

# Inversion of Control

## Protocol Location

Protocols live in `RecipePlannerServices`. Production impls alongside them. Test fakes in `RecipePlannerTestSupport`.

```swift
// In RecipePlannerServices
protocol RecipeRepository {
    func fetchAll() async throws -> [Recipe]
    func fetchById(_ id: UUID) async throws -> Recipe?
    func save(_ recipe: Recipe) async throws
    func delete(_ recipe: Recipe) async throws
}
```

## Test Fakes

Controllable behavior via stored properties for assertions.

```swift
// In RecipePlannerTestSupport
final class TestRecipeRepository: RecipeRepository {
    var recipesToReturn: [Recipe] = []
    var savedRecipes: [Recipe] = []
    var errorToThrow: Error?

    func fetchAll() async throws -> [Recipe] {
        if let error = errorToThrow { throw error }
        return recipesToReturn
    }

    func save(_ recipe: Recipe) async throws {
        if let error = errorToThrow { throw error }
        savedRecipes.append(recipe)
    }
}
```

## DependencyContainer

A struct in the app target wires production implementations.

```swift
struct DependencyContainer {
    let recipeRepository: any RecipeRepository
    let mealPlanRepository: any MealPlanRepository
    let nutritionClient: any NutritionClient

    init(modelContext: ModelContext) {
        self.recipeRepository = SwiftDataRecipeRepository(modelContext: modelContext)
        self.mealPlanRepository = SwiftDataMealPlanRepository(modelContext: modelContext)
        self.nutritionClient = APIProxyNutritionClient()
    }
}
```

## Constructor Injection

ViewModels accept `any ProtocolName` via initializer. Wire from container at the app entry point.

```swift
@Observable @MainActor
final class RecipeListViewModel {
    private let recipeRepository: any RecipeRepository

    init(recipeRepository: any RecipeRepository) {
        self.recipeRepository = recipeRepository
    }
}
```

## Rules

- Use `any ProtocolName` (existential type) for dependency declarations.
- Constructor injection only — no `@Environment` for domain dependencies.
- `DependencyContainer` is the single wiring point.
- Test fakes expose stored properties (`savedRecipes`, `errorToThrow`) for assertion and control.
- Production code never imports `RecipePlannerTestSupport`.
