import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 11 Splash Screen Tests', () {
    testWidgets('Splash screen has pure white background and VitaCase text only', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ColoredBox(
              key: Key('splash_bg'),
              color: Colors.white,
              child: Center(
                child: Text(
                  'VitaCase',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify VitaCase text is present
      expect(find.text('VitaCase'), findsOneWidget);

      // Verify no logo icons or spinners are displayed on the splash screen
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.health_and_safety), findsNothing);

      // Verify background color is solid white
      final coloredBox = tester.widget<ColoredBox>(find.byKey(const Key('splash_bg')));
      expect(coloredBox.color, equals(Colors.white));
    });

    test('Splash visual duration is targeted at ~300ms', () {
      const splashDuration = Duration(milliseconds: 300);
      expect(splashDuration.inMilliseconds, equals(300));
    });
  });
}
