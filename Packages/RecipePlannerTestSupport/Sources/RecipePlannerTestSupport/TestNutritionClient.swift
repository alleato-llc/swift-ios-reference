import Foundation
import RecipePlannerServices

public final class TestNutritionClient: NutritionClient, @unchecked Sendable {
    public private(set) var fetchCallCount = 0
    public private(set) var lastIngredientName: String?
    public var nutritionToReturn: NutritionInfo = NutritionInfo(
        calories: 100,
        proteinGrams: 10,
        carbsGrams: 20,
        fatGrams: 5
    )
    public var errorToThrow: Error?

    public init() {}

    public func fetchNutrition(for ingredientName: String) async throws -> NutritionInfo {
        if let error = errorToThrow { throw error }
        fetchCallCount += 1
        lastIngredientName = ingredientName
        return nutritionToReturn
    }
}
