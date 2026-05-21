import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import 'screenshot_protection_service.dart';

final screenshotProtectionServiceProvider = Provider(
  (ref) => ScreenshotProtectionService(),
);

final securityControllerProvider =
    NotifierProvider<SecurityController, SecurityStatus>(
      SecurityController.new,
    );

class SecurityStatus {
  const SecurityStatus({
    required this.lockEnabled,
    required this.biometricEnabled,
    required this.screenshotProtectionEnabled,
  });

  final bool lockEnabled;
  final bool biometricEnabled;
  final bool screenshotProtectionEnabled;

  String get encryptionLabel => 'AES-256 active';
  String get storageLabel => 'Local-only storage';
}

class SecurityController extends Notifier<SecurityStatus> {
  @override
  SecurityStatus build() {
    return SecurityStatus(
      lockEnabled: ref.watch(appLockEnabledProvider),
      biometricEnabled: ref.watch(biometricEnabledProvider),
      screenshotProtectionEnabled: false,
    );
  }

  Future<void> applySecureScreenPolicy() async {
    await ref.read(screenshotProtectionServiceProvider).enable();
  }
}
