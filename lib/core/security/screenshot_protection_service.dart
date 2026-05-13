import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenshotProtectionService {
  static const _channel = MethodChannel('vitacase/security');

  Future<void> enable() async {
    if (kIsWeb) return;

    try {
      await _channel.invokeMethod<void>('enableSecureScreen');
    } on MissingPluginException {
      debugPrint('[Security] Secure screen plugin is not available on this platform.');
    }
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
