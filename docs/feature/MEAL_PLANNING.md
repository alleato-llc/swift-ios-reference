# Meal Planning

## Overview

The meal planning feature lets users assign recipes to specific days and meal types for weekly planning, and automatically generates a consolidated shopping list from planned meals.

## Components

| Component | Type | Responsibility |
|---|---|---|
| `MealPlanView` | SwiftUI View | Weekly meal plan overview with day/meal grid |
| `MealPlanWeekView` | SwiftUI View | Week navigation and day-level layout |
| `MealPlanViewModel` | `@Observable @MainActor` | Weekly plan state, add/delete plans, week navigation, shopping list |
| `ShoppingListView` | SwiftUI View | Displays aggregated shopping list |
| `ShoppingListCalculator` | Stateless `enum` | Aggregates ingredients from meal plans into `ShoppingItem` list |
| `MealPlanRepository` | Protocol | Data access: `fetchWeek`, `save`, `delete` |
| `SwiftDataMealPlanRepository` | Implementation | SwiftData-backed persistence |

## User Flows

### View Weekly Plan
1. `MealPlanView` loads with the current week.
2. `MealPlanViewModel.loadWeek()` fetches plans for the week from `MealPlanRepository` and available recipes from `RecipeRepository`.
3. Plans are grouped by day via `plans(for:)`.

### Navigate Weeks
1. User taps forward/back arrows.
2. `MealPlanViewModel.navigateWeek(by:)` shifts `selectedDate` by 7 days.
3. Week reloads with new data.

### Add a Meal
1. User selects a date, meal type, and recipe.
2. `MealPlanViewModel.addMealPlan(date:mealType:recipe:notes:)` creates a `MealPlan` and saves it.
3. The week reloads, and the shopping list recalculates.

### Delete a Meal
1. User removes a meal plan entry.
2. `MealPlanViewModel.deleteMealPlan(_:)` deletes it and recalculates the shopping list.

### View Shopping List
1. `ShoppingListView` displays `MealPlanViewModel.shoppingItems`.
2. Items are computed by `ShoppingListCalculator.calculate(from:)`.
3. Ingredients with the same name and unit are combined (quantities summed).
4. Results are sorted alphabetically.

## Shopping List Calculation

`ShoppingListCalculator` is a stateless enum with a single static method:

- Groups ingredients by lowercase name + unit
- Sums quantities for matching ingredients
- Returns sorted `[ShoppingItem]`

## Data Model

See `docs/DATABASE.md` for the `MealPlan` model schema.

## Testing

- `MealPlanViewModelTests` -- Tests week loading, adding/deleting plans, week navigation, and error handling using `TestMealPlanRepository` and `TestRecipeRepository`.
- `ShoppingListCalculatorTests` -- Tests aggregation, deduplication, empty input, missing recipes, and sort order.
