import Foundation
import RecipePlannerCore

public enum NutritionCalculator {
    /// Calculates per-serving nutrition by dividing total nutrition across servings.
    public static func perServing(total: NutritionInfo, servings: Int) -> NutritionInfo {
        guard servings > 0 else { return .zero }
        let divisor = Double(servings)
        return NutritionInfo(
            calories: total.calories / divisor,
            proteinGrams: total.proteinGrams / divisor,
            carbsGrams: total.carbsGrams / divisor,
            fatGrams: total.fatGrams / divisor
        )
    }

    /// Sums nutrition info for a list of meal plans in a day.
    public static func dailyTotal(from items: [NutritionInfo]) -> NutritionInfo {
        items.reduce(.zero, +)
    }
}
