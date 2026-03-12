---
name: test-data-isolation
description: Ensures tests are independent by using random UUIDs, fresh data per test, and factory helpers. Tests must not depend on data from other tests. Use when writing or reviewing tests.
version: 1.0.0
---

# Test Data Isolation

Each test must be fully independent — it creates its own data, uses random identifiers, and never assumes or depends on state left by other tests.

## Principles

### 1. Every test creates its own data

Tests must not read, reference, or depend on data created by other tests. Each test arranges its own inputs and asserts only on the outputs it produces.

```swift
// Bad — depends on data from another test
let recipes = try repo.fetchAll()
#expect(recipes.first?.name == "Expected Recipe")

// Good — creates its own data, then queries it
let recipe = TestRecipeFactory.makeRecipe(name: "Pasta Carbonara")
try repo.save(recipe)
let fetched = try repo.fetch(id: recipe.id)
#expect(fetched?.name == "Pasta Carbonara")
```

### 2. Use random identifiers

All IDs must be random. `UUID()` is the default in factory methods. This prevents accidental coupling between tests and ensures tests pass regardless of execution order.

```swift
// Bad — hardcoded IDs risk collision
let recipe = Recipe(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    name: "Test Recipe")

// Good — random IDs guarantee isolation
let recipe = TestRecipeFactory.makeRecipe(name: "Test Recipe")
```

### 3. Distinguish domain data from contextual data

**Domain data** is what the test is exercising — the entity being created, modified, or queried. Each test creates its own.

**Contextual data** is the prerequisite state that must exist for the domain operation to succeed — a recipe that a meal plan references, ingredients that a shopping list aggregates. Create contextual data in the test or via factory helpers so every test starts with a valid context.

```swift
@Test @MainActor
func addMealPlanWithRecipe() throws {
    let context = try makeInMemoryContext()
    let recipeRepo = SwiftDataRecipeRepository(modelContext: context)
    let mealPlanRepo = SwiftDataMealPlanRepository(modelContext: context)

    // Contextual data — recipe must exist for meal plan to reference
    let recipe = TestRecipeFactory.makeRecipe(name: "Tacos")
    try recipeRepo.save(recipe)

    // Domain data — what this test is actually exercising
    let mealPlan = TestRecipeFactory.makeMealPlan(
        mealType: .dinner,
        recipe: recipe
    )
    try mealPlanRepo.save(mealPlan)

    let fetched = try mealPlanRepo.fetchAll()
    #expect(fetched.count == 1)
    #expect(fetched.first?.recipe?.name == "Tacos")
}
```

### 4. In-memory persistence resets between tests

Each test function creates its own `ModelContext` from a fresh in-memory container. No data leaks between tests.

```swift
@MainActor
private func makeInMemoryContext() throws -> ModelContext {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: Recipe.self, Ingredient.self, MealPlan.self,
        configurations: config
    )
    return ModelContext(container)
}
```

### 5. Test doubles start empty

Test doubles (e.g., `TestRecipeRepository`) begin with no data. Each test populates its own. Never share a test double instance between test functions.

```swift
@Test @MainActor
func loadRecipesPopulatesViewModel() throws {
    let repo = TestRecipeRepository()
    repo.recipes = [TestRecipeFactory.makeRecipe(name: "Soup")]
    let viewModel = RecipeListViewModel(recipeRepository: repo)

    viewModel.loadRecipes()

    #expect(viewModel.recipes.count == 1)
}
```

### 6. Never hardcode IDs

Hardcoded IDs create hidden coupling. Even if tests appear independent, hardcoded IDs can cause:
- **Flaky tests** when execution order changes
- **False positives** when a test accidentally reads another test's data
- **Cascading failures** when one test's data pollutes another's assertions

## Factory pattern

`TestRecipeFactory` is a stateless enum in the `RecipePlannerTestSupport` package. Every parameter has a default value so tests only specify what matters.

```swift
public enum TestRecipeFactory {
    public static func makeRecipe(
        id: UUID = UUID(),
        name: String = "Test Recipe",
        summary: String = "A test recipe",
        instructions: String = "Step 1: Test",
        servings: Int = 4,
        prepTimeMinutes: Int = 15,
        cookTimeMinutes: Int = 30,
        category: RecipeCategory = .dinner,
        ingredients: [Ingredient] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) -> Recipe { ... }
}
```

Override only the parameters the test cares about; rely on factory defaults for everything else. Use descriptive names to make test intent clear (e.g., `name: "Delete Me"`).

## What about database cleanup?

In-memory SwiftData containers are created fresh per test, so cleanup is automatic. For ViewModel tests using test doubles, each test creates its own fake repository instance. Because of this:

- In-memory containers are destroyed when the test function exits
- Random IDs mean no collisions even if containers were shared
- Test doubles start empty — no leftover state to clean up

If your domain requires stricter isolation (e.g., shared persistent containers in UI tests), create a fresh `ModelConfiguration(isStoredInMemoryOnly: true)` per test.

## Checklist

When writing or reviewing tests, verify:

- [ ] Each test creates its own domain data (recipes, meal plans, etc.)
- [ ] All IDs are random — no hardcoded UUID strings
- [ ] Contextual data (prerequisite entities) is created in the test or factory helpers
- [ ] No test reads or references data created by another test
- [ ] Assertions reference the test's own data — not hardcoded expected values
- [ ] Test doubles and in-memory containers are fresh per test function
