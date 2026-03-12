---
name: view-architecture
description: Thin SwiftUI views with environment-based DI and navigation patterns
version: 1.0.0
---

# View Architecture

Views are thin presentation layers that bind to ViewModels. No business logic in views.

## Principles

1. **Views bind to ViewModels** -- `@Bindable var viewModel` for two-way binding to `@Observable` ViewModels
2. **No business logic in views** -- views call ViewModel methods; all logic lives in the ViewModel
3. **`@Environment` for dependency injection** -- repositories and clients injected via SwiftUI environment
4. **Navigation via `NavigationStack`** -- type-safe `navigationDestination(for:)` routing
5. **Break complex views into computed properties or private subviews**

## View structure

```swift
import RecipePlannerCore
import SwiftUI

struct RecipeListView: View {
    @Bindable var viewModel: RecipeListViewModel
    @State private var isShowingAddRecipe = false

    var body: some View {
        List {
            ForEach(viewModel.filteredRecipes, id: \.id) { recipe in
                NavigationLink(value: recipe) {
                    RecipeRowView(recipe: recipe)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    viewModel.deleteRecipe(viewModel.filteredRecipes[index])
                }
            }
        }
        .navigationTitle("Recipes")
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailView(
                viewModel: RecipeDetailViewModel(
                    recipe: recipe,
                    recipeRepository: viewModel.recipeRepository
                )
            )
        }
        .searchable(text: $viewModel.searchText)
        .onChange(of: viewModel.searchText) {
            viewModel.loadRecipes()
        }
        .onAppear {
            viewModel.loadRecipes()
        }
        .alert("Error", isPresented: $viewModel.isShowingError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .sheet(isPresented: $isShowingAddRecipe) {
            NavigationStack {
                RecipeFormView(recipe: nil, recipeRepository: viewModel.recipeRepository) {
                    isShowingAddRecipe = false
                    viewModel.loadRecipes()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { isShowingAddRecipe = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
```

## Key patterns

### Data loading with `.onAppear`

```swift
.onAppear {
    viewModel.loadRecipes()
}
```

### Error display with `.alert`

The ViewModel exposes `isShowingError: Bool` and `errorMessage: String?`. The view binds to these.

```swift
.alert("Error", isPresented: $viewModel.isShowingError) {
    Button("OK") {}
} message: {
    Text(viewModel.errorMessage ?? "An unknown error occurred")
}
```

### Modal presentation with `.sheet`

Use `@State private var` for presentation state. The sheet creates its own ViewModel.

```swift
@State private var isShowingAddRecipe = false

.sheet(isPresented: $isShowingAddRecipe) {
    NavigationStack {
        RecipeFormView(...)
    }
}
```

### Type-safe navigation

Use `NavigationLink(value:)` with `.navigationDestination(for:)` for type-safe routing.

```swift
NavigationLink(value: recipe) { RecipeRowView(recipe: recipe) }

.navigationDestination(for: Recipe.self) { recipe in
    RecipeDetailView(viewModel: RecipeDetailViewModel(recipe: recipe, ...))
}
```

### Private subviews

Extract repeated row layouts into private structs within the same file.

```swift
private struct RecipeRowView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recipe.name).font(.headline)
            HStack {
                Label(recipe.recipeCategory.displayName, systemImage: "tag")
                Spacer()
                Label("\(recipe.totalTimeMinutes) min", systemImage: "clock")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}
```

## Conventions

- View files live in `RecipePlanner/Views/` grouped by domain (e.g., `Recipe/`, `MealPlan/`, `Shopping/`)
- One primary view per file; private subviews in the same file are fine
- `@Bindable` for ViewModel binding, `@State` for view-local presentation state only
- Views never import `SwiftData` directly -- all persistence goes through the ViewModel
- `.searchable` binds directly to a ViewModel property
- Toolbar buttons use SF Symbols via `Image(systemName:)`
