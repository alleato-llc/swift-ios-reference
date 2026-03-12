import RecipePlannerCore
import RecipePlannerTestSupport
import Testing

@testable import RecipePlannerServices

@Suite
struct ShoppingListCalculatorTests {
    @Test
    func emptyMealPlansReturnsEmptyList() {
        let result = ShoppingListCalculator.calculate(from: [])
        #expect(result.isEmpty)
    }

    @Test
    func singleMealPlanReturnsRecipeIngredients() {
        let recipe = TestRecipeFactory.makeRecipeWithIngredients(
            name: "Chicken Dinner",
            ingredients: [
                ("Chicken", 2.0, .pieces),
                ("Salt", 1.0, .teaspoons),
            ]
        )
        let plan = TestRecipeFactory.makeMealPlan(recipe: recipe)

        let result = ShoppingListCalculator.calculate(from: [plan])

        #expect(result.count == 2)
        let chicken = result.first { $0.name == "chicken" }
        #expect(chicken?.totalQuantity == 2.0)
        #expect(chicken?.unit == .pieces)
    }

    @Test
    func duplicateIngredientsAreCombined() {
        let recipe1 = TestRecipeFactory.makeRecipeWithIngredients(
            name: "Dish 1",
            ingredients: [("Olive Oil", 2.0, .tablespoons)]
        )
        let recipe2 = TestRecipeFactory.makeRecipeWithIngredients(
            name: "Dish 2",
            ingredients: [("Olive Oil", 3.0, .tablespoons)]
        )
        let plan1 = TestRecipeFactory.makeMealPlan(recipe: recipe1)
        let plan2 = TestRecipeFactory.makeMealPlan(recipe: recipe2)

        let result = ShoppingListCalculator.calculate(from: [plan1, plan2])

        let oil = result.first { $0.name == "olive oil" }
        #expect(oil?.totalQuantity == 5.0)
    }

    @Test
    func mealPlanWithNoRecipeIsSkipped() {
        let plan = TestRecipeFactory.makeMealPlan(recipe: nil)

        let result = ShoppingListCalculator.calculate(from: [plan])

        #expect(result.isEmpty)
    }

    @Test
    func resultIsSortedByName() {
        let recipe = TestRecipeFactory.makeRecipeWithIngredients(
            name: "Test",
            ingredients: [
                ("Zucchini", 1.0, .whole),
                ("Avocado", 2.0, .whole),
                ("Mushrooms", 3.0, .cups),
            ]
        )
        let plan = TestRecipeFactory.makeMealPlan(recipe: recipe)

        let result = ShoppingListCalculator.calculate(from: [plan])

        #expect(result.map(\.name) == ["avocado", "mushrooms", "zucchini"])
    }
}
