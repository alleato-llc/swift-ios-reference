import Foundation
import RecipePlannerCore

public enum TestRecipeFactory {
    public static func makeRecipe(
        id: UUID = UUID(),
        name: String = "Test Recipe",
        summary: String = "A test recipe",
        instructions: String = "Step 1: Test",
        servings: Int = 4,
        prepTimeMinutes: Int = 15,
        cookTimeMinutes: Int = 30,
        category: RecipeCategory = .dinner,
        ingredients: [Ingredient] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) -> Recipe {
        Recipe(
            id: id,
            name: name,
            summary: summary,
            instructions: instructions,
            servings: servings,
            prepTimeMinutes: prepTimeMinutes,
            cookTimeMinutes: cookTimeMinutes,
            category: category,
            ingredients: ingredients,
            createdAt: createdAt,
            modifiedAt: modifiedAt
        )
    }

    public static func makeIngredient(
        id: UUID = UUID(),
        name: String = "Test Ingredient",
        quantity: Double = 1.0,
        unit: MeasurementUnit = .whole
    ) -> Ingredient {
        Ingredient(id: id, name: name, quantity: quantity, unit: unit)
    }

    public static func makeMealPlan(
        id: UUID = UUID(),
        date: Date = Date(),
        mealType: MealType = .dinner,
        recipe: Recipe? = nil,
        notes: String = ""
    ) -> MealPlan {
        MealPlan(
            id: id,
            date: date,
            mealType: mealType,
            recipe: recipe,
            notes: notes
        )
    }

    public static func makeRecipeWithIngredients(
        name: String = "Test Recipe",
        category: RecipeCategory = .dinner,
        ingredients: [(name: String, quantity: Double, unit: MeasurementUnit)] = [
            ("Chicken", 2.0, .pieces),
            ("Salt", 1.0, .teaspoons),
            ("Olive Oil", 2.0, .tablespoons),
        ]
    ) -> Recipe {
        let ingredientModels = ingredients.map { item in
            makeIngredient(name: item.name, quantity: item.quantity, unit: item.unit)
        }
        return makeRecipe(name: name, category: category, ingredients: ingredientModels)
    }
}
