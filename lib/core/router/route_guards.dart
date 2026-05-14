import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/profile/presentation/providers/legacy_providers.dart';
import '../../shared/providers/onboarding_provider.dart';
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
  });

  final bool isBootstrapped;
  final bool onboardingCompleted;
  final AppLockState lockState;
  final bool isLockEnabled;
  final String? pendingNotificationRoute;
  final bool profileCreated;
  final String? profileName;
  final bool legalAccepted;
}

final routeGuardStateProvider = Provider<RouteGuardState>((ref) {
  final bootstrap = ref.watch(appBootstrapProvider);
  final isBootstrapped = bootstrap.hasValue;

  final guard = RouteGuardState(
    isBootstrapped: isBootstrapped,
    onboardingCompleted: ref.watch(onboardingCompletedProvider),
    lockState: ref.watch(appLockStateProvider),
    isLockEnabled: ref.watch(appLockEnabledProvider),
    pendingNotificationRoute: ref.watch(pendingNotificationRouteProvider),
    profileCreated: ref.watch(profileCreatedProvider),
    profileName: ref.watch(profileNameProvider),
    legalAccepted: ref.watch(legalAcceptedProvider),
  );

  if (kDebugMode) {
    debugPrint(
      '[RouteGuard] boot=${guard.isBootstrapped} onboarding=${guard.onboardingCompleted} '
      'profile=${guard.profileCreated} legal=${guard.legalAccepted} '
      'lockEnabled=${guard.isLockEnabled} lockState=${guard.lockState}',
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

  if (!isGoingToOnboarding && !isGoingToLegal) {
    return AppRoutes.onboarding;
  }
  return null;
}

String? profileRedirect(GoRouterState state, RouteGuardState guard) {
  final isGoingToProfileCreate =
      state.matchedLocation == AppRoutes.profileCreate;
  final isGoingToLegal = _isLegalRoute(state);

  if (!guard.profileCreated && !isGoingToProfileCreate && !isGoingToLegal) {
    return AppRoutes.profileCreate;
  }
  return null;
}

String? legalRedirect(GoRouterState state, RouteGuardState guard) {
  if (guard.legalAccepted) return null;

  final isGoingToProfileCreate =
      state.matchedLocation == AppRoutes.profileCreate;
  final isGoingToLegal = _isLegalRoute(state);

  if (!isGoingToLegal && !isGoingToProfileCreate) {
    return AppRoutes.profileCreate;
  }
  return null;
}

String? lockRedirect(GoRouterState state, RouteGuardState guard) {
  final isGoingToLock = state.matchedLocation == AppRoutes.lock;

  // Do not let lock flow override first-run setup. This prevents startup blank
  // loops when old prefs say locked but onboarding/profile/legal is incomplete.
  if (!guard.onboardingCompleted || !guard.profileCreated || !guard.legalAccepted) {
    return isGoingToLock ? AppRoutes.onboarding : null;
  }

  if (guard.lockState == AppLockState.unknown) {
    return null;
  }

  if (guard.isLockEnabled && guard.lockState != AppLockState.unlocked) {
    return isGoingToLock ? null : AppRoutes.lock;
  }

  if (isGoingToLock &&
      (!guard.isLockEnabled || guard.lockState == AppLockState.unlocked)) {
    return AppRoutes.home;
  }

  return null;
}

String? completedEntryRedirect(GoRouterState state, RouteGuardState guard) {
  final isGoingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
  final isGoingToProfileCreate =
      state.matchedLocation == AppRoutes.profileCreate;

  if (!isGoingToOnboarding && !isGoingToProfileCreate) return null;

  final isFullySetUp =
      guard.onboardingCompleted && guard.profileName != null && guard.legalAccepted;
  return isFullySetUp ? AppRoutes.home : null;
}

bool _isLegalRoute(GoRouterState state) {
  final location = state.matchedLocation;
  return location.contains('terms') ||
      location.contains('privacy') ||
      location.contains('disclaimer');
}
