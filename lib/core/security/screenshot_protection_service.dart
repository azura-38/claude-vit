import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenshotProtectionService {
  static const _channel = MethodChannel('vitacase/security');

  // Screenshot protection disabled – enable() is a no-op.
  Future<void> enable() async {
    return; // Disabled: screenshot protection devre dışı bırakıldı.
  }

  Future<void> disable() async {
    if (kIsWeb) return;

    try {
      await _channel.invokeMethod<void>('disableSecureScreen');
    } on MissingPluginException {
      debugPrint('[Security] Secure screen plugin is not available on this platform.');
    }
  }
}
