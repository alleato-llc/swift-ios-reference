import Foundation
import OSLog
import RecipePlannerCore
import RecipePlannerServices

private let logger = Logger(subsystem: "com.alleato.recipeplanner", category: "recipe-list")

@Observable
@MainActor
final class RecipeListViewModel {
    private(set) var recipes: [Recipe] = []
    private(set) var isLoading = false
    var searchText = ""
    var selectedCategory: RecipeCategory?

    let recipeRepository: any RecipeRepository
    private let errorPresenter = ErrorPresenter()

    var isShowingError: Bool {
        get { errorPresenter.isShowingError }
        set { if !newValue { errorPresenter.dismiss() } }
    }

    var errorMessage: String? {
        errorPresenter.currentError?.errorDescription
    }

    var filteredRecipes: [Recipe] {
        var result = recipes
        if let category = selectedCategory {
            result = result.filter { $0.recipeCategory == category }
        }
        return result
    }

    init(recipeRepository: any RecipeRepository) {
        self.recipeRepository = recipeRepository
    }

    func loadRecipes() {
        isLoading = true
        defer { isLoading = false }

        do {
            if searchText.isEmpty {
                recipes = try recipeRepository.fetchAll()
            } else {
                recipes = try recipeRepository.search(query: searchText)
            }
        } catch {
            logger.error("Failed to load recipes: \(error.localizedDescription)")
            errorPresenter.present(error)
        }
    }

    func deleteRecipe(_ recipe: Recipe) {
        do {
            try recipeRepository.delete(recipe)
            recipes.removeAll { $0.id == recipe.id }
        } catch {
            logger.error("Failed to delete recipe: \(error.localizedDescription)")
            errorPresenter.present(error)
        }
    }
}
