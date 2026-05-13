# VitaCase Root Cause Elimination Master Plan

## Objective

This document defines the complete root-level rebuild plan required to transform VitaCase from a strong beta into a true production-grade encrypted health platform.

The goal is not to patch isolated bugs.

The goal is to eliminate:

- architectural fragility
- notification unreliability
- privacy risks
- prototype behavior
- provider bleed
- inconsistent UX
- weak lifecycle handling
- scalability risks
- launch blockers

This document focuses on permanent systemic fixes.

## Current Reality

### Current Category

Beta

### Current Readiness

61/100

### Current Risk

High technical debt growth due to:

- fast UI expansion
- partially stabilized architecture
- incomplete infrastructure systems

## Root Problem

The app evolved faster visually than structurally.

Result:

- strong UI
- incomplete systems
- mixed architecture maturity

The solution is not:

- more screens
- more gradients
- more animations

The solution is:

- system stabilization
- architecture consolidation
- lifecycle hardening
- feature completion
- privacy hardening

## Master Root Fix Phases

1. Foundation Stabilization
2. Notification Engine Rebuild
3. Security and Privacy Hardening
4. Vault Architecture Rebuild
5. Profile and Settings Consolidation
6. Localization and Theme Completion
7. Accessibility Pass
8. Performance Hardening
9. Release Governance
10. Production QA and App Store Finalization

## Phase 1: Foundation Stabilization

### Goal

Eliminate architecture inconsistency.

### Root Problems

- provider bleed
- mixed architecture maturity
- giant screens
- business logic inside widgets
- inconsistent state ownership
- weak lifecycle coordination

### Required Actions

#### 1. Enforce Feature Architecture

Every feature must use:

```text
feature/
  data/
  domain/
  presentation/
```

No exceptions.

#### 2. Remove Provider Bleed

Create:

- `ProfileController`
- `SettingsController`
- `NotificationController`
- `SessionController`

No screen should directly orchestrate multiple unrelated providers.

#### 3. Remove Widget Business Logic

Widgets should:

- render state
- trigger controller actions

Widgets should not:

- calculate schedules
- manipulate storage
- orchestrate services

#### 4. Modularize Giant Screens

Split:

- `app_settings_screen.dart`
- `profile_screen.dart`

Into:

- appearance section
- security section
- backup section
- notification section
- legal section

#### 5. Centralize Lifecycle

Create:

- `AppLifecycleController`

Responsible for:

- app lock
- notification refresh
- ad lifecycle
- resume protection
- backup reminders

## [/] Phase 2: Notification Engine Rebuild
  - `[ ]` Step 1: Add and Initialize Awesome Notifications
  - `[ ]` Step 2: Create unified `NotificationEngine`
  - `[ ]` Step 3: Migrate `Medicine` and `Appointment` triggers
  - `[ ]` Step 4: Eliminate `SmartNotificationService`

### Goal

Achieve production-grade reminder reliability.

### Root Problems

- schedule logic distributed
- no durable reminder registry
- startup reschedule instability
- weak recurrence handling
- weak permission onboarding

### Required Actions

#### 1. Build ReminderSchedulerRepository

Create durable reminder records.

Every reminder must persist:

- entity id
- occurrence id
- scheduled time
- timezone
- notification id
- type
- recurrence metadata

#### 2. Create Reconciliation Engine

On:

- app start
- timezone change
- device reboot
- restore

Reconcile:

- missing reminders
- stale reminders
- duplicates

#### 3. Separate Permission Request Flow

Do not request permissions during initialization.

Flow:

- onboarding rationale
- moment-of-need explanation
- permission request

#### 4. Add Actionable Notifications

Support:

- mark as taken
- snooze
- reschedule
- open detail

#### 5. Add Notification Testing Infrastructure

Create:

- debug scheduler
- pending notification inspector
- duplicate detector

## Phase 3: Security and Privacy Hardening

### Goal

Make VitaCase truly privacy-first.

### Root Problems

- decrypted temp file exposure
- incomplete backup validation
- weak external file opening policy
- incomplete lifecycle hardening

### Required Actions

#### 1. Remove Temp File Exposure

Do not decrypt files into shared temp directories.

Instead:

- build secure in-app preview
- stream decrypted content in memory

#### 2. External Open Consent

If user opens externally:

- explicit warning
- explain privacy implications
- require confirmation

#### 3. Harden Backup System

Implement:

- passphrase-based encryption
- manifest validation
- integrity checks
- restore verification

#### 4. Strengthen Session Lock

Add:

- inactivity timeout
- background timeout
- biometric re-entry
- failed attempt lockout

#### 5. Security Claims Governance

Do not market:

- military-grade encryption
- zero-knowledge claims
- medical-grade security

Unless technically validated.

## Phase 4: Vault Architecture Rebuild

### Goal

Eliminate prototype vault behavior.

### Root Problems

- Unsplash preview remnants
- fake preview overlays
- weak preview pipeline
- inconsistent categories

### Required Actions

#### 1. Build SecurePreviewController

Single source of truth for:

- document preview
- preview permissions
- secure rendering

#### 2. Replace Prototype Assets

Remove:

- Unsplash previews
- fake thumbnails
- hardcoded vault text

#### 3. Add Secure Metadata Pipeline

Persist:

- document type
- preview metadata
- OCR metadata
- tags
- encrypted thumbnail refs

#### 4. Add Real Search/Filter/Sort

Support:

- category filters
- tags
- date sorting
- search
- favorites

## Phase 5: Profile and Settings Consolidation

### Goal

Eliminate Frankenstein architecture.

### Root Problems

- legacy providers
- mock services
- mixed profile state
- giant settings widget

### Required Actions

#### 1. Build Unified ProfileState

Single immutable state:

- identity
- medical info
- emergency info
- completion status
- settings summary

#### 2. Remove Mock Services

Delete:

- `mock_profile_service.dart`
- prototype placeholder systems

#### 3. Build Settings Sections

Separate:

- `AppearanceSettings`
- `NotificationSettings`
- `SecuritySettings`
- `BackupSettings`
- `LegalSettings`

#### 4. Add Setup Checklist

For first user:

- notification setup
- PIN setup
- profile setup
- emergency contact
- medication setup

## Phase 6: Localization and Theme Completion

### Goal

Achieve global consistency.

### Root Problems

- hardcoded strings
- partial semantic colors
- mixed TR/EN UI

### Required Actions

#### 1. Complete ARB Migration

No visible string may remain hardcoded.

#### 2. Complete Semantic Theme Migration

All widgets must use:

- `Theme.of(context).colorScheme`

No feature-specific hardcoded colors.

#### 3. Add Theme QA

Verify:

- dark mode
- AMOLED mode
- dialogs
- ads
- overlays
- sheets
- bottom nav

## Phase 7: Accessibility Pass

### Goal

Make VitaCase usable for real healthcare users.

### Root Problems

- weak semantics
- small touch targets
- limited scaling support

### Required Actions

#### 1. Add Semantics Everywhere

Buttons, cards, actions, PIN keypad.

#### 2. Validate Elderly UX

Check:

- readability
- spacing
- tap sizes
- emergency flows

#### 3. Add Reduced Motion Support

Animations must adapt.

## Phase 8: Performance Hardening

### Goal

Prevent long-term scalability collapse.

### Root Problems

- excessive blur
- heavy gradients
- animation repetition
- possible rebuild storms

### Required Actions

#### 1. Add Rebuild Audits

Inspect:

- provider rebuilds
- giant widget rebuilds
- unnecessary watches

#### 2. Add Low-End Device Profiling

Test:

- low RAM
- low GPU
- Android 10/11 devices

#### 3. Optimize Heavy UI

Reduce:

- backdrop blur
- nested opacity
- giant shadows

## Phase 9: Release Governance

### Goal

Prevent unfinished feature exposure.

### Root Problems

- visible coming soon routes
- incomplete backup UI
- placeholder explore routes

### Required Actions

#### 1. Add ReleaseFeatureFlags

Hide unfinished systems.

#### 2. Create Release Checklist

Before release:

- localization complete
- accessibility pass complete
- notifications verified
- ads verified
- onboarding verified

#### 3. Add Internal Beta Mode

Expose unfinished features only in beta.

## Phase 10: Final Production QA

### Goal

Reach launch-grade reliability.

### Required Actions

#### 1. Add Critical Widget Tests

Test:

- appointment flow
- medication flow
- onboarding flow
- lock flow
- vault preview
- notification scheduling

#### 2. Add Service Tests

Test:

- encryption
- backup restore
- notification reconciliation

#### 3. Add Manual QA Matrix

Test:

- Android 10-15
- iOS latest
- dark/light
- airplane mode
- timezone change
- reboot
- terminated state

## Final Target State

VitaCase must become:

- offline-first
- privacy-first
- encrypted
- lifecycle-safe
- notification-reliable
- accessibility-safe
- App Store quality
- emotionally premium
- technically trustworthy

## Final Warning

Do not:

- keep expanding features rapidly
- keep adding visual complexity
- prioritize animations over systems

Prioritize:

1. reliability
2. privacy
3. architecture
4. lifecycle stability
5. notification correctness
6. trust UX

Only after those:

- continue feature expansion

## Final Success Condition

VitaCase should no longer feel like:

- a Flutter prototype
- a UI concept
- a stitched demo

It should feel like:

- a real encrypted health companion
- a trustworthy medical utility
- a production-grade mobile platform

