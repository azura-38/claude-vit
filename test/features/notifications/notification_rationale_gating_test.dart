import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/l10n/app_localizations.dart';
import 'package:vitacase/shared/data/services/notification_engine.dart';
import 'package:vitacase/shared/widgets/dialogs/notification_rationale_sheet.dart';

import 'fake_awesome_notifications_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAwesomeNotificationsClient fakeClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'app_locale': 'en',
    });
    NotificationEngine.resetForTesting();
    fakeClient = FakeAwesomeNotificationsClient();
    NotificationEngine.setClientForTesting(fakeClient);
  });

  tearDown(() {
    NotificationEngine.resetForTesting();
  });

  test('1. initCore does not request notification permissions', () async {
    await NotificationEngine.initCore();
    expect(NotificationEngine.isInitialized, isTrue);
    expect(fakeClient.requestPermissionCallCount, 0);
  });

  test('2. isPermissionGranted returns false when not allowed without prompting', () async {
    fakeClient.isAllowed = false;
    final granted = await NotificationEngine.isPermissionGranted();
    expect(granted, isFalse);
    expect(fakeClient.requestPermissionCallCount, 0);
  });

  test('3. isPermissionGranted returns true when allowed without prompting', () async {
    fakeClient.isAllowed = true;
    final granted = await NotificationEngine.isPermissionGranted();
    expect(granted, isTrue);
    expect(fakeClient.requestPermissionCallCount, 0);
  });

  testWidgets('4. showIfNeeded returns true immediately if already granted', (tester) async {
    fakeClient.isAllowed = true;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await NotificationRationaleSheet.showIfNeeded(context);
              expect(result, isTrue);
            },
            child: const Text('Check'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationRationaleSheet), findsNothing);
    expect(fakeClient.requestPermissionCallCount, 0);
  });

  testWidgets('5. Rationale sheet appears when permission not granted, requests on Enable tap', (tester) async {
    fakeClient.isAllowed = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              await NotificationRationaleSheet.showIfNeeded(context);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Rationale sheet is displayed
    expect(find.byType(NotificationRationaleSheet), findsOneWidget);
    // No request yet!
    expect(fakeClient.requestPermissionCallCount, 0);

    // Tap enable button inside rationale sheet
    final enableBtn = find.byType(ElevatedButton).last;
    await tester.tap(enableBtn);
    await tester.pumpAndSettle();

    // Now permission request was triggered explicitly by user action
    expect(fakeClient.requestPermissionCallCount, 1);
  });
}
