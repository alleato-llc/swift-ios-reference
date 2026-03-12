import RecipePlannerCore
import RecipePlannerServices
import SwiftUI

struct RecipeFormView: View {
    let recipe: Recipe?
    let recipeRepository: any RecipeRepository
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var summary = ""
    @State private var instructions = ""
    @State private var servings = 4
    @State private var prepTimeMinutes = 0
    @State private var cookTimeMinutes = 0
    @State private var category: RecipeCategory = .dinner
    @State private var ingredients: [IngredientInput] = []
    @State private var isSaving = false

    private var isEditing: Bool { recipe != nil }

    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $name)
                TextField("Summary", text: $summary, axis: .vertical)
                    .lineLimit(3...)
                Picker("Category", selection: $category) {
                    ForEach(RecipeCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                Stepper("Servings: \(servings)", value: $servings, in: 1...50)
                Stepper("Prep: \(prepTimeMinutes) min", value: $prepTimeMinutes, in: 0...480, step: 5)
                Stepper("Cook: \(cookTimeMinutes) min", value: $cookTimeMinutes, in: 0...480, step: 5)
            }

            Section("Ingredients") {
                ForEach($ingredients) { $ingredient in
                    HStack {
                        TextField("Name", text: $ingredient.name)
                        TextField("Qty", value: $ingredient.quantity, format: .number)
                            .frame(width: 60)
                            .keyboardType(.decimalPad)
                        Picker("", selection: $ingredient.unit) {
                            ForEach(MeasurementUnit.allCases, id: \.self) { unit in
                                Text(unit.abbreviation.isEmpty ? unit.displayName : unit.abbreviation)
                                    .tag(unit)
                            }
                        }
                        .frame(width: 80)
                    }
                }
                .onDelete { indexSet in
                    ingredients.remove(atOffsets: indexSet)
                }

                Button("Add Ingredient") {
                    ingredients.append(IngredientInput())
                }
            }

            Section("Instructions") {
                TextEditor(text: $instructions)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle(isEditing ? "Edit Recipe" : "New Recipe")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(isEditing ? "Save" : "Create") {
                    save()
                }
                .disabled(name.isEmpty || isSaving)
            }
        }
        .onAppear {
            if let recipe {
                name = recipe.name
                summary = recipe.summary
                instructions = recipe.instructions
                servings = recipe.servings
                prepTimeMinutes = recipe.prepTimeMinutes
                cookTimeMinutes = recipe.cookTimeMinutes
                category = recipe.recipeCategory
                ingredients = (recipe.ingredients ?? []).map { IngredientInput(from: $0) }
            }
        }
    }

    private func save() {
        isSaving = true
        defer { isSaving = false }

        let ingredientModels = ingredients.map { input in
            Ingredient(name: input.name, quantity: input.quantity, unit: input.unit)
        }

        let target = recipe ?? Recipe(name: name)
        target.name = name
        target.summary = summary
        target.instructions = instructions
        target.servings = servings
        target.prepTimeMinutes = prepTimeMinutes
        target.cookTimeMinutes = cookTimeMinutes
        target.category = category.rawValue
        target.ingredients = ingredientModels
        target.modifiedAt = Date()

        try? recipeRepository.save(target)
        onSave()
        dismiss()
    }
}

private struct IngredientInput: Identifiable {
    let id = UUID()
    var name: String = ""
    var quantity: Double = 1.0
    var unit: MeasurementUnit = .whole

    init() {}

    init(from ingredient: Ingredient) {
        self.name = ingredient.name
        self.quantity = ingredient.quantity
        self.unit = ingredient.measurementUnit
    }
}
