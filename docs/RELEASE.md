# Release

## Versioning

Version numbers are managed in `project.yml`:

```yaml
MARKETING_VERSION: "1.0.0"    # User-facing version (App Store)
CURRENT_PROJECT_VERSION: "1"  # Build number (increment each submission)
```

After modifying versions, regenerate the Xcode project:

```bash
xcodegen generate
```

## Release Process

1. **Update version numbers** in `project.yml`. Bump `MARKETING_VERSION` for the release and increment `CURRENT_PROJECT_VERSION`.

2. **Regenerate the project**:
   ```bash
   xcodegen generate
   ```

3. **Run all tests**:
   ```bash
   cd Packages/RecipePlannerServices && swift test
   xcodebuild -scheme RecipePlanner -destination 'platform=iOS Simulator,name=iPhone 16' test
   ```

4. **Archive the build** in Xcode:
   - Product > Archive
   - Or via command line:
     ```bash
     xcodebuild -scheme RecipePlanner -destination generic/platform=iOS archive -archivePath build/RecipePlanner.xcarchive
     ```

5. **Upload to App Store Connect**:
   - Use the Xcode Organizer (Window > Organizer) to distribute the archive.
   - Or use `xcodebuild -exportArchive` with an export options plist.

6. **Tag the release**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

## Pre-Release Checklist

- [ ] All tests pass
- [ ] `swiftformat` and `swiftlint` pass
- [ ] Version numbers updated in `project.yml`
- [ ] Release notes prepared
- [ ] Archive builds without errors
