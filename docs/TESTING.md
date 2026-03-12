# Testing

## Framework

All tests use the **Swift Testing** framework (`@Suite`, `@Test`, `#expect`). No XCTest.

## Test Organization

| Test Location | What It Tests | Infrastructure |
|---|---|---|
| `Packages/RecipePlannerServices/Tests/` | Calculators, repository logic | SPM test target, in-memory SwiftData |
| `RecipePlannerTests/` | ViewModel behavior | Xcode test target, test doubles |

## Running Tests

```bash
# SPM package tests (fast, no simulator)
cd Packages/RecipePlannerServices && swift test

# App-level tests (requires simulator)
xcodebuild -scheme RecipePlanner -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Test Doubles

Test doubles live in the `RecipePlannerTestSupport` package. They are fakes that implement the real protocol with in-memory storage and call-capture counters.

| Test Double | Replaces | Pattern |
|---|---|---|
| `TestRecipeRepository` | `SwiftDataRecipeRepository` | In-memory array, tracks call counts and arguments |
| `TestMealPlanRepository` | `SwiftDataMealPlanRepository` | In-memory array, tracks call counts |
| `TestNutritionClient` | `StubNutritionClient` | Configurable responses, call tracking |

Each test double exposes:
- `*CallCount` properties for verifying interactions
- `errorToThrow` for simulating failures
- Internal state (e.g., `recipes` array) for verification

## Factory Helpers

`TestRecipeFactory` provides static factory methods with sensible defaults:
- `makeRecipe(...)` -- single recipe with optional overrides
- `makeIngredient(...)` -- single ingredient
- `makeMealPlan(...)` -- single meal plan
- `makeRecipeWithIngredients(...)` -- recipe pre-populated with ingredients

## Test Isolation

- Each test creates fresh data via factory helpers with random UUIDs.
- No shared mutable state between tests.
- In-memory SwiftData containers for repository tests ensure no persistence between runs.

## Conventions

- Test method names describe the scenario: `emptyMealPlansReturnsEmptyList`, `duplicateIngredientsAreCombined`.
- Assert on observable outputs (returned values, state properties, call counts) rather than implementation internals.
- Use `#expect` for all assertions.
