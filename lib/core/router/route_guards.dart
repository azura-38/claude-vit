import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/profile/presentation/providers/legacy_providers.dart';
import '../../shared/providers/onboarding_provider.dart';
import '../bootstrap/app_bootstrap_controller.dart';
import '../constants/app_routes.dart';
import '../notifications/notification_navigation.dart';
import '../types/runtime_types.dart';

/// Snapshot of all guard-relevant state consumed by the router's redirect.
///
/// All fields are read once from their respective providers and stored here.
/// This makes redirect functions pure — they never call ref.read/watch themselves,
/// preventing stale reads and provider-inside-redirect bugs.
class RouteGuardState {
  const RouteGuardState({
    required this.isBootstrapped,
    required this.onboardingCompleted,
    required this.lockState,
    required this.isLockEnabled,
    required this.pendingNotificationRoute,
    required this.profileCreated,
    required this.profileName,
    required this.legalAccepted,
  });

  /// True once [appBootstrapProvider] has emitted data.
  /// While false, all redirects return null so BootstrapScreen can manage UI.
  final bool isBootstrapped;

  final bool onboardingCompleted;
  final AppLockState lockState;
  final bool isLockEnabled;
  final String? pendingNotificationRoute;

  /// True if user has a non-empty profile name stored.
  final bool profileCreated;

  /// The profile's full name, or null if not set.
  final String? profileName;

  /// True if user has accepted legal documents.
  final bool legalAccepted;
}

final routeGuardStateProvider = Provider<RouteGuardState>((ref) {
  // Bootstrap state — derived from the AsyncNotifier
  // Using maybeWhen: while loading/error → isBootstrapped = false
  final bootstrap = ref.watch(appBootstrapProvider);
  final isBootstrapped = bootstrap.hasValue;

  return RouteGuardState(
    isBootstrapped: isBootstrapped,
    onboardingCompleted: ref.watch(onboardingCompletedProvider),
    lockState: ref.watch(appLockStateProvider),
    isLockEnabled: ref.watch(appLockEnabledProvider),
    pendingNotificationRoute: ref.watch(pendingNotificationRouteProvider),
    profileCreated: ref.watch(profileCreatedProvider),
    profileName: ref.watch(profileNameProvider),
    legalAccepted: ref.watch(legalAcceptedProvider),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Guard Functions — pure functions, no ref access, only read from RouteGuardState
// ─────────────────────────────────────────────────────────────────────────────

/// Handle notification deep links.
/// Only activates when app is unlocked AND onboarding is done.
String? notificationRedirect(
  Ref ref,
  GoRouterState state,
  RouteGuardState guard,
) {
  final route = guard.pendingNotificationRoute;
  if (route == null) return null;
  if (guard.lockState != AppLockState.unlocked) return null;
  if (!guard.onboardingCompleted) return null;
  if (state.matchedLocation == route) return null;

  // Clear the pending route after consuming it
  Future.microtask(
    () => ref.read(pendingNotificationRouteProvider.notifier).clear(),
  );
  return route;
}

/// Handle app lock.
String? lockRedirect(GoRouterState state, RouteGuardState guard) {
  final isGoingToLock = state.matchedLocation == AppRoutes.lock;

  // Lock state unknown means we haven't loaded prefs yet — during this window
  // the lock screen is shown as a safe default to prevent unauthorized access.
  if (guard.lockState == AppLockState.unknown && !isGoingToLock) {
    return AppRoutes.lock;
  }

  // Lock is enabled AND app is locked → redirect to lock screen
  if (guard.isLockEnabled && guard.lockState != AppLockState.unlocked) {
    return isGoingToLock ? null : AppRoutes.lock;
  }

  // Already on lock screen but lock is disabled/unlocked → go home
  if (isGoingToLock &&
      (!guard.isLockEnabled || guard.lockState == AppLockState.unlocked)) {
    return AppRoutes.home;
  }

  return null;
}

/// Redirect to onboarding if not completed.
String? onboardingRedirect(GoRouterState state, RouteGuardState guard) {
  if (guard.onboardingCompleted) return null;

  final isGoingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
  final isGoingToProfileCreate =
      state.matchedLocation == AppRoutes.profileCreate;

  if (!isGoingToOnboarding && !isGoingToProfileCreate) {
    return AppRoutes.onboarding;
  }
  return null;
}

/// Redirect to profile-create if profile doesn't exist.
/// Uses pre-read guard state — no ref.read() inside.
String? profileRedirect(GoRouterState state, RouteGuardState guard) {
  final isGoingToProfileCreate =
      state.matchedLocation == AppRoutes.profileCreate;

  if (!guard.profileCreated && !isGoingToProfileCreate) {
    return AppRoutes.profileCreate;
  }
  return null;
}

/// Redirect to profile-create if legal not accepted.
/// Uses pre-read guard state — no ref.read() inside.
String? legalRedirect(GoRouterState state, RouteGuardState guard) {
  if (guard.legalAccepted) return null;

  final isGoingToProfileCreate =
      state.matchedLocation == AppRoutes.profileCreate;
  final isGoingToLegal =
      state.matchedLocation.contains('terms') ||
      state.matchedLocation.contains('privacy') ||
      state.matchedLocation.contains('disclaimer');

  if (!isGoingToLegal && !isGoingToProfileCreate) {
    return AppRoutes.profileCreate;
  }
  return null;
}

/// If user is already fully set up but trying to visit onboarding/profile-create, send home.
String? completedEntryRedirect(GoRouterState state, RouteGuardState guard) {
  final isGoingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
  final isGoingToProfileCreate =
      state.matchedLocation == AppRoutes.profileCreate;

  if (!isGoingToOnboarding && !isGoingToProfileCreate) return null;

  final isFullySetUp = guard.profileName != null && guard.legalAccepted;
  return isFullySetUp ? AppRoutes.home : null;
}
