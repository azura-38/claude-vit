import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/features/profile/presentation/widgets/metric_box.dart';

void main() {
  group('Phase 11 Responsive Overflow Tests (360px Narrow Device)', () {
    testWidgets('MetricBox does not overflow with 3-digit values in narrow Row', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errors.add(details);
        originalOnError?.call(details);
      };

      // Set surface size to narrow 360x640 device
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        FlutterError.onError = originalOnError;
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320, // Content width after screen padding
              child: Row(
                children: [
                  MetricBox(
                    title: 'Current Weight',
                    value: '120',
                    unit: 'kg',
                  ),
                  SizedBox(width: 12),
                  MetricBox(
                    title: 'Height',
                    value: '185',
                    unit: 'cm',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure no RenderFlex overflow errors occurred
      final overflowErrors = errors.where((e) => e.toString().contains('overflowed')).toList();
      expect(overflowErrors, isEmpty, reason: 'MetricBox must not overflow on narrow screens');

      expect(find.text('120'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
      expect(find.text('185'), findsOneWidget);
      expect(find.text('cm'), findsOneWidget);
    });
  });
}
