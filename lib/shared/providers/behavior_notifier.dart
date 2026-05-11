import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/service_providers.dart';
import 'shared_prefs_provider.dart';
import 'daily_mission_providers.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

final behaviorProvider = Provider((ref) => BehaviorNotifier(ref));

class BehaviorNotifier {
  final Ref ref;
  bool _initialized = false;

  BehaviorNotifier(this.ref);

  static const String _lastLoginKey = 'user_last_login_date';

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = ref.read(sharedPreferencesProvider);
    final lastLoginStr = prefs.getString(_lastLoginKey);
    final now = DateTime.now();

    if (lastLoginStr != null) {
      final lastLogin = DateTime.tryParse(lastLoginStr);
      if (lastLogin != null) {
        final diff = now.difference(lastLogin);

        // If they returned after a while, clear old notifications
        if (diff.inHours > 1) {
          ref
              .read(notificationServiceProvider)
              .cancelNotification(9991); // Streak
          ref
              .read(notificationServiceProvider)
              .cancelNotification(9992); // Mission
        }
      }
    }

    // Update last login
    await prefs.setString(_lastLoginKey, now.toIso8601String());

    if (ref.read(engagementRemindersProvider)) {
      _scheduleBehaviorals();
    } else {
      ref.read(notificationServiceProvider).cancelNotification(9991);
      ref.read(notificationServiceProvider).cancelNotification(9992);
    }

    // Listen for mission changes
    _listenToMissions();
    _listenToReminderPreference();
  }

  void _scheduleBehaviorals() {
    ref.read(notificationServiceProvider).showStreakWarning();
    ref.read(notificationServiceProvider).showMissionReminder();
  }

  void _listenToMissions() {
    ref.listen(dailyMissionProvider, (previous, next) {
      final missions = next.asData?.value;
      if (missions != null) {
        final allDone = missions.every((m) => m.isCompleted);
        if (allDone) {
          ref
              .read(notificationServiceProvider)
              .cancelNotification(9992); // Mission reminder
        }
      }
    });
  }

  void _listenToReminderPreference() {
    ref.listen(engagementRemindersProvider, (previous, next) {
      if (next) {
        _scheduleBehaviorals();
      } else {
        ref.read(notificationServiceProvider).cancelNotification(9991);
        ref.read(notificationServiceProvider).cancelNotification(9992);
      }
    });
  }

  void notifyLimitReached() {
    ref.read(notificationServiceProvider).showLimitReachedPush();
  }
}
