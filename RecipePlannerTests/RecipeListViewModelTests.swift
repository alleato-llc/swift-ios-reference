import RecipePlannerCore
import RecipePlannerTestSupport
import Testing

@testable import RecipePlanner

@Suite
struct RecipeListViewModelTests {
    @Test @MainActor
    func loadRecipesPopulatesList() {
        let repo = TestRecipeRepository()
        try! repo.save(TestRecipeFactory.makeRecipe(name: "Test Recipe"))
        let viewModel = RecipeListViewModel(recipeRepository: repo)

        viewModel.loadRecipes()

        #expect(viewModel.recipes.count == 1)
        #expect(viewModel.recipes.first?.name == "Test Recipe")
    }

    @Test @MainActor
    func loadRecipesWithSearchFilters() {
        let repo = TestRecipeRepository()
        try! repo.save(TestRecipeFactory.makeRecipe(name: "Chicken Soup"))
        try! repo.save(TestRecipeFactory.makeRecipe(name: "Beef Stew"))
        let viewModel = RecipeListViewModel(recipeRepository: repo)
        viewModel.searchText = "Chicken"

        viewModel.loadRecipes()

        #expect(viewModel.recipes.count == 1)
        #expect(viewModel.recipes.first?.name == "Chicken Soup")
    }

    @Test @MainActor
    func deleteRecipeRemovesFromList() {
        let repo = TestRecipeRepository()
        let recipe = TestRecipeFactory.makeRecipe(name: "Delete Me")
        try! repo.save(recipe)
        let viewModel = RecipeListViewModel(recipeRepository: repo)
        viewModel.loadRecipes()

        viewModel.deleteRecipe(recipe)

        #expect(viewModel.recipes.isEmpty)
        #expect(repo.deleteCallCount == 1)
    }

    @Test @MainActor
    func filteredRecipesByCategory() {
        let repo = TestRecipeRepository()
        try! repo.save(TestRecipeFactory.makeRecipe(name: "Pancakes", category: .breakfast))
        try! repo.save(TestRecipeFactory.makeRecipe(name: "Pasta", category: .dinner))
        let viewModel = RecipeListViewModel(recipeRepository: repo)
        viewModel.loadRecipes()

        viewModel.selectedCategory = .breakfast

        #expect(viewModel.filteredRecipes.count == 1)
        #expect(viewModel.filteredRecipes.first?.name == "Pancakes")
    }

    @Test @MainActor
    func errorSetsErrorState() {
        let repo = TestRecipeRepository()
        repo.errorToThrow = RecipePlannerError.repositoryFailure(
            underlying: NSError(domain: "test", code: 1)
        )
        let viewModel = RecipeListViewModel(recipeRepository: repo)

        viewModel.loadRecipes()

        #expect(viewModel.isShowingError)
        #expect(viewModel.errorMessage != nil)
    }
}
