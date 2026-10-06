import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/profile/presentation/providers/legacy_providers.dart';
import '../../shared/providers/onboarding_provider.dart';
import '../../shared/providers/premium_provider.dart';
import '../bootstrap/app_bootstrap_controller.dart';
import '../types/runtime_types.dart';

final adVisibilityPolicyProvider = Provider<AdVisibilityPolicy>((ref) {
  return AdVisibilityPolicy(
    bootstrapCompleted: ref.watch(appBootstrapProvider).hasValue,
    isPremium: ref.watch(premiumProvider),
    onboardingCompleted: ref.watch(onboardingCompletedProvider),
    profileCreated: ref.watch(profileCreatedProvider),
    legalAccepted: ref.watch(legalAcceptedProvider),
    lockEnabled: ref.watch(appLockEnabledProvider),
    lockState: ref.watch(appLockStateProvider),
  );
});

class AdVisibilityPolicy {
  const AdVisibilityPolicy({
    this.bootstrapCompleted = true,
    required this.isPremium,
    required this.onboardingCompleted,
    required this.profileCreated,
    this.legalAccepted = true,
    required this.lockEnabled,
    required this.lockState,
  });

  final bool bootstrapCompleted;
  final bool isPremium;
  final bool onboardingCompleted;
  final bool profileCreated;
  final bool legalAccepted;
  final bool lockEnabled;
  final AppLockState lockState;

  bool get canShowBanner {
    if (!bootstrapCompleted) return false;
    if (isPremium) return false;
    if (!onboardingCompleted) return false;
    if (!legalAccepted) return false;
    if (lockEnabled && lockState != AppLockState.unlocked) return false;
    return true;
  }

  bool get canShowAppOpen {
    if (!canShowBanner) return false;
    return true;
  }

  bool get canShowInterstitial => canShowBanner;

  bool get canShowRewarded {
    if (!bootstrapCompleted) return false;
    if (!onboardingCompleted) return false;
    if (!legalAccepted) return false;
    if (lockEnabled && lockState != AppLockState.unlocked) return false;
    return true;
  }

  bool get canShowRewardedInterstitial => canShowRewarded;
}
