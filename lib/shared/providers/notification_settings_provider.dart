import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_preferences_controller.dart';

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      NotificationSettingsNotifier.new,
    );

class NotificationSettings {
  final bool smartNotificationsEnabled;
  final bool quietHoursEnabled;
  final int quietHoursStart; // 0-23
  final int quietHoursStartMinute; // 0-59
  final int quietHoursEnd; // 0-23
  final int quietHoursEndMinute; // 0-59
  final bool showSensitiveDetails;

  const NotificationSettings({
    this.smartNotificationsEnabled = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = 22, // 10 PM
    this.quietHoursStartMinute = 0,
    this.quietHoursEnd = 8, // 8 AM
    this.quietHoursEndMinute = 0,
    this.showSensitiveDetails = false,
  });

  NotificationSettings copyWith({
    bool? smartNotificationsEnabled,
    bool? quietHoursEnabled,
    int? quietHoursStart,
    int? quietHoursStartMinute,
    int? quietHoursEnd,
    int? quietHoursEndMinute,
    bool? showSensitiveDetails,
  }) {
    return NotificationSettings(
      smartNotificationsEnabled:
          smartNotificationsEnabled ?? this.smartNotificationsEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursStartMinute:
          quietHoursStartMinute ?? this.quietHoursStartMinute,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      quietHoursEndMinute: quietHoursEndMinute ?? this.quietHoursEndMinute,
      showSensitiveDetails: showSensitiveDetails ?? this.showSensitiveDetails,
    );
  }
}

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    final prefs = ref.watch(userPreferencesControllerProvider);
    return prefs.maybeWhen(
      data: (p) => p.notificationSettings,
      orElse: () => const NotificationSettings(),
    );
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    await ref.read(userPreferencesControllerProvider.notifier).updateNotifications(settings);
  }
}
