import RecipePlannerServices
import SwiftUI

struct ShoppingListView: View {
    @Bindable var viewModel: MealPlanViewModel

    var body: some View {
        List {
            if viewModel.shoppingItems.isEmpty {
                ContentUnavailableView(
                    "No Items",
                    systemImage: "cart",
                    description: Text("Add meals to your plan to generate a shopping list")
                )
            } else {
                Section("Shopping List (\(viewModel.shoppingItems.count) items)") {
                    ForEach(viewModel.shoppingItems, id: \.name) { item in
                        HStack {
                            Text(item.name.capitalized)
                            Spacer()
                            Text("\(item.displayQuantity) \(item.unit.abbreviation)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Shopping List")
        .onAppear {
            viewModel.loadWeek()
        }
    }
}

extension ShoppingItem {
    var displayQuantity: String {
        if totalQuantity == totalQuantity.rounded() {
            return String(Int(totalQuantity))
        }
        return String(format: "%.1f", totalQuantity)
    }
}
