import Foundation
import RecipePlannerCore
import RecipePlannerServices

@MainActor
public final class TestMealPlanRepository: MealPlanRepository {
    public var plans: [MealPlan] = []
    public private(set) var saveCallCount = 0
    public private(set) var deleteCallCount = 0
    public var errorToThrow: Error?

    public init() {}

    public func fetchAll() throws -> [MealPlan] {
        if let error = errorToThrow { throw error }
        return plans
    }

    public func fetch(for date: Date) throws -> [MealPlan] {
        if let error = errorToThrow { throw error }
        return plans.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    public func fetchWeek(startingFrom date: Date) throws -> [MealPlan] {
        if let error = errorToThrow { throw error }
        let start = date.startOfWeek
        let end = start.adding(days: 7)
        return plans.filter { $0.date >= start && $0.date < end }
    }

    public func save(_ mealPlan: MealPlan) throws {
        if let error = errorToThrow { throw error }
        saveCallCount += 1
        if let index = plans.firstIndex(where: { $0.id == mealPlan.id }) {
            plans[index] = mealPlan
        } else {
            plans.append(mealPlan)
        }
    }

    public func delete(_ mealPlan: MealPlan) throws {
        if let error = errorToThrow { throw error }
        deleteCallCount += 1
        plans.removeAll { $0.id == mealPlan.id }
    }
}
