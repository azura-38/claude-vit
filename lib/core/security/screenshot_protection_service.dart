import 'package:flutter/services.dart';

class ScreenshotProtectionService {
  static const _channel = MethodChannel('vitacase/security');

  Future<void> enable() async {
    await _channel.invokeMethod<void>('enableSecureScreen');
  }

  Future<void> disable() async {
    await _channel.invokeMethod<void>('disableSecureScreen');
  }
}
