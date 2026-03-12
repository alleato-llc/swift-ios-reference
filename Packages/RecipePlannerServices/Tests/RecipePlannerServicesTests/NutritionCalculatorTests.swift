import Testing

@testable import RecipePlannerServices

@Suite
struct NutritionCalculatorTests {
    @Test
    func perServingDividesEvenly() {
        let total = NutritionInfo(calories: 400, proteinGrams: 40, carbsGrams: 60, fatGrams: 20)

        let result = NutritionCalculator.perServing(total: total, servings: 4)

        #expect(result.calories == 100)
        #expect(result.proteinGrams == 10)
        #expect(result.carbsGrams == 15)
        #expect(result.fatGrams == 5)
    }

    @Test
    func perServingWithZeroServingsReturnsZero() {
        let total = NutritionInfo(calories: 400, proteinGrams: 40, carbsGrams: 60, fatGrams: 20)

        let result = NutritionCalculator.perServing(total: total, servings: 0)

        #expect(result == .zero)
    }

    @Test
    func dailyTotalSumsAll() {
        let items = [
            NutritionInfo(calories: 300, proteinGrams: 20, carbsGrams: 40, fatGrams: 10),
            NutritionInfo(calories: 500, proteinGrams: 30, carbsGrams: 60, fatGrams: 15),
        ]

        let result = NutritionCalculator.dailyTotal(from: items)

        #expect(result.calories == 800)
        #expect(result.proteinGrams == 50)
        #expect(result.carbsGrams == 100)
        #expect(result.fatGrams == 25)
    }

    @Test
    func dailyTotalOfEmptyListIsZero() {
        let result = NutritionCalculator.dailyTotal(from: [])

        #expect(result == .zero)
    }
}
