---
name: schema-migrations
description: Schema migration patterns using SwiftData VersionedSchema and SchemaMigrationPlan. Covers creating versioned schemas, lightweight migration stages, and registering migration plans. Use when modifying @Model properties, types, or relationships.
version: 1.0.0
---

# Schema Migrations

## Step-by-step

### 1. Create a new VersionedSchema

Each schema version captures the full model definitions at that point in time. Place in `Packages/RecipePlannerCore/Sources/RecipePlannerCore/Models/Migration/Versions/`.

```swift
// SchemaV2.swift
import SwiftData

enum RecipePlannerSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Recipe.self, Ingredient.self, MealPlan.self]
    }

    @Model
    final class Recipe {
        var id: UUID = UUID()
        var name: String = ""
        var summary: String = ""
        var instructions: String = ""
        var servings: Int = 4
        var prepTimeMinutes: Int = 0
        var cookTimeMinutes: Int = 0
        var category: String = "dinner"
        var difficulty: String = "medium"  // ← new field
        var createdAt: Date = Date()
        var modifiedAt: Date = Date()

        @Relationship(deleteRule: .cascade, inverse: \Ingredient.recipe)
        var ingredients: [Ingredient]?
    }

    // Include ALL models, even unchanged ones
    @Model
    final class Ingredient { /* ... full definition ... */ }

    @Model
    final class MealPlan { /* ... full definition ... */ }
}
```

### 2. Add a lightweight migration stage

Add the migration stage to the migration plan. Place the plan in `Packages/RecipePlannerCore/Sources/RecipePlannerCore/Models/Migration/`.

```swift
// RecipePlannerMigrationPlan.swift
import SwiftData

enum RecipePlannerMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            RecipePlannerSchemaV1.self,
            RecipePlannerSchemaV2.self,
        ]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: RecipePlannerSchemaV1.self,
        toVersion: RecipePlannerSchemaV2.self
    )
}
```

### 3. Update the live model

Update the actual `@Model` in `RecipePlannerCore/Models/` to match the new schema version:

```swift
@Model
public final class Recipe {
    // ... existing fields ...
    public var difficulty: String = RecipeDifficulty.medium.rawValue

    public var recipeDifficulty: RecipeDifficulty {
        RecipeDifficulty(rawValue: difficulty) ?? .medium
    }
}
```

### 4. Register the migration plan

Update `ModelContainer` initialization in the app entry point:

```swift
let container = try ModelContainer(
    for: schema,
    migrationPlan: RecipePlannerMigrationPlan.self
)
```

### 5. Test the migration

Verify the new schema works with in-memory SwiftData:

```swift
@Test @MainActor
func newFieldHasDefault() throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: Recipe.self, Ingredient.self, MealPlan.self,
        configurations: config
    )
    let context = ModelContext(container)
    let recipe = TestRecipeFactory.makeRecipe(name: "Test")
    context.insert(recipe)
    try context.save()

    let fetched = try context.fetch(FetchDescriptor<Recipe>()).first
    #expect(fetched?.difficulty == "medium")
}
```

## Conventions

- Each `VersionedSchema` enum includes **all** model definitions — unchanged models must be redeclared
- Prefer **lightweight migrations** (additive changes with defaults) — avoid custom migration stages unless data transformation is required
- New properties must have default values for lightweight migration compatibility
- Schema version files go in `Models/Migration/Versions/SchemaV{N}.swift`
- The migration plan goes in `Models/Migration/RecipePlannerMigrationPlan.swift`
- Store enums as String rawValue (not enum type) for forward compatibility
- Document each version's changes in `docs/MIGRATIONS.md`
