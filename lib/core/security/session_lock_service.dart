import 'package:flutter/widgets.dart';

class SessionLockService {
  DateTime? _pausedAt;

  bool shouldObscure({
    required bool lockEnabled,
    required AppLifecycleState state,
  }) {
    return lockEnabled &&
        (state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden);
  }

  void markPaused() {
    _pausedAt = DateTime.now();
  }

  bool shouldLockOnResume(Duration timeout) {
    final pausedAt = _pausedAt;
    if (pausedAt == null) return false;
    return DateTime.now().difference(pausedAt) >= timeout;
  }
}
