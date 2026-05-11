import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/profile/presentation/providers/legacy_providers.dart';
import '../../shared/providers/onboarding_provider.dart';
import '../constants/app_routes.dart';
import '../notifications/notification_navigation.dart';
import '../types/runtime_types.dart';

class RouteGuardState {
  const RouteGuardState({
    required this.onboardingCompleted,
    required this.lockState,
    required this.isLockEnabled,
    required this.pendingNotificationRoute,
  });

  final bool onboardingCompleted;
  final AppLockState lockState;
  final bool isLockEnabled;
  final String? pendingNotificationRoute;
}

final routeGuardStateProvider = Provider<RouteGuardState>((ref) {
  return RouteGuardState(
    onboardingCompleted: ref.watch(onboardingCompletedProvider),
    lockState: ref.watch(appLockStateProvider),
    isLockEnabled: ref.watch(appLockEnabledProvider),
    pendingNotificationRoute: ref.watch(pendingNotificationRouteProvider),
  );
});

String? notificationRedirect(Ref ref, GoRouterState state, RouteGuardState guard) {
  final route = guard.pendingNotificationRoute;
  if (route == null) return null;
  if (guard.lockState != AppLockState.unlocked) return null;
  if (!guard.onboardingCompleted) return null;
  if (state.matchedLocation == route) return null;

  Future.microtask(
    () => ref.read(pendingNotificationRouteProvider.notifier).clear(),
  );
  return route;
}

String? lockRedirect(GoRouterState state, RouteGuardState guard) {
  final isGoingToLock = state.matchedLocation == AppRoutes.lock;

  if (guard.lockState == AppLockState.unknown && !isGoingToLock) {
    return AppRoutes.lock;
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

String? onboardingRedirect(GoRouterState state, RouteGuardState guard) {
  if (guard.onboardingCompleted) return null;

  final isGoingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
  final isGoingToProfileCreate = state.matchedLocation == AppRoutes.profileCreate;
  if (!isGoingToOnboarding && !isGoingToProfileCreate) {
    return AppRoutes.onboarding;
  }
  return null;
}

String? profileRedirect(Ref ref, GoRouterState state) {
  final isGoingToProfileCreate = state.matchedLocation == AppRoutes.profileCreate;
  final profileCreated = ref.read(profileCreatedProvider);
  if (!profileCreated && !isGoingToProfileCreate) {
    return AppRoutes.profileCreate;
  }
  return null;
}

String? legalRedirect(Ref ref, GoRouterState state) {
  final legalAccepted = ref.read(legalAcceptedProvider);
  if (legalAccepted) return null;

  final isGoingToProfileCreate = state.matchedLocation == AppRoutes.profileCreate;
  final isGoingToLegal =
      state.matchedLocation.contains('terms') ||
      state.matchedLocation.contains('privacy') ||
      state.matchedLocation.contains('disclaimer');

  if (!isGoingToLegal && !isGoingToProfileCreate) {
    return AppRoutes.profileCreate;
  }
  return null;
}

String? completedEntryRedirect(Ref ref, GoRouterState state) {
  final isGoingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
  final isGoingToProfileCreate = state.matchedLocation == AppRoutes.profileCreate;
  if (!isGoingToOnboarding && !isGoingToProfileCreate) return null;

  final hasName = ref.read(profileNameProvider) != null;
  final legalAccepted = ref.read(legalAcceptedProvider);
  return hasName && legalAccepted ? AppRoutes.home : null;
}
