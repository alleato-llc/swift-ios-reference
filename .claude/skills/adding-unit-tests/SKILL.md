---
name: adding-unit-tests
description: Swift Testing for pure logic and ViewModel tests
version: 1.0.0
---

# Adding Unit Tests

Unit tests verify pure business logic and ViewModel behavior without a real persistence layer or network.

## When to use unit tests

| Component | Test type | Why |
|-----------|-----------|-----|
| Calculator (stateless enum) | Unit test | Pure logic, no dependencies |
| ViewModel | Unit test | Uses test doubles for repositories/clients |
| SwiftData repository | Repository test | Needs in-memory ModelContainer |
| View | Manual / preview | No automated view tests |

## Framework

Use Swift Testing exclusively. No XCTest.

- `@Suite` on the test struct
- `@Test` on each test function
- `#expect` for assertions
- `#require` for unwrapping / preconditions that should fail the test

## Calculator tests (stateless enum)

Calculators are stateless enums with static methods. Tests call the static method directly.

```swift
import RecipePlannerCore
import RecipePlannerTestSupport
import Testing

@testable import RecipePlannerServices

@Suite
struct ShoppingListCalculatorTests {
    @Test
    func emptyMealPlansReturnsEmptyList() {
        let result = ShoppingListCalculator.calculate(from: [])
        #expect(result.isEmpty)
    }

    @Test
    func duplicateIngredientsAreCombined() {
        let recipe1 = TestRecipeFactory.makeRecipeWithIngredients(
            name: "Dish 1",
            ingredients: [("Olive Oil", 2.0, .tablespoons)]
        )
        let recipe2 = TestRecipeFactory.makeRecipeWithIngredients(
            name: "Dish 2",
            ingredients: [("Olive Oil", 3.0, .tablespoons)]
        )
        let plan1 = TestRecipeFactory.makeMealPlan(recipe: recipe1)
        let plan2 = TestRecipeFactory.makeMealPlan(recipe: recipe2)

        let result = ShoppingListCalculator.calculate(from: [plan1, plan2])

        let oil = result.first { $0.name == "olive oil" }
        #expect(oil?.totalQuantity == 5.0)
    }
}
```

## ViewModel tests with test doubles

ViewModels require `@MainActor` on the test function. Inject test doubles from `RecipePlannerTestSupport`.

```swift
import RecipePlannerCore
import RecipePlannerTestSupport
import Testing

@testable import RecipePlanner

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

## Conventions

- Named `*Tests` (e.g., `ShoppingListCalculatorTests`)
- `@Suite` struct, not class
- One `@Test` per behavior, descriptive function name
- Use `TestRecipeFactory` for test data -- never construct models inline
- Use `#require` when an unwrap failure means the rest of the test is meaningless
- Cover: normal cases, edge cases, error conditions
- Assert on observable state (ViewModel properties, return values), not internal implementation
