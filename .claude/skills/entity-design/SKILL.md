---
name: entity-design
description: SwiftData @Model entities with enum-as-String and timestamp patterns
version: 1.0.0
---

# Entity Design

## Basic Entity Structure

All entities use `@Model final class` with non-optional properties and sensible defaults.

```swift
@Model
final class Recipe {
    var id: UUID
    var name: String
    var instructions: String
    var servings: Int
    var categoryRawValue: String
    var createdAt: Date
    var modifiedAt: Date

    @Relationship(deleteRule: .cascade)
    var ingredients: [Ingredient]

    init(
        name: String,
        instructions: String = "",
        servings: Int = 1,
        category: RecipeCategory = .other,
        ingredients: [Ingredient] = []
    ) {
        self.id = UUID()
        self.name = name
        self.instructions = instructions
        self.servings = servings
        self.categoryRawValue = category.rawValue
        self.ingredients = ingredients
        let now = Date()
        self.createdAt = now
        self.modifiedAt = now
    }
}
```

## Enum-as-String Pattern

SwiftData does not reliably persist Swift enums directly. Store `rawValue` as String, expose typed computed property.

```swift
var categoryRawValue: String

var category: RecipeCategory {
    get { RecipeCategory(rawValue: categoryRawValue) ?? .other }
    set { categoryRawValue = newValue.rawValue }
}
```

- Stored property named `*RawValue: String`.
- Always supply a fallback in the getter for forward compatibility.

## Timestamp Pattern

- `createdAt` set once in `init`, never mutated.
- `modifiedAt` updated explicitly by the caller before saving — no auto-update observers.
- Both non-optional, set internally (no default parameter).

## Relationships

```swift
@Relationship(deleteRule: .cascade)
var entries: [MealPlanEntry]

@Relationship
var recipe: Recipe?
```

- `.cascade` when children should not exist independently.
- Optional for references that may be unset.
- Collections default to empty arrays.

## Property Defaults

- Required fields (`name`) have no default.
- Optional-in-concept fields use sensible defaults, not `Optional`.
- Collections default to `[]`.

## Anti-Patterns

- Storing enums directly as `@Model` properties — use `rawValue` strings.
- Auto-updating `modifiedAt` in a property observer.
- Using `Optional` for fields that always have a value.
- Public setters on `createdAt`.
