import Foundation
import RecipePlannerCore
import SwiftData

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
