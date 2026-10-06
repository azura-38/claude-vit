import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/l10n/app_localizations.dart';
import 'package:vitacase/l10n/vita_app_localizations_delegate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const supported10 = ['en', 'tr', 'de', 'es', 'fr', 'hi', 'it', 'ja', 'pt', 'zh'];

  Widget buildLocalizedWidget({
    required Locale locale,
    required Widget Function(BuildContext context) builder,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: VitaAppLocalizationsDelegate.supportedLocales,
      localizationsDelegates: VitaAppLocalizationsDelegate.localizationsDelegates,
      home: Builder(builder: builder),
    );
  }

  group('Phase 17 - 10-Language Content Completion & Runtime QA (A - M)', () {
    // -------------------------------------------------------------------------
    // A. 10 Locale Runtime Loading
    // -------------------------------------------------------------------------
    test('A. 10 locale runtime loading via delegate', () async {
      const delegate = VitaAppLocalizationsDelegate();
      expect(VitaAppLocalizationsDelegate.supportedLocales.length, 10);

      for (final code in supported10) {
        final locale = Locale(code);
        expect(delegate.isSupported(locale), isTrue);
        final loc = await delegate.load(locale);
        expect(loc, isNotNull);
        expect(loc.appName, isNotEmpty);
        expect(loc.addMedication, isNotEmpty);
        expect(loc.addContactTitle, isNotEmpty);
      }
    });

    // -------------------------------------------------------------------------
    // B. Onboarding All Locales
    // -------------------------------------------------------------------------
    testWidgets('B. Onboarding all 10 locales content completeness', (tester) async {
      for (final code in supported10) {
        await tester.pumpWidget(
          buildLocalizedWidget(
            locale: Locale(code),
            builder: (context) {
              return Scaffold(
                body: ListView(
                  children: [
                    Text(context.tr('ob1_title')),
                    Text(context.tr('ob1_subtitle')),
                    Text(context.tr('ob1_desc')),
                    Text(context.tr('ob2_title')),
                    Text(context.tr('ob2_desc')),
                    Text(context.tr('ob3_title')),
                    Text(context.tr('ob3_desc')),
                    Text(context.tr('ob4_title')),
                    Text(context.tr('ob4_desc')),
                    Text(context.tr('ob5_title')),
                    Text(context.tr('ob5_desc')),
                    Text(context.tr('ob_feature1_title')),
                    Text(context.tr('ob_feature2_title')),
                    Text(context.tr('ob_feature3_title')),
                    Text(context.tr('skip')),
                    Text(context.tr('continue')),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Text), findsNWidgets(16), reason: 'All 16 onboarding texts must render for $code');
      }
    });

    // -------------------------------------------------------------------------
    // C. Profile All Locales
    // -------------------------------------------------------------------------
    testWidgets('C. Profile and physical measurements all 10 locales', (tester) async {
      for (final code in supported10) {
        await tester.pumpWidget(
          buildLocalizedWidget(
            locale: Locale(code),
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    Text(context.tr('personal_information')),
                    Text(context.tr('important_information')),
                    Text(context.tr('physical_metrics')),
                    Text(context.tr('health_profile')),
                    Text(context.tr('health_conditions')),
                    Text(context.tr('profile_completion_status')),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Text), findsNWidgets(6), reason: 'All profile section titles must render for $code');
      }
    });

    // -------------------------------------------------------------------------
    // D. Appointments All Locales
    // -------------------------------------------------------------------------
    testWidgets('D. Appointments creation and responsibility notice all 10 locales', (tester) async {
      for (final code in supported10) {
        await tester.pumpWidget(
          buildLocalizedWidget(
            locale: Locale(code),
            builder: (context) {
              final loc = AppLocalizations.of(context)!;
              return Scaffold(
                body: ListView(
                  children: [
                    Text(context.tr('appointment_title')),
                    Text(context.tr('hint_title')),
                    Text(context.tr('notice_appointment_responsibility')),
                    Text(loc.appointments),
                    Text(context.tr('importance_high')),
                    Text(context.tr('importance_normal')),
                    Text(loc.label_reminder),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Text), findsNWidgets(7), reason: 'All appointment fields must render for $code');
      }
    });

    // -------------------------------------------------------------------------
    // E. Medicines All Locales
    // -------------------------------------------------------------------------
    testWidgets('E. Medicines create/edit and responsibility notice all 10 locales', (tester) async {
      for (final code in supported10) {
        await tester.pumpWidget(
          buildLocalizedWidget(
            locale: Locale(code),
            builder: (context) {
              final loc = AppLocalizations.of(context)!;
              return Scaffold(
                body: Column(
                  children: [
                    Text(loc.addMedication),
                    Text(context.tr('edit_medication')),
                    Text(context.tr('notice_medication_responsibility')),
                    Text(loc.medicineName),
                    Text(context.tr('daily_reminders')),
                    Text(context.tr('reminder_troubleshooting')),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Text), findsNWidgets(6), reason: 'All medication fields must render for $code');
      }
    });

    // -------------------------------------------------------------------------
    // F. Doctors All Locales
    // -------------------------------------------------------------------------
    testWidgets('F. Doctors add/edit and title all 10 locales', (tester) async {
      for (final code in supported10) {
        await tester.pumpWidget(
          buildLocalizedWidget(
            locale: Locale(code),
            builder: (context) {
              final loc = AppLocalizations.of(context)!;
              return Scaffold(
                body: Column(
                  children: [
                    Text(loc.addContactTitle),
                    Text(context.tr('edit_contact_title')),
                    Text(loc.requiredContactError),
                    Text(loc.doctor_title_dr),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Text), findsNWidgets(4), reason: 'All doctor fields must render for $code');
      }
    });

    // -------------------------------------------------------------------------
    // G. Vault All Locales
    // -------------------------------------------------------------------------
    testWidgets('G. Vault external app warning and responsibility notice all 10 locales', (tester) async {
      for (final code in supported10) {
        await tester.pumpWidget(
          buildLocalizedWidget(
            locale: Locale(code),
            builder: (context) {
              final loc = AppLocalizations.of(context)!;
              return Scaffold(
                body: Column(
                  children: [
                    Text(context.tr('vault_external_app_warning')),
                    Text(context.tr('notice_document_responsibility')),
                    Text(context.tr('docs_no_results')),
                    Text(context.tr('docs_try_different')),
                    Text(loc.vault),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Text), findsNWidgets(5), reason: 'All vault texts must render for $code');
      }
    });

    // -------------------------------------------------------------------------
    // H. Settings / Security All Locales
    // -------------------------------------------------------------------------
    testWidgets('H. Settings, App Lock and PIN dialogs all 10 locales', (tester) async {
      for (final code in supported10) {
        await tester.pumpWidget(
          buildLocalizedWidget(
            locale: Locale(code),
            builder: (context) {
              final loc = AppLocalizations.of(context)!;
              return Scaffold(
                body: ListView(
                  children: [
                    Text(loc.appLock),
                    Text(context.tr('pin_not_set')),
                    Text(context.tr('pin_not_set_desc')),
                    Text(context.tr('btn_create')),
                    Text(context.tr('enter_6_digit_pin')),
                    Text(context.tr('pin_disable_desc')),
                    Text(context.tr('current_pin')),
                    Text(context.tr('new_pin')),
                    Text(loc.clearAllData),
                    Text(loc.dataSecurity),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Text), findsNWidgets(10), reason: 'All security texts must render for $code');
      }
    });

    // -------------------------------------------------------------------------
    // I. Review / Rate Us All Locales
    // -------------------------------------------------------------------------
    testWidgets('I. Review prompt and Rate Us all 10 locales', (tester) async {
      for (final code in supported10) {
        await tester.pumpWidget(
          buildLocalizedWidget(
            locale: Locale(code),
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    Text(context.tr('review_prompt_title')),
                    Text(context.tr('review_prompt_desc')),
                    Text(context.tr('review_prompt_action')),
                    Text(context.tr('rate_us')),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Text), findsNWidgets(4), reason: 'All review prompt texts must render for $code');
      }
    });

    // -------------------------------------------------------------------------
    // J. Ads UI All Locales
    // -------------------------------------------------------------------------
    testWidgets('J. Reward themes, AdMob UI placeholders all 10 locales', (tester) async {
      for (final code in supported10) {
        await tester.pumpWidget(
          buildLocalizedWidget(
            locale: Locale(code),
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    Text(context.tr('reward_themes_active')),
                    Text(context.tr('reward_themes_locked')),
                    Text(context.tr('reward_themes_time_left', extra: {'time': '2d 4h'})),
                    Text(context.tr('reward_themes_unlock_prompt')),
                    Text(context.tr('reward_themes_add_day')),
                    Text(context.tr('mission_ad_daily')),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Text), findsNWidgets(6), reason: 'All ads UI strings must render for $code');
      }
    });

    // -------------------------------------------------------------------------
    // K. No Unexpected English Fallback
    // -------------------------------------------------------------------------
    testWidgets('K. Non-English locales resolve native translations without raw English fallback', (tester) async {
      final nonEn = supported10.where((c) => c != 'en').toList();

      for (final code in nonEn) {
        await tester.pumpWidget(
          buildLocalizedWidget(
            locale: Locale(code),
            builder: (context) {
              final pinNotSet = context.tr('pin_not_set');
              final btnCreate = context.tr('btn_create');
              final currentPin = context.tr('current_pin');
              final editMed = context.tr('edit_medication');
              final editContact = context.tr('edit_contact_title');

              // Must not match English exactly
              expect(pinNotSet, isNot(equals('PIN Not Set')), reason: '$code should not use English for pin_not_set');
              expect(btnCreate, isNot(equals('Create')), reason: '$code should not use English for btn_create');
              expect(currentPin, isNot(equals('Current PIN')), reason: '$code should not use English for current_pin');
              expect(editMed, isNot(equals('Edit Medication')), reason: '$code should not use English for edit_medication');
              expect(editContact, isNot(equals('Edit Person / Contact')), reason: '$code should not use English for edit_contact_title');

              return Text('$pinNotSet | $btnCreate | $currentPin | $editMed | $editContact');
            },
          ),
        );
        await tester.pumpAndSettle();
      }
    });

    // -------------------------------------------------------------------------
    // L. Long Text Safety
    // -------------------------------------------------------------------------
    testWidgets('L. Long text safety across German, French, Japanese, Chinese', (tester) async {
      final verboseLocales = ['de', 'fr', 'ja', 'zh'];

      for (final code in verboseLocales) {
        await tester.pumpWidget(
          buildLocalizedWidget(
            locale: Locale(code),
            builder: (context) {
              return Scaffold(
                body: SizedBox(
                  width: 320, // narrow screen simulation
                  child: ListView(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          context.tr('notice_document_responsibility'),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Card(
                        child: Text(
                          context.tr('vault_external_app_warning'),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        context.tr('developer_debug_panel_desc'),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        context.tr('reminder_troubleshooting_desc'),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();
        // Asserts no RenderFlex overflow exceptions thrown during layout
        expect(tester.takeException(), isNull);
      }
    });

    // -------------------------------------------------------------------------
    // M. Hardcoded User-Facing String Audit
    // -------------------------------------------------------------------------
    test('M. Hardcoded user-facing string audit across all 10 locales', () {
      final auditedKeys = [
        'pin_not_set',
        'pin_not_set_desc',
        'btn_create',
        'enter_6_digit_pin',
        'pin_disable_desc',
        'current_pin',
        'new_pin',
        'vault_external_app_warning',
        'achievement_unlocked',
        'reward_themes_active',
        'reward_themes_locked',
        'reward_themes_unlock_prompt',
        'reward_themes_add_day',
        'developer_debug_panel',
        'developer_debug_panel_desc',
        'open_debug_panel',
        'notice_document_responsibility',
        'notice_medication_responsibility',
        'notice_appointment_responsibility',
        'edit_medication',
        'edit_contact_title',
        'daily_reminders',
        'reminder_troubleshooting',
        'reminder_troubleshooting_desc',
      ];

      for (final code in supported10) {
        for (final key in auditedKeys) {
          final translated = lookupTranslationWithLocale(code, key);
          expect(translated, isNotNull, reason: 'Key $key must exist in locale $code');
          expect(translated, isNotEmpty, reason: 'Key $key must not be empty in locale $code');
          expect(translated, isNot(equals(key)), reason: 'Key $key should not resolve to raw key name in $code');
        }
      }
    });
  });
}
