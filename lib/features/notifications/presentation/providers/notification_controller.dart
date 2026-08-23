import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/data/services/notification_engine.dart';
import '../../../profile/presentation/providers/settings_controller.dart';

final notificationControllerProvider = Provider((ref) => NotificationController(ref));

class NotificationController {
  final Ref ref;

  NotificationController(this.ref);

  Future<void> testNotification() => NotificationEngine.testNotification();

  Future<void> setSmartNotificationsEnabled(bool enabled) =>
      NotificationEngine.setSmartNotificationsEnabled(enabled);

  /// hide = true  → içeriği gizle
  /// hide = false → içeriği göster
  Future<void> setHideSensitiveContent(bool hide) async {
    // 1) Settings controller state'ini güncelle
    final settings = ref.read(settingsControllerProvider);
    await ref.read(settingsControllerProvider.notifier).updateNotificationSettings(
      settings.notificationSettings.copyWith(showSensitiveDetails: !hide),
    );

    // 2) SharedPreferences'e yaz — NotificationEngine bu key'i okuyor
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_hide_sensitive_content', hide);
  }

  Future<void> setFullScreenRemindersEnabled(bool enabled) async {
    final settings = ref.read(settingsControllerProvider);
    await ref.read(settingsControllerProvider.notifier).updateNotificationSettings(
      settings.notificationSettings.copyWith(fullScreenRemindersEnabled: enabled),
    );
    await NotificationEngine.setFullScreenRemindersEnabled(enabled);
  }

  Future<void> cancelEngagementNotifications() =>
      NotificationEngine.cancelEngagementNotifications();
}
