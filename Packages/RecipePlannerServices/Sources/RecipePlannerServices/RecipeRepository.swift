import Foundation
import RecipePlannerCore

@MainActor
public protocol RecipeRepository {
    func fetchAll() throws -> [Recipe]
    func fetch(id: UUID) throws -> Recipe?
    func save(_ recipe: Recipe) throws
    func delete(_ recipe: Recipe) throws
    func search(query: String) throws -> [Recipe]
}
