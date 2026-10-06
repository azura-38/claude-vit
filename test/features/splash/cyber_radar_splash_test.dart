import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/core/splash/cyber_radar_splash.dart';

void main() {
  group('Cyber Radar Splash Screen Tests', () {
    testWidgets('Light Cyber Radar renders with #F4F7FB background and light elements', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CyberRadarSplash(
            isDarkMode: false,
            logoAsset: '', // fallback vector logo
          ),
        ),
      );

      // Verify Scaffold background is #F4F7FB
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(const Color(0xFFF4F7FB)));

      // Verify branding elements
      expect(find.text('YOUR VAULT'), findsOneWidget);
      expect(find.text('Vita'), findsOneWidget);
      expect(find.text('Case'), findsOneWidget);

      // Pump animation frame to verify painters execute without exception
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CyberRadarSplash), findsOneWidget);
    });

    testWidgets('Dark Cyber Radar renders with #090F15 background and dark telemetry chips', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CyberRadarSplash(
            isDarkMode: true,
            logoAsset: '', // fallback vector logo
          ),
        ),
      );

      // Verify Scaffold background is #090F15
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(const Color(0xFF090F15)));

      // Verify dark branding and badge
      expect(find.text('VAULT ACTIVE'), findsOneWidget);
      expect(find.text('Vita'), findsOneWidget);
      expect(find.text('Case'), findsOneWidget);

      // Verify telemetry chips
      expect(find.text('• AES-256 GCM'), findsOneWidget);
      expect(find.text('✓ Hardware Enclave'), findsOneWidget);

      // Pump animation frame to verify painters execute without exception
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CyberRadarSplash), findsOneWidget);
    });
  });
}
