# Recipe Browsing

## Overview

The recipe browsing feature allows users to create, view, edit, search, and delete recipes. It is the core feature of the app.

## Components

| Component | Type | Responsibility |
|---|---|---|
| `RecipeListView` | SwiftUI View | Displays recipes in a searchable, filterable list |
| `RecipeListViewModel` | `@Observable @MainActor` | Manages recipe list state, search, category filtering, delete |
| `RecipeDetailView` | SwiftUI View | Displays full recipe details (ingredients, instructions, times) |
| `RecipeDetailViewModel` | `@Observable @MainActor` | Loads single recipe, manages detail state |
| `RecipeFormView` | SwiftUI View | Create/edit form for recipe properties and ingredients |
| `RecipeRepository` | Protocol | Data access contract: `fetchAll`, `fetch(id:)`, `save`, `delete`, `search` |
| `SwiftDataRecipeRepository` | Implementation | SwiftData-backed persistence |

## User Flows

### Browse Recipes
1. `RecipeListView` renders on app launch.
2. `RecipeListViewModel.loadRecipes()` fetches all recipes from `RecipeRepository`.
3. Recipes display in a list. User can tap to navigate to `RecipeDetailView`.

### Search Recipes
1. User types in the search bar.
2. `RecipeListViewModel.searchText` updates.
3. `loadRecipes()` calls `recipeRepository.search(query:)` when search text is non-empty.

### Filter by Category
1. User selects a `RecipeCategory` filter.
2. `RecipeListViewModel.selectedCategory` updates.
3. `filteredRecipes` computed property filters the loaded recipes client-side.

### Create / Edit Recipe
1. User navigates to `RecipeFormView` (via "Add" button or edit action).
2. User fills in recipe details and ingredients.
3. On save, the recipe is persisted via `RecipeRepository.save(_:)`.

### Delete Recipe
1. User swipes to delete in `RecipeListView`.
2. `RecipeListViewModel.deleteRecipe(_:)` calls `RecipeRepository.delete(_:)` and removes from local state.

## Data Model

See `docs/DATABASE.md` for the `Recipe` and `Ingredient` model schemas.

## Testing

- `RecipeListViewModelTests` -- Tests loading, searching, deleting, and error handling using `TestRecipeRepository`.
- `RecipeDetailViewModelTests` -- Tests detail loading and state management.
- `RecipeRepositoryTests` -- Tests `SwiftDataRecipeRepository` with in-memory SwiftData container.
