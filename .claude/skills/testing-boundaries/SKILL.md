---
name: testing-boundaries
description: Creates protocol-conforming fakes that honor the contract at each external boundary. Covers call capture, configurable errors, and @MainActor isolation. Use when adding a new protocol boundary or testing ViewModel/service interactions.
version: 1.0.0
---

# Testing Boundaries

Every external dependency sits behind a contract boundary — a protocol that defines what the dependency does, not how it does it (see `inversion-of-control`). This skill covers how to create test implementations that honor the contract, and how to verify your code uses the contract correctly.

## Shared principles

### 1. Fakes over mocks

Hand-written protocol-conforming fakes with in-memory state. No mock libraries — the fake is a real class with real behavior.

### 2. Contract fidelity

A test implementation must behave like the real implementation at the contract level:
- **Store and retrieve data correctly** — `save` followed by `fetchAll` returns the saved entity
- **Respect error semantics** — throw the same error types the real implementation would
- **Filter correctly** — `search(query:)` should actually filter, not return everything

A fake that always returns success without realistic behavior will let bugs through.

### 3. Call capture

Track every invocation so tests can assert on what was called:

```swift
public private(set) var saveCallCount = 0
public private(set) var deleteCallCount = 0
public private(set) var lastSearchQuery: String?
```

Use `public private(set)` — tests read, only the fake writes.

### 4. Configurable errors

All fakes support error injection via `errorToThrow`:

```swift
public var errorToThrow: Error?

public func fetchAll() throws -> [Recipe] {
    if let error = errorToThrow { throw error }
    fetchAllCallCount += 1
    return recipes
}
```

Error check runs first in every method — before incrementing call counts or modifying state.

### 5. Reset between tests

Each test function creates its own fresh fake instance. No shared state between tests. In-memory SwiftData containers are destroyed when the test function exits.

## Location

Fakes live in the `RecipePlannerTestSupport` package:

```
Packages/RecipePlannerTestSupport/Sources/RecipePlannerTestSupport/
├── TestRecipeFactory.swift         Factory with sensible defaults
├── TestRecipeRepository.swift      Fake repository
├── TestMealPlanRepository.swift    Fake repository
└── TestNutritionClient.swift       Fake client
```

## Repository fake pattern

Repository protocols are `@MainActor`, so fakes must be too.

```swift
@MainActor
public final class TestRecipeRepository: RecipeRepository {
    // In-memory storage
    public private(set) var recipes: [Recipe] = []

    // Call tracking
    public private(set) var saveCallCount = 0
    public private(set) var deleteCallCount = 0
    public private(set) var fetchAllCallCount = 0
    public private(set) var searchCallCount = 0
    public private(set) var lastSearchQuery: String?

    // Error injection
    public var errorToThrow: Error?

    public init() {}

    public func fetchAll() throws -> [Recipe] {
        if let error = errorToThrow { throw error }
        fetchAllCallCount += 1
        return recipes
    }

    public func save(_ recipe: Recipe) throws {
        if let error = errorToThrow { throw error }
        saveCallCount += 1
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
        } else {
            recipes.append(recipe)
        }
    }

    public func delete(_ recipe: Recipe) throws {
        if let error = errorToThrow { throw error }
        deleteCallCount += 1
        recipes.removeAll { $0.id == recipe.id }
    }

    public func search(query: String) throws -> [Recipe] {
        if let error = errorToThrow { throw error }
        searchCallCount += 1
        lastSearchQuery = query
        return recipes.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }
}
```

Note the contract fidelity: `save` updates if the ID exists, `delete` removes by ID, `search` actually filters. These behaviors mirror the real `SwiftDataRecipeRepository`.

## Client fake pattern

External API clients are non-isolated protocols with async methods. Fakes use `@unchecked Sendable` when state mutation is needed.

```swift
public final class TestNutritionClient: NutritionClient, @unchecked Sendable {
    public private(set) var fetchCallCount = 0
    public private(set) var lastIngredientName: String?
    public var nutritionToReturn: NutritionInfo = NutritionInfo(
        calories: 100, proteinGrams: 10, carbsGrams: 20, fatGrams: 5
    )
    public var errorToThrow: Error?

    public init() {}

    public func fetchNutrition(for ingredientName: String) async throws -> NutritionInfo {
        if let error = errorToThrow { throw error }
        fetchCallCount += 1
        lastIngredientName = ingredientName
        return nutritionToReturn
    }
}
```

## Using test doubles in tests

```swift
@Test @MainActor
func deleteRecipeRemovesFromList() {
    let repo = TestRecipeRepository()
    let recipe = TestRecipeFactory.makeRecipe(name: "Delete Me")
    try! repo.save(recipe)
    let viewModel = RecipeListViewModel(recipeRepository: repo)
    viewModel.loadRecipes()

    viewModel.deleteRecipe(recipe)

    #expect(viewModel.recipes.isEmpty)
    #expect(repo.deleteCallCount == 1)  // verify the contract was used correctly
}

@Test @MainActor
func errorSetsErrorState() {
    let repo = TestRecipeRepository()
    repo.errorToThrow = RecipePlannerError.repositoryFailure(
        underlying: NSError(domain: "test", code: 1)
    )
    let viewModel = RecipeListViewModel(recipeRepository: repo)

    viewModel.loadRecipes()

    #expect(viewModel.isShowingError)
}
```

## Conventions

- Fakes live in `Packages/RecipePlannerTestSupport/Sources/RecipePlannerTestSupport/`
- Named `Test*` (e.g., `TestRecipeRepository`, `TestNutritionClient`)
- All properties `public` so tests can configure and inspect them
- Tracked properties use `public private(set)` — tests read, only the fake writes
- Error check runs first in every method (before incrementing call counts)
- Provide sensible default return values so tests only configure what they need
- `@MainActor` fakes for `@MainActor` protocols; `@unchecked Sendable` for async-only protocols
- Each test creates its own fresh fake instance

## Checklist

When creating or reviewing test fakes, verify:

- [ ] Fake conforms to the full protocol — no missing methods
- [ ] Contract fidelity — save/fetch/delete/search behave like the real implementation
- [ ] Error injection via `errorToThrow` property
- [ ] Call counts tracked for every method
- [ ] Error check runs before call count increment and state mutation
- [ ] `@MainActor` matches the protocol's actor isolation
- [ ] Each test creates its own fresh fake — no shared state
