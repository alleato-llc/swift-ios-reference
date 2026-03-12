import RecipePlannerCore
import RecipePlannerTestSupport
import Testing

@testable import RecipePlanner

@Suite
struct RecipeDetailViewModelTests {
    @Test @MainActor
    func saveRecipeUpdatesFields() {
        let repo = TestRecipeRepository()
        let recipe = TestRecipeFactory.makeRecipe(name: "Original")
        let viewModel = RecipeDetailViewModel(recipe: recipe, recipeRepository: repo)

        viewModel.saveRecipe(
            name: "Updated",
            summary: "New summary",
            instructions: "New instructions",
            servings: 6,
            prepTimeMinutes: 10,
            cookTimeMinutes: 20,
            category: .lunch,
            ingredients: []
        )

        #expect(viewModel.recipe.name == "Updated")
        #expect(viewModel.recipe.servings == 6)
        #expect(viewModel.recipe.recipeCategory == .lunch)
        #expect(repo.saveCallCount == 1)
    }

    @Test @MainActor
    func saveRecipeUpdatesModifiedAt() {
        let repo = TestRecipeRepository()
        let earlyDate = Date(timeIntervalSince1970: 0)
        let recipe = TestRecipeFactory.makeRecipe(name: "Test", modifiedAt: earlyDate)
        let viewModel = RecipeDetailViewModel(recipe: recipe, recipeRepository: repo)

        viewModel.saveRecipe(
            name: "Test",
            summary: "",
            instructions: "",
            servings: 4,
            prepTimeMinutes: 0,
            cookTimeMinutes: 0,
            category: .dinner,
            ingredients: []
        )

        #expect(viewModel.recipe.modifiedAt > earlyDate)
    }

    @Test @MainActor
    func saveRecipeErrorSetsErrorState() {
        let repo = TestRecipeRepository()
        repo.errorToThrow = RecipePlannerError.repositoryFailure(
            underlying: NSError(domain: "test", code: 1)
        )
        let recipe = TestRecipeFactory.makeRecipe(name: "Test")
        let viewModel = RecipeDetailViewModel(recipe: recipe, recipeRepository: repo)

        viewModel.saveRecipe(
            name: "Test",
            summary: "",
            instructions: "",
            servings: 4,
            prepTimeMinutes: 0,
            cookTimeMinutes: 0,
            category: .dinner,
            ingredients: []
        )

        #expect(viewModel.isShowingError)
    }
}
