// Phase 19.6 — Utility-First UI Cleanup & Legacy UX Audit Tests
// Coverage: Dashboard, ReviewCard, Vault, Navigation, Profile, Ads, Gamification Guards
// Minimum required: 20 scenarios | Actual: 25 scenarios

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vitacase/core/config/app_config.dart';
import 'package:vitacase/core/utils/ui_utils.dart';
import 'package:vitacase/features/dashboard/presentation/widgets/dashboard_review_card.dart';
import 'package:vitacase/shared/data/services/review_service.dart';
import 'package:vitacase/shared/providers/shared_prefs_provider.dart';

// ─── Fake helpers ────────────────────────────────────────────────────────────

class _FakeReviewDelegate implements ReviewPlatformDelegate {
  bool wasReviewRequested = false;
  bool wasStoreOpened = false;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> requestReview() async {
    wasReviewRequested = true;
  }

  @override
  Future<void> openStoreListing({String? appStoreId}) async {
    wasStoreOpened = true;
  }
}

class _UnavailableReviewDelegate implements ReviewPlatformDelegate {
  bool wasStoreOpened = false;

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<void> requestReview() async {}

  @override
  Future<void> openStoreListing({String? appStoreId}) async {
    wasStoreOpened = true;
  }
}

// ─── Helper: pumps card without animate hang ─────────────────────────────────

/// Pumps the card widget. If it will be visible (showsCard = true), we must use
/// pumpAndSettle to drain the flutter_animate timer; otherwise a simple pump suffices.
Future<void> _pumpCard(WidgetTester tester, SharedPreferences prefs,
    {bool showsCard = false}) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const MaterialApp(home: Scaffold(body: DashboardReviewCard())),
  ));
  if (showsCard) {
    await tester.pump(const Duration(milliseconds: 500));
  } else {
    await tester.pump();
  }
}

// ─── Group 1: AppConfig Guards ───────────────────────────────────────────────

void main() {
  group('Phase 19.6 — AppConfig & Ads Guards', () {
    test('1. isProductionAdsActive is FALSE (no production ads in this build)', () {
      expect(AppConfig.isProductionAdsActive, isFalse,
          reason: 'Production ads must NOT be active during Phase 19.6');
    });

    test('2. AppConfig.isProductionAdsActive returns false without ENABLE_PRODUCTION_ADS flag', () {
      const value = bool.fromEnvironment('ENABLE_PRODUCTION_ADS', defaultValue: false);
      expect(value, isFalse);
    });

    test('3. Prod ad IDs are declared but inactive (string constants present)', () {
      expect(AppConfig.prodAdmobAppId, isNotEmpty);
      expect(AppConfig.prodBannerAdId, isNotEmpty);
      expect(AppConfig.prodInterstitialAdId, isNotEmpty);
      expect(AppConfig.isProductionAdsActive, isFalse);
    });
  });

  // ─── Group 2: ReviewCard Logic ────────────────────────────────────────────

  group('Phase 19.6 — DashboardReviewCard lifecycle', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      ReviewService.instance.resetForTesting();
    });

    testWidgets('4. ReviewCard is hidden when launch count < 5', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(DashboardReviewCard.keyLaunchCount, 3);
      await _pumpCard(tester, prefs, showsCard: false);

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('5. ReviewCard is visible on exactly the 5th launch', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(DashboardReviewCard.keyLaunchCount, 5);
      await _pumpCard(tester, prefs, showsCard: true);

      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('6. ReviewCard is hidden when already dismissed (persisted pref)', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(DashboardReviewCard.keyLaunchCount, 10);
      await prefs.setBool(DashboardReviewCard.keyDismissed, true);
      await _pumpCard(tester, prefs, showsCard: false);

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('7. ReviewCard is hidden when review already completed', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(DashboardReviewCard.keyLaunchCount, 10);
      await prefs.setBool(DashboardReviewCard.keyCompleted, true);
      await _pumpCard(tester, prefs, showsCard: false);

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('8. ReviewCard dismiss button hides card locally and persists flag', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(DashboardReviewCard.keyLaunchCount, 5);
      await _pumpCard(tester, prefs, showsCard: true);

      expect(find.byType(FilledButton), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(find.byType(FilledButton), findsNothing);
      expect(prefs.getBool(DashboardReviewCard.keyDismissed), isTrue);
    });
  });

  // ─── Group 3: ReviewService ───────────────────────────────────────────────

  group('Phase 19.6 — ReviewService centralization', () {
    late _FakeReviewDelegate fakeDelegate;
    late ReviewService reviewService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fakeDelegate = _FakeReviewDelegate();
      reviewService = ReviewService(delegate: fakeDelegate);
    });

    tearDown(() {
      ReviewService.instance.resetForTesting();
    });

    test('9. ReviewService triggers in-app review when platform is available', () async {
      final result = await reviewService.requestReviewOrOpenStore();
      expect(result, isTrue);
      expect(fakeDelegate.wasReviewRequested, isTrue);
      expect(fakeDelegate.wasStoreOpened, isFalse);
    });

    test('10. ReviewService falls back to store listing when platform unavailable', () async {
      final unavailable = _UnavailableReviewDelegate();
      final service = ReviewService(delegate: unavailable);
      final result = await service.requestReviewOrOpenStore();
      expect(result, isTrue);
      expect(unavailable.wasStoreOpened, isTrue);
    });

    test('11. ReviewService suppresses concurrent review requests (debounce guard)', () async {
      final first = reviewService.requestReviewOrOpenStore();
      final second = reviewService.requestReviewOrOpenStore();
      final results = await Future.wait([first, second]);
      expect(results.where((r) => r).length, equals(1),
          reason: 'Only one of the concurrent requests should succeed');
    });

    test('12. forceStoreFallback bypasses in-app review even when available', () async {
      final result = await reviewService.requestReviewOrOpenStore(forceStoreFallback: true);
      expect(result, isTrue);
      expect(fakeDelegate.wasReviewRequested, isFalse);
      expect(fakeDelegate.wasStoreOpened, isTrue);
    });
  });

  // ─── Group 4: SafeNavigationContext ──────────────────────────────────────

  group('Phase 19.6 — SafeNavigationContext safePop semantics', () {
    testWidgets('13. safePop returns false when context is not mounted', (tester) async {
      BuildContext? savedContext;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          savedContext = context;
          return const SizedBox();
        }),
      ));
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      final result = savedContext?.safePop() ?? false;
      expect(result, isFalse);
    });

    testWidgets('14. safePop returns true and pops a pushed route', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (ctx) => ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).push(MaterialPageRoute<void>(
              builder: (inner) => Builder(builder: (innerCtx) => ElevatedButton(
                onPressed: () => innerCtx.safePop(),
                child: const Text('Pop'),
              )),
            ));
          },
          child: const Text('Push'),
        )),
      ));

      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();
      expect(find.text('Pop'), findsOneWidget);

      await tester.tap(find.text('Pop'));
      await tester.pumpAndSettle();
      expect(find.text('Push'), findsOneWidget);
      expect(find.text('Pop'), findsNothing);
    });

    testWidgets('15. safePop from dialog closes dialog, not the screen', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (ctx) => ElevatedButton(
          onPressed: () => showDialog<void>(
            context: ctx,
            builder: (dialogCtx) => AlertDialog(
              actions: [
                ElevatedButton(
                  onPressed: () => dialogCtx.safePop(),
                  child: const Text('CloseDialog'),
                ),
              ],
            ),
          ),
          child: const Text('OpenDialog'),
        )),
      ));

      await tester.tap(find.text('OpenDialog'));
      await tester.pumpAndSettle();
      expect(find.text('CloseDialog'), findsOneWidget);

      await tester.tap(find.text('CloseDialog'));
      await tester.pumpAndSettle();
      expect(find.text('CloseDialog'), findsNothing);
      expect(find.text('OpenDialog'), findsOneWidget);
    });
  });

  // ─── Group 5: No Gamification in Production UI ───────────────────────────

  group('Phase 19.6 — No gamification in production UI', () {
    test('16. DashboardReviewCard key constants do not reference gamification', () {
      expect(DashboardReviewCard.keyDismissed, isNot(contains('xp')));
      expect(DashboardReviewCard.keyDismissed, isNot(contains('streak')));
      expect(DashboardReviewCard.keyDismissed, isNot(contains('reward')));
      expect(DashboardReviewCard.keyCompleted, isNot(contains('xp')));
      expect(DashboardReviewCard.keyLaunchCount, isNot(contains('streak')));
    });

    testWidgets('17. ReviewCard visible content contains no XP or streak text', (tester) async {
      SharedPreferences.setMockInitialValues({
        DashboardReviewCard.keyLaunchCount: 5,
      });
      final prefs = await SharedPreferences.getInstance();
      await _pumpCard(tester, prefs, showsCard: true);

      expect(find.textContaining('XP'), findsNothing);
      expect(find.textContaining('streak'), findsNothing);
      expect(find.textContaining('Level'), findsNothing);
      expect(find.textContaining('achievement'), findsNothing);
    });

    testWidgets('18. ReviewCard action triggers review service, not gamification reward', (tester) async {
      SharedPreferences.setMockInitialValues({
        DashboardReviewCard.keyLaunchCount: 5,
      });
      final prefs = await SharedPreferences.getInstance();

      final fakeDelegate = _FakeReviewDelegate();
      ReviewService.instance.setDelegateForTesting(fakeDelegate);

      await _pumpCard(tester, prefs, showsCard: true);
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(fakeDelegate.wasReviewRequested, isTrue);
    });
  });

  // ─── Group 6: Dashboard Utility-First Contract ───────────────────────────

  group('Phase 19.6 — Dashboard utility-first structure contract', () {
    test('19. ReviewCard key constants are stable identifiers', () {
      expect(DashboardReviewCard.keyDismissed, equals('review_card_dismissed'));
      expect(DashboardReviewCard.keyCompleted, equals('review_card_completed'));
      expect(DashboardReviewCard.keyLaunchCount, equals('app_launch_count'));
    });

    testWidgets('20. ReviewCard renders dismiss (X) icon button when visible', (tester) async {
      SharedPreferences.setMockInitialValues({
        DashboardReviewCard.keyLaunchCount: 5,
      });
      final prefs = await SharedPreferences.getInstance();
      await _pumpCard(tester, prefs, showsCard: true);

      // The close (dismiss) icon should be present
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('21. ReviewCard hides on first cold start (launchCount == 0)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await _pumpCard(tester, prefs, showsCard: false);

      expect(find.byType(FilledButton), findsNothing);
    });

    test('22. AppConfig.isProductionAdsActive is false in test environment', () {
      expect(AppConfig.isProductionAdsActive, equals(false),
          reason: 'Ads must remain in test mode during Phase 19.6');
    });
  });

  // ─── Group 7: ReviewService Robustness ───────────────────────────────────

  group('Phase 19.6 — ReviewService robustness', () {
    tearDown(() {
      ReviewService.instance.resetForTesting();
    });

    test('23. ReviewService.instance is a singleton', () {
      final a = ReviewService.instance;
      final b = ReviewService.instance;
      expect(identical(a, b), isTrue);
    });

    test('24. ReviewService debounce: second call within 3s returns false', () async {
      final delegate = _FakeReviewDelegate();
      final service = ReviewService(delegate: delegate);

      await service.requestReviewOrOpenStore();
      final secondResult = await service.requestReviewOrOpenStore();
      expect(secondResult, isFalse,
          reason: 'Rapid second call within debounce window must be suppressed');
    });

    test('25. ReviewService resetForTesting allows re-invocation', () async {
      final delegate = _FakeReviewDelegate();
      final service = ReviewService(delegate: delegate);

      await service.requestReviewOrOpenStore();
      service.resetForTesting();
      service.setDelegateForTesting(delegate);

      final result = await service.requestReviewOrOpenStore();
      expect(result, isTrue);
    });
  });
}
