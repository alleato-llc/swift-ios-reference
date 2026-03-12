# Database

## Persistence Layer

RecipePlanner uses **SwiftData** for local on-device persistence. All models are annotated with `@Model` and managed through a `ModelContainer` configured at app launch.

## Models

### Recipe

| Property | Type | Notes |
|---|---|---|
| `id` | `UUID` | Primary identifier |
| `name` | `String` | Recipe title |
| `summary` | `String` | Short description |
| `instructions` | `String` | Full preparation instructions |
| `servings` | `Int` | Number of servings (default: 4) |
| `prepTimeMinutes` | `Int` | Preparation time |
| `cookTimeMinutes` | `Int` | Cooking time |
| `category` | `String` | Stored as `RecipeCategory.rawValue` |
| `createdAt` | `Date` | Creation timestamp |
| `modifiedAt` | `Date` | Last modification timestamp |
| `ingredients` | `[Ingredient]?` | Cascade delete relationship |

### Ingredient

| Property | Type | Notes |
|---|---|---|
| `id` | `UUID` | Primary identifier |
| `name` | `String` | Ingredient name |
| `quantity` | `Double` | Amount needed |
| `unit` | `String` | Stored as `MeasurementUnit.rawValue` |
| `createdAt` | `Date` | Creation timestamp |
| `modifiedAt` | `Date` | Last modification timestamp |
| `recipe` | `Recipe?` | Inverse relationship |

### MealPlan

| Property | Type | Notes |
|---|---|---|
| `id` | `UUID` | Primary identifier |
| `date` | `Date` | Planned date |
| `mealType` | `String` | Stored as `MealType.rawValue` |
| `notes` | `String` | Optional notes |
| `createdAt` | `Date` | Creation timestamp |
| `modifiedAt` | `Date` | Last modification timestamp |
| `recipe` | `Recipe?` | Associated recipe |

## Enums (String Raw Values)

Enums are stored as their `String` raw values for SwiftData compatibility. Computed properties on each model provide typed access.

- **RecipeCategory**: `breakfast`, `lunch`, `dinner`, `snack`, `dessert`
- **MealType**: `breakfast`, `lunch`, `dinner`, `snack`
- **MeasurementUnit**: `cups`, `tablespoons`, `teaspoons`, `ounces`, `grams`, `pieces`, `whole`

## Relationships

- `Recipe` -> `[Ingredient]`: One-to-many with cascade delete. Deleting a recipe removes its ingredients.
- `MealPlan` -> `Recipe`: Many-to-one. Multiple meal plans can reference the same recipe.

## CloudKit

No CloudKit integration currently. SwiftData stores data locally in the app's default container.
