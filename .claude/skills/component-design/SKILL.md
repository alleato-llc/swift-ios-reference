---
name: component-design
description: Design guidelines for Swift iOS components — Views, ViewModels, Repositories, Clients, and Calculators. Covers responsibility boundaries, method sizing, composition, and when to decompose. Use when creating or reviewing Views, ViewModels, Repositories, or Clients.
version: 1.0.0
---

# Component Design

## Shared rules

These apply to all component types.

### Single responsibility first, then size

A type should be responsible for **one thing**. File size is a secondary signal — only evaluate it after confirming the type is properly decomposed.

If a file exceeds **300–500 lines**, evaluate whether it's doing too much. Ask:

1. Does this type have more than one reason to change?
2. Can the methods be grouped into clusters that serve different purposes?
3. Would extracting a cluster into its own type make both types clearer?

If the answer to all three is no — the type is genuinely one cohesive responsibility that happens to be large — that's fine. The constraint is a trigger to evaluate, not a hard limit.

### Method size

Most methods should naturally land at **20–30 lines** when they're doing one thing well.

**Up to 100 lines** is acceptable for orchestration methods in ViewModels that coordinate a sequence of steps — each step is a clear block, and extracting them into private methods would just scatter the narrative.

**Over 100 lines** is the trigger to evaluate. Ask:
- Is this method doing more than one thing?
- Are there blocks of code that could be named (extracted into a method) to clarify the flow?
- Is there duplicated logic that could be shared?

### Method composition

Structure methods at **one level of abstraction**. A method should either coordinate high-level steps or implement low-level details — not both.

```swift
// Bad — mixes orchestration with implementation details
func saveRecipe() {
    guard !name.isEmpty else { errorPresenter.present(...); return }
    let recipe = Recipe(name: name, summary: summary, ...)
    recipe.ingredients = ingredients.map { ing in
        Ingredient(name: ing.name, quantity: Double(ing.quantity) ?? 0, ...)
    }
    do {
        try recipeRepository.save(recipe)
        // ... 20 more lines of inline state updates
    } catch { ... }
}

// Good — orchestration at one level, details pushed down
func saveRecipe() {
    guard validate() else { return }
    let recipe = buildRecipe()
    do {
        try recipeRepository.save(recipe)
        dismiss()
    } catch { errorPresenter.present(error) }
}
```

When an orchestration method is long but each step is clear and sequential, it's fine to keep it as one method. Extract when:
- A block of code needs a name to explain what it does
- The same logic appears in multiple places
- The method mixes abstraction levels

### Composition over inheritance

Prefer composing types with collaborators over building class hierarchies for code reuse.

```swift
// Bad — inheritance for code reuse
class BaseViewModel {
    let errorPresenter = ErrorPresenter()
    func handleError(_ error: Error) { errorPresenter.present(error) }
}
class RecipeListViewModel: BaseViewModel { ... }
class MealPlanViewModel: BaseViewModel { ... }

// Good — each ViewModel owns its own ErrorPresenter
@Observable @MainActor
final class RecipeListViewModel {
    let errorPresenter = ErrorPresenter()
    // ...
}
```

Use inheritance only for framework extension points (e.g., `UIViewController` subclasses if needed).

## Component types

| Component | Responsibility | Dependencies | Error handling |
|---|---|---|---|
| **View** | Display state, forward user actions | ViewModel via `@State` | No `try`/`catch` — bind to ViewModel |
| **ViewModel** | Orchestrate workflows, validate input | Repositories, Clients via protocols | Catch errors, delegate to `ErrorPresenter` |
| **Repository** | Persistence boundary (protocol) | None (protocol) / ModelContext (impl) | Throws domain errors |
| **Client** | External service boundary (protocol) | None (protocol) / URLSession (impl) | Throws domain errors |
| **Calculator** | Pure computation | None | Returns plain values |

## View

Thin — bind to ViewModel, no business logic, no data fetching.

```swift
struct RecipeListView: View {
    @State var viewModel: RecipeListViewModel

    var body: some View {
        List(viewModel.recipes) { recipe in
            RecipeRow(recipe: recipe)
        }
        .task { await viewModel.loadRecipes() }
        .alert("Error", isPresented: $viewModel.errorPresenter.isPresented,
               presenting: viewModel.errorPresenter.message) { _ in
        } message: { Text($0) }
    }
}
```

- No `try`/`catch` in views. No direct repository or client calls.
- Use `.task` for async loading. Bind to ViewModel state.

## ViewModel

`@Observable @MainActor` classes. Orchestrate business logic, own an `ErrorPresenter`.

```swift
@Observable @MainActor
final class RecipeListViewModel {
    private(set) var recipes: [Recipe] = []
    let errorPresenter = ErrorPresenter()
    private let recipeRepository: any RecipeRepository

    init(recipeRepository: any RecipeRepository) {
        self.recipeRepository = recipeRepository
    }

    func loadRecipes() async {
        do {
            recipes = try await recipeRepository.fetchAll()
        } catch { errorPresenter.present(error) }
    }
}
```

- One ViewModel per screen. Constructor injection for dependencies.
- Catch errors and delegate to `ErrorPresenter`. No SwiftUI imports.

## Repository

Protocol defines the contract. SwiftData implementation is the production version. Data access only — no business logic. One repository per aggregate root.

```swift
@MainActor
public protocol RecipeRepository {
    func fetchAll() throws -> [Recipe]
    func fetch(id: UUID) throws -> Recipe?
    func save(_ recipe: Recipe) throws
    func delete(_ recipe: Recipe) throws
}
```

- **One method per operation** — not `execute(operation:params:)`
- **No business logic** — a repository stores and retrieves data, nothing more
- `@MainActor` because `ModelContext` is main-actor bound

## Client

Protocol defines the external boundary. HTTP implementation wraps `URLSession`. One method per external operation. Return domain types, not raw `Data`.

```swift
public protocol NutritionClient {
    func fetchNutrition(for ingredient: String) async throws -> NutritionInfo
}
```

- **Method parameters are domain concepts** — not `URLRequest` or library-specific types
- **Named after the domain concept** (`NutritionClient`), not the technology (`HttpNutritionFetcher`)

## Calculator

Stateless enums with static methods for pure computation.

```swift
enum NutritionCalculator {
    static func totalCalories(for ingredients: [Ingredient]) -> Double {
        ingredients.reduce(0) { $0 + $1.calories * $1.quantity }
    }
}
```

- No state, no dependencies, no side effects.
- Use `enum` to prevent instantiation. Unit-testable without setup.

## Conventions

- Views are thin — bind to ViewModel state, forward user actions
- ViewModels own `ErrorPresenter` — no error handling in Views
- One ViewModel per screen, one repository per aggregate root
- Calculators are stateless enums — pure computation, no side effects
- Constructor injection for all dependencies — no global state
- `@MainActor` only for ViewModels and repository protocols — services and models are non-isolated

## Checklist

When creating or reviewing components, verify:

- [ ] Views contain no business logic — only state binding and user action forwarding
- [ ] ViewModels orchestrate workflows and own error presentation
- [ ] Repositories are data access only — no computation or business rules
- [ ] Clients wrap one external service — domain types in, domain types out
- [ ] Calculators are stateless with no side effects
- [ ] Methods stay at one level of abstraction
- [ ] Files under 300–500 lines; decompose if cohesion warrants it
