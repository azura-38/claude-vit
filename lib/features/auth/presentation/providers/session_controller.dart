import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';
import '../../../../core/types/runtime_types.dart';

final sessionControllerProvider = Provider((ref) => SessionController(ref));

class SessionController {
  final Ref ref;
  SessionController(this.ref);

  AppLockState get lockState => ref.watch(appLockStateProvider);
  bool get isLocked => lockState == AppLockState.locked;
  
  void unlock() => ref.read(appLockStateProvider.notifier).setUnlocked();
  void lock() => ref.read(appLockStateProvider.notifier).setLocked();
}
