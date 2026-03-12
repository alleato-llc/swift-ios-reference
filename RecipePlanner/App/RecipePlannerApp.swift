import OSLog
import RecipePlannerCore
import SwiftData
import SwiftUI

private let logger = Logger(subsystem: "com.alleato.recipeplanner", category: "app")

@main
struct RecipePlannerApp: App {
    private let container: ModelContainer
    private let deps: DependencyContainer

    init() {
        do {
            self.container = try ModelContainer(
                for: Recipe.self, Ingredient.self, MealPlan.self
            )
        } catch {
            logger.fault("ModelContainer failed: \(error.localizedDescription)")
            fatalError("ModelContainer failed: \(error)")
        }
        self.deps = DependencyContainer(modelContext: container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(deps: deps)
        }
        .modelContainer(container)
    }
}
