import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shared_prefs_provider.dart';

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
  static const _keySmartEnabled = 'notification_smart_enabled';
  static const _keyEnabled = 'notification_quiet_hours_enabled';
  static const _keyStart = 'notification_quiet_hours_start';
  static const _keyStartMinute = 'notification_quiet_hours_start_minute';
  static const _keyEnd = 'notification_quiet_hours_end';
  static const _keyEndMinute = 'notification_quiet_hours_end_minute';
  static const _keyShowSensitive = 'notification_show_sensitive_details';

  @override
  NotificationSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return NotificationSettings(
      smartNotificationsEnabled: prefs.getBool(_keySmartEnabled) ?? true,
      quietHoursEnabled: prefs.getBool(_keyEnabled) ?? false,
      quietHoursStart: prefs.getInt(_keyStart) ?? 22,
      quietHoursStartMinute: prefs.getInt(_keyStartMinute) ?? 0,
      quietHoursEnd: prefs.getInt(_keyEnd) ?? 8,
      quietHoursEndMinute: prefs.getInt(_keyEndMinute) ?? 0,
      showSensitiveDetails: prefs.getBool(_keyShowSensitive) ?? false,
    );
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_keySmartEnabled, settings.smartNotificationsEnabled);
    await prefs.setBool(_keyEnabled, settings.quietHoursEnabled);
    await prefs.setInt(_keyStart, settings.quietHoursStart);
    await prefs.setInt(_keyStartMinute, settings.quietHoursStartMinute);
    await prefs.setInt(_keyEnd, settings.quietHoursEnd);
    await prefs.setInt(_keyEndMinute, settings.quietHoursEndMinute);
    await prefs.setBool(_keyShowSensitive, settings.showSensitiveDetails);
    state = settings;
  }
}
