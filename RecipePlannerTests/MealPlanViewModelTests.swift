import RecipePlannerCore
import RecipePlannerTestSupport
import Testing

@testable import RecipePlanner

@Suite
struct MealPlanViewModelTests {
    @Test @MainActor
    func loadWeekPopulatesRecipes() {
        let mealPlanRepo = TestMealPlanRepository()
        let recipeRepo = TestRecipeRepository()
        let recipe = TestRecipeFactory.makeRecipe(name: "Test Recipe")
        try! recipeRepo.save(recipe)
        let viewModel = MealPlanViewModel(
            mealPlanRepository: mealPlanRepo,
            recipeRepository: recipeRepo
        )

        viewModel.loadWeek()

        #expect(viewModel.availableRecipes.count == 1)
    }

    @Test @MainActor
    func addMealPlanSavesAndReloads() {
        let mealPlanRepo = TestMealPlanRepository()
        let recipeRepo = TestRecipeRepository()
        let recipe = TestRecipeFactory.makeRecipe(name: "Pasta")
        let viewModel = MealPlanViewModel(
            mealPlanRepository: mealPlanRepo,
            recipeRepository: recipeRepo
        )

        viewModel.addMealPlan(date: Date(), mealType: .dinner, recipe: recipe)

        #expect(mealPlanRepo.saveCallCount == 1)
    }

    @Test @MainActor
    func deleteMealPlanRemovesFromList() {
        let mealPlanRepo = TestMealPlanRepository()
        let recipeRepo = TestRecipeRepository()
        let recipe = TestRecipeFactory.makeRecipe(name: "Test")
        let plan = TestRecipeFactory.makeMealPlan(recipe: recipe)
        mealPlanRepo.plans = [plan]
        let viewModel = MealPlanViewModel(
            mealPlanRepository: mealPlanRepo,
            recipeRepository: recipeRepo
        )
        viewModel.loadWeek()

        viewModel.deleteMealPlan(plan)

        #expect(mealPlanRepo.deleteCallCount == 1)
    }

    @Test @MainActor
    func navigateWeekChangesSelectedDate() {
        let mealPlanRepo = TestMealPlanRepository()
        let recipeRepo = TestRecipeRepository()
        let viewModel = MealPlanViewModel(
            mealPlanRepository: mealPlanRepo,
            recipeRepository: recipeRepo
        )
        let originalDate = viewModel.selectedDate

        viewModel.navigateWeek(by: 1)

        #expect(viewModel.selectedDate.daysFrom(originalDate) == 7)
    }

    @Test @MainActor
    func weekDaysReturnsSeven() {
        let mealPlanRepo = TestMealPlanRepository()
        let recipeRepo = TestRecipeRepository()
        let viewModel = MealPlanViewModel(
            mealPlanRepository: mealPlanRepo,
            recipeRepository: recipeRepo
        )

        #expect(viewModel.weekDays.count == 7)
    }
}
