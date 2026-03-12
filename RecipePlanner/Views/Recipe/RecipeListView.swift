import RecipePlannerCore
import SwiftUI

struct RecipeListView: View {
    @Bindable var viewModel: RecipeListViewModel
    @State private var isShowingAddRecipe = false

    var body: some View {
        List {
            ForEach(viewModel.filteredRecipes, id: \.id) { recipe in
                NavigationLink(value: recipe) {
                    RecipeRowView(recipe: recipe)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let recipe = viewModel.filteredRecipes[index]
                    viewModel.deleteRecipe(recipe)
                }
            }
        }
        .navigationTitle("Recipes")
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailView(
                viewModel: RecipeDetailViewModel(
                    recipe: recipe,
                    recipeRepository: viewModel.recipeRepository
                )
            )
        }
        .searchable(text: $viewModel.searchText)
        .onChange(of: viewModel.searchText) {
            viewModel.loadRecipes()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingAddRecipe = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingAddRecipe) {
            NavigationStack {
                RecipeFormView(
                    recipe: nil,
                    recipeRepository: viewModel.recipeRepository
                ) {
                    isShowingAddRecipe = false
                    viewModel.loadRecipes()
                }
            }
        }
        .onAppear {
            viewModel.loadRecipes()
        }
        .alert("Error", isPresented: $viewModel.isShowingError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }
}

private struct RecipeRowView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recipe.name)
                .font(.headline)
            HStack {
                Label(recipe.recipeCategory.displayName, systemImage: "tag")
                Spacer()
                if recipe.totalTimeMinutes > 0 {
                    Label("\(recipe.totalTimeMinutes) min", systemImage: "clock")
                }
                Label("\(recipe.servings) servings", systemImage: "person.2")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
