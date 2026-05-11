import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/profile/presentation/providers/legacy_providers.dart';
import '../../shared/providers/onboarding_provider.dart';
import '../../shared/providers/premium_provider.dart';
import '../types/runtime_types.dart';

final adVisibilityPolicyProvider = Provider<AdVisibilityPolicy>((ref) {
  return AdVisibilityPolicy(
    isPremium: ref.watch(premiumProvider),
    onboardingCompleted: ref.watch(onboardingCompletedProvider),
    profileCreated: ref.watch(profileCreatedProvider),
    lockEnabled: ref.watch(appLockEnabledProvider),
    lockState: ref.watch(appLockStateProvider),
  );
});

class AdVisibilityPolicy {
  const AdVisibilityPolicy({
    required this.isPremium,
    required this.onboardingCompleted,
    required this.profileCreated,
    required this.lockEnabled,
    required this.lockState,
  });

  final bool isPremium;
  final bool onboardingCompleted;
  final bool profileCreated;
  final bool lockEnabled;
  final AppLockState lockState;

  bool get canShowBanner {
    if (isPremium) return false;
    if (!onboardingCompleted || !profileCreated) return false;
    if (lockEnabled && lockState != AppLockState.unlocked) return false;
    return true;
  }

  bool get canShowAppOpen {
    if (!canShowBanner) return false;
    return true;
  }

  bool get canShowInterstitial => canShowBanner;
}
