# VitaCase Architecture

VitaCase uses Flutter with a feature-first architecture.

## Core Stack

- State management: `flutter_riverpod`
- Routing: `go_router`
- Primary structure: feature-first modules

## Target Folder Shape

```text
lib/
  core/
  features/
  shared/
  repositories/
  models/
```

Each feature should prefer:

```text
feature_name/
  data/
  domain/
  presentation/
```

## Architecture Principles

- Keep business logic out of widgets.
- Prefer small, focused widgets over giant screens.
- Keep providers scoped to the feature or shared layer that owns them.
- Avoid duplicated providers and provider bleed.
- Prefer repository/domain boundaries for data access and business rules.
- Use existing app patterns before adding new abstractions.
- Keep startup lifecycle stable and predictable.

## Navigation

- Use `go_router`.
- Avoid direct `Navigator.push` / `Navigator.pop` in new code unless required by an existing local pattern.
- Verify routes, redirects, auth/security lock flows, onboarding, and emergency flow after navigation changes.

## UI Structure

- Use the Serene Precision design language.
- Keep healthcare UI calm, minimal, premium, and trustworthy.
- Use theme tokens and shared components.
- Avoid hardcoded visible strings.
- Avoid hardcoded colors.
- Avoid fake data in production UI.

## Feature Boundaries

When changing a feature, check impact on:

- Startup lifecycle
- Security lock and biometric unlock
- Notifications
- Vault privacy
- Localization
- Dark mode
- Accessibility
- Ads placement
