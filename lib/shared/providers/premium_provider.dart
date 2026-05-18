import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/types/runtime_types.dart';

/// Premium is intentionally disabled for VitaCase V1.
/// V1 uses free mode with ads and local limits only.
class PremiumNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> setPremium(bool value) async {
    state = false;
  }

  Future<void> addTemporaryPremium(int days) async {
    state = false;
  }
}

final premiumProvider = NotifierProvider<PremiumNotifier, bool>(PremiumNotifier.new);

final premiumAvailabilityProvider = Provider<PremiumAvailability>((ref) {
  return PremiumAvailability.disabled;
});

final premiumEnabledProvider = Provider<bool>((ref) {
  return false;
});
