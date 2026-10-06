import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/profile/presentation/providers/legacy_providers.dart';
import '../../shared/providers/onboarding_provider.dart';
import '../../shared/providers/user_preferences_controller.dart';
import '../bootstrap/app_bootstrap_controller.dart';
import '../constants/app_routes.dart';
import '../notifications/notification_navigation.dart';
import '../types/runtime_types.dart';

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
    this.legalNeedsUpdate = false,
  });

  final bool isBootstrapped;
  final bool onboardingCompleted;
  final AppLockState lockState;
  final bool isLockEnabled;
  final String? pendingNotificationRoute;
  final bool profileCreated;
  final String? profileName;
  final bool legalAccepted;
  final bool legalNeedsUpdate;
}

final routeGuardStateProvider = Provider<RouteGuardState>((ref) {
  final bootstrap = ref.watch(appBootstrapProvider);
  final prefsAsync = ref.watch(userPreferencesControllerProvider);
  final isBootstrapped = bootstrap.hasValue && !prefsAsync.isLoading;

  final guard = RouteGuardState(
    isBootstrapped: isBootstrapped,
    onboardingCompleted: ref.watch(onboardingCompletedProvider),
    lockState: ref.watch(appLockStateProvider),
    isLockEnabled: ref.watch(appLockEnabledProvider),
    pendingNotificationRoute: ref.watch(pendingNotificationRouteProvider),
    profileCreated: ref.watch(profileCreatedProvider),
    profileName: ref.watch(profileNameProvider),
    legalAccepted: ref.watch(legalAcceptedProvider),
    legalNeedsUpdate: ref.watch(legalNeedsUpdateProvider),
  );

  if (kDebugMode) {
    debugPrint(
      '[RouteGuard] boot=${guard.isBootstrapped} onboarding=${guard.onboardingCompleted} '
      'profile=${guard.profileCreated} legal=${guard.legalAccepted} '
      'lockEnabled=${guard.isLockEnabled} lockState=${guard.lockState} '
      'legalNeedsUpdate=${guard.legalNeedsUpdate}',
    );
  }

  return guard;
});

String? notificationRedirect(
  Ref ref,
  GoRouterState state,
  RouteGuardState guard,
) {
  final route = guard.pendingNotificationRoute;
  if (route == null) return null;
  if (guard.lockState != AppLockState.unlocked) return null;
  if (!guard.onboardingCompleted) return null;
  if (!guard.profileCreated || !guard.legalAccepted) return null;
  if (state.matchedLocation == route) return null;

  Future.microtask(
    () => ref.read(pendingNotificationRouteProvider.notifier).clear(),
  );
  return route;
}

String? onboardingRedirect(GoRouterState state, RouteGuardState guard) {
  if (guard.onboardingCompleted) return null;

  final isGoingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
  final isGoingToLegal = _isLegalRoute(state);

  // During first-run onboarding, profile/legal guards must not run yet.
  // Only onboarding itself and legal documents are allowed.
  if (!isGoingToOnboarding && !isGoingToLegal) {
    return AppRoutes.onboarding;
  }
  return null;
}

String? profileRedirect(GoRouterState state, RouteGuardState guard) {
  // Never force profile creation before onboarding has been completed.
  // Otherwise /onboarding -> /profile-create -> /onboarding redirect loops occur.
  if (!guard.onboardingCompleted) return null;

  final isGoingToProfileCreate = state.matchedLocation == AppRoutes.profileCreate;
  final isGoingToLegal = _isLegalRoute(state);

  if (!guard.profileCreated && !isGoingToProfileCreate && !isGoingToLegal) {
    return AppRoutes.profileCreate;
  }
  return null;
}

String? legalRedirect(GoRouterState state, RouteGuardState guard) {
  // Legal acceptance is collected in profile creation, so do not redirect to
  // profile-create until onboarding is done.
  if (!guard.onboardingCompleted) return null;
  if (guard.legalAccepted) return null;

  final isGoingToProfileCreate = state.matchedLocation == AppRoutes.profileCreate;
  final isGoingToLegalUpdate = state.matchedLocation == AppRoutes.legalUpdate;
  final isGoingToLegal = _isLegalRoute(state);

  // Existing user with outdated legal version → show update consent screen
  if (guard.legalNeedsUpdate) {
    if (!isGoingToLegalUpdate && !isGoingToLegal) {
      return AppRoutes.legalUpdate;
    }
    return null;
  }

  // New user who never accepted → profile create (existing behavior)
  if (!isGoingToLegal && !isGoingToProfileCreate) {
    return AppRoutes.profileCreate;
  }
  return null;
}

String? lockRedirect(GoRouterState state, RouteGuardState guard) {
  final isGoingToLock = state.matchedLocation == AppRoutes.lock;

  if (!guard.onboardingCompleted || !guard.profileCreated || !guard.legalAccepted) {
    return isGoingToLock ? AppRoutes.onboarding : null;
  }

  if (guard.lockState == AppLockState.unknown) {
    return null;
  }

  if (guard.isLockEnabled && guard.lockState != AppLockState.unlocked) {
    if (isGoingToLock) return null;
    final currentLoc = state.matchedLocation;
    if (currentLoc.isNotEmpty && currentLoc != AppRoutes.lock && currentLoc != AppRoutes.home) {
      return '${AppRoutes.lock}?from=${Uri.encodeComponent(currentLoc)}';
    }
    return AppRoutes.lock;
  }

  if (isGoingToLock &&
      (!guard.isLockEnabled || guard.lockState == AppLockState.unlocked)) {
    final from = state.uri.queryParameters['from'];
    if (from != null && from.isNotEmpty && from != AppRoutes.lock) {
      return Uri.decodeComponent(from);
    }
    return AppRoutes.home;
  }

  return null;
}

String? completedEntryRedirect(GoRouterState state, RouteGuardState guard) {
  final isGoingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
  final isGoingToProfileCreate = state.matchedLocation == AppRoutes.profileCreate;
  final isGoingToLegalUpdate = state.matchedLocation == AppRoutes.legalUpdate;

  if (!isGoingToOnboarding && !isGoingToProfileCreate && !isGoingToLegalUpdate) return null;

  final isFullySetUp =
      guard.onboardingCompleted && guard.profileCreated && guard.legalAccepted;
  return isFullySetUp ? AppRoutes.home : null;
}

bool _isLegalRoute(GoRouterState state) {
  final location = state.matchedLocation;
  return location.contains('terms') ||
      location.contains('privacy') ||
      location.contains('disclaimer') ||
      location.contains('kvkk') ||
      location.contains('data-deletion') ||
      location.contains('legal-update');
}
