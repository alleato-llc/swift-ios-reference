import RecipePlannerCore
import SwiftUI

struct MealPlanView: View {
    @Bindable var viewModel: MealPlanViewModel
    @State private var isAddingMeal = false
    @State private var selectedDayForAdd: Date?
    @State private var selectedMealType: MealType = .dinner

    var body: some View {
        List {
            Section {
                HStack {
                    Button {
                        viewModel.navigateWeek(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                    }

                    Spacer()

                    Text(weekLabel)
                        .font(.headline)

                    Spacer()

                    Button {
                        viewModel.navigateWeek(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
            }

            ForEach(viewModel.weekDays, id: \.self) { day in
                Section(dayLabel(for: day)) {
                    let plans = viewModel.plans(for: day)
                    if plans.isEmpty {
                        Button("Add meal") {
                            selectedDayForAdd = day
                            isAddingMeal = true
                        }
                        .foregroundStyle(.secondary)
                    } else {
                        ForEach(plans, id: \.id) { plan in
                            MealPlanRowView(plan: plan)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteMealPlan(plans[index])
                            }
                        }

                        Button("Add meal") {
                            selectedDayForAdd = day
                            isAddingMeal = true
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Meal Plan")
        .onAppear {
            viewModel.loadWeek()
        }
        .onChange(of: viewModel.selectedDate) {
            viewModel.loadWeek()
        }
        .sheet(isPresented: $isAddingMeal) {
            AddMealPlanSheet(
                date: selectedDayForAdd ?? Date(),
                availableRecipes: viewModel.availableRecipes
            ) { recipe, mealType, notes in
                viewModel.addMealPlan(
                    date: selectedDayForAdd ?? Date(),
                    mealType: mealType,
                    recipe: recipe,
                    notes: notes
                )
            }
        }
        .alert("Error", isPresented: $viewModel.isShowingError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }

    private var weekLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: viewModel.selectedDate)
        let end = formatter.string(from: viewModel.selectedDate.adding(days: 6))
        return "\(start) – \(end)"
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}

private struct MealPlanRowView: View {
    let plan: MealPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(plan.meal.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Spacer()
            }
            if let recipe = plan.recipe {
                Text(recipe.name)
                    .font(.headline)
            }
            if !plan.notes.isEmpty {
                Text(plan.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct AddMealPlanSheet: View {
    let date: Date
    let availableRecipes: [Recipe]
    let onAdd: (Recipe, MealType, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedRecipe: Recipe?
    @State private var mealType: MealType = .dinner
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                mealTypePicker
                recipeSection
                notesSection
            }
            .navigationTitle("Add Meal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    addButton
                }
            }
        }
    }

    private var mealTypePicker: some View {
        Picker("Meal", selection: $mealType) {
            ForEach(MealType.allCases, id: \.self) { type in
                Text(type.displayName).tag(type)
            }
        }
    }

    private var recipeSection: some View {
        Section("Recipe") {
            ForEach(availableRecipes, id: \.id) { recipe in
                recipeRow(recipe)
            }
        }
    }

    private func recipeRow(_ recipe: Recipe) -> some View {
        Button {
            selectedRecipe = recipe
        } label: {
            HStack {
                Text(recipe.name)
                Spacer()
                if selectedRecipe?.id == recipe.id {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .tint(.primary)
    }

    private var notesSection: some View {
        Section("Notes") {
            TextField("Optional notes", text: $notes)
        }
    }

    private var addButton: some View {
        Button("Add") {
            if let recipe = selectedRecipe {
                onAdd(recipe, mealType, notes)
            }
            dismiss()
        }
        .disabled(selectedRecipe == nil)
    }
}
