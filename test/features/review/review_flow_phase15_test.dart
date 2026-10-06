import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/utils/external_launcher.dart';
import 'package:vitacase/features/dashboard/presentation/widgets/dashboard_review_card.dart';
import 'package:vitacase/features/profile/presentation/screens/profile_screen.dart';
import 'package:vitacase/l10n/vita_app_localizations_delegate.dart';
import 'package:vitacase/shared/data/services/review_service.dart';
import 'package:vitacase/shared/providers/shared_prefs_provider.dart';

class FakeReviewPlatformDelegate implements ReviewPlatformDelegate {
  bool available;
  bool throwOnRequest;
  bool throwOnOpenStore;
  int isAvailableCount = 0;
  int requestReviewCount = 0;
  int openStoreListingCount = 0;

  FakeReviewPlatformDelegate({
    this.available = true,
    this.throwOnRequest = false,
    this.throwOnOpenStore = false,
  });

  @override
  Future<bool> isAvailable() async {
    isAvailableCount++;
    return available;
  }

  @override
  Future<void> requestReview() async {
    requestReviewCount++;
    if (throwOnRequest) {
      throw Exception('Simulated In-App Review platform exception');
    }
  }

  @override
  Future<void> openStoreListing({String? appStoreId}) async {
    openStoreListingCount++;
    if (throwOnOpenStore) {
      throw Exception('Simulated store listing platform error');
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeReviewPlatformDelegate fakeDelegate;
  late ReviewService reviewService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeDelegate = FakeReviewPlatformDelegate();
    reviewService = ReviewService(delegate: fakeDelegate);
    ReviewService.instance.resetForTesting();
    ReviewService.instance.setDelegateForTesting(fakeDelegate);
  });

  tearDown(() {
    ReviewService.instance.resetForTesting();
  });

  group('Phase 15 Rate Us / Review Tests (K - R)', () {
    test('K. Review service initialization with valid defaults and store URL', () {
      final service = ReviewService.instance;
      expect(service, isNotNull);
      expect(ReviewService.playStoreUrl, contains('com.limanex.vitacase'));
      expect(ExternalLauncher.playStoreUrl, 'https://play.google.com/store/apps/details?id=com.limanex.vitacase');
      expect(ExternalLauncher.playStoreMarketUri, 'market://details?id=com.limanex.vitacase');
    });

    test('L. In-App Review request when API is available', () async {
      fakeDelegate.available = true;

      final result = await reviewService.requestReviewOrOpenStore();

      expect(result, isTrue);
      expect(fakeDelegate.isAvailableCount, 1);
      expect(fakeDelegate.requestReviewCount, 1);
      expect(fakeDelegate.openStoreListingCount, 0);
    });

    test('M. Review API failure triggers graceful store fallback without crashing', () async {
      fakeDelegate.available = true;
      fakeDelegate.throwOnRequest = true; // In-app review throws

      final result = await reviewService.requestReviewOrOpenStore();

      expect(result, isTrue); // Fallback succeeded
      expect(fakeDelegate.isAvailableCount, 1);
      expect(fakeDelegate.requestReviewCount, 1);
      expect(fakeDelegate.openStoreListingCount, 1); // Fell back to store listing
    });

    test('N. Play Store fallback when In-App Review is not available', () async {
      fakeDelegate.available = false;

      final result = await reviewService.requestReviewOrOpenStore();

      expect(result, isTrue);
      expect(fakeDelegate.isAvailableCount, 1);
      expect(fakeDelegate.requestReviewCount, 0);
      expect(fakeDelegate.openStoreListingCount, 1);
    });

    testWidgets('O. Review Card Rate action triggers review flow and marks completed', (tester) async {
      SharedPreferences.setMockInitialValues({
        'app_launch_count': 5,
        'review_card_dismissed': false,
        'review_card_completed': false,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            reviewServiceProvider.overrideWithValue(reviewService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DashboardReviewCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rate VitaCase'), findsOneWidget);

      await tester.tap(find.text('Rate VitaCase'));
      await tester.pumpAndSettle();

      // Card is dismissed locally and marked completed in preferences
      expect(find.text('Rate VitaCase'), findsNothing);
      expect(prefs.getBool(DashboardReviewCard.keyCompleted), isTrue);
      expect(fakeDelegate.requestReviewCount, 1);
    });

    testWidgets('P. Review Card X dismissal permanently marks dismissed', (tester) async {
      SharedPreferences.setMockInitialValues({
        'app_launch_count': 5,
        'review_card_dismissed': false,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            reviewServiceProvider.overrideWithValue(reviewService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DashboardReviewCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(prefs.getBool(DashboardReviewCard.keyDismissed), isTrue);
      expect(fakeDelegate.requestReviewCount, 0);
    });

    testWidgets('Q. Review Card one-time persistence: does not show if already dismissed or completed', (tester) async {
      SharedPreferences.setMockInitialValues({
        'app_launch_count': 12,
        'review_card_dismissed': true,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            reviewServiceProvider.overrideWithValue(reviewService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DashboardReviewCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DashboardReviewCard), findsOneWidget);
      expect(find.text('Rate VitaCase'), findsNothing);
      expect(find.text('Enjoying VitaCase?'), findsNothing);
    });

    testWidgets('R. Profile Rate Us action triggers the same central review flow', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            reviewServiceProvider.overrideWithValue(reviewService),
          ],
          child: const MaterialApp(
            localizationsDelegates: VitaAppLocalizationsDelegate.localizationsDelegates,
            supportedLocales: VitaAppLocalizationsDelegate.supportedLocales,
            locale: Locale('en'),
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to find Rate VitaCase navigation item in Profile
      final rateUsFinder = find.widgetWithText(InkWell, 'Rate VitaCase');
      if (rateUsFinder.evaluate().isEmpty) {
        // Find text directly
        final textFinder = find.text('Rate VitaCase');
        expect(textFinder, findsOneWidget);
        await tester.ensureVisible(textFinder);
        await tester.pumpAndSettle();
        await tester.tap(textFinder);
      } else {
        await tester.ensureVisible(rateUsFinder);
        await tester.pumpAndSettle();
        await tester.tap(rateUsFinder);
      }

      await tester.pumpAndSettle();

      // Verifies that Profile uses the exact same ReviewService flow
      expect(fakeDelegate.isAvailableCount, 1);
      expect(fakeDelegate.requestReviewCount, 1);
    });
  });
}
