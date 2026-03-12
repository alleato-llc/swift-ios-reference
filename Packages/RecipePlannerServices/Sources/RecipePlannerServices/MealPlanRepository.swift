import Foundation
import RecipePlannerCore

@MainActor
public protocol MealPlanRepository {
    func fetchAll() throws -> [MealPlan]
    func fetch(for date: Date) throws -> [MealPlan]
    func fetchWeek(startingFrom date: Date) throws -> [MealPlan]
    func save(_ mealPlan: MealPlan) throws
    func delete(_ mealPlan: MealPlan) throws
}
