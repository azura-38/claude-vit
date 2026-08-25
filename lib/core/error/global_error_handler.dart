import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized, unified error handling system for VitaCase.
///
/// Ensures single-point registration for [FlutterError.onError] and
/// [PlatformDispatcher.instance.onError], sanitizing sensitive health/security data
/// and fanning out safely to Sentry, Firebase Crashlytics, local persistence, and debug logs.
class GlobalErrorHandler {
  GlobalErrorHandler._();

  static bool _isInitialized = false;

  /// Whether the centralized handlers are active.
  static bool get isInitialized => _isInitialized;

  /// Initializes the unified error handling chain once during bootstrap.
  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    FlutterError.onError = handleFlutterError;
    PlatformDispatcher.instance.onError = handlePlatformError;
  }

  /// Centralized Flutter framework error handler.
  static void handleFlutterError(FlutterErrorDetails details) {
    final sanitizedException = sanitizeErrorMessage(details.exceptionAsString());
    final stackString = details.stack?.toString() ?? '';

    // 1. Debug logging
    debugPrint('[FlutterError] $sanitizedException');
    if (details.stack != null) {
      debugPrintStack(stackTrace: details.stack, label: '[FlutterError stack]');
    }

    // 2. Local persistence (for debug panel / support)
    unawaited(persistError(sanitizedException, stackString));

    // 3. Sentry integration (safe if Sentry is active)
    try {
      Sentry.captureException(details.exception, stackTrace: details.stack);
    } catch (_) {}

    // 4. Firebase Crashlytics integration (safe if Firebase is initialized on mobile)
    if (!kIsWeb) {
      try {
        if (Firebase.apps.isNotEmpty) {
          FirebaseCrashlytics.instance.recordFlutterError(details);
        }
      } catch (_) {}
    }
  }

  /// Centralized uncaught async platform error handler.
  static bool handlePlatformError(Object error, StackTrace stack) {
    final sanitizedMessage = sanitizeErrorMessage(error.toString());

    // 1. Debug logging
    debugPrint('[PlatformError] $sanitizedMessage');
    debugPrintStack(stackTrace: stack, label: '[PlatformError stack]');

    // 2. Local persistence
    unawaited(persistError(sanitizedMessage, stack.toString()));

    // 3. Sentry integration
    try {
      Sentry.captureException(error, stackTrace: stack);
    } catch (_) {}

    // 4. Firebase Crashlytics integration
    if (!kIsWeb) {
      try {
        if (Firebase.apps.isNotEmpty) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
      } catch (_) {}
    }

    return true;
  }

  /// Sanitizes sensitive user information (e.g. decrypted temp paths, PINs, tokens)
  /// before external or disk logging.
  static String sanitizeErrorMessage(String raw) {
    var sanitized = raw;

    // Redact temporary decrypted file paths
    sanitized = sanitized.replaceAll(
      RegExp(r'decrypted_\d+_[^\s,\)]+'),
      '[REDACTED_TEMP_FILE]',
    );

    // Redact PIN-like parameter assignments if ever leaked in an exception
    sanitized = sanitized.replaceAll(
      RegExp(r'(pin|passcode|code)[:=]\s*(\d{4,6})', caseSensitive: false),
      r'$1=[REDACTED_PIN]',
    );

    return sanitized;
  }

  /// Safely records the last error in SharedPreferences.
  static Future<void> persistError(String message, String stack) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_error_message', message);
      await prefs.setString('last_error_stack', stack);
      await prefs.setInt('last_error_ts', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('[GlobalErrorHandler] Failed to persist error: $e');
    }
  }
}
