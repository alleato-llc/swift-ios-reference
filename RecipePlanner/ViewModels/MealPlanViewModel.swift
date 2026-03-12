import Foundation
import OSLog
import RecipePlannerCore
import RecipePlannerServices

private let logger = Logger(subsystem: "com.alleato.recipeplanner", category: "meal-plan")

@Observable
@MainActor
final class MealPlanViewModel {
    private(set) var weeklyPlans: [MealPlan] = []
    private(set) var availableRecipes: [Recipe] = []
    private(set) var shoppingItems: [ShoppingItem] = []
    private(set) var isLoading = false
    var selectedDate: Date = Date().startOfWeek

    private let mealPlanRepository: any MealPlanRepository
    private let recipeRepository: any RecipeRepository
    private let errorPresenter = ErrorPresenter()

    var isShowingError: Bool {
        get { errorPresenter.isShowingError }
        set { if !newValue { errorPresenter.dismiss() } }
    }

    var errorMessage: String? {
        errorPresenter.currentError?.errorDescription
    }

    var weekDays: [Date] {
        (0 ..< 7).map { selectedDate.adding(days: $0) }
    }

    init(
        mealPlanRepository: any MealPlanRepository,
        recipeRepository: any RecipeRepository
    ) {
        self.mealPlanRepository = mealPlanRepository
        self.recipeRepository = recipeRepository
    }

    func loadWeek() {
        isLoading = true
        defer { isLoading = false }

        do {
            weeklyPlans = try mealPlanRepository.fetchWeek(startingFrom: selectedDate)
            availableRecipes = try recipeRepository.fetchAll()
            shoppingItems = ShoppingListCalculator.calculate(from: weeklyPlans)
        } catch {
            logger.error("Failed to load meal plans: \(error.localizedDescription)")
            errorPresenter.present(error)
        }
    }

    func addMealPlan(date: Date, mealType: MealType, recipe: Recipe, notes: String = "") {
        let plan = MealPlan(date: date, mealType: mealType, recipe: recipe, notes: notes)
        do {
            try mealPlanRepository.save(plan)
            loadWeek()
        } catch {
            logger.error("Failed to save meal plan: \(error.localizedDescription)")
            errorPresenter.present(error)
        }
    }

    func deleteMealPlan(_ plan: MealPlan) {
        do {
            try mealPlanRepository.delete(plan)
            weeklyPlans.removeAll { $0.id == plan.id }
            shoppingItems = ShoppingListCalculator.calculate(from: weeklyPlans)
        } catch {
            logger.error("Failed to delete meal plan: \(error.localizedDescription)")
            errorPresenter.present(error)
        }
    }

    func plans(for date: Date) -> [MealPlan] {
        weeklyPlans.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func navigateWeek(by offset: Int) {
        selectedDate = selectedDate.adding(days: 7 * offset)
    }
}
