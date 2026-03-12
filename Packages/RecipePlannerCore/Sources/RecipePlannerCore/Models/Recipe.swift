import Foundation
import SwiftData

@Model
public final class Recipe {
    public var id: UUID = UUID()
    public var name: String = ""
    public var summary: String = ""
    public var instructions: String = ""
    public var servings: Int = 4
    public var prepTimeMinutes: Int = 0
    public var cookTimeMinutes: Int = 0
    public var category: String = RecipeCategory.dinner.rawValue
    public var createdAt: Date = Date()
    public var modifiedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \Ingredient.recipe)
    public var ingredients: [Ingredient]?

    public var recipeCategory: RecipeCategory {
        RecipeCategory(rawValue: category) ?? .dinner
    }

    public var totalTimeMinutes: Int {
        prepTimeMinutes + cookTimeMinutes
    }

    public init(
        id: UUID = UUID(),
        name: String,
        summary: String = "",
        instructions: String = "",
        servings: Int = 4,
        prepTimeMinutes: Int = 0,
        cookTimeMinutes: Int = 0,
        category: RecipeCategory = .dinner,
        ingredients: [Ingredient] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.instructions = instructions
        self.servings = servings
        self.prepTimeMinutes = prepTimeMinutes
        self.cookTimeMinutes = cookTimeMinutes
        self.category = category.rawValue
        self.ingredients = ingredients
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}
