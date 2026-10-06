import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/constants/app_routes.dart';
import 'package:vitacase/core/constants/legal_version.dart';
import 'package:vitacase/features/legal/presentation/screens/terms_and_privacy_screen.dart';
import 'package:vitacase/features/profile/presentation/widgets/settings/legal_section.dart';
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

  group('Phase 20.8 — Consolidated Terms & Privacy Architecture Tests', () {
    test('1. LegalVersion is 1.1.7-2026-10', () {
      expect(LegalVersion.current, '1.1.7-2026-10');
    });

    test('2. Consolidated canonical legal markdown asset terms_and_privacy.md exists and contains all 5 sections', () async {
      final doc = await rootBundle.loadString('assets/legal/terms_and_privacy.md');
      expect(doc, contains('VITACASE – TERMS & PRIVACY'));
      expect(doc, contains('1.1.7-2026-10'));
      expect(doc, contains('SECTION 1 — TERMS OF USE'));
      expect(doc, contains('SECTION 2 — PRIVACY POLICY & GLOBAL DATA PROTECTION'));
      expect(doc, contains('SECTION 3 — TÜRKİYE — 6698 SAYILI KVKK AYDINLATMA BİLGİLENDİRMESİ'));
      expect(doc, contains('SECTION 4 — HEALTH & MEDICAL DISCLAIMER'));
      expect(doc, contains('SECTION 5 — DATA RETENTION & DELETION POLICY'));
      expect(doc, contains('AES-256-GCM'));
      expect(doc, contains('limanexsoftware@outlook.com'));
      expect(doc, contains('[TODO: Registered Business Address'));
      expect(doc, contains('[TODO: MERSİS / Ticaret Sicil No'));
      expect(doc, contains('[TODO: Kayıtlı Elektronik Posta (KEP) Adresi'));
    });

    test('3. AppRoutes contains settingsTermsAndPrivacy and preserved routes', () {
      expect(AppRoutes.settingsTermsAndPrivacy, '/settings/terms-and-privacy');
      expect(AppRoutes.settingsTerms, '/settings/terms');
      expect(AppRoutes.settingsPrivacy, '/settings/privacy');
      expect(AppRoutes.settingsDisclaimer, '/settings/disclaimer');
      expect(AppRoutes.settingsKvkk, '/settings/kvkk');
      expect(AppRoutes.settingsDataDeletion, '/settings/data-deletion');
    });

    testWidgets('4. TermsAndPrivacyScreen renders with 5 navigation chips in English', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildTestApp(home: const TermsAndPrivacyScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(TermsAndPrivacyScreen), findsOneWidget);
      expect(find.text('Terms & Privacy'), findsWidgets);
      expect(find.text('1. Terms of Use'), findsOneWidget);
      expect(find.text('2. Privacy & GDPR'), findsOneWidget);
      expect(find.text('3. Türkiye KVKK'), findsOneWidget);
      expect(find.text('4. Disclaimer'), findsOneWidget);
      expect(find.text('5. Data Deletion'), findsOneWidget);
      expect(find.text('Legal Version: 1.1.7-2026-10'), findsOneWidget);
    });

    testWidgets('5. TermsAndPrivacyScreen renders with localized chips in Turkish', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildTestApp(
          home: const TermsAndPrivacyScreen(),
          locale: const Locale('tr'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(TermsAndPrivacyScreen), findsOneWidget);
      expect(find.text('Kullanım Koşulları ve Gizlilik'), findsWidgets);
      expect(find.text('1. Kullanım Koşulları'), findsOneWidget);
      expect(find.text('2. Gizlilik & GDPR'), findsOneWidget);
      expect(find.text('3. KVKK Aydınlatma'), findsOneWidget);
      expect(find.text('4. Yasal Uyarı'), findsOneWidget);
      expect(find.text('5. Veri Silme'), findsOneWidget);
    });

    testWidgets('6. Settings LegalSection has only ONE unified tile and no separate KVKK/GDPR tiles', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({'app_locale': 'tr'});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        _buildTestApp(
          home: const Scaffold(body: LegalSection(isDark: false)),
          locale: const Locale('tr'),
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Must find the unified Terms & Privacy tile
      expect(find.text('Kullanım Koşulları ve Gizlilik'), findsOneWidget);

      // Must NOT have separate tiles for KVKK, privacy, terms, or data deletion in the menu
      expect(find.text('KVKK Aydınlatma Metni'), findsNothing);
      expect(find.text('Veri Saklama ve Silme Politikası'), findsNothing);
    });
  });
}
