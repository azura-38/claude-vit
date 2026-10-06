import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/constants/app_routes.dart';
import 'package:vitacase/core/constants/legal_version.dart';
import 'package:vitacase/core/router/route_guards.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/core/ads/ad_visibility_policy.dart';
import 'package:vitacase/features/legal/presentation/screens/legal_update_screen.dart';
import 'package:vitacase/features/profile/presentation/providers/legacy_providers.dart';
import 'package:vitacase/shared/providers/shared_prefs_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 20.3 — LegalAcceptedNotifier with Versioning', () {
    test('brand new user has state = false and needsUpdate = false', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final state = container.read(legalAcceptedProvider);
      final needsUpdate = container.read(legalNeedsUpdateProvider);

      expect(state, false);
      expect(needsUpdate, false);
    });

    test('existing user with legal_accepted=true but missing version requires update', () async {
      SharedPreferences.setMockInitialValues({'legal_accepted': true});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final state = container.read(legalAcceptedProvider);
      final needsUpdate = container.read(legalNeedsUpdateProvider);

      expect(state, false, reason: 'Outdated legal version must not count as accepted');
      expect(needsUpdate, true, reason: 'Existing user must be flagged as needing update');
    });

    test('existing user with outdated version string requires update', () async {
      SharedPreferences.setMockInitialValues({
        'legal_accepted': true,
        'legal_accepted_version': '1.0.0-2025-01',
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final state = container.read(legalAcceptedProvider);
      final needsUpdate = container.read(legalNeedsUpdateProvider);

      expect(state, false);
      expect(needsUpdate, true);
    });

    test('accepting legal writes both boolean and current version string', () async {
      SharedPreferences.setMockInitialValues({'legal_accepted': true});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      await container.read(legalAcceptedProvider.notifier).accept();

      expect(container.read(legalAcceptedProvider), true);
      expect(container.read(legalNeedsUpdateProvider), false);
      expect(prefs.getBool('legal_accepted'), true);
      expect(prefs.getString('legal_accepted_version'), LegalVersion.current);
      
      final timestampStr = prefs.getString('legal_accepted_at');
      expect(timestampStr, isNotNull);
      final parsedDate = DateTime.parse(timestampStr!);
      expect(parsedDate.isUtc, isTrue, reason: 'Timestamp must be saved as UTC ISO 8601');
      expect(container.read(legalAcceptedAtProvider), timestampStr);
      expect(container.read(legalAcceptedProvider.notifier).acceptedAt, timestampStr);
      expect(container.read(legalAcceptedProvider.notifier).acceptedVersion, LegalVersion.current);

      // Verify persistence across app restart (new container with existing prefs)
      final restartedContainer = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(restartedContainer.dispose);
      expect(restartedContainer.read(legalAcceptedProvider), isTrue);
      expect(restartedContainer.read(legalNeedsUpdateProvider), isFalse);
      expect(restartedContainer.read(legalAcceptedAtProvider), timestampStr);

      // Verify no PIN or health data is added to consent storage
      final allKeys = prefs.getKeys();
      expect(allKeys.contains('pin'), isFalse);
      expect(allKeys.contains('salt'), isFalse);
      expect(allKeys.contains('health_data'), isFalse);
    });

    test('AdVisibilityPolicy blocks ads when legal is not accepted', () {
      const blockedPolicy = AdVisibilityPolicy(
        isPremium: false,
        onboardingCompleted: true,
        profileCreated: true,
        legalAccepted: false,
        lockEnabled: false,
        lockState: AppLockState.unlocked,
      );
      expect(blockedPolicy.canShowBanner, false);
      expect(blockedPolicy.canShowAppOpen, false);
      expect(blockedPolicy.canShowInterstitial, false);

      const allowedPolicy = AdVisibilityPolicy(
        isPremium: false,
        onboardingCompleted: true,
        profileCreated: true,
        legalAccepted: true,
        lockEnabled: false,
        lockState: AppLockState.unlocked,
      );
      expect(allowedPolicy.canShowBanner, true);
      expect(allowedPolicy.canShowAppOpen, true);
      expect(allowedPolicy.canShowInterstitial, true);
    });
  });

  group('Phase 20.3 — Route Guards for Legal Update', () {
    GoRouterState mockState(String path) {
      final uri = Uri.parse(path);
      final router = GoRouter(
        routes: [
          GoRoute(path: path, builder: (context, state) => const SizedBox()),
          GoRoute(path: AppRoutes.home, builder: (context, state) => const SizedBox()),
          GoRoute(path: AppRoutes.legalUpdate, builder: (context, state) => const SizedBox()),
          GoRoute(path: AppRoutes.profileCreate, builder: (context, state) => const SizedBox()),
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

    test('redirects to /legal-update when user needs legal update', () {
      final state = mockState(AppRoutes.home);
      final guard = RouteGuardState(
        isBootstrapped: true,
        onboardingCompleted: true,
        lockState: AppLockState.unlocked,
        isLockEnabled: false,
        pendingNotificationRoute: null,
        profileCreated: true,
        profileName: 'John',
        legalAccepted: false,
        legalNeedsUpdate: true,
      );

      final redirect = legalRedirect(state, guard);
      expect(redirect, AppRoutes.legalUpdate);
    });

    test('allows user to stay on /legal-update when needsUpdate is true', () {
      final state = mockState(AppRoutes.legalUpdate);
      final guard = RouteGuardState(
        isBootstrapped: true,
        onboardingCompleted: true,
        lockState: AppLockState.unlocked,
        isLockEnabled: false,
        pendingNotificationRoute: null,
        profileCreated: true,
        profileName: 'John',
        legalAccepted: false,
        legalNeedsUpdate: true,
      );

      final redirect = legalRedirect(state, guard);
      expect(redirect, null);
    });

    test('redirects new user (never accepted) to /profile-create', () {
      final state = mockState(AppRoutes.home);
      final guard = RouteGuardState(
        isBootstrapped: true,
        onboardingCompleted: true,
        lockState: AppLockState.unlocked,
        isLockEnabled: false,
        pendingNotificationRoute: null,
        profileCreated: false,
        profileName: null,
        legalAccepted: false,
        legalNeedsUpdate: false,
      );

      final redirect = legalRedirect(state, guard);
      expect(redirect, AppRoutes.profileCreate);
    });

    test('completedEntryRedirect sends already-accepted user away from /legal-update', () {
      final state = mockState(AppRoutes.legalUpdate);
      final guard = RouteGuardState(
        isBootstrapped: true,
        onboardingCompleted: true,
        lockState: AppLockState.unlocked,
        isLockEnabled: false,
        pendingNotificationRoute: null,
        profileCreated: true,
        profileName: 'John',
        legalAccepted: true,
        legalNeedsUpdate: false,
      );

      final redirect = completedEntryRedirect(state, guard);
      expect(redirect, AppRoutes.home);
    });
  });

  group('Phase 20.3 — LegalUpdateScreen Widget Test', () {
    testWidgets('renders legal update screen and requires checkbox before continue', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({'legal_accepted': true});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(
            home: LegalUpdateScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and elements exist
      expect(find.byType(LegalUpdateScreen), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);

      // Verify button is initially disabled
      final FilledButton initialButton = tester.widget(find.byType(FilledButton));
      expect(initialButton.onPressed, isNull);

      // Tap checkbox
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      // Verify button is now enabled
      final FilledButton enabledButton = tester.widget(find.byType(FilledButton));
      expect(enabledButton.onPressed, isNotNull);
    });
  });
}

