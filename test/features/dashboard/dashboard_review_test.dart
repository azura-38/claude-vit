import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/features/dashboard/presentation/widgets/dashboard_review_card.dart';
import 'package:vitacase/shared/providers/shared_prefs_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DashboardReviewCard Tests', () {
    testWidgets('Does not display card if launch count is less than 5', (tester) async {
      SharedPreferences.setMockInitialValues({
        'app_launch_count': 4,
        'review_card_dismissed': false,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DashboardReviewCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNothing);
      expect(find.text('Enjoying VitaCase?'), findsNothing);
    });

    testWidgets('Displays card when launch count reaches 5 and not dismissed', (tester) async {
      SharedPreferences.setMockInitialValues({
        'app_launch_count': 5,
        'review_card_dismissed': false,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DashboardReviewCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enjoying VitaCase?'), findsOneWidget);
      expect(find.text('Rate us and share your feedback.'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.text('Rate VitaCase'), findsOneWidget);
    });

    testWidgets('Does not display card if already dismissed regardless of launch count', (tester) async {
      SharedPreferences.setMockInitialValues({
        'app_launch_count': 10,
        'review_card_dismissed': true,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DashboardReviewCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNothing);
      expect(find.text('Enjoying VitaCase?'), findsNothing);
    });

    testWidgets('Dismissing via X permanently marks review_card_dismissed', (tester) async {
      SharedPreferences.setMockInitialValues({
        'app_launch_count': 5,
        'review_card_dismissed': false,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DashboardReviewCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enjoying VitaCase?'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Enjoying VitaCase?'), findsNothing);
      expect(prefs.getBool('review_card_dismissed'), isTrue);
    });
  });
}
