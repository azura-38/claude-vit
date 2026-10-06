import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/constants/legal_data.dart';
import 'package:vitacase/core/constants/legal_version.dart';
import 'package:vitacase/features/legal/presentation/screens/legal_update_screen.dart';
import 'package:vitacase/features/onboarding/presentation/screens/legal/data_deletion_screen.dart';
import 'package:vitacase/features/profile/presentation/screens/profile_create_screen.dart';
import 'package:vitacase/l10n/vita_app_localizations_delegate.dart';
import 'package:vitacase/shared/providers/shared_prefs_provider.dart';

Widget _buildTestApp({
  required Widget home,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: VitaAppLocalizationsDelegate.localizationsDelegates,
      supportedLocales: VitaAppLocalizationsDelegate.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 20.5 — Legal Master Audit & Harmonization Tests', () {
    test('1. LegalVersion conforms to expected release format', () {
      expect(LegalVersion.current, '1.1.7-2026-10');
    });

    test('2. All 5 canonical legal markdown assets exist and are loadable', () async {
      final pp = await rootBundle.loadString('assets/legal/privacy_policy.md');
      expect(pp, contains('VITACASE – PRIVACY POLICY'));
      expect(pp, contains('1.1.7-2026-10'));
      expect(pp, contains('AES-256-GCM'));

      final tos = await rootBundle.loadString('assets/legal/terms_of_service.md');
      expect(tos, contains('TERMS AND CONDITIONS'));
      expect(tos, contains('1.1.7-2026-10'));
      expect(tos, contains('Limanex Software'));

      final disc = await rootBundle.loadString('assets/legal/disclaimer.md');
      expect(disc, contains('DISCLAIMER'));
      expect(disc, contains('1.1.7-2026-10'));

      final kvkk = await rootBundle.loadString('assets/legal/kvkk.md');
      expect(kvkk, contains('6698 SAYILI KİŞİSEL VERİLERİN KORUNMASI KANUNU'));
      expect(kvkk, contains('1.1.7-2026-10'));
      expect(kvkk, contains('[TODO'));

      final dd = await rootBundle.loadString('assets/legal/data_deletion.md');
      expect(dd, contains('VITACASE – DATA RETENTION & DELETION POLICY'));
      expect(dd, contains('1.1.7-2026-10'));
      expect(dd, contains('Wipe All Data'));
      expect(dd, contains('isolated private data storage sandbox'));
    });

    test('3. LegalData has complete, non-stub content for all supported UI and bonus languages', () {
      const locales = ['en', 'tr', 'de', 'es', 'fr', 'pt', 'it', 'hi', 'zh', 'ja', 'ar', 'ko'];

      for (final loc in locales) {
        final pp = LegalData.getPrivacyPolicy(loc);
        expect(pp, isNotEmpty, reason: 'Privacy Policy must not be empty for $loc');
        expect(pp, isNot(endsWith('...')), reason: 'Privacy Policy must not be a stub for $loc');

        final terms = LegalData.getTerms(loc);
        expect(terms, isNotEmpty, reason: 'Terms must not be empty for $loc');
        expect(terms, isNot(endsWith('...')), reason: 'Terms must not be a stub for $loc');

        final disc = LegalData.getDisclaimer(loc);
        expect(disc, isNotEmpty, reason: 'Disclaimer must not be empty for $loc');
        expect(disc, isNot(endsWith('...')), reason: 'Disclaimer must not be a stub for $loc');
      }
    });

    testWidgets('4. DataDeletionScreen renders markdown correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildTestApp(home: const DataDeletionScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(DataDeletionScreen), findsOneWidget);
      expect(find.text('Data Retention & Deletion'), findsOneWidget);
    });

    testWidgets('5. ProfileCreateScreen renders unified Terms & Privacy link without separate KVKK item', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({'app_locale': 'tr'});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        _buildTestApp(
          home: const ProfileCreateScreen(),
          locale: const Locale('tr'),
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Phase 20.8: Unified Terms & Privacy entry is rendered, no separate KVKK button
      expect(find.text('Kullanım Koşulları ve Gizlilik'), findsOneWidget);
      expect(find.text('KVKK'), findsNothing);
    });

    testWidgets('6. LegalUpdateScreen renders unified Terms & Privacy link without separate KVKK item', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({'legal_accepted': true, 'app_locale': 'tr'});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        _buildTestApp(
          home: const LegalUpdateScreen(),
          locale: const Locale('tr'),
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Phase 20.8: Unified Terms & Privacy entry is rendered, no separate KVKK button
      expect(find.text('Kullanım Koşulları ve Gizlilik'), findsOneWidget);
      expect(find.text('KVKK Aydınlatma Metni'), findsNothing);
    });
  });
}
