import Foundation
import RecipePlannerCore

public struct ShoppingItem: Sendable, Equatable {
    public let name: String
    public let totalQuantity: Double
    public let unit: MeasurementUnit

    public init(name: String, totalQuantity: Double, unit: MeasurementUnit) {
        self.name = name
        self.totalQuantity = totalQuantity
        self.unit = unit
    }
}

public enum ShoppingListCalculator {
    /// Aggregates ingredients from meal plans into a consolidated shopping list.
    /// Ingredients with the same name and unit are combined by summing quantities.
    public static func calculate(from mealPlans: [MealPlan]) -> [ShoppingItem] {
        var grouped: [String: (quantity: Double, unit: MeasurementUnit)] = [:]

        for plan in mealPlans {
            guard let recipe = plan.recipe else { continue }
            for ingredient in recipe.ingredients ?? [] {
                let key = "\(ingredient.name.lowercased())|\(ingredient.unit)"
                let existing = grouped[key] ?? (quantity: 0, unit: ingredient.measurementUnit)
                grouped[key] = (
                    quantity: existing.quantity + ingredient.quantity,
                    unit: existing.unit
                )
            }
        }

        return grouped
            .map { (key, value) in
                let name = String(key.split(separator: "|").first ?? "")
                return ShoppingItem(name: name, totalQuantity: value.quantity, unit: value.unit)
            }
            .sorted { $0.name < $1.name }
    }
}
