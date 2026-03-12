# Contributing

## Setup

1. Install dependencies:
   ```bash
   brew install xcodegen swiftformat swiftlint
   ```

2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```

3. Open the project:
   ```bash
   open RecipePlanner.xcodeproj
   ```

## Development Workflow

1. Create a feature branch from `main`.
2. Make your changes.
3. Run code quality tools before submitting:
   ```bash
   swiftformat .
   swiftlint
   ```
4. Run tests:
   ```bash
   cd Packages/RecipePlannerServices && swift test
   xcodebuild -scheme RecipePlanner -destination 'platform=iOS Simulator,name=iPhone 16' test
   ```
5. Open a pull request against `main`.

## Code Standards

- Follow existing MVVM patterns: thin views, `@Observable` view models, protocol-based repositories.
- All new services and clients must have a corresponding protocol and test double in `RecipePlannerTestSupport`.
- Use `TestRecipeFactory` for creating test data -- do not construct models directly in tests.
- Run `swiftformat` and `swiftlint` before every commit. Pre-commit hooks are configured in `.pre-commit-config.yaml`.

## PR Checklist

- [ ] Code compiles without warnings
- [ ] Tests pass (both SPM and Xcode scheme)
- [ ] `swiftformat` and `swiftlint` pass with no issues
- [ ] New protocols have test doubles in `RecipePlannerTestSupport`
- [ ] Documentation updated if architecture or features changed
