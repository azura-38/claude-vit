import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/data/services/notification_engine.dart';
import '../../../profile/presentation/providers/settings_controller.dart';

final notificationControllerProvider = Provider((ref) => NotificationController(ref));

class NotificationController {
  final Ref ref;

  NotificationController(this.ref);

  Future<void> testNotification() => NotificationEngine.testNotification();
  
  Future<void> setSmartNotificationsEnabled(bool enabled) => NotificationEngine.setSmartNotificationsEnabled(enabled);
  
  Future<void> setHideSensitiveContent(bool hide) async {
    final settings = ref.read(settingsControllerProvider);
    await ref.read(settingsControllerProvider.notifier).updateNotificationSettings(
      settings.notificationSettings.copyWith(showSensitiveDetails: !hide),
    );
  }
}
