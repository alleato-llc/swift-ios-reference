import RecipePlannerCore
import SwiftUI

struct RecipeDetailView: View {
    @Bindable var viewModel: RecipeDetailViewModel
    @State private var isEditing = false

    var body: some View {
        List {
            Section("Overview") {
                if !viewModel.recipe.summary.isEmpty {
                    Text(viewModel.recipe.summary)
                }

                HStack {
                    Label(viewModel.recipe.recipeCategory.displayName, systemImage: "tag")
                    Spacer()
                    Label("\(viewModel.recipe.servings) servings", systemImage: "person.2")
                }

                if viewModel.recipe.totalTimeMinutes > 0 {
                    HStack {
                        if viewModel.recipe.prepTimeMinutes > 0 {
                            Label("Prep: \(viewModel.recipe.prepTimeMinutes) min", systemImage: "timer")
                        }
                        if viewModel.recipe.cookTimeMinutes > 0 {
                            Label("Cook: \(viewModel.recipe.cookTimeMinutes) min", systemImage: "flame")
                        }
                    }
                }
            }

            if let ingredients = viewModel.recipe.ingredients, !ingredients.isEmpty {
                Section("Ingredients") {
                    ForEach(ingredients, id: \.id) { ingredient in
                        HStack {
                            Text(ingredient.name)
                            Spacer()
                            Text("\(ingredient.displayQuantity) \(ingredient.measurementUnit.abbreviation)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if !viewModel.recipe.instructions.isEmpty {
                Section("Instructions") {
                    Text(viewModel.recipe.instructions)
                }
            }
        }
        .navigationTitle(viewModel.recipe.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                RecipeFormView(
                    recipe: viewModel.recipe,
                    recipeRepository: viewModel.recipeRepository
                ) {
                    isEditing = false
                }
            }
        }
        .alert("Error", isPresented: $viewModel.isShowingError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }
}
