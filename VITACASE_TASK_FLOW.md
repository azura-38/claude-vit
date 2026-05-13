# VitaCase Task Flow

Use this checklist before and after every VitaCase coding task.

## Before Coding

1. Read all VitaCase memory files:
   - `VITACASE_CONTEXT.md`
   - `VITACASE_ARCHITECTURE.md`
   - `VITACASE_RULES.md`
   - `VITACASE_CURRENT_PRIORITIES.md`
   - `VITACASE_TASK_FLOW.md`
2. Understand current priorities.
3. Identify affected feature boundaries.
4. Check architecture consistency.
5. Avoid breaking startup lifecycle.
6. Avoid introducing provider bleed.
7. Avoid hardcoded strings and colors.
8. Keep UX premium, minimal, and healthcare-friendly.
9. Confirm whether the task touches privacy, vault, notifications, ads, localization, or navigation.

## During Coding

- Follow existing patterns first.
- Keep changes scoped to the task.
- Use Riverpod providers intentionally and close to their ownership boundary.
- Use `go_router` for navigation changes.
- Keep widgets small and presentation-focused.
- Move business logic into domain, repository, service, or controller layers.
- Use theme and localization systems.
- Treat vault, export, delete, unlock, and emergency flows as sensitive.

## Before Finishing

Run:

```text
flutter analyze
flutter test
```

Verify:

- Navigation behavior
- Dark mode
- Localization impact
- Notification impact
- Privacy/security impact
- Startup lifecycle impact
- Provider ownership
- Accessibility basics
- Ads placement rules

## Final Response Expectations

Summarize:

- What changed
- Files touched
- Verification performed
- Any tests not run
- Any remaining risk or follow-up
