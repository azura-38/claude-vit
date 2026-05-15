import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecureScreenController {
  SecureScreenController._();

  static const MethodChannel _channel = MethodChannel('vitacase/security');
  static int _activeGuards = 0;

  static Future<void> enable() async {
    _activeGuards++;
    if (_activeGuards != 1) return;

    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('enableSecureScreen');
    } catch (e) {
      debugPrint('[SecureScreen] enable failed: $e');
    }
  }

  static Future<void> disable() async {
    if (_activeGuards > 0) _activeGuards--;
    if (_activeGuards != 0) return;

    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('disableSecureScreen');
    } catch (e) {
      debugPrint('[SecureScreen] disable failed: $e');
    }
  }
}

class SecureScreenGuard extends StatefulWidget {
  const SecureScreenGuard({super.key, required this.child});

  final Widget child;

  @override
  State<SecureScreenGuard> createState() => _SecureScreenGuardState();
}

class _SecureScreenGuardState extends State<SecureScreenGuard> {
  @override
  void initState() {
    super.initState();
    SecureScreenController.enable();
  }

  @override
  void dispose() {
    SecureScreenController.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
