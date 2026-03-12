---
name: error-handling
description: Error enum with associated values and centralized ErrorPresenter
version: 1.0.0
---

# Error Handling

## Error Enum

A single error type with associated values covers all failure cases.

```swift
enum RecipePlannerError: Error, LocalizedError {
    case notFound(String)
    case invalidInput(String)
    case repositoryFailure(String)
    case networkFailure(String)

    var errorDescription: String? {
        switch self {
        case .notFound(let msg):       "Not Found: \(msg)"
        case .invalidInput(let msg):   "Invalid Input: \(msg)"
        case .repositoryFailure(let msg): "Data Error: \(msg)"
        case .networkFailure(let msg): "Network Error: \(msg)"
        }
    }
}
```

- One enum for the entire app. Associated `String` values carry context.
- Conforms to `LocalizedError` for user-facing messages.

## ErrorPresenter

`@Observable @MainActor` class managing error display state. One per ViewModel.

```swift
@Observable @MainActor
final class ErrorPresenter {
    var isPresented = false
    private(set) var message: String?

    func present(_ error: Error) {
        message = (error as? RecipePlannerError)?.errorDescription
            ?? error.localizedDescription
        isPresented = true
    }

    func dismiss() { isPresented = false; message = nil }
}
```

## ViewModel Pattern

Catch errors in async methods, delegate to `ErrorPresenter`.

```swift
func loadRecipe() async {
    do {
        recipe = try await recipeRepository.fetchById(recipeId)
        if recipe == nil {
            errorPresenter.present(RecipePlannerError.notFound("Recipe \(recipeId) not found"))
        }
    } catch { errorPresenter.present(error) }
}
```

- Every `async throws` call wrapped in `do`/`catch`.
- No `try?` that silently swallows errors. Document if intentionally ignored.

## View Alert Binding

```swift
.alert("Error", isPresented: $viewModel.errorPresenter.isPresented,
       presenting: viewModel.errorPresenter.message) { _ in
    Button("OK") { viewModel.errorPresenter.dismiss() }
} message: { Text($0) }
```

- One `.alert` per view, bound to ViewModel's `ErrorPresenter`.
- No error handling logic in the view.

## Testing Errors

```swift
@Test
func loadRecipe_repositoryFailure_presentsError() async {
    let repository = TestRecipeRepository()
    repository.errorToThrow = RecipePlannerError.repositoryFailure("Connection lost")
    let viewModel = RecipeDetailViewModel(recipeId: UUID(), recipeRepository: repository)

    await viewModel.loadRecipe()

    #expect(viewModel.errorPresenter.isPresented)
    #expect(viewModel.errorPresenter.message?.contains("Data Error") == true)
}
```
