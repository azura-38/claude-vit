import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/types/runtime_types.dart';

/// Premium is intentionally disabled for VitaCase V1.
///
/// V1 launch scope is free + ads/local limits only. RevenueCat/subscriptions
/// will be reintroduced in a later version after purchase, restore, and
/// entitlement validation are fully wired and tested.
class PremiumNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> setPremium(bool value) async {
    // No-op while premium is disabled in V1.
    state = false;
  }

  Future<void> addTemporaryPremium(int days) async {
    // No-op while premium is disabled in V1.
    state = false;
  }
}

final premiumProvider = NotifierProvider<PremiumNotifier, bool>(
  PremiumNotifier.new,
);

final premiumAvailabilityProvider = Provider<PremiumAvailability>((ref) {
  return AppConfig.premiumEnabled
      ? PremiumAvailability.enabled
      : PremiumAvailability.disabled;
});

final premiumEnabledProvider = Provider<bool>((ref) {
  return false;
});
