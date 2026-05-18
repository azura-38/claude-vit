import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/translations.dart';
import '../models/user_behavior.dart';

class SmartMessageEngine {
  static String get(UserBehavior user) {
    if (user.lastActiveDays >= 3) return 'smart_streak_warning';
    if (user.adsWatched >= 10) return 'smart_ad_reward';
    if (user.actionsCount >= 5) return 'smart_doc_bonus';
    return 'smart_default';
  }
}

class NotificationEngine {
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;
  static const _enabledKey = 'notification_smart_enabled';
  static const _lastEngagementKey = 'last_engagement_notif_time';
  static DateTime? _lastImmediateNotificationAt;
  static const Duration _immediateCooldown = Duration(seconds: 90);

  static Future<void> _ensureReady({bool requestPermission = false}) async {
    if (!_isInitialized) {
      await initializeCore();
    }
    _prefs ??= await SharedPreferences.getInstance();
    if (requestPermission) {
      await requestPermissions();
    }
  }

  static Future<void> initializeCore() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();

    await AwesomeNotifications().initialize(
      'resource://drawable/ic_notification',
      [
        NotificationChannel(
          channelGroupKey: 'medical_group',
          channelKey: 'medicine_reminders',
          channelName: 'Medicine Reminders',
          channelDescription: 'Notification channel for medication reminders',
          defaultColor: AppColors.medicalBlue,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelGroupKey: 'medical_group',
          channelKey: 'appointment_reminders',
          channelName: 'Appointment Reminders',
          channelDescription: 'Notification channel for appointments and plans',
          defaultColor: AppColors.medicalBlue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelGroupKey: 'system_group',
          channelKey: 'smart_engagement',
          channelName: 'Smart Engagement',
          channelDescription: 'Smart behavioral notifications',
          defaultColor: AppColors.primaryIndigo,
          ledColor: Colors.white,
          importance: NotificationImportance.Default,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(channelGroupKey: 'medical_group', channelGroupName: 'Health & Reminder Notifications'),
        NotificationChannelGroup(channelGroupKey: 'system_group', channelGroupName: 'System Notifications'),
      ],
      debug: true,
    );

    _isInitialized = true;
    debugPrint('[NotificationEngine] Core initialized ✅');
  }

  static Future<void> requestPermissions() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    debugPrint('[NotificationEngine] Permissions requested ✅');
  }

  static Future<void> initialize() async {
    await initializeCore();
    await requestPermissions();
  }

  static Future<void> startListening(Future<void> Function(ReceivedAction) onActionReceived) async {
    await _ensureReady();
    await AwesomeNotifications().setListeners(onActionReceivedMethod: onActionReceived);
  }

  static String _translate(String key) {
    final lang = _prefs?.getString('app_locale') ?? 'en';
    return Translations.data[lang]?[key] ?? Translations.data['en']?[key] ?? key;
  }

  static String _safeText(String text) {
    final hide = _prefs?.getBool('notification_hide_sensitive_content') ?? true;
    if (hide) return _translate('notification_details_hidden');
    return text;
  }

  static int getStableId(String id, [DateTime? date]) {
    final key = date != null ? '${id}_${date.millisecondsSinceEpoch}' : id;
    int hash = 0x811c9dc5;
    for (int i = 0; i < key.length; i++) {
      hash ^= key.codeUnitAt(i);
      hash *= 0x01000193;
      hash &= 0xFFFFFFFF;
    }
    return hash.abs() & 0x7FFFFFFF;
  }

  static Future<void> scheduleMedicine({
    required String id,
    required String title,
    required String body,
    required DateTime scheduleTime,
    String? payload,
  }) async {
    await _ensureReady(requestPermission: true);
    if (scheduleTime.isBefore(DateTime.now())) return;
    final notifId = getStableId(id, scheduleTime);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notifId,
        channelKey: 'medicine_reminders',
        title: title,
        body: _safeText(body),
        payload: {'entityId': id, 'payload': payload ?? ''},
        category: NotificationCategory.Reminder,
        fullScreenIntent: true,
        wakeUpScreen: true,
      ),
      actionButtons: [
        NotificationActionButton(key: 'MARK_DONE', label: 'Taken', actionType: ActionType.Default),
        NotificationActionButton(key: 'SKIP', label: 'Skip', actionType: ActionType.Default, isDangerousOption: true),
      ],
      schedule: NotificationCalendar.fromDate(date: scheduleTime, preciseAlarm: true, allowWhileIdle: true),
    );
  }

  static Future<void> scheduleAppointment({
    required String id,
    required String title,
    required String body,
    required DateTime scheduleTime,
    String? payload,
  }) async {
    await _ensureReady(requestPermission: true);
    if (scheduleTime.isBefore(DateTime.now())) return;
    final notifId = getStableId(id, scheduleTime);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notifId,
        channelKey: 'appointment_reminders',
        title: title,
        body: _safeText(body),
        payload: {'entityId': id, 'payload': payload ?? ''},
        category: NotificationCategory.Event,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduleTime, preciseAlarm: true, allowWhileIdle: true),
    );
  }

  static Future<void> showSmartNow(String messageKey) async {
    await _ensureReady(requestPermission: true);
    final isEnabled = _prefs?.getBool(_enabledKey) ?? true;
    if (!isEnabled) return;

    final now = DateTime.now();
    if (_lastImmediateNotificationAt != null && now.difference(_lastImmediateNotificationAt!) < _immediateCooldown) return;

    _lastImmediateNotificationAt = now;
    await _updateLastEngagement();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: getStableId(messageKey),
        channelKey: 'smart_engagement',
        title: 'VitaCase',
        body: _translate(messageKey),
        category: NotificationCategory.Promo,
      ),
    );
  }

  static Future<void> scheduleCloseReminder() async {
    await _ensureReady();
    if (!_canShowEngagement()) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: getStableId('smart_engagement_close'),
        channelKey: 'smart_engagement',
        title: 'VitaCase',
        body: _translate('smart_default'),
        category: NotificationCategory.Promo,
      ),
      schedule: NotificationCalendar.fromDate(date: DateTime.now().add(const Duration(hours: 6)), preciseAlarm: true, allowWhileIdle: true),
    );
    await _updateLastEngagement();
  }

  static Future<void> testNotification() async {
    await _ensureReady(requestPermission: true);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 9998,
        channelKey: 'smart_engagement',
        title: 'VitaCase ✅',
        body: _translate('notif_test_body'),
        category: NotificationCategory.Promo,
      ),
    );
  }

  static Future<void> setSmartNotificationsEnabled(bool value) async {
    await _ensureReady();
    await _prefs?.setBool(_enabledKey, value);
  }

  static bool _canShowEngagement() {
    final lastTime = _prefs?.getInt(_lastEngagementKey);
    if (lastTime == null) return true;
    final lastEngagementAt = DateTime.fromMillisecondsSinceEpoch(lastTime);
    return DateTime.now().difference(lastEngagementAt).inHours >= 24;
  }

  static Future<void> _updateLastEngagement() async {
    await _prefs?.setInt(_lastEngagementKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> cancel(String id, [DateTime? date]) async {
    await _ensureReady();
    await AwesomeNotifications().cancel(getStableId(id, date));
  }

  static Future<void> cancelAll() async {
    await _ensureReady();
    await AwesomeNotifications().cancelAll();
  }
}

class NotificationTriggers {
  static void onAppOpen(UserBehavior user) {
    if (user.lastActiveDays >= 2) {
      NotificationEngine.showSmartNow(SmartMessageEngine.get(user));
    }
  }

  static void onAdWatched() {
    NotificationEngine.showSmartNow('notif_bonus_ready');
  }

  static void onDataAdded() {
    NotificationEngine.showSmartNow('notif_doc_safe');
  }

  static void onAppClose() {
    NotificationEngine.scheduleCloseReminder().catchError((e) => debugPrint('Schedule error: $e'));
  }
}
