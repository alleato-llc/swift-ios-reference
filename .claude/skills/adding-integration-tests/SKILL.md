---
name: adding-integration-tests
description: Integration tests that exercise ViewModels with test doubles and repositories with real in-memory SwiftData. Covers assertion patterns and derive-from-inputs. Use when testing component interactions or data persistence.
version: 1.0.0
---

# Adding Integration Tests

Integration tests exercise a component with its dependencies — test doubles for ViewModels, real in-memory SwiftData for repositories.

## Two flavors

| Flavor | Dependencies | Example |
|---|---|---|
| **ViewModel tests** | Test doubles (TestRecipeRepository, TestNutritionClient) | `RecipeListViewModelTests` |
| **Repository tests** | Real SwiftData (in-memory ModelContainer) | `RecipeRepositoryTests` |

## ViewModel tests (with test doubles)

Test the ViewModel layer using fakes from `RecipePlannerTestSupport`. Inject the fake, exercise the ViewModel method, assert on ViewModel state and fake call counts.

```swift
@Suite
struct RecipeListViewModelTests {
    @Test @MainActor
    func loadRecipesPopulatesList() {
        let repo = TestRecipeRepository()
        try! repo.save(TestRecipeFactory.makeRecipe(name: "Test Recipe"))
        let viewModel = RecipeListViewModel(recipeRepository: repo)

        viewModel.loadRecipes()

        #expect(viewModel.recipes.count == 1)
        #expect(viewModel.recipes.first?.name == "Test Recipe")
    }

    @Test @MainActor
    func deleteRecipeDelegatesToRepository() {
        let repo = TestRecipeRepository()
        let recipe = TestRecipeFactory.makeRecipe(name: "Delete Me")
        try! repo.save(recipe)
        let viewModel = RecipeListViewModel(recipeRepository: repo)
        viewModel.loadRecipes()

        viewModel.deleteRecipe(recipe)

        #expect(viewModel.recipes.isEmpty)
        #expect(repo.deleteCallCount == 1)
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
        #expect(viewModel.errorMessage != nil)
    }
}
```

## Repository tests (real SwiftData)

Test the repository against real SwiftData. Each test gets a fresh in-memory container — no data leaks between tests.

```swift
@Suite
struct RecipeRepositoryTests {
    @MainActor
    private func makeInMemoryContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Recipe.self, Ingredient.self, MealPlan.self,
            configurations: config
        )
        return ModelContext(container)
    }

    @Test @MainActor
    func saveAndFetchAllReturnsRecipe() throws {
        let context = try makeInMemoryContext()
        let repo = SwiftDataRecipeRepository(modelContext: context)
        let recipe = TestRecipeFactory.makeRecipe(name: "Pasta Carbonara")

        try repo.save(recipe)
        let results = try repo.fetchAll()

        #expect(results.count == 1)
        #expect(results.first?.name == "Pasta Carbonara")
    }

    @Test @MainActor
    func fetchByIdReturnsNilForUnknownId() throws {
        let context = try makeInMemoryContext()
        let repo = SwiftDataRecipeRepository(modelContext: context)

        let found = try repo.fetch(id: UUID())

        #expect(found == nil)
    }

    @Test @MainActor
    func deleteRemovesRecipe() throws {
        let context = try makeInMemoryContext()
        let repo = SwiftDataRecipeRepository(modelContext: context)
        let recipe = TestRecipeFactory.makeRecipe(name: "Delete Me")

        try repo.save(recipe)
        try repo.delete(recipe)
        let results = try repo.fetchAll()

        #expect(results.isEmpty)
    }
}
```

## What to assert on

Assert on **observable side effects**, not internal implementation:

1. **ViewModel state** — published properties after the operation (`recipes`, `isShowingError`)
2. **Test double call counts** — verify delegation happened (`repo.deleteCallCount == 1`)
3. **Error state** — `isShowingError`, `errorMessage` after error injection
4. **Repository state** — fetch after save/delete to verify persistence
5. **Negative assertions** — verify side effects did NOT happen on failure paths

### Derive expected values from inputs

Do not hardcode expected values when they can be computed from the test inputs:

```swift
// Bad — magic value, reader must trace back
let recipe = TestRecipeFactory.makeRecipe(name: "Pasta", servings: 4)
try repo.save(recipe)
let fetched = try repo.fetch(id: recipe.id)
#expect(fetched?.servings == 4)

// Good — derived from the input, documents the contract
#expect(fetched?.servings == recipe.servings)
#expect(fetched?.name == recipe.name)
```

## Conventions

- ViewModel tests: `@Suite` struct, `@Test @MainActor` per test function
- Repository tests: `@Suite` struct, `@Test @MainActor`, fresh `ModelContext` per test
- Use `TestRecipeFactory` for test data — override only what matters
- Use `#expect` for assertions, `#require` for preconditions that must hold
- Test both success and error paths
- Verify that failure paths do NOT trigger downstream side effects
- Named `*Tests` (e.g., `RecipeListViewModelTests`, `RecipeRepositoryTests`)
- ViewModel tests live in `RecipePlannerTests/` (app target)
- Repository tests live in `Packages/RecipePlannerServices/Tests/`

## Checklist

When writing or reviewing integration tests, verify:

- [ ] ViewModel tests inject test doubles, not real repositories
- [ ] Repository tests use `ModelConfiguration(isStoredInMemoryOnly: true)`
- [ ] Each test creates its own data — no shared mutable state
- [ ] Both success and error paths tested
- [ ] Assertions use observable state (ViewModel properties, return values, call counts)
- [ ] Error injection tested via `errorToThrow`
- [ ] Expected values derived from inputs, not hardcoded
