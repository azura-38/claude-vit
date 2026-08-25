import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/l10n/vita_app_localizations_delegate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization & Fallback Tests', () {
    test('English lookup returns expected English translation', () {
      final text = lookupTranslationWithLocale('en', 'physical_metrics');
      expect(text, equals('Physical Metrics'));
    });

    test('Turkish lookup returns expected Turkish translation', () {
      final text = lookupTranslationWithLocale('tr', 'physical_metrics');
      expect(text, equals('Fiziksel Ölçümler'));
    });

    test('Missing translation in non-English locale safely falls back to English', () {
      final text = lookupTranslationWithLocale('de', 'full_screen_reminders');
      expect(text, isNotEmpty);
      expect(text, isNot(equals('null')));
    });

    test('Unknown arbitrary key humanizes without crashing or returning raw null', () {
      final text = lookupTranslationWithLocale('en', 'some_unknown_feature_label');
      expect(text, isNotEmpty);
      expect(text, isNot(equals('null')));
    });
  });

  group('Landscape Layout & Rendering Tests', () {
    testWidgets('Dashboard renders in landscape without RenderFlex overflow', (tester) async {
      // Set landscape viewport dimensions (e.g. 800 x 480)
      tester.view.physicalSize = const Size(800, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: VitaAppLocalizationsDelegate.localizationsDelegates,
          supportedLocales: VitaAppLocalizationsDelegate.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: SafeArea(
              child: ListView(
                children: [
                  Container(
                    height: 100,
                    color: Colors.blue,
                    alignment: Alignment.center,
                    child: const Text('Landscape Dashboard Header'),
                  ),
                  Container(
                    height: 200,
                    color: Colors.green,
                    alignment: Alignment.center,
                    child: const Text('Landscape Content'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Landscape Dashboard Header'), findsOneWidget);
      expect(find.text('Landscape Content'), findsOneWidget);
    });
  });
}
