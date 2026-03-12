import Foundation
import RecipePlannerServices
import SwiftData

@MainActor
struct DependencyContainer {
    let recipeRepository: any RecipeRepository
    let mealPlanRepository: any MealPlanRepository
    let nutritionClient: any NutritionClient

    init(modelContext: ModelContext) {
        self.recipeRepository = SwiftDataRecipeRepository(modelContext: modelContext)
        self.mealPlanRepository = SwiftDataMealPlanRepository(modelContext: modelContext)
        self.nutritionClient = StubNutritionClient()
    }
}

/// Stub implementation until a real nutrition API is integrated
private struct StubNutritionClient: NutritionClient {
    func fetchNutrition(for ingredientName: String) async throws -> NutritionInfo {
        NutritionInfo(calories: 0, proteinGrams: 0, carbsGrams: 0, fatGrams: 0)
    }
}
