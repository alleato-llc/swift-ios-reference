# Migrations

## SwiftData Schema Versioning

SwiftData supports lightweight and custom migrations through `VersionedSchema` and `SchemaMigrationPlan`.

## Current State

The project is at its **initial schema** with no migrations. All models (`Recipe`, `Ingredient`, `MealPlan`) are at their original definitions.

## When Migrations Are Needed

A migration is required when:
- Adding, removing, or renaming a model property
- Changing a property's type
- Modifying relationship cardinality or delete rules
- Adding a new model that relates to existing models

## Migration Strategy

When the schema changes, follow this approach:

1. Create a `VersionedSchema` for the current schema before making changes.
2. Define the new schema version.
3. Create a `SchemaMigrationPlan` that maps the migration steps.
4. Register the migration plan with the `ModelContainer`.

```swift
enum RecipePlannerSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Recipe.self, Ingredient.self, MealPlan.self] }
}

enum RecipePlannerMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [RecipePlannerSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
```

## Guidelines

- Prefer lightweight migrations (additive changes) when possible.
- Test migrations with real data before release.
- Document each migration version and what it changes in this file.
