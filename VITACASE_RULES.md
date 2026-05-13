# VitaCase Rules

These rules apply to every coding task.

## Product Truth

- VitaCase is not currently an AI medical assistant.
- Do not claim current OCR, AI summaries, AI medical analysis, or document intelligence unless actually implemented.
- Future AI/OCR ideas must be described as roadmap or planned capabilities only.
- Do not market security claims stronger than the implementation.

## Coding Rules

- Use `flutter_riverpod` for state.
- Use `go_router` for routing.
- Use feature-first structure.
- Keep business logic outside widgets.
- Avoid giant widgets and giant screens.
- Avoid duplicated providers.
- Avoid provider bleed across unrelated features.
- Avoid hardcoded visible strings.
- Avoid hardcoded colors.
- Avoid fake data in production UI.
- Prefer existing app conventions and shared helpers.

## Security Rules

- Never store raw PIN.
- Use secure storage for secrets and sensitive auth material.
- Prefer local-only data.
- Sensitive documents must stay encrypted.
- Avoid external document opening.
- If external opening is necessary, show a privacy warning first.
- Do not leave decrypted temporary files behind.
- Treat vault preview, export, delete, and share flows as sensitive.

## Notification Rules

Notification engine must support:

- Medication reminders
- Appointment reminders
- Refill reminders

Avoid:

- Requesting notification permissions during startup
- Aggressive rescheduling
- Duplicate schedules
- Unreliable recurrence logic

Notification changes must be checked for permission timing, recurrence behavior, duplicate IDs, timezone handling, and app lifecycle effects.

## Ads Rules

Ads must never:

- Interrupt onboarding
- Appear immediately after unlock
- Appear during emergency flow
- Appear during sensitive save, delete, export, vault, or security flows

Ads must:

- Be adaptive
- Respect dark mode
- Preserve trust
- Avoid making healthcare actions feel monetized or unsafe

## Localization And Accessibility

- All visible user-facing strings should be localizable.
- Check Turkish and English impact when editing UI text.
- Preserve semantic labels for controls.
- Support readable contrast, text scaling, and touch targets.
