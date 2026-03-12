import Foundation
import RecipePlannerCore
import SwiftData

@MainActor
public final class SwiftDataMealPlanRepository: MealPlanRepository {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func fetchAll() throws -> [MealPlan] {
        let descriptor = FetchDescriptor<MealPlan>(
            sortBy: [SortDescriptor(\.date)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func fetch(for date: Date) throws -> [MealPlan] {
        let startOfDay = date.startOfDay
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let descriptor = FetchDescriptor<MealPlan>(
            predicate: #Predicate { plan in
                plan.date >= startOfDay && plan.date < endOfDay
            },
            sortBy: [SortDescriptor(\.mealType)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func fetchWeek(startingFrom date: Date) throws -> [MealPlan] {
        let start = date.startOfWeek
        let end = start.adding(days: 7)
        let descriptor = FetchDescriptor<MealPlan>(
            predicate: #Predicate { plan in
                plan.date >= start && plan.date < end
            },
            sortBy: [SortDescriptor(\.date), SortDescriptor(\.mealType)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func save(_ mealPlan: MealPlan) throws {
        modelContext.insert(mealPlan)
        try modelContext.save()
    }

    public func delete(_ mealPlan: MealPlan) throws {
        modelContext.delete(mealPlan)
        try modelContext.save()
    }
}
