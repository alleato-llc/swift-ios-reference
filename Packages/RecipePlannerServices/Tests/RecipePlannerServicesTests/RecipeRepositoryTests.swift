import Foundation
import RecipePlannerCore
import RecipePlannerTestSupport
import SwiftData
import Testing

@testable import RecipePlannerServices

@Suite
struct RecipeRepositoryTests {
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
    func saveAndFetchAllReturnsRecipe() throws {
        let context = try makeInMemoryContext()
        let repo = SwiftDataRecipeRepository(modelContext: context)
        let recipe = TestRecipeFactory.makeRecipe(name: "Pasta Carbonara")

        try repo.save(recipe)
        let results = try repo.fetchAll()

        #expect(results.count == 1)
        #expect(results.first?.name == "Pasta Carbonara")
    }

    @Test @MainActor
    func fetchByIdReturnsCorrectRecipe() throws {
        let context = try makeInMemoryContext()
        let repo = SwiftDataRecipeRepository(modelContext: context)
        let recipe = TestRecipeFactory.makeRecipe(name: "Find Me")

        try repo.save(recipe)
        let found = try repo.fetch(id: recipe.id)

        #expect(found?.name == "Find Me")
    }

    @Test @MainActor
    func fetchByIdReturnsNilForUnknownId() throws {
        let context = try makeInMemoryContext()
        let repo = SwiftDataRecipeRepository(modelContext: context)

        let found = try repo.fetch(id: UUID())

        #expect(found == nil)
    }

    @Test @MainActor
    func deleteRemovesRecipe() throws {
        let context = try makeInMemoryContext()
        let repo = SwiftDataRecipeRepository(modelContext: context)
        let recipe = TestRecipeFactory.makeRecipe(name: "Delete Me")

        try repo.save(recipe)
        try repo.delete(recipe)
        let results = try repo.fetchAll()

        #expect(results.isEmpty)
    }

    @Test @MainActor
    func searchFindsMatchingRecipes() throws {
        let context = try makeInMemoryContext()
        let repo = SwiftDataRecipeRepository(modelContext: context)

        try repo.save(TestRecipeFactory.makeRecipe(name: "Chicken Parmesan"))
        try repo.save(TestRecipeFactory.makeRecipe(name: "Beef Tacos"))
        try repo.save(TestRecipeFactory.makeRecipe(name: "Chicken Tikka"))

        let results = try repo.search(query: "Chicken")

        #expect(results.count == 2)
        #expect(results.allSatisfy { $0.name.contains("Chicken") })
    }
}
