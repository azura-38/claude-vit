import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/constants/app_routes.dart';
import 'package:vitacase/features/profile/presentation/screens/profile_create_screen.dart';
import 'package:vitacase/shared/providers/shared_prefs_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  GoRouter createTestRouter() {
    return GoRouter(
      initialLocation: '/profile/create',
      routes: [
        GoRoute(
          path: '/profile/create',
          builder: (context, state) => const ProfileCreateScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const Scaffold(body: Text('Home Screen')),
        ),
      ],
    );
  }

  group('Profile Legal Checkbox and Skip Validation Tests', () {
    testWidgets('Tapping Skip when legal checkbox is unchecked shows must_agree SnackBar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final router = createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Skip button
      final skipButton = find.byType(OutlinedButton);
      expect(skipButton, findsOneWidget);

      await tester.tap(skipButton);
      await tester.pump();

      // Validation snackbar should be shown
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Tapping Continue when legal checkbox is unchecked shows must_agree SnackBar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final router = createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final continueButton = find.text('Continue');
      expect(continueButton, findsOneWidget);

      await tester.tap(continueButton);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('When legal checkbox is checked, tapping Skip completes without profile', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final router = createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the legal checkbox
      final checkboxTile = find.byType(CheckboxListTile);
      expect(checkboxTile, findsOneWidget);
      await tester.tap(checkboxTile);
      await tester.pumpAndSettle();

      // Tap Skip button
      final skipButton = find.byType(OutlinedButton);
      expect(skipButton, findsOneWidget);
      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      // Verify that profile_creation_skipped is set to true in SharedPreferences
      expect(prefs.getBool('profile_creation_skipped'), isTrue);
      // And routed to Home Screen
      expect(find.text('Home Screen'), findsOneWidget);
    });
  });
}
