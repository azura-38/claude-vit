import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/features/auth/presentation/providers/auth_providers.dart';
import 'package:vitacase/features/auth/presentation/widgets/app_lock_gate.dart';

class _FakeAppLockEnabledNotifier extends AppLockEnabledNotifier {
  @override
  bool build() => false;
}

class _FakeAppLockStateNotifier extends AppLockStateNotifier {
  @override
  AppLockState build() => AppLockState.unlocked;
}

void main() {
  group('Phase 11 AppLockGate Lifecycle & Assertion Tests', () {
    testWidgets('AppLockGate renders child when unlocked without inherited dependency leak', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLockEnabledProvider.overrideWith(_FakeAppLockEnabledNotifier.new),
            appLockStateProvider.overrideWith(_FakeAppLockStateNotifier.new),
          ],
          child: const MaterialApp(
            home: AppLockGate(
              child: Text('Protected Content'),
            ),
          ),
        ),
      );

      expect(find.text('Protected Content'), findsOneWidget);
    });

    testWidgets('AppLockGate unmounts cleanly without _dependents assertion failure', (tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLockEnabledProvider.overrideWith(_FakeAppLockEnabledNotifier.new),
            appLockStateProvider.overrideWith(_FakeAppLockStateNotifier.new),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AppLockGate(
                key: key,
                child: const Text('Child'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Child'), findsOneWidget);

      // Re-pump with empty widget to trigger complete unmount
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Child'), findsNothing);
    });
  });
}
