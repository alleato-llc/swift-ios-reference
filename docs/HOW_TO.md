# How To

## Prerequisites

- **Xcode 16+** with iOS 17 SDK
- **XcodeGen**: `brew install xcodegen`
- **SwiftFormat**: `brew install swiftformat`
- **SwiftLint**: `brew install swiftlint`

## Initial Setup

```bash
git clone <repository-url>
cd swift-ios-reference
xcodegen generate
open RecipePlanner.xcodeproj
```

Select the `RecipePlanner` scheme and an iOS Simulator target, then build and run.

## Common Tasks

### Add a New Model

1. Create the `@Model` class in `Packages/RecipePlannerCore/Sources/RecipePlannerCore/Models/`.
2. Use `String` raw values for any enum properties (see `Recipe.category` pattern).
3. Add a computed property for typed enum access.
4. Add factory methods to `TestRecipeFactory` in `RecipePlannerTestSupport`.

### Add a New Repository

1. Define the protocol in `Packages/RecipePlannerServices/Sources/RecipePlannerServices/`.
2. Create the `SwiftData*` implementation in the same location.
3. Create a `Test*Repository` in `RecipePlannerTestSupport` with call-count tracking and `errorToThrow`.
4. Register the concrete implementation in `DependencyContainer`.

### Add a New View

1. Create the SwiftUI view in `RecipePlanner/Views/<Feature>/`.
2. Create an `@Observable @MainActor` ViewModel in `RecipePlanner/ViewModels/`.
3. Accept dependencies via initializer injection using protocol types.
4. Write ViewModel tests in `RecipePlannerTests/` using test doubles from TestSupport.

### Add a New Calculator

1. Create a stateless `enum` with `static` methods in `Packages/RecipePlannerServices/Sources/RecipePlannerServices/<Feature>/`.
2. Write tests in `Packages/RecipePlannerServices/Tests/RecipePlannerServicesTests/`.
3. No test double needed -- calculators are pure functions.

### Run Tests

```bash
# Package-level tests (fast)
cd Packages/RecipePlannerServices && swift test

# App-level tests (requires simulator)
xcodebuild -scheme RecipePlanner -destination 'platform=iOS Simulator,name=iPhone 16' test
```

### Format and Lint Code

```bash
swiftformat .
swiftlint
```

### Regenerate Xcode Project

After modifying `project.yml` or package dependencies:

```bash
xcodegen generate
```

## Troubleshooting

- **"No such module" errors**: Run `xcodegen generate` to regenerate the project, then clean build (Cmd+Shift+K).
- **SwiftData model changes not reflected**: Clean build folder and restart the simulator to reset the local database.
- **Test target build failures**: Ensure `RecipePlannerTestSupport` is listed as a dependency in `project.yml` for the test target.
