---
name: persistence
description: SwiftData @Model entities with ModelContainer and in-memory testing
version: 1.0.0
---

# Persistence

SwiftData for local persistence with the repository pattern. `@Model` entities in the Core package; repository implementations in the Services package.

## Entity definition

Entities use `@Model` and live in `RecipePlannerCore`. Default values on every property for SwiftData compatibility.

```swift
import Foundation
import SwiftData

@Model
public final class Recipe {
    public var id: UUID = UUID()
    public var name: String = ""
    public var summary: String = ""
    public var instructions: String = ""
    public var servings: Int = 4
    public var prepTimeMinutes: Int = 0
    public var cookTimeMinutes: Int = 0
    public var category: String = RecipeCategory.dinner.rawValue
    public var createdAt: Date = Date()
    public var modifiedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \Ingredient.recipe)
    public var ingredients: [Ingredient]?

    // Computed property for typed access to raw-value-stored enum
    public var recipeCategory: RecipeCategory {
        RecipeCategory(rawValue: category) ?? .dinner
    }

    public init(
        id: UUID = UUID(),
        name: String,
        summary: String = "",
        // ... all parameters with defaults
    ) {
        self.id = id
        self.name = name
        // ...
    }
}
```

### Entity conventions

- Store enums as raw values (e.g., `category: String`) with a computed property for typed access
- `@Relationship` with explicit `deleteRule` and `inverse`
- Default values on every stored property
- `public` access for cross-package use

## Repository protocol

Protocols are `@MainActor` because `ModelContext` is main-actor bound.

```swift
@MainActor
public protocol RecipeRepository {
    func fetchAll() throws -> [Recipe]
    func fetch(id: UUID) throws -> Recipe?
    func save(_ recipe: Recipe) throws
    func delete(_ recipe: Recipe) throws
    func search(query: String) throws -> [Recipe]
}
```

## Repository implementation

Implementations take `ModelContext` via initializer injection. Use `FetchDescriptor` with `#Predicate` and `SortDescriptor`.

```swift
@MainActor
public final class SwiftDataRecipeRepository: RecipeRepository {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func fetchAll() throws -> [Recipe] {
        let descriptor = FetchDescriptor<Recipe>(
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func fetch(id: UUID) throws -> Recipe? {
        let descriptor = FetchDescriptor<Recipe>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    public func save(_ recipe: Recipe) throws {
        modelContext.insert(recipe)
        try modelContext.save()
    }

    public func delete(_ recipe: Recipe) throws {
        modelContext.delete(recipe)
        try modelContext.save()
    }

    public func search(query: String) throws -> [Recipe] {
        let descriptor = FetchDescriptor<Recipe>(
            predicate: #Predicate { recipe in
                recipe.name.localizedStandardContains(query)
                    || recipe.summary.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }
}
```

## ModelContainer setup

Configure at app startup. Register all `@Model` types.

```swift
@main
struct RecipePlannerApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([Recipe.self, Ingredient.self, MealPlan.self])
        container = try! ModelContainer(for: schema)
    }

    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(container)
    }
}
```

## In-memory testing

Use `ModelConfiguration(isStoredInMemoryOnly: true)` for isolated repository tests. Each test creates its own container.

```swift
@MainActor
private func makeInMemoryContext() throws -> ModelContext {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: Recipe.self, Ingredient.self, MealPlan.self,
        configurations: config
    )
    return ModelContext(container)
}

@Test @MainActor
func saveAndFetchReturnsRecipe() throws {
    let context = try makeInMemoryContext()
    let repo = SwiftDataRecipeRepository(modelContext: context)
    let recipe = TestRecipeFactory.makeRecipe(name: "Pasta Carbonara")

    try repo.save(recipe)
    let results = try repo.fetchAll()

    #expect(results.count == 1)
    #expect(results.first?.name == "Pasta Carbonara")
}
```

## Conventions

- `@Model` entities in `RecipePlannerCore` -- no SwiftData imports in the app target for models
- Repository protocols in `RecipePlannerServices` -- implementations in the same package
- One repository per aggregate root (e.g., `RecipeRepository`, `MealPlanRepository`)
- `modelContext.insert` + `modelContext.save()` for writes
- `FetchDescriptor` with `#Predicate` for queries -- no raw string predicates
- `SortDescriptor` for ordering
- Never expose `ModelContext` to ViewModels directly -- always go through the repository
