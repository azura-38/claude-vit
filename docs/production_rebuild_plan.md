# VitaCase Production Rebuild Plan

## Current Foundation

- Keep the existing feature screens while moving shared behavior into `lib/core`.
- Use Riverpod as the app state boundary and GoRouter as the only navigation boundary.
- Keep offline-first storage as the default; remote services must be optional and explicit.
- Treat health data as sensitive by default: local encryption, private notifications, secure screen, and lock-aware lifecycle.

## Phase 1: Stabilize

- Replace dead buttons with async save flows, validation, loading states, haptics, and localized feedback.
- Keep onboarding completion, legal acceptance, lock state, locale, and theme in persistent Riverpod controllers.
- Route every navigation action through `context.go`, `context.push`, or named GoRouter routes.

## Phase 2: Core Systems

- `core/design_system`: spacing, radius, motion, typography, semantic colors.
- `core/security`: PIN, biometric, secure storage, session lock, screenshot protection.
- `core/notifications`: permission onboarding, timezone-safe scheduling, notification route handling.
- `core/feedback`: snackbars, dialogs, confirmation sheets, and reusable error/empty/loading states.

## Phase 3: Data Layer

- Keep repositories as feature boundaries.
- Move remaining inline/demo models into feature `domain` folders.
- Add DTO and mapper layers for every persisted entity.
- Encrypt document bytes and sensitive strings before persistence.
- Add streams or Riverpod async notifiers for all list screens.

## Phase 4: Feature Rebuild

- Vault: encrypted file storage, previews, secure delete, categories, filters, OCR-ready metadata.
- Appointments: date/time picker reliability, recurrence, reminders, timeline integration.
- Medications: schedules, refill stock, adherence history, actionable notifications.
- Profile: real health identity, emergency contact, BMI, blood type, allergies, completion score.
- Dashboard: daily medications, upcoming appointments, vault shortcuts, emergency access.

## Phase 5: Release Quality

- Run `flutter analyze`, unit tests, widget tests, and Android/iOS smoke builds on every release branch.
- Test app lifecycle lock, notification taps, timezone changes, denied permissions, and low-storage devices.
- Audit accessibility labels, text scaling, high contrast, and elderly-friendly tap targets.
