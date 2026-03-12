import Foundation
import RecipePlannerCore
import RecipePlannerServices

@MainActor
public final class TestRecipeRepository: RecipeRepository {
    public private(set) var recipes: [Recipe] = []
    public private(set) var saveCallCount = 0
    public private(set) var deleteCallCount = 0
    public private(set) var fetchAllCallCount = 0
    public private(set) var searchCallCount = 0
    public private(set) var lastSearchQuery: String?
    public var errorToThrow: Error?

    public init() {}

    public func fetchAll() throws -> [Recipe] {
        if let error = errorToThrow { throw error }
        fetchAllCallCount += 1
        return recipes
    }

    public func fetch(id: UUID) throws -> Recipe? {
        if let error = errorToThrow { throw error }
        return recipes.first { $0.id == id }
    }

    public func save(_ recipe: Recipe) throws {
        if let error = errorToThrow { throw error }
        saveCallCount += 1
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
        } else {
            recipes.append(recipe)
        }
    }

    public func delete(_ recipe: Recipe) throws {
        if let error = errorToThrow { throw error }
        deleteCallCount += 1
        recipes.removeAll { $0.id == recipe.id }
    }

    public func search(query: String) throws -> [Recipe] {
        if let error = errorToThrow { throw error }
        searchCallCount += 1
        lastSearchQuery = query
        return recipes.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || $0.summary.localizedCaseInsensitiveContains(query)
        }
    }
}
