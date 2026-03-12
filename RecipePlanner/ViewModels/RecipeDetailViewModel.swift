import Foundation
import OSLog
import RecipePlannerCore
import RecipePlannerServices

private let logger = Logger(subsystem: "com.alleato.recipeplanner", category: "recipe-detail")

@Observable
@MainActor
final class RecipeDetailViewModel {
    private(set) var recipe: Recipe
    private(set) var isSaving = false

    let recipeRepository: any RecipeRepository
    private let errorPresenter = ErrorPresenter()

    var isShowingError: Bool {
        get { errorPresenter.isShowingError }
        set { if !newValue { errorPresenter.dismiss() } }
    }

    var errorMessage: String? {
        errorPresenter.currentError?.errorDescription
    }

    init(recipe: Recipe, recipeRepository: any RecipeRepository) {
        self.recipe = recipe
        self.recipeRepository = recipeRepository
    }

    func saveRecipe(
        name: String,
        summary: String,
        instructions: String,
        servings: Int,
        prepTimeMinutes: Int,
        cookTimeMinutes: Int,
        category: RecipeCategory,
        ingredients: [Ingredient]
    ) {
        isSaving = true
        defer { isSaving = false }

        recipe.name = name
        recipe.summary = summary
        recipe.instructions = instructions
        recipe.servings = servings
        recipe.prepTimeMinutes = prepTimeMinutes
        recipe.cookTimeMinutes = cookTimeMinutes
        recipe.category = category.rawValue
        recipe.ingredients = ingredients
        recipe.modifiedAt = Date()

        do {
            try recipeRepository.save(recipe)
        } catch {
            logger.error("Failed to save recipe: \(error.localizedDescription)")
            errorPresenter.present(error)
        }
    }
}
