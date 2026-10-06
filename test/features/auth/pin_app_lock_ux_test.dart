import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/constants/app_routes.dart';
import 'package:vitacase/core/router/route_guards.dart';
import 'package:vitacase/core/security/session_lock_service.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/features/auth/presentation/providers/auth_providers.dart';
import 'package:vitacase/features/auth/presentation/screens/lock/lock_screen.dart';
import 'package:vitacase/features/profile/presentation/widgets/settings/security_section.dart';
import 'package:vitacase/l10n/vita_app_localizations_delegate.dart';
import 'package:vitacase/features/profile/presentation/providers/settings_controller.dart';
import 'package:vitacase/core/theme/app_theme.dart';
import 'package:vitacase/shared/domain/entities/lock_timeout.dart';
import 'package:vitacase/shared/providers/notification_settings_provider.dart';
import 'package:vitacase/shared/data/services/pin_service.dart';
import 'package:vitacase/shared/providers/shared_prefs_provider.dart';

class FakeSettingsController extends SettingsController {
  FakeSettingsController([bool initialLock = true]) : _initialLock = initialLock;
  final bool _initialLock;

  @override
  SettingsState build() {
    return SettingsState(
      themeMode: AppThemeType.system,
      locale: 'en',
      isLockEnabled: _initialLock,
      lockTimeout: LockTimeout.instant,
      biometricEnabled: false,
      quickActionsEnabled: false,
      notificationSettings: const NotificationSettings(),
    );
  }

  @override
  Future<void> toggleLock(bool enabled) async {
    state = SettingsState(
      themeMode: state.themeMode,
      locale: state.locale,
      isLockEnabled: enabled,
      lockTimeout: state.lockTimeout,
      biometricEnabled: state.biometricEnabled,
      quickActionsEnabled: state.quickActionsEnabled,
      notificationSettings: state.notificationSettings,
    );
  }

  @override
  Future<void> toggleBiometric(bool enabled) async {}
}

class FakeAppLockEnabledNotifier extends AppLockEnabledNotifier {
  @override
  bool build() => false;

  @override
  Future<void> setEnabled(bool enabled) async {}
}

class FakePinStorage implements PinStorage {
  final Map<String, String> data = {};

  @override
  Future<String?> read(String key) async => data[key];

  @override
  Future<void> write(String key, String value) async => data[key] = value;

  @override
  Future<void> delete(String key) async => data.remove(key);
}

Widget createTestApp({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: VitaAppLocalizationsDelegate.localizationsDelegates,
      supportedLocales: VitaAppLocalizationsDelegate.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePinStorage fakeStorage;
  late SharedPreferences prefs;
  late PinService pinService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    fakeStorage = FakePinStorage();
    pinService = PinService(storage: fakeStorage, prefs: prefs);
  });

  group('Phase 2 - PIN Setup & Validation UX', () {
    test('5-digit PIN is rejected by validation', () {
      expect(PinService.isValidPinFormat('12345'), isFalse);
      expect(() => pinService.setPin('12345'), throwsA(isA<ArgumentError>()));
    });

    test('6-digit numeric PIN is accepted by validation', () async {
      expect(PinService.isValidPinFormat('123456'), isTrue);
      await pinService.setPin('123456');
      expect(await pinService.hasPin(), isTrue);
      expect(await pinService.verifyPin('123456'), isTrue);
    });

    test('Non-numeric characters in 6-length string are rejected', () {
      expect(PinService.isValidPinFormat('12345a'), isFalse);
      expect(PinService.isValidPinFormat('abcdef'), isFalse);
      expect(() => pinService.setPin('12345a'), throwsA(isA<ArgumentError>()));
    });
  });

  group('Phase 2 - LockScreen UX', () {
    testWidgets('1. LockScreen opens in setup mode when no PIN is configured', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          overrides: [
            pinServiceProvider.overrideWithValue(pinService),
            sharedPreferencesProvider.overrideWithValue(prefs),
            hasPinProvider.overrideWith((ref) async => false),
          ],
          child: const LockScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LockScreen), findsOneWidget);
      expect(find.text('Set Secure PIN'), findsOneWidget);
    });

    testWidgets('2. LockScreen opens in unlock mode when PIN exists', (tester) async {
      await pinService.setPin('123456');

      await tester.pumpWidget(
        createTestApp(
          overrides: [
            pinServiceProvider.overrideWithValue(pinService),
            sharedPreferencesProvider.overrideWithValue(prefs),
            hasPinProvider.overrideWith((ref) async => true),
          ],
          child: const LockScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LockScreen), findsOneWidget);
      expect(find.text('Set Secure PIN'), findsNothing);
    });

    testWidgets('3. Setup mode handles confirmation mismatch and match', (tester) async {
      final container = ProviderContainer(
        overrides: [
          pinServiceProvider.overrideWithValue(pinService),
          sharedPreferencesProvider.overrideWithValue(prefs),
          hasPinProvider.overrideWith((ref) async => false),
          appLockEnabledProvider.overrideWith(() => FakeAppLockEnabledNotifier()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: VitaAppLocalizationsDelegate.localizationsDelegates,
            supportedLocales: VitaAppLocalizationsDelegate.supportedLocales,
            locale: const Locale('en'),
            home: const LockScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter 1st PIN: 123456
      for (final digit in ['1', '2', '3', '4', '5', '6']) {
        await tester.tap(find.text(digit).last);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // Should now ask for confirmation
      expect(find.text('Confirm PIN'), findsAtLeastNWidgets(1));

      // Enter mismatched PIN: 123455
      for (final digit in ['1', '2', '3', '4', '5', '5']) {
        await tester.tap(find.text(digit).last);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // Mismatch should show error and reset to Set Secure PIN
      expect(find.text('PINs do not match. Try again.'), findsOneWidget);

      // Enter 1st PIN again: 654321
      for (final digit in ['6', '5', '4', '3', '2', '1']) {
        await tester.tap(find.text(digit).last);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // Confirm with exact match: 654321
      for (final digit in ['6', '5', '4', '3', '2', '1']) {
        await tester.tap(find.text(digit).last);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // Lock state should now be unlocked
      expect(container.read(appLockStateProvider), AppLockState.unlocked);
      expect(await pinService.verifyPin('654321'), isTrue);
    });

    testWidgets('4. Unlock mode: wrong PIN keeps screen locked and correct PIN unlocks', (tester) async {
      await pinService.setPin('112233');

      final container = ProviderContainer(
        overrides: [
          pinServiceProvider.overrideWithValue(pinService),
          sharedPreferencesProvider.overrideWithValue(prefs),
          hasPinProvider.overrideWith((ref) async => true),
        ],
      );
      container.read(appLockStateProvider.notifier).setLocked();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: VitaAppLocalizationsDelegate.localizationsDelegates,
            supportedLocales: VitaAppLocalizationsDelegate.supportedLocales,
            locale: const Locale('en'),
            home: const LockScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter wrong PIN: 999999
      for (final digit in ['9', '9', '9', '9', '9', '9']) {
        await tester.tap(find.text(digit).last);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // State remains locked, incorrect PIN snackbar shown
      expect(container.read(appLockStateProvider), AppLockState.locked);
      expect(find.text('Incorrect PIN'), findsOneWidget);

      // Now enter correct PIN: 112233
      for (final digit in ['1', '1', '2', '2', '3', '3']) {
        await tester.tap(find.text(digit).last);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // State is now unlocked
      expect(container.read(appLockStateProvider), AppLockState.unlocked);
    });
  });

  group('Phase 2 - App Lock Enable / Disable in Settings', () {
    testWidgets('Disabling App Lock requires valid PIN verification', (tester) async {
      await pinService.setPin('123456');

      final container = ProviderContainer(
        overrides: [
          pinServiceProvider.overrideWithValue(pinService),
          sharedPreferencesProvider.overrideWithValue(prefs),
          hasPinProvider.overrideWith((ref) async => true),
          settingsControllerProvider.overrideWith(() => FakeSettingsController(true)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: VitaAppLocalizationsDelegate.localizationsDelegates,
            supportedLocales: VitaAppLocalizationsDelegate.supportedLocales,
            locale: const Locale('tr'),
            home: const Scaffold(
              body: SecuritySection(isDark: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Toggle switch to disable App Lock
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Dialog should open asking for PIN to disable
      expect(find.text('Devre Dışı Bırak'), findsOneWidget);

      // Enter wrong PIN: 000000
      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, '000000');
      await tester.pumpAndSettle();

      // Tap disable button
      await tester.tap(find.text('Devre Dışı Bırak'));
      await tester.pumpAndSettle();

      // Error shown, dialog remains open
      expect(find.text('Hatalı PIN'), findsOneWidget);
      expect(find.text('Devre Dışı Bırak'), findsOneWidget);

      // Enter correct PIN: 123456
      await tester.enterText(textFieldFinder, '123456');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Devre Dışı Bırak'));
      await tester.pumpAndSettle();

      // Dialog closed
      expect(find.text('Devre Dışı Bırak'), findsNothing);

      // PIN is preserved in storage! (PIN is not cleared when lock is disabled)
      expect(await pinService.hasPin(), isTrue);
      expect(await pinService.verifyPin('123456'), isTrue);
    });

    testWidgets('Enabling App Lock when no PIN exists prompts setup dialog', (tester) async {
      final container = ProviderContainer(
        overrides: [
          pinServiceProvider.overrideWithValue(pinService),
          sharedPreferencesProvider.overrideWithValue(prefs),
          hasPinProvider.overrideWith((ref) async => false),
          settingsControllerProvider.overrideWith(() => FakeSettingsController(false)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: VitaAppLocalizationsDelegate.localizationsDelegates,
            supportedLocales: VitaAppLocalizationsDelegate.supportedLocales,
            locale: const Locale('tr'),
            home: const Scaffold(
              body: SecuritySection(isDark: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Dialog opens: 'Yeni PIN Oluştur'
      expect(find.text('Yeni PIN Oluştur'), findsOneWidget);
    });
  });

  group('Phase 2 - Route Guard & Navigation', () {
    GoRouterState createMockState(String location) {
      final uri = Uri.parse(location);
      final router = GoRouter(
        routes: [
          GoRoute(path: '/documents', builder: (context, state) => const SizedBox()),
          GoRoute(path: AppRoutes.lock, builder: (context, state) => const SizedBox()),
          GoRoute(path: AppRoutes.home, builder: (context, state) => const SizedBox()),
        ],
      );
      return GoRouterState(
        router.configuration,
        uri: uri,
        matchedLocation: uri.path,
        fullPath: uri.path,
        pathParameters: const {},
        pageKey: const ValueKey('test'),
      );
    }

    test('lockRedirect redirects to /lock with from query parameter when locked', () {
      const guard = RouteGuardState(
        isBootstrapped: true,
        onboardingCompleted: true,
        lockState: AppLockState.locked,
        isLockEnabled: true,
        pendingNotificationRoute: null,
        profileCreated: true,
        profileName: 'John',
        legalAccepted: true,
      );

      final state = createMockState('/documents');

      final redirect = lockRedirect(state, guard);
      expect(redirect, '/lock?from=%2Fdocuments');
    });

    test('lockRedirect restores previous route upon unlock', () {
      const guard = RouteGuardState(
        isBootstrapped: true,
        onboardingCompleted: true,
        lockState: AppLockState.unlocked,
        isLockEnabled: true,
        pendingNotificationRoute: null,
        profileCreated: true,
        profileName: 'John',
        legalAccepted: true,
      );

      final state = createMockState('/lock?from=%2Fdocuments');

      final redirect = lockRedirect(state, guard);
      expect(redirect, '/documents');
    });

    test('lockRedirect redirects to /home if no from query parameter provided', () {
      const guard = RouteGuardState(
        isBootstrapped: true,
        onboardingCompleted: true,
        lockState: AppLockState.unlocked,
        isLockEnabled: true,
        pendingNotificationRoute: null,
        profileCreated: true,
        profileName: 'John',
        legalAccepted: true,
      );

      final state = createMockState(AppRoutes.lock);

      final redirect = lockRedirect(state, guard);
      expect(redirect, AppRoutes.home);
    });
  });

  group('Phase 2 - Lifecycle & Timeout', () {
    test('SessionLockService locks on timeout expiration', () {
      final sessionLock = SessionLockService();
      sessionLock.markPaused();

      // Instant timeout should lock immediately
      expect(sessionLock.shouldLockOnResume(Duration.zero), isTrue);

      // Long timeout should not lock immediately
      expect(sessionLock.shouldLockOnResume(const Duration(minutes: 5)), isFalse);
    });
  });
}
