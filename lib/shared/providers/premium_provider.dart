import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';
import '../../core/config/app_config.dart';
import '../../core/types/runtime_types.dart';

/// Provider to track the user's premium status.
/// Using a Notifier for modern, robust state management.
class PremiumNotifier extends Notifier<bool> {
  static const String _expiryKey = 'premium_until_date';
  static const String _checksumKey = 'premium_checksum';
  // Obfuscated secret for HMAC — not perfect on client, but far better than reversed string
  static const String _hmacSecret = 'vC_s3cur3_hmAc_k3y_2026_pR0d';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);

    if (!AppConfig.premiumEnabled) {
      return false;
    }

    final expiryStr = prefs.getString(_expiryKey);
    if (expiryStr != null) {
      final expiry = DateTime.tryParse(expiryStr);
      if (expiry != null && DateTime.now().isBefore(expiry)) {
        final storedChecksum = prefs.getString(_checksumKey);
        final expectedChecksum = _generateChecksum(expiryStr);
        if (storedChecksum == expectedChecksum) {
          return true;
        }
      }
    }

    return false;
  }

  String _generateChecksum(String data) {
    final key = utf8.encode(_hmacSecret);
    final bytes = utf8.encode(data);
    return Hmac(sha256, key).convert(bytes).toString();
  }

  Future<void> setPremium(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (value) {
      final expiry = DateTime.now().add(const Duration(days: 3650));
      final expiryStr = expiry.toIso8601String();
      await prefs.setString(_expiryKey, expiryStr);
      await prefs.setString(_checksumKey, _generateChecksum(expiryStr));
    } else {
      await prefs.remove(_expiryKey);
      await prefs.remove(_checksumKey);
    }
    state = value;
  }

  Future<void> addTemporaryPremium(int days) async {
    if (!AppConfig.premiumEnabled) {
      state = false;
      return;
    }

    final prefs = ref.read(sharedPreferencesProvider);
    final currentExpiryStr = prefs.getString(_expiryKey);

    DateTime base = DateTime.now();
    if (currentExpiryStr != null) {
      final currentExpiry = DateTime.tryParse(currentExpiryStr);
      if (currentExpiry != null && currentExpiry.isAfter(base)) {
        base = currentExpiry;
      }
    }

    final newExpiry = base.add(Duration(days: days));
    final newExpiryStr = newExpiry.toIso8601String();
    await prefs.setString(_expiryKey, newExpiryStr);
    await prefs.setString(_checksumKey, _generateChecksum(newExpiryStr));
    state = true;
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
  return ref.watch(premiumAvailabilityProvider) == PremiumAvailability.enabled;
});
