import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/shared/widgets/dialogs/reward_dialog.dart';

void main() {
  testWidgets('RewardDialog auto-closes after timer without throwing error', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => RewardDialog.show(
                context,
                title: 'Test Reward',
                description: 'You earned a badge!',
              ),
              child: const Text('Show Reward'),
            ),
          ),
        ),
      ),
    );

    // Tap button to show dialog
    await tester.tap(find.text('Show Reward'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Test Reward'), findsOneWidget);

    // Fast-forward past the 4.5s auto-close timer and route pop animation
    await tester.pump(const Duration(milliseconds: 4500));
    await tester.pump(const Duration(milliseconds: 500));

    // Dialog should be safely popped
    expect(find.text('Test Reward'), findsNothing);
  });

  testWidgets('RewardDialog prevents race condition when dismissed manually before timer', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => RewardDialog.show(
                context,
                title: 'Race Condition Reward',
                description: 'Race condition test',
              ),
              child: const Text('Show Reward'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Reward'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Race Condition Reward'), findsOneWidget);

    // Dismiss manually by tapping dialog card
    await tester.tap(find.text('Race Condition Reward'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Fast-forward past timer duration — no error / extra pop occurs
    await tester.pump(const Duration(milliseconds: 5000));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Show Reward'), findsOneWidget);
  });
}
