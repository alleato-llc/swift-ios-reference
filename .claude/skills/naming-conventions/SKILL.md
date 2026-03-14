---
name: naming-conventions
description: Naming rules for Swift iOS types — *ViewModel for orchestrators, *Client for external boundaries, *Calculator for standalone logic. Use when creating new types or reviewing naming.
version: 1.0.0
---

# Naming Conventions

## Type suffixes

| Suffix | When to use | Depends on other components? | Example |
|---|---|---|---|
| `*View` | SwiftUI view | Yes — ViewModel | `RecipeListView` |
| `*ViewModel` | Orchestrates business logic for a screen | Yes — repositories, clients | `RecipeListViewModel` |
| `*Repository` | Data access boundary (protocol or impl) | Yes — ModelContext (impl) | `RecipeRepository` |
| `*Client` | External service boundary (protocol or impl) | Yes — URLSession, SDK (impl) | `NutritionClient` |
| `*Calculator` | Standalone logic — pure computation, analysis | No — takes inputs, returns outputs | `NutritionCalculator` |
| `*Generator` | Standalone logic — produces text/data output | No — takes inputs, returns formatted output | `ReportGenerator` |
| `*Exporter` | Standalone logic — serializes to a format | No — takes domain types, returns encoded data | `JsonRecipeExporter` |
| `*Importer` | Standalone logic — deserializes from a format | No — takes encoded data, returns domain types | `JsonRecipeImporter` |
| `*Presenter` | Centralized UI concern (e.g., error display) | No — holds state for View binding | `ErrorPresenter` |
| `*Factory` | Test data builders | No — creates test objects | `TestRecipeFactory` |

### Key rule: `*ViewModel` implies dependencies

A type named `*ViewModel` tells the reader it orchestrates other components — it has constructor-injected dependencies. If a type performs self-contained logic with no dependencies, choose a suffix that describes its purpose: `*Calculator` for analysis/computation, `*Generator` for producing formatted output, `*Exporter`/`*Importer` for serialization boundaries.

```swift
// Bad — NutritionViewModel implies it depends on other components
@Observable @MainActor
final class NutritionViewModel {
    // But it has no dependencies — just math
    func totalCalories(for ingredients: [Ingredient]) -> Double { ... }
}

// Good — NutritionCalculator tells the reader it's standalone computation
enum NutritionCalculator {
    static func totalCalories(for ingredients: [Ingredient]) -> Double { ... }
}
```

## Protocol vs Implementation vs Test Fake

| Layer | Naming rule | Example |
|---|---|---|
| Protocol | Plain domain name | `RecipeRepository`, `NutritionClient` |
| Production impl | Technology prefix | `SwiftDataRecipeRepository`, `APIProxyNutritionClient` |
| Test fake | `Test` prefix | `TestRecipeRepository`, `TestNutritionClient` |

Technology prefixes: `SwiftData`, `APIProxy`, `UserDefaults`, `InMemory` for production implementations.

```swift
// Protocol — plain domain name
protocol RecipeRepository { ... }

// Production — context prefix describing technology
final class SwiftDataRecipeRepository: RecipeRepository { ... }
final class APIProxyNutritionClient: NutritionClient { ... }
final class UserDefaultsPreferencesRepository: PreferencesRepository { ... }

// Test fake — Test prefix
final class TestRecipeRepository: RecipeRepository { ... }
final class TestNutritionClient: NutritionClient { ... }
```

## Test type suffixes

| Suffix | Type | Example |
|---|---|---|
| `*Tests` | Test suite (Swift Testing `@Suite`) | `RecipeListViewModelTests` |
| `*CalculatorTests` | Pure logic tests | `ShoppingListCalculatorTests` |
| `*RepositoryTests` | Repository tests (in-memory SwiftData) | `RecipeRepositoryTests` |

## Method naming

### Factory methods in test helpers

Use `make*` prefix for test data factory methods to distinguish from production operations:

```swift
// Builds a domain object — does not persist or interact with services
public static func makeRecipe(name: String = "Test Recipe", ...) -> Recipe { ... }
public static func makeIngredient(name: String = "Test Ingredient", ...) -> Ingredient { ... }
public static func makeMealPlan(date: Date = Date(), ...) -> MealPlan { ... }
```

### View action methods

Use imperative verbs for ViewModel methods triggered by user actions:

```swift
func loadRecipes() { ... }
func deleteRecipe(_ recipe: Recipe) { ... }
func saveRecipe() { ... }
func navigateToNextWeek() { ... }
```

## File naming

Files match their primary type name:

```
RecipeRepository.swift            # Protocol
SwiftDataRecipeRepository.swift   # Production implementation
TestRecipeRepository.swift        # Test fake
RecipeListView.swift              # View
RecipeListViewModel.swift         # ViewModel
NutritionCalculator.swift         # Calculator
ReportGenerator.swift             # Generator
JsonRecipeExporter.swift          # Exporter
JsonRecipeImporter.swift          # Importer
```

## Model and Enum naming

Domain models use plain nouns — no suffix. Enums use descriptive names.

```swift
@Model final class Recipe { ... }
@Model final class MealPlan { ... }
struct NutritionInfo { ... }
enum RecipeCategory: String { ... }
enum MealType: String { ... }
```

## Conventions

- Protocols use plain domain names — never `I*` or `*Protocol` prefixes/suffixes
- Production implementations are prefixed by technology (`SwiftData*`, `APIProxy*`)
- Test fakes are prefixed with `Test`
- Files are named after their primary type
- `*ViewModel` implies constructor-injected dependencies — standalone logic uses `*Calculator`, `*Generator`, `*Exporter`, or `*Importer`

## Checklist

When creating or reviewing types, verify:

- [ ] Type suffix matches its responsibility (ViewModel, Repository, Client, Calculator, View)
- [ ] Protocols use plain domain names without prefixes or suffixes
- [ ] Implementations use technology prefix (SwiftData*, APIProxy*, Test*)
- [ ] File name matches the primary type name
- [ ] `*ViewModel` types actually have dependencies — standalone logic uses `*Calculator`, `*Generator`, `*Exporter`, or `*Importer`
- [ ] Test factory methods use `make*` prefix
