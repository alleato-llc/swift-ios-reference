import Foundation
import SwiftData

@Model
public final class MealPlan {
    public var id: UUID = UUID()
    public var date: Date = Date()
    public var mealType: String = MealType.dinner.rawValue
    public var notes: String = ""
    public var createdAt: Date = Date()
    public var modifiedAt: Date = Date()

    @Relationship
    public var recipe: Recipe?

    public var meal: MealType {
        MealType(rawValue: mealType) ?? .dinner
    }

    public init(
        id: UUID = UUID(),
        date: Date,
        mealType: MealType = .dinner,
        recipe: Recipe? = nil,
        notes: String = "",
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.mealType = mealType.rawValue
        self.recipe = recipe
        self.notes = notes
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}
