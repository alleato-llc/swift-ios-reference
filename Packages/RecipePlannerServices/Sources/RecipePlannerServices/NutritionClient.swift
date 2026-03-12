import Foundation

public protocol NutritionClient {
    func fetchNutrition(for ingredientName: String) async throws -> NutritionInfo
}
