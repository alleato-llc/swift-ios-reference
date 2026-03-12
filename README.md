# RecipePlanner

A Swift iOS reference project for recipe and meal planning, built with SwiftUI, SwiftData, and the Observation framework. Codifies best practices for iOS app architecture, modular packaging, and testing.

## Requirements

- Xcode 16+ (iOS 17+ deployment target)
- Swift 6.0 (GraalVM CE)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) for project generation
- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) + [SwiftLint](https://github.com/realm/SwiftLint) for code quality

## Quick Start

```bash
brew install xcodegen swiftformat swiftlint
xcodegen generate
open RecipePlanner.xcodeproj
```

## Build & Test

```bash
# Generate Xcode project
xcodegen generate

# Build
xcodebuild -scheme RecipePlanner -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run SPM package tests (unit tests, no simulator required)
cd Packages/RecipePlannerServices && swift test

# Run app-level tests (requires simulator)
xcodebuild -scheme RecipePlanner -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Architecture

MVVM with protocol-based dependency injection, organized into three local SPM packages:

| Package | Purpose |
|---|---|
| **RecipePlannerCore** | Domain models (`Recipe`, `Ingredient`, `MealPlan`), enums, extensions |
| **RecipePlannerServices** | Repository protocols, SwiftData implementations, calculators, clients |
| **RecipePlannerTestSupport** | Test doubles (`TestRecipeRepository`), factory helpers (`TestRecipeFactory`) |

The main app target contains views, view models, and the `DependencyContainer`.

## Domain

- **Recipe browsing** -- Create, edit, search, and filter recipes by category
- **Meal planning** -- Assign recipes to days/meal types for weekly planning
- **Shopping lists** -- Auto-generated aggregated ingredient lists from planned meals

## Project Structure

```
RecipePlanner/
  App/                  # App entry point, DependencyContainer, ContentView
  Views/                # SwiftUI views (Recipe/, MealPlan/, Shopping/)
  ViewModels/           # @Observable view models
Packages/
  RecipePlannerCore/    # Domain models and enums
  RecipePlannerServices/ # Repositories, calculators, clients
  RecipePlannerTestSupport/ # Test doubles and factories
RecipePlannerTests/     # App-level ViewModel tests
project.yml             # XcodeGen spec
```

## Documentation

See `docs/` for detailed documentation on architecture, testing, database schema, and features.
