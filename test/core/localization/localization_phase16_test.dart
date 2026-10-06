import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/di/repository_providers.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/l10n/translations.dart';
import 'package:vitacase/features/profile/presentation/widgets/metric_box.dart';
import 'package:vitacase/l10n/app_localizations_en.dart';
import 'package:vitacase/l10n/vita_app_localizations_delegate.dart';
import 'package:vitacase/shared/domain/entities/user_preferences.dart';
import 'package:vitacase/shared/domain/repositories/user_preferences_repository.dart';
import 'package:vitacase/shared/providers/locale_provider.dart';
import 'package:vitacase/shared/providers/shared_prefs_provider.dart';
import 'package:vitacase/shared/widgets/navigation/app_bottom_nav.dart';

class _MockUserPreferencesRepository implements UserPreferencesRepository {
  UserPreferences _prefs = const UserPreferences();

  @override
  Future<UserPreferences> getPreferences() async => _prefs;

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    _prefs = preferences;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const supported10 = ['en', 'tr', 'de', 'es', 'fr', 'hi', 'it', 'ja', 'pt', 'zh'];

  group('Phase 16 Localization Foundation & Language Consistency Tests (A - L)', () {
    test('A. All 10 locales load via VitaAppLocalizationsDelegate', () async {
      const delegate = VitaAppLocalizationsDelegate();
      expect(VitaAppLocalizationsDelegate.supportedLocales.length, 10);

      for (final code in supported10) {
        final locale = Locale(code);
        expect(delegate.isSupported(locale), isTrue, reason: 'Locale $code should be supported');

        final localizations = await delegate.load(locale);
        expect(localizations, isNotNull);
        expect(localizations.appName, isNotEmpty);
        expect(localizations.home, isNotEmpty);
        expect(localizations.vault, isNotEmpty);
        expect(localizations.appointments, isNotEmpty);
        expect(localizations.profile, isNotEmpty);
      }
    });

    test('B. Locale switching updates localeProvider reactively', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final sharedPrefs = await SharedPreferences.getInstance();
      final mockRepo = _MockUserPreferencesRepository();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          userPreferencesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      // Initial locale is English
      expect(container.read(localeProvider), const Locale('en'));

      // Switch to German
      await container.read(localeProvider.notifier).setLocale('de');
      expect(container.read(localeProvider), const Locale('de'));

      // Switch to Japanese
      await container.read(localeProvider.notifier).setLocale('ja');
      expect(container.read(localeProvider), const Locale('ja'));

      // Switch to Turkish
      await container.read(localeProvider.notifier).setLocale('tr');
      expect(container.read(localeProvider), const Locale('tr'));
    });

    test('C. Locale persistence saves to user preferences and SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final sharedPrefs = await SharedPreferences.getInstance();
      final mockRepo = _MockUserPreferencesRepository();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          userPreferencesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(localeProvider.notifier).setLocale('es');

      // Verify persistent SharedPreferences
      expect(sharedPrefs.getString('app_locale'), 'es');

      // Verify repository preference
      final repoPrefs = await mockRepo.getPreferences();
      expect(repoPrefs.locale, 'es');
    });

    test('D. No missing key fallback safely humanizes missing keys without crashing', () {
      final fallbackEn = lookupTranslationWithLocale('en', 'completely_unrecognized_custom_key');
      expect(fallbackEn, 'Completely Unrecognized Custom Key');

      final fallbackDe = lookupTranslationWithLocale('de', 'completely_unrecognized_custom_key');
      expect(fallbackDe, 'Completely Unrecognized Custom Key');

      final fallbackEmpty = lookupTranslationWithLocale('en', '');
      expect(fallbackEmpty, '');
    });

    test('E. Parameterized strings correctly replace extra placeholders across languages', () {
      final replacedEn = lookupTranslationWithLocale(
        'en',
        'docs_download_failed',
        extra: {'error': 'Network timeout'},
      );
      expect(replacedEn, contains('Network timeout'));

      final replacedTr = lookupTranslationWithLocale(
        'tr',
        'docs_download_failed',
        extra: {'error': 'Bağlantı koptu'},
      );
      expect(replacedTr, contains('Bağlantı koptu'));

      final replacedDe = lookupTranslationWithLocale(
        'de',
        'docs_download_failed',
        extra: {'error': 'Zeitüberschreitung'},
      );
      expect(replacedDe, contains('Zeitüberschreitung'));
    });

    test('F. Placeholder consistency across translations', () {
      // Check that parameterized strings in Translations.data retain matching placeholders
      for (final code in supported10) {
        final langData = Translations.data[code];
        if (langData == null) continue;

        if (langData.containsKey('docs_download_failed')) {
          expect(
            langData['docs_download_failed'],
            contains('{error}'),
            reason: '$code should contain {error} in docs_download_failed',
          );
        }
      }
    });

    testWidgets('G. Long translation layout safety prevents overflows in German and French', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final localeCode in ['de', 'fr']) {
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(localeCode),
            localizationsDelegates: VitaAppLocalizationsDelegate.localizationsDelegates,
            supportedLocales: VitaAppLocalizationsDelegate.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        MetricBox(
                          title: lookupTranslationWithLocale(localeCode, 'current_weight'),
                          value: '75',
                          unit: 'kg',
                        ),
                        MetricBox(
                          title: lookupTranslationWithLocale(localeCode, 'height_label'),
                          value: '180',
                          unit: 'cm',
                        ),
                      ],
                    ),
                    AppBottomNav(
                      currentIndex: 0,
                      onTap: (_) {},
                      onExploreTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'No overflow should occur in $localeCode');
      }
    });

    test('H. Review localization is non-empty and distinct in all 10 locales', () {
      final reviewKeys = [
        'review_prompt_title',
        'review_prompt_desc',
        'review_prompt_action',
        'rate_us',
      ];

      for (final code in supported10) {
        for (final key in reviewKeys) {
          final translated = lookupTranslationWithLocale(code, key);
          expect(translated, isNotEmpty, reason: '$key in $code should not be empty');
          expect(translated, isNot(contains('_')), reason: '$key in $code should not be unparsed key');
        }
      }

      // Check specific expected phrases
      expect(lookupTranslationWithLocale('en', 'rate_us'), 'Rate Us');
      expect(lookupTranslationWithLocale('tr', 'rate_us'), 'Bizi Değerlendirin');
      expect(lookupTranslationWithLocale('de', 'rate_us'), 'Bewerten Sie uns');
      expect(lookupTranslationWithLocale('es', 'rate_us'), 'Califícanos');
      expect(lookupTranslationWithLocale('fr', 'rate_us'), 'Évaluez-nous');
      expect(lookupTranslationWithLocale('hi', 'rate_us'), 'हमें रेट करें');
      expect(lookupTranslationWithLocale('it', 'rate_us'), 'Valutaci');
      expect(lookupTranslationWithLocale('ja', 'rate_us'), '評価する');
      expect(lookupTranslationWithLocale('pt', 'rate_us'), 'Avalie-nos');
      expect(lookupTranslationWithLocale('zh', 'rate_us'), '评价我们');
    });

    test('I. Ads UI localization exists and is non-empty across all 10 locales', () async {
      const delegate = VitaAppLocalizationsDelegate();
      for (final code in supported10) {
        final l10n = await delegate.load(Locale(code));
        expect(l10n.ad_failed, isNotEmpty, reason: 'ad_failed in $code should not be empty');
        expect(l10n.ad_reward_not_earned, isNotEmpty, reason: 'ad_reward_not_earned in $code should not be empty');
        expect(l10n.ad_unavailable, isNotEmpty, reason: 'ad_unavailable in $code should not be empty');
        expect(l10n.ad_unavailable_try_later, isNotEmpty, reason: 'ad_unavailable_try_later in $code should not be empty');
        expect(l10n.ad_watch_btn, isNotEmpty, reason: 'ad_watch_btn in $code should not be empty');
      }
    });

    test('J. Onboarding localization covers all slides and features in all 10 locales', () {
      final onboardingKeys = [
        'ob1_title',
        'ob1_subtitle',
        'ob1_desc',
        'ob2_title',
        'ob2_desc',
        'ob3_title',
        'ob3_desc',
        'ob4_title',
        'ob4_desc',
        'ob5_title',
        'ob5_desc',
        'ob_feature1_title',
        'ob_feature1_desc',
        'ob_feature2_title',
        'ob_feature2_desc',
        'ob_feature3_title',
        'ob_feature3_desc',
      ];

      for (final code in supported10) {
        for (final key in onboardingKeys) {
          final translated = lookupTranslationWithLocale(code, key);
          expect(translated, isNotEmpty, reason: '$key in $code should not be empty');
          expect(translated, isNot(equals(key)), reason: '$key in $code should be properly translated');
        }
      }
    });

    test('K. Unsupported or missing locale gracefully falls back to English without crashing', () async {
      const delegate = VitaAppLocalizationsDelegate();

      // Delegate isSupported returns false for unsupported locales
      expect(delegate.isSupported(const Locale('ru')), isFalse);
      expect(delegate.isSupported(const Locale('ar')), isFalse);
      expect(delegate.isSupported(const Locale('xx')), isFalse);

      // But delegate.load does NOT throw FlutterError; it falls back to AppLocalizationsEn
      final fallbackInstance = await delegate.load(const Locale('ru'));
      expect(fallbackInstance, isA<AppLocalizationsEn>());
      expect(fallbackInstance.appName, 'VitaCase');

      // lookupTranslationWithLocale also gracefully falls back to English
      final rateUsRu = lookupTranslationWithLocale('ru', 'rate_us');
      expect(rateUsRu, 'Rate Us');
    });

    test('L. App restart locale persistence restores persisted locale immediately', () async {
      // Simulate app kill & restart: SharedPreferences has 'ja' already stored
      SharedPreferences.setMockInitialValues({'app_locale': 'ja'});
      final sharedPrefs = await SharedPreferences.getInstance();
      final mockRepo = _MockUserPreferencesRepository();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          userPreferencesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      // Verify that localeProvider synchronously starts with 'ja' from SharedPreferences
      final initialLocale = container.read(localeProvider);
      expect(initialLocale, const Locale('ja'));
    });
  });
}
