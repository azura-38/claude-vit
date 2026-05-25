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

  static const _medicineChannel = 'medicine_reminders_v2';
  static const _appointmentChannel = 'appointment_reminders_v2';
  static const _smartChannel = 'smart_engagement_v2';

  static Future<void> Function(ReceivedAction)? _onActionReceivedCallback;

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if (_onActionReceivedCallback != null) {
      await _onActionReceivedCallback!(receivedAction);
    }
  }

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

    final channels = [
      NotificationChannel(
        channelGroupKey: 'medical_group_v2',
        channelKey: _medicineChannel,
        channelName: 'Medicine Reminders',
        channelDescription: 'Notification channel for medication reminders',
        defaultColor: AppColors.medicalBlue,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        criticalAlerts: true,
        playSound: true,
        enableVibration: true,
      ),
      NotificationChannel(
        channelGroupKey: 'medical_group_v2',
        channelKey: _appointmentChannel,
        channelName: 'Appointment Reminders',
        channelDescription: 'Notification channel for appointments and plans',
        defaultColor: AppColors.medicalBlue,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
      ),
      NotificationChannel(
        channelGroupKey: 'system_group_v2',
        channelKey: _smartChannel,
        channelName: 'Smart Engagement',
        channelDescription: 'Smart behavioral and test notifications',
        defaultColor: AppColors.primaryIndigo,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
      ),
    ];

    final groups = [
      NotificationChannelGroup(channelGroupKey: 'medical_group_v2', channelGroupName: 'Health & Reminder Notifications'),
      NotificationChannelGroup(channelGroupKey: 'system_group_v2', channelGroupName: 'System Notifications'),
    ];

    try {
      await AwesomeNotifications().initialize(
        null,
        channels,
        channelGroups: groups,
        debug: true,
      );
      _isInitialized = true;
      debugPrint('[NotificationEngine] Core initialized with safe default icon ✅');
    } catch (e, st) {
      debugPrint('[NotificationEngine] Initialization failed: $e');
      debugPrintStack(stackTrace: st);
      _isInitialized = false;
    }
  }

  static Future<void> requestPermissions() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    debugPrint('[NotificationEngine] Permission allowed: ${await AwesomeNotifications().isNotificationAllowed()}');
  }

  static Future<void> initialize() async {
    await initializeCore();
    await requestPermissions();
  }

  static Future<void> startListening(Future<void> Function(ReceivedAction) onActionReceived) async {
    await _ensureReady();
    _onActionReceivedCallback = onActionReceived;
    await AwesomeNotifications().setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  static String _languageCode() => _prefs?.getString('app_locale') ?? 'en';

  static bool _isTurkish() => _languageCode().startsWith('tr');

  static String _label({required String tr, required String en}) => _isTurkish() ? tr : en;

  static String _translate(String key) {
    final lang = _languageCode();
    final value = Translations.data[lang]?[key] ?? Translations.data['en']?[key];
    if (value != null && value.isNotEmpty) return value;

    switch (key) {
      case 'notification_details_hidden':
        return _label(tr: 'Hatırlatma detayları gizlendi.', en: 'Reminder details are hidden.');
      case 'notif_test_body':
        return _label(tr: 'VitaCase test bildirimi başarıyla çalıştı.', en: 'VitaCase test notification is working.');
      case 'notif_bonus_ready':
        return _label(tr: 'Ödülün hazır.', en: 'Your reward is ready.');
      case 'notif_doc_safe':
        return _label(tr: 'Yeni kaydın güvenle saklandı.', en: 'Your new record is safely stored.');
      case 'smart_default':
        return _label(tr: 'Bugünkü kayıtlarını kontrol etmeyi unutma.', en: 'Do not forget to check your records today.');
      default:
        return key;
    }
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

  static Future<bool> _createNotificationSafe({
    required NotificationContent content,
    List<NotificationActionButton>? actionButtons,
    NotificationCalendar? schedule,
  }) async {
    try {
      final created = await AwesomeNotifications().createNotification(
        content: content,
        actionButtons: actionButtons,
        schedule: schedule,
      );
      debugPrint('[NotificationEngine] createNotification id=${content.id} channel=${content.channelKey} scheduled=${schedule != null} result=$created');
      return created;
    } catch (e, st) {
      debugPrint('[NotificationEngine] Failed to create notification id=${content.id}: $e');
      debugPrintStack(stackTrace: st);

      if (schedule != null && schedule.preciseAlarm == true) {
        debugPrint('[NotificationEngine] Retrying scheduled notification with preciseAlarm=false...');
        try {
          final fallbackSchedule = NotificationCalendar(
            era: schedule.era,
            year: schedule.year,
            month: schedule.month,
            day: schedule.day,
            hour: schedule.hour,
            minute: schedule.minute,
            second: schedule.second,
            weekday: schedule.weekday,
            weekOfYear: schedule.weekOfYear,
            timeZone: schedule.timeZone,
            repeats: schedule.repeats,
            allowWhileIdle: true,
            preciseAlarm: false,
          );
          final created = await AwesomeNotifications().createNotification(
            content: content,
            actionButtons: actionButtons,
            schedule: fallbackSchedule,
          );
          debugPrint('[NotificationEngine] fallback createNotification result=$created');
          return created;
        } catch (fallbackError, fallbackSt) {
          debugPrint('[NotificationEngine] Failed to create fallback notification: $fallbackError');
          debugPrintStack(stackTrace: fallbackSt);
          return false;
        }
      }
      return false;
    }
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
    await _createNotificationSafe(
      content: NotificationContent(
        id: notifId,
        channelKey: _medicineChannel,
        title: title,
        body: _safeText(body),
        payload: {'entityId': id, 'payload': payload ?? ''},
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
      ),
      actionButtons: [
        NotificationActionButton(key: 'MARK_DONE', label: _label(tr: 'Aldım', en: 'Taken'), actionType: ActionType.Default),
        NotificationActionButton(key: 'SKIP', label: _label(tr: 'Almadım', en: 'Not taken'), actionType: ActionType.Default, isDangerousOption: true),
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
    await _createNotificationSafe(
      content: NotificationContent(
        id: notifId,
        channelKey: _appointmentChannel,
        title: title,
        body: _safeText(body),
        payload: {'entityId': id, 'payload': payload ?? ''},
        category: NotificationCategory.Event,
        wakeUpScreen: true,
      ),
      actionButtons: [NotificationActionButton(key: 'OPEN_APPOINTMENT', label: _label(tr: 'Aç', en: 'Open'), actionType: ActionType.Default)],
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

    await _createNotificationSafe(
      content: NotificationContent(
        id: getStableId('${messageKey}_${now.millisecondsSinceEpoch}'),
        channelKey: _smartChannel,
        title: 'VitaCase',
        body: _translate(messageKey),
        category: NotificationCategory.Promo,
      ),
    );
  }

  static Future<void> scheduleCloseReminder() async {
    await _ensureReady();
    if (!_canShowEngagement()) return;

    await _createNotificationSafe(
      content: NotificationContent(
        id: getStableId('smart_engagement_close'),
        channelKey: _smartChannel,
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
    final now = DateTime.now();
    await _createNotificationSafe(
      content: NotificationContent(
        id: getStableId('test_${now.millisecondsSinceEpoch}'),
        channelKey: _smartChannel,
        title: 'VitaCase ✅',
        body: _translate('notif_test_body'),
        category: NotificationCategory.Status,
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
