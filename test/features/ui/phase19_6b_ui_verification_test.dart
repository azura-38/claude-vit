import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/core/config/app_config.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/features/profile/domain/models/user_profile.dart';
import 'package:vitacase/features/profile/presentation/widgets/bmi_card.dart';
import 'package:vitacase/features/vault/presentation/widgets/vault_controls.dart';
import 'package:vitacase/l10n/vita_app_localizations_delegate.dart';
import 'package:vitacase/shared/domain/enums/document_category.dart';
import 'package:vitacase/shared/widgets/inputs/blood_group_selector.dart';
import 'package:vitacase/shared/widgets/navigation/app_bottom_nav.dart';

Widget _buildTestApp({required Widget home, Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: VitaAppLocalizationsDelegate.localizationsDelegates,
    supportedLocales: VitaAppLocalizationsDelegate.supportedLocales,
    home: home,
  );
}

void main() {
  group('Phase 19.6B — Vault Layout & Small Screen', () {
    testWidgets('1. VaultControls renders on narrow 300px width without overflow', (tester) async {
      tester.view.physicalSize = const Size(300, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = TextEditingController();

      await tester.pumpWidget(
        _buildTestApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VaultControls(
                isDark: false,
                controller: controller,
                query: '',
                selectedCategory: null,
                sortMode: VaultSortMode.newest,
                allLabel: 'All',
                sortLabel: (m) => m.name,
                categoryLabel: (c) => c.name,
                onSearchChanged: (_) {},
                onCategoryChanged: (_) {},
                onSortChanged: (_) {},
                onClear: () {},
                selectedTag: null,
                availableTags: const ['Prescription', 'Lab Report', 'Cardiology'],
                onTagChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('2. VaultControls tag list scrolls horizontally without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = TextEditingController();

      await tester.pumpWidget(
        _buildTestApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VaultControls(
                isDark: true,
                controller: controller,
                query: 'test',
                selectedCategory: DocumentCategory.healthReports,
                sortMode: VaultSortMode.oldest,
                allLabel: 'All Documents',
                sortLabel: (m) => m.name,
                categoryLabel: (c) => c.name,
                onSearchChanged: (_) {},
                onCategoryChanged: (_) {},
                onSortChanged: (_) {},
                onClear: () {},
                selectedTag: 'Allergy',
                availableTags: const ['Allergy', 'Vaccine', 'Surgery', 'Pediatrics', 'Radiology'],
                onTagChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.filter_alt_off_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Phase 19.6B — Bottom Navigation Layout', () {
    testWidgets('3. AppBottomNav renders on narrow 320px width without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      int tappedIndex = -1;
      bool exploreTapped = false;

      await tester.pumpWidget(
        _buildTestApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNav(
              currentIndex: 0,
              onTap: (i) => tappedIndex = i,
              onExploreTap: () => exploreTapped = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.description_rounded), findsOneWidget);
      expect(find.byIcon(Icons.explore_rounded), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.explore_rounded));
      expect(exploreTapped, isTrue);

      await tester.tap(find.byIcon(Icons.description_rounded));
      expect(tappedIndex, equals(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('4. AppBottomNav handles simulated large text scaling without overflow', (tester) async {
      tester.view.physicalSize = const Size(340, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(1.3),
              padding: EdgeInsets.only(bottom: 24),
            ),
            child: Scaffold(
              bottomNavigationBar: AppBottomNav(
                currentIndex: 1,
                onTap: (_) {},
                onExploreTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Phase 19.6B — Forms & Selectors', () {
    test('5. BloodGroupSelector contains standard 8 blood groups (including O+ and O-)', () {
      expect(BloodGroupSelector.bloodGroups, containsAll(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']));
      expect(BloodGroupSelector.bloodGroups.length, equals(8));
    });

    test('6. BloodGroupSelector normalizes legacy 0+ and 0- to O+ and O-', () {
      expect(BloodGroupSelector.normalize('0+'), equals('O+'));
      expect(BloodGroupSelector.normalize('0-'), equals('O-'));
      expect(BloodGroupSelector.normalize('O+'), equals('O+'));
      expect(BloodGroupSelector.normalize('A+'), equals('A+'));
      expect(BloodGroupSelector.normalize(''), equals(''));
      expect(BloodGroupSelector.normalize(null), equals(''));
    });

    testWidgets('7. BloodGroupSelector displays normalized group correctly', (tester) async {
      String group = '0+';

      await tester.pumpWidget(
        _buildTestApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return BloodGroupSelector(
                  selectedGroup: group,
                  onChanged: (v) => setState(() => group = v),
                  isDark: false,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('O+'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('8. BmiCard layout does not overflow with narrow width and large text', (tester) async {
      tester.view.physicalSize = const Size(300, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final profile = UserProfile(
        weight: 98,
        height: 172,
        gender: Gender.male,
      );

      await tester.pumpWidget(
        _buildTestApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.2)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: BmiCard(profile: profile),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('172'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Phase 19.6B — Localization Integrity across 10 Locales', () {
    test('9. All 10 supported locales define valid onboarding and utility strings', () {
      const locales = ['en', 'tr', 'de', 'es', 'fr', 'hi', 'it', 'ja', 'pt', 'zh'];
      for (final loc in locales) {
        final ob1Title = lookupTranslationWithLocale(loc, 'ob1_title');
        final appName = lookupTranslationWithLocale(loc, 'app_name');
        final dataSec = lookupTranslationWithLocale(loc, 'data_security');

        expect(ob1Title.isNotEmpty, isTrue, reason: '$loc ob1_title must not be empty');
        expect(ob1Title, isNot(contains('Ob1 Title')), reason: '$loc ob1_title must not be placeholder');
        expect(appName.isNotEmpty, isTrue, reason: '$loc app_name must not be empty');
        expect(dataSec.isNotEmpty, isTrue, reason: '$loc data_security must not be empty');
      }
    });

    test('10. Categories and document tags exist across locales without crash', () {
      const locales = ['en', 'tr', 'de', 'es', 'fr', 'hi', 'it', 'ja', 'pt', 'zh'];
      for (final loc in locales) {
        final vaultTitle = lookupTranslationWithLocale(loc, 'docs_title');
        final prescriptions = lookupTranslationWithLocale(loc, 'docs_category_prescriptions');
        final reports = lookupTranslationWithLocale(loc, 'docs_category_reports');

        expect(vaultTitle.isNotEmpty, isTrue, reason: '$loc docs_title missing');
        expect(prescriptions.isNotEmpty, isTrue, reason: '$loc prescriptions missing');
        expect(reports.isNotEmpty, isTrue, reason: '$loc reports missing');
      }
    });
  });

  group('Phase 19.6B — Guards & Safety Contracts', () {
    test('11. Production ads flag is strictly false', () {
      expect(AppConfig.isProductionAdsActive, isFalse);
    });

    test('12. Leaderboard is disabled in AppConfig', () {
      expect(AppConfig.isLeaderboardEnabled, isFalse);
    });
  });
}
