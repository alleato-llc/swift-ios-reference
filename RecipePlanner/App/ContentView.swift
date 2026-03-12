import RecipePlannerCore
import RecipePlannerServices
import SwiftData
import SwiftUI

struct ContentView: View {
    let deps: DependencyContainer

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            NavigationStack {
                RecipeListView(
                    viewModel: RecipeListViewModel(
                        recipeRepository: deps.recipeRepository
                    )
                )
            }
            .tabItem {
                Label("Recipes", systemImage: "book")
            }

            NavigationStack {
                MealPlanView(
                    viewModel: MealPlanViewModel(
                        mealPlanRepository: deps.mealPlanRepository,
                        recipeRepository: deps.recipeRepository
                    )
                )
            }
            .tabItem {
                Label("Meal Plan", systemImage: "calendar")
            }

            NavigationStack {
                ShoppingListView(
                    viewModel: MealPlanViewModel(
                        mealPlanRepository: deps.mealPlanRepository,
                        recipeRepository: deps.recipeRepository
                    )
                )
            }
            .tabItem {
                Label("Shopping", systemImage: "cart")
            }
        }
    }
}
