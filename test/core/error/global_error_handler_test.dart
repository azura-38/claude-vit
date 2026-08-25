import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/error/global_error_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('VitaCase V1.1 — Unified GlobalErrorHandler Tests', () {
    test('A & B & C: initialize registers handlers idempotently without duplicate registration', () {
      GlobalErrorHandler.initialize();
      expect(GlobalErrorHandler.isInitialized, isTrue);

      final originalFlutterHandler = FlutterError.onError;
      final originalPlatformHandler = PlatformDispatcher.instance.onError;

      expect(originalFlutterHandler, equals(GlobalErrorHandler.handleFlutterError));
      expect(originalPlatformHandler, equals(GlobalErrorHandler.handlePlatformError));

      // Calling initialize a second time is safe and does not overwrite or crash
      GlobalErrorHandler.initialize();
      expect(FlutterError.onError, equals(originalFlutterHandler));
      expect(PlatformDispatcher.instance.onError, equals(originalPlatformHandler));
    });

    test('D & E: Privacy Sanitization redacts PIN parameter assignments', () {
      const rawErrorWithPin = 'AuthException: Verification failed for pin=123456';
      final sanitizedPin = GlobalErrorHandler.sanitizeErrorMessage(rawErrorWithPin);

      expect(sanitizedPin, isNot(contains('123456')));
      expect(sanitizedPin, contains('[REDACTED_PIN]'));
    });

    test('D & F: Privacy Sanitization redacts temporary decrypted document paths', () {
      const rawErrorWithTempPath =
          'FileSystemException: Cannot open file /data/user/0/com.limanex.vitacase/cache/decrypted_1724623910_blood_test.pdf';
      final sanitizedPath = GlobalErrorHandler.sanitizeErrorMessage(rawErrorWithTempPath);

      expect(sanitizedPath, isNot(contains('decrypted_1724623910_blood_test.pdf')));
      expect(sanitizedPath, contains('[REDACTED_TEMP_FILE]'));
    });

    test('G: Safe when Firebase & Sentry are uninitialized during early Flutter errors', () {
      final details = FlutterErrorDetails(
        exception: Exception('Early bootstrap layout error before Firebase is ready'),
        stack: StackTrace.current,
        library: 'widgets library',
      );

      expect(() => GlobalErrorHandler.handleFlutterError(details), returnsNormally);
    });

    test('G: Safe when Firebase & Sentry are uninitialized during uncaught platform async errors', () {
      final error = StateError('Uncaught asynchronous background error');
      final stack = StackTrace.current;

      final handled = GlobalErrorHandler.handlePlatformError(error, stack);
      expect(handled, isTrue);
    });

    test('persistError records sanitized error in local SharedPreferences for diagnostic log', () async {
      await GlobalErrorHandler.persistError('Test fatal error', 'Test stack trace');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('last_error_message'), equals('Test fatal error'));
      expect(prefs.getString('last_error_stack'), equals('Test stack trace'));
      expect(prefs.getInt('last_error_ts'), isNotNull);
    });
  });
}
