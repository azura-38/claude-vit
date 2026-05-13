import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/data/services/notification_engine.dart';
import '../../../../shared/providers/user_behavior_provider.dart';
import '../../../../shared/data/services/ad_controller.dart';
import '../../../../shared/providers/document_providers.dart';
import '../../../../core/security/session_lock_service.dart';
import '../../../../core/security/security_controller.dart';

final appLifecycleProvider = NotifierProvider<AppLifecycleController, bool>(
  AppLifecycleController.new,
);

class AppLifecycleController extends Notifier<bool> {
  DateTime? _lastPausedTime;
  final _sessionLockService = SessionLockService();

  @override
  bool build() {
    // State represents whether the screen should be obscured (to prevent OS snapshots)
    return false;
  }

  /// Initial startup logic moved from main/app.dart
  void init() {
    final lockEnabled = ref.read(appLockEnabledProvider);
    if (lockEnabled) {
      ref.read(appLockStateProvider.notifier).setLocked();
    }
    
    // Apply security policies (e.g. anti-screenshot)
    unawaited(ref.read(securityControllerProvider.notifier).applySecureScreenPolicy());
    
    // Trigger behavioral notification checks
    final user = ref.read(userBehaviorProvider);
    NotificationTriggers.onAppOpen(user);
    
    // Show ads if lock is not active (to not overlap)
    if (!lockEnabled) {
      unawaited(ref.read(adControllerProvider).onAppOpen());
    }
  }

  /// Centralized lifecycle state handling
  void handleLifecycleState(AppLifecycleState lifecycleState) {
    final lockEnabled = ref.read(appLockEnabledProvider);

    // Update obscure state (blur overlay)
    state = _sessionLockService.shouldObscure(
      lockEnabled: lockEnabled,
      state: lifecycleState,
    );

    if (lifecycleState == AppLifecycleState.paused) {
      _handlePaused();
    } else if (lifecycleState == AppLifecycleState.resumed) {
      _handleResumed(lockEnabled);
    }
  }

  void _handlePaused() {
    _lastPausedTime = DateTime.now();
    _sessionLockService.markPaused();
    NotificationTriggers.onAppClose();
  }

  void _handleResumed(bool lockEnabled) {
    // Cleanup temporary files on resume
    ref.read(fileStorageServiceProvider).cleanupAllTempFiles();

    if (lockEnabled && _lastPausedTime != null) {
      final timeout = ref.read(lockTimeoutProvider);
      
      // Auto-lock if timeout duration exceeded
      if (_sessionLockService.shouldLockOnResume(timeout.duration)) {
        ref.read(appLockStateProvider.notifier).setLocked();
      } else {
        unawaited(ref.read(adControllerProvider).onAppOpen());
      }
    } else {
      unawaited(ref.read(adControllerProvider).onAppOpen());
    }
  }
}
