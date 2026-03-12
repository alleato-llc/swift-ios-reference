---
name: state-management
description: Observable ViewModels with State and Environment property wrappers
version: 1.0.0
---

# State Management

`@Observable` ViewModels own application state. SwiftUI property wrappers connect views to state.

## Property wrapper guide

| Wrapper | Use | Where |
|---------|-----|-------|
| `@Observable` | Mark a class as observable | ViewModel class declaration |
| `@Bindable` | Two-way binding to `@Observable` object | View property for its ViewModel |
| `@State` | View-local state (presentation, toggles) | View struct |
| `@Environment` | Dependency injection from parent | View struct |
| `@AppStorage` | UserDefaults-backed persistent state | View or ViewModel |

## ViewModel as `@Observable`

ViewModels use `@Observable` (not `ObservableObject`). Properties update views automatically.

```swift
@Observable
@MainActor
final class RecipeListViewModel {
    // Read-only from outside -- views observe, only ViewModel mutates
    private(set) var recipes: [Recipe] = []
    private(set) var isLoading = false
    private(set) var isShowingError = false
    private(set) var errorMessage: String?

    // Read-write -- views can bind for two-way interaction
    var searchText = ""
    var selectedCategory: RecipeCategory?

    // Computed property -- derived state, automatically updates
    var filteredRecipes: [Recipe] {
        var result = recipes
        if let category = selectedCategory {
            result = result.filter { $0.recipeCategory == category }
        }
        return result
    }

    let recipeRepository: any RecipeRepository

    init(recipeRepository: any RecipeRepository) {
        self.recipeRepository = recipeRepository
    }

    func loadRecipes() {
        isLoading = true
        defer { isLoading = false }
        do {
            recipes = searchText.isEmpty
                ? try recipeRepository.fetchAll()
                : try recipeRepository.search(query: searchText)
        } catch {
            errorMessage = error.localizedDescription
            isShowingError = true
        }
    }
}
```

## View binding with `@Bindable`

`@Bindable` creates two-way bindings (`$viewModel.property`) to `@Observable` objects.

```swift
struct RecipeListView: View {
    @Bindable var viewModel: RecipeListViewModel

    var body: some View {
        List {
            ForEach(viewModel.filteredRecipes, id: \.id) { recipe in
                NavigationLink(value: recipe) {
                    Text(recipe.name)
                }
            }
        }
        .searchable(text: $viewModel.searchText)
        .alert("Error", isPresented: $viewModel.isShowingError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
}
```

## View-local state with `@State`

Use `@State` for presentation concerns that do not belong in the ViewModel.

```swift
struct RecipeListView: View {
    @Bindable var viewModel: RecipeListViewModel
    @State private var isShowingAddRecipe = false

    var body: some View {
        // ...
        .sheet(isPresented: $isShowingAddRecipe) {
            RecipeFormView(...)
        }
        .toolbar {
            Button { isShowingAddRecipe = true } label: {
                Image(systemName: "plus")
            }
        }
    }
}
```

## Dependency injection with `@Environment`

Register dependencies at the app level; views pull them from the environment.

```swift
// App-level registration
@main
struct RecipePlannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(recipeRepository)
        }
    }
}

// View consumption
struct RecipeListView: View {
    @Environment(RecipeRepository.self) var recipeRepository
}
```

## `@AppStorage` for user preferences

Backed by `UserDefaults`. Use for simple settings, not domain data.

```swift
struct SettingsView: View {
    @AppStorage("defaultServings") private var defaultServings = 4
    @AppStorage("showNutrition") private var showNutrition = true

    var body: some View {
        Form {
            Stepper("Default servings: \(defaultServings)", value: $defaultServings, in: 1...20)
            Toggle("Show nutrition", isOn: $showNutrition)
        }
    }
}
```

## Conventions

- `@Observable` replaces `ObservableObject` / `@Published` -- do not use the older pattern
- `private(set)` for ViewModel state that views should read but not write
- Computed properties for derived state -- no redundant stored state
- `@State` is only for view-local presentation concerns (sheet visibility, text field focus)
- `@Bindable` is required for `$` binding syntax with `@Observable` objects
- Dependencies flow down via `@Environment` or initializer injection
