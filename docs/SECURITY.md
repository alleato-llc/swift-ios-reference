# Security

## Current State

RecipePlanner is a local-only app with no network communication, authentication, or sensitive data handling in its current form.

## Data Storage

All data is stored locally via SwiftData in the app's default container. No data leaves the device. SwiftData uses SQLite under the hood, stored in the app's sandboxed container.

## No Sensitive Data

The app does not currently handle:
- User credentials or authentication tokens
- Payment information
- Personal health data
- Location data

## Future Considerations

### API Keys

When a real `NutritionClient` implementation replaces the current stub:
- Store API keys in the iOS Keychain, not in source code or `UserDefaults`.
- Use environment-specific configuration (Debug vs Release) for API endpoints.
- Never log API keys or tokens.

### Network Communication

When network features are added:
- Use HTTPS exclusively.
- Implement certificate pinning for sensitive endpoints.
- Validate all server responses before processing.
- Handle network errors gracefully without exposing internal details.

### CloudKit Sync

If CloudKit sync is added:
- Review which fields are synced -- exclude any sensitive data.
- Ensure proper iCloud entitlements and container configuration.
- Test sync conflict resolution thoroughly.

### Data Export

If data export features are added:
- Sanitize exported data.
- Use secure sharing mechanisms (e.g., `UIActivityViewController`).
