import 'dart:async';
import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/l10n/translations.dart';
import '../../../../core/notifications/app_notification_payload.dart';
import '../../../../core/types/runtime_types.dart';
import '../models/user_behavior.dart';

class SmartMessageEngine {
  static String get(UserBehavior user) {
    if (user.lastActiveDays >= 3) return 'smart_streak_warning';
    if (user.adsWatched >= 10) return 'smart_ad_reward';
    if (user.actionsCount >= 5) return 'smart_doc_bonus';
    return 'smart_default';
  }
}

class PendingNotificationRequest {
  final int id;
  final String? payload;
  const PendingNotificationRequest({required this.id, this.payload});
}

abstract class AwesomeNotificationsClient {
  Future<bool> initialize(
    String? defaultIcon,
    List<NotificationChannel> channels, {
    List<NotificationChannelGroup>? channelGroups,
    bool debug = false,
  });

  Future<bool> isNotificationAllowed();

  Future<bool> requestPermissionToSendNotifications({
    String? channelKey,
    List<NotificationPermission> permissions,
  });

  Future<bool> createNotification({
    required NotificationContent content,
    NotificationCalendar? schedule,
    List<NotificationActionButton>? actionButtons,
  });

  Future<void> cancel(int id);

  Future<void> cancelAll();

  Future<List<NotificationModel>> listScheduledNotifications();

  Future<void> setListeners({
    required Future<void> Function(ReceivedAction) onActionReceivedMethod,
  });

  Future<String> getLocalTimeZoneIdentifier();
}

class DefaultAwesomeNotificationsClient implements AwesomeNotificationsClient {
  final AwesomeNotifications _awesome = AwesomeNotifications();

  @override
  Future<bool> initialize(
    String? defaultIcon,
    List<NotificationChannel> channels, {
    List<NotificationChannelGroup>? channelGroups,
    bool debug = false,
  }) {
    return _awesome.initialize(
      defaultIcon,
      channels,
      channelGroups: channelGroups,
      debug: debug,
    );
  }

  @override
  Future<bool> isNotificationAllowed() {
    return _awesome.isNotificationAllowed();
  }

  @override
  Future<bool> requestPermissionToSendNotifications({
    String? channelKey,
    List<NotificationPermission> permissions = const [
      NotificationPermission.Alert,
      NotificationPermission.Sound,
      NotificationPermission.Badge,
      NotificationPermission.Vibration,
      NotificationPermission.Light,
    ],
  }) {
    return _awesome.requestPermissionToSendNotifications(
      channelKey: channelKey,
      permissions: permissions,
    );
  }

  @override
  Future<bool> createNotification({
    required NotificationContent content,
    NotificationCalendar? schedule,
    List<NotificationActionButton>? actionButtons,
  }) {
    return _awesome.createNotification(
      content: content,
      schedule: schedule,
      actionButtons: actionButtons,
    );
  }

  @override
  Future<void> cancel(int id) {
    return _awesome.cancel(id);
  }

  @override
  Future<void> cancelAll() {
    return _awesome.cancelAll();
  }

  @override
  Future<List<NotificationModel>> listScheduledNotifications() {
    return _awesome.listScheduledNotifications();
  }

  @override
  Future<void> setListeners({
    required Future<void> Function(ReceivedAction) onActionReceivedMethod,
  }) {
    return _awesome.setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  @override
  Future<String> getLocalTimeZoneIdentifier() {
    return _awesome.getLocalTimeZoneIdentifier();
  }
}

class NotificationEngine {
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;
  static const _enabledKey = 'notification_smart_enabled';
  static const _fullScreenKey = 'notification_full_screen_intent';
  static const _lastEngagementKey = 'last_engagement_notif_time';
  static DateTime? _lastImmediateNotificationAt;
  static const Duration _immediateCooldown = Duration(seconds: 90);

  static const _medicineChannel = 'medicine_reminders_v2';
  static const _appointmentChannel = 'appointment_reminders_v2';
  static const _smartChannel = 'smart_engagement_v2';

  static AwesomeNotificationsClient _client = DefaultAwesomeNotificationsClient();

  static Future<void> Function(ReceivedAction)? _onActionReceivedCallback;
  static Future<void> Function(String id)? _onMedicineTaken;
  static Future<void> Function(String id)? _onMedicineSkipped;
  static void Function(String payload)? _onRoute;

  static final NotificationEngine instance = NotificationEngine();

  static bool get isInitialized => _isInitialized;

  static bool _isTimezoneInitialized = false;
  static String _canonicalTimeZone = 'Europe/Istanbul';

  static String getCanonicalTimeZone() => _canonicalTimeZone;

  @visibleForTesting
  static void setCanonicalTimeZoneForTesting(String tzName) {
    _canonicalTimeZone = tzName;
  }

  static bool get isTimezoneInitialized => _isTimezoneInitialized;

  @visibleForTesting
  static void resetForTesting() {
    _isInitialized = false;
    _isTimezoneInitialized = false;
    _canonicalTimeZone = 'Europe/Istanbul';
    _prefs = null;
    _client = DefaultAwesomeNotificationsClient();
    _onActionReceivedCallback = null;
    _onMedicineTaken = null;
    _onMedicineSkipped = null;
    _onRoute = null;
    _lastImmediateNotificationAt = null;
  }

  @visibleForTesting
  static void setClientForTesting(AwesomeNotificationsClient client) {
    _client = client;
  }

  @visibleForTesting
  static void setPrefsForTesting(SharedPreferences prefs) {
    _prefs = prefs;
  }

  static Future<void> ensureTimezoneInitialized() async {
    if (_isTimezoneInitialized) return;
    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('[NotificationEngine] Timezone db init warning: $e');
    }

    String? detected;
    try {
      detected = await _client.getLocalTimeZoneIdentifier();
    } catch (_) {}

    if (detected == null || detected.isEmpty || !_isValidIanaTimeZone(detected)) {
      try {
        detected = await FlutterTimezone.getLocalTimezone();
      } catch (_) {}
    }

    detected = _normalizeTimeZoneName(detected);

    try {
      if (tz.timeZoneDatabase.locations.containsKey(detected)) {
        tz.setLocalLocation(tz.getLocation(detected));
        _canonicalTimeZone = detected;
      } else {
        tz.setLocalLocation(tz.UTC);
        _canonicalTimeZone = 'UTC';
      }
    } catch (_) {
      try {
        final _ = tz.local;
        _canonicalTimeZone = tz.local.name;
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
        _canonicalTimeZone = 'UTC';
      }
    }

    _isTimezoneInitialized = true;
    debugPrint('[NotificationEngine] Timezone initialized: $_canonicalTimeZone ✅');
  }

  static bool _isValidIanaTimeZone(String name) {
    if (name.isEmpty) return false;
    if (name.contains(' ') || name.contains('Standart') || name.contains('Standard')) {
      return false;
    }
    return tz.timeZoneDatabase.locations.containsKey(name);
  }

  static String _normalizeTimeZoneName(String? name) {
    if (name == null || name.isEmpty) return 'Europe/Istanbul';
    final trimmed = name.trim();
    if (trimmed == 'Türkiye Standart Saati' ||
        trimmed == 'Turkey Standard Time' ||
        trimmed == 'TRT' ||
        trimmed == '+03' ||
        trimmed == 'GMT+3' ||
        trimmed == 'GMT+03:00') {
      return 'Europe/Istanbul';
    }
    if (tz.timeZoneDatabase.locations.containsKey(trimmed)) {
      return trimmed;
    }
    return 'Europe/Istanbul';
  }

  static NotificationCalendar createCalendarSchedule({
    required DateTime date,
    bool preciseAlarm = true,
    bool allowWhileIdle = true,
    bool repeats = false,
  }) {
    // Critical Rule: User input is local wall-clock time.
    // If date has isUtc == true, convert to local wall clock time.
    final local = date.isUtc ? date.toLocal() : date;
    final tzName = getCanonicalTimeZone();

    return NotificationCalendar(
      year: local.year,
      month: local.month,
      day: local.day,
      hour: local.hour,
      minute: local.minute,
      second: local.second,
      millisecond: 0,
      timeZone: tzName,
      preciseAlarm: preciseAlarm,
      allowWhileIdle: allowWhileIdle,
      repeats: repeats,
    );
  }

  static void setMedicineActionHandlers({
    required Future<void> Function(String id) onTaken,
    required Future<void> Function(String id) onSkipped,
  }) {
    _onMedicineTaken = onTaken;
    _onMedicineSkipped = onSkipped;
  }

  static void setRouteHandler(void Function(String payload) handler) {
    _onRoute = handler;
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    try {
      if (_onActionReceivedCallback != null) {
        await _onActionReceivedCallback!(receivedAction);
      }

      final payload = receivedAction.payload?['payload'];
      if (payload != null && payload.isNotEmpty && _onRoute != null) {
        _onRoute!(payload);
      }

      final entityId = receivedAction.payload?['entityId'];
      if (entityId != null && entityId.isNotEmpty) {
        final btn = receivedAction.buttonKeyPressed;
        if ((btn == 'MARK_DONE' || btn == 'TAKEN') && _onMedicineTaken != null) {
          await _onMedicineTaken!(entityId);
        } else if ((btn == 'SKIP' || btn == 'SKIPPED') && _onMedicineSkipped != null) {
          await _onMedicineSkipped!(entityId);
        }
      }
    } catch (e) {
      debugPrint('[NotificationEngine] Safe error in onActionReceivedMethod: $e');
    }
  }

  static Future<void> _ensureReady({bool requestPermission = false}) async {
    await ensureTimezoneInitialized();
    if (!_isInitialized) {
      await initializeCore();
    }
    _prefs ??= await SharedPreferences.getInstance();
    if (requestPermission) {
      await requestPermissions();
    }
  }

  static Future<void> initializeCore() async {
    await ensureTimezoneInitialized();
    if (_isInitialized) return;
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (_) {}

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
      await _client.initialize(
        null,
        channels,
        channelGroups: groups,
        debug: kDebugMode,
      );
      await _client.setListeners(onActionReceivedMethod: onActionReceivedMethod);
      _isInitialized = true;
      debugPrint('[NotificationEngine] Core initialized with safe default icon ✅');
    } catch (e, st) {
      debugPrint('[NotificationEngine] Initialization failed safely: $e');
      debugPrintStack(stackTrace: st);
      _isInitialized = true;
    }
  }

  static Future<void> initCore() => initializeCore();

  static Future<NotificationPermissionState> requestPermissions({bool requestExactAlarm = false}) async {
    try {
      await _ensureReady();
      final isAllowed = await _client.isNotificationAllowed();
      final useFullScreen = _prefs?.getBool(_fullScreenKey) ?? false;
      if (!isAllowed) {
        final permissions = [
          if (useFullScreen) NotificationPermission.FullScreenIntent,
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
        ];
        final granted = await _client.requestPermissionToSendNotifications(permissions: permissions);
        return granted ? NotificationPermissionState.granted : NotificationPermissionState.denied;
      }
      return NotificationPermissionState.granted;
    } catch (e) {
      debugPrint('[NotificationEngine] Permission request error: $e');
      return NotificationPermissionState.denied;
    }
  }

  static Future<NotificationPermissionState> checkPermissionStatus() async {
    try {
      await _ensureReady();
      final isAllowed = await _client.isNotificationAllowed();
      return isAllowed ? NotificationPermissionState.granted : NotificationPermissionState.denied;
    } catch (_) {
      return NotificationPermissionState.denied;
    }
  }

  static Future<bool> isPermissionGranted() async {
    return (await checkPermissionStatus()) == NotificationPermissionState.granted;
  }

  static Future<void> initialize() async {
    await initializeCore();
    await requestPermissions();
  }

  static Future<void> startListening([Future<void> Function(ReceivedAction)? onActionReceived]) async {
    await _ensureReady();
    if (onActionReceived != null) {
      _onActionReceivedCallback = onActionReceived;
    }
    await _client.setListeners(onActionReceivedMethod: onActionReceivedMethod);
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

  static String safeText(String text) {
    final hide = _prefs?.getBool('notification_hide_sensitive_content') ?? true;
    if (hide) return _translate('notification_details_hidden');
    return text;
  }

  static String safeMedicationBodyStatic(String name) => safeText(name);
  static String safeAppointmentBodyStatic(String titleOrDoctor) => safeText(titleOrDoctor);

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
      final created = await _client.createNotification(
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
          final created = await _client.createNotification(
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

  static Future<void> scheduleMedication({
    required String id,
    required String title,
    required String body,
    required DateTime date,
    int? explicitId,
    AppNotificationPayload? payload,
    String? stringPayload,
  }) async {
    try {
      await _ensureReady();
      final local = date.isUtc ? date.toLocal() : date;
      if (local.isBefore(DateTime.now())) return;
      final notifId = explicitId ?? getStableId(id, local);
      final useFullScreen = _prefs?.getBool(_fullScreenKey) ?? false;
      final encodedPayload = payload?.encode() ?? stringPayload ?? '';

      await _createNotificationSafe(
        content: NotificationContent(
          id: notifId,
          channelKey: _medicineChannel,
          title: title,
          body: safeText(body),
          payload: {
            'entityId': id,
            'payload': encodedPayload,
          },
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          fullScreenIntent: useFullScreen,
        ),
        actionButtons: [
          NotificationActionButton(key: 'MARK_DONE', label: _label(tr: 'Aldım', en: 'Taken'), actionType: ActionType.Default),
          NotificationActionButton(key: 'SKIP', label: _label(tr: 'Almadım', en: 'Not taken'), actionType: ActionType.Default, isDangerousOption: true),
        ],
        schedule: createCalendarSchedule(date: local, preciseAlarm: true, allowWhileIdle: true),
      );
    } catch (e) {
      debugPrint('[NotificationEngine] Safe error in scheduleMedication: $e');
    }
  }

  static Future<void> scheduleMedicine({
    required String id,
    required String title,
    required String body,
    required DateTime scheduleTime,
    String? payload,
    int? explicitId,
  }) =>
      scheduleMedication(
        id: id,
        title: title,
        body: body,
        date: scheduleTime,
        explicitId: explicitId,
        stringPayload: payload,
      );

  static Future<void> scheduleAppointment({
    required String id,
    required String title,
    required String body,
    DateTime? date,
    DateTime? scheduleTime,
    int? explicitId,
    AppNotificationPayload? payload,
    String? stringPayload,
  }) async {
    try {
      final targetDate = date ?? scheduleTime;
      if (targetDate == null) return;
      final local = targetDate.isUtc ? targetDate.toLocal() : targetDate;
      if (local.isBefore(DateTime.now())) return;
      await _ensureReady();
      final notifId = explicitId ?? getStableId(id, local);
      final useFullScreen = _prefs?.getBool(_fullScreenKey) ?? false;
      final encodedPayload = payload?.encode() ?? stringPayload ?? '';

      await _createNotificationSafe(
        content: NotificationContent(
          id: notifId,
          channelKey: _appointmentChannel,
          title: title,
          body: safeText(body),
          payload: {
            'entityId': id,
            'payload': encodedPayload,
          },
          category: NotificationCategory.Event,
          wakeUpScreen: true,
          fullScreenIntent: useFullScreen,
        ),
        actionButtons: [
          NotificationActionButton(key: 'OPEN_APPOINTMENT', label: _label(tr: 'Aç', en: 'Open'), actionType: ActionType.Default),
        ],
        schedule: createCalendarSchedule(date: local, preciseAlarm: true, allowWhileIdle: true),
      );
    } catch (e) {
      debugPrint('[NotificationEngine] Safe error in scheduleAppointment: $e');
    }
  }

  static Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    try {
      await _ensureReady();
      final scheduled = await _client.listScheduledNotifications();
      return scheduled.map((m) {
        final id = m.content?.id ?? 0;
        final payload = m.content?.payload?['payload'];
        return PendingNotificationRequest(id: id, payload: payload);
      }).toList();
    } catch (e) {
      debugPrint('[NotificationEngine] getPendingNotificationRequests error: $e');
      return [];
    }
  }

  static Future<void> showSmartNow(String messageKey) async {
    await _ensureReady();
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
      schedule: createCalendarSchedule(date: DateTime.now().add(const Duration(hours: 6)), preciseAlarm: true, allowWhileIdle: true),
    );
    await _updateLastEngagement();
  }

  static Future<void> testNotification() async {
    await _ensureReady();
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

  static Future<void> setFullScreenRemindersEnabled(bool value) async {
    await _ensureReady();
    await _prefs?.setBool(_fullScreenKey, value);
    if (value) {
      await _client.requestPermissionToSendNotifications(
        permissions: [
          NotificationPermission.FullScreenIntent,
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
        ],
      );
    }
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

  static const int engagementNotificationId = 900100;
  static const String _engagementEnabledKey = 'engagementNotificationsEnabled';
  static const String _engagementCategoriesKey = 'last_engagement_categories';
  static const String _engagementDayKey = 'last_scheduled_engagement_day';

  static bool _isInQuietHours(int hour, int minute) {
    final quietEnabled = _prefs?.getBool('quietHoursEnabled') ?? false;
    if (!quietEnabled) {
      return hour >= 21 || hour < 9;
    }
    final qStartHour = _prefs?.getInt('quietHoursStart') ?? 22;
    final qStartMin = _prefs?.getInt('quietHoursStartMinute') ?? 0;
    final qEndHour = _prefs?.getInt('quietHoursEnd') ?? 8;
    final qEndMin = _prefs?.getInt('quietHoursEndMinute') ?? 0;

    final pickedMinutes = hour * 60 + minute;
    final startMinutes = qStartHour * 60 + qStartMin;
    final endMinutes = qEndHour * 60 + qEndMin;

    if (startMinutes < endMinutes) {
      return pickedMinutes >= startMinutes && pickedMinutes <= endMinutes;
    } else {
      return pickedMinutes >= startMinutes || pickedMinutes <= endMinutes;
    }
  }

  static Future<void> cancelEngagementNotifications() async {
    await _ensureReady();
    await _client.cancel(engagementNotificationId);
  }

  static Future<void> scheduleDailyEngagementNotification() async {
    await _ensureReady();

    final isAllowed = await _client.isNotificationAllowed();
    if (!isAllowed) {
      debugPrint('[NotificationEngine] Cannot schedule engagement: permissions not allowed.');
      return;
    }

    final isEnabled = _prefs?.getBool(_engagementEnabledKey) ?? true;
    if (!isEnabled) {
      debugPrint('[NotificationEngine] Cannot schedule engagement: user disabled them.');
      return;
    }

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowStr = "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";

    final lastScheduledDay = _prefs?.getString(_engagementDayKey);
    if (lastScheduledDay == tomorrowStr) {
      debugPrint('[NotificationEngine] Engagement notification already scheduled for tomorrow ($tomorrowStr).');
      return;
    }

    final List<String> lastCategories = _prefs?.getStringList(_engagementCategoriesKey) ?? [];
    final categories = ['health_check', 'theme_discovery', 'vault_organization'];
    final available = List<String>.from(categories);
    if (lastCategories.length >= 2 && lastCategories[0] == lastCategories[1]) {
      available.remove(lastCategories[0]);
    }

    final rand = Random();
    available.shuffle(rand);
    final chosenCategory = available.first;

    final newCategories = [chosenCategory, ...lastCategories];
    if (newCategories.length > 5) {
      newCategories.removeRange(5, newCategories.length);
    }
    await _prefs?.setStringList(_engagementCategoriesKey, newCategories);

    final isTr = _isTurkish();
    final title = 'VitaCase';
    String body = '';
    String route = '';

    if (chosenCategory == 'health_check') {
      route = AppRoutes.home;
      final messagesTr = [
        'Bugün sağlık planını kontrol ettin mi?',
        'İlaçlarını, randevularını ve belgelerini hızlıca gözden geçir.',
        'VitaCase seni bekliyor: Bugünkü sağlık notlarını kontrol et.',
        'Randevuların ve ilaç hatırlatmaların güncel mi?'
      ];
      final messagesEn = [
        'Have you checked your health plan today?',
        'Review your medications, appointments, and documents.',
        'VitaCase is ready: check today’s health notes.',
        'Are your appointments and medication reminders up to date?'
      ];
      final list = isTr ? messagesTr : messagesEn;
      body = list[rand.nextInt(list.length)];
    } else if (chosenCategory == 'theme_discovery') {
      route = AppRoutes.settingsTheme;
      final messagesTr = [
        'Bugün VitaCase görünümünü yenilemek ister misin?',
        'Yeni bir tema ile sağlık kasanı kişiselleştir.',
        'VitaCase tarzını değiştir: temaları keşfet.',
        'Sana uygun sakin bir tema seçmeye ne dersin?'
      ];
      final messagesEn = [
        'Want to refresh your VitaCase look today?',
        'Personalize your health vault with a new theme.',
        'Change your VitaCase style: explore themes.',
        'How about choosing a calmer theme today?'
      ];
      final list = isTr ? messagesTr : messagesEn;
      body = list[rand.nextInt(list.length)];
    } else if (chosenCategory == 'vault_organization') {
      route = AppRoutes.documents;
      final messagesTr = [
        'Önemli sağlık belgelerin düzenli mi?',
        'Sağlık kasanı kısa bir kontrolle güncel tut.',
        'Belgelerine hızlıca göz atmak ister misin?',
        'Acil durumda ihtiyaç duyabileceğin bilgileri hazır tut.'
      ];
      final messagesEn = [
        'Are your important health documents organized?',
        'Keep your health vault up to date with a quick check.',
        'Want to take a quick look at your documents?',
        'Keep the information you may need in an emergency ready.'
      ];
      final list = isTr ? messagesTr : messagesEn;
      body = list[rand.nextInt(list.length)];
    }

    int hour = 12;
    int minute = 0;
    for (int i = 0; i < 50; i++) {
      final totalMinutes = 600 + rand.nextInt(630); // 10:00 is 600 minutes
      final tempHour = totalMinutes ~/ 60;
      final tempMin = totalMinutes % 60;
      if (!_isInQuietHours(tempHour, tempMin)) {
        hour = tempHour;
        minute = tempMin;
        break;
      }
    }

    final scheduleTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, hour, minute);

    await _createNotificationSafe(
      content: NotificationContent(
        id: engagementNotificationId,
        channelKey: _smartChannel,
        title: title,
        body: body,
        category: NotificationCategory.Promo,
        payload: {
          'payload': AppNotificationPayload(
            type: NotificationType.engagement,
            entityId: chosenCategory,
            route: route,
            occurrenceAt: scheduleTime,
          ).encode(),
        },
      ),
      schedule: createCalendarSchedule(date: scheduleTime, allowWhileIdle: true, preciseAlarm: false),
    );

    await _prefs?.setString(_engagementDayKey, tomorrowStr);
    debugPrint('[NotificationEngine] Scheduled engagement notification at $scheduleTime, category: $chosenCategory');
  }

  static Future<void> testScheduleEngagementIn1Minute() async {
    await _ensureReady();
    final now = DateTime.now();
    final scheduleTime = now.add(const Duration(minutes: 1));
    final categories = ['health_check', 'theme_discovery', 'vault_organization'];
    final rand = Random();
    final chosenCategory = categories[rand.nextInt(categories.length)];
    final isTr = _isTurkish();
    String body = '';
    String route = '';

    if (chosenCategory == 'health_check') {
      route = AppRoutes.home;
      body = isTr
          ? 'VitaCase seni bekliyor: Bugünkü sağlık notlarını kontrol et.'
          : 'VitaCase is ready: check today’s health notes.';
    } else if (chosenCategory == 'theme_discovery') {
      route = AppRoutes.settingsTheme;
      body = isTr
          ? 'VitaCase tarzını değiştir: temaları keşfet.'
          : 'Change your VitaCase style: explore themes.';
    } else {
      route = AppRoutes.documents;
      body = isTr
          ? 'Acil durumda ihtiyaç duyabileceğin bilgileri hazır tut.'
          : 'Keep the information you may need in an emergency ready.';
    }

    await _createNotificationSafe(
      content: NotificationContent(
        id: engagementNotificationId,
        channelKey: _smartChannel,
        title: 'VitaCase Test (1 min)',
        body: body,
        category: NotificationCategory.Promo,
        payload: {
          'payload': AppNotificationPayload(
            type: NotificationType.engagement,
            entityId: chosenCategory,
            route: route,
            occurrenceAt: scheduleTime,
          ).encode(),
        },
      ),
      schedule: createCalendarSchedule(date: scheduleTime, allowWhileIdle: true, preciseAlarm: false),
    );
    debugPrint('[NotificationEngine] Scheduled test engagement notification in 1 minute at $scheduleTime');
  }

  static Future<void> testSendEngagementNow() async {
    await _ensureReady();
    final now = DateTime.now();
    final categories = ['health_check', 'theme_discovery', 'vault_organization'];
    final rand = Random();
    final chosenCategory = categories[rand.nextInt(categories.length)];
    final isTr = _isTurkish();
    String body = '';
    String route = '';

    if (chosenCategory == 'health_check') {
      route = AppRoutes.home;
      body = isTr
          ? 'Bugün sağlık planını kontrol ettin mi?'
          : 'Have you checked your health plan today?';
    } else if (chosenCategory == 'theme_discovery') {
      route = AppRoutes.settingsTheme;
      body = isTr
          ? 'Yeni bir tema ile sağlık kasanı kişiselleştir.'
          : 'Personalize your health vault with a new theme.';
    } else {
      route = AppRoutes.documents;
      body = isTr
          ? 'Önemli sağlık belgelerin düzenli mi?'
          : 'Are your important health documents organized?';
    }

    await _createNotificationSafe(
      content: NotificationContent(
        id: getStableId('test_now_${now.millisecondsSinceEpoch}'),
        channelKey: _smartChannel,
        title: 'VitaCase (Now)',
        body: body,
        category: NotificationCategory.Promo,
        payload: {
          'payload': AppNotificationPayload(
            type: NotificationType.engagement,
            entityId: chosenCategory,
            route: route,
            occurrenceAt: now,
          ).encode(),
        },
      ),
    );
    debugPrint('[NotificationEngine] Dispatched test engagement notification immediately.');
  }

  static Future<void> cancelById(int id) async {
    try {
      await _ensureReady();
      await _client.cancel(id);
    } catch (e) {
      debugPrint('[NotificationEngine] Safe cancelById error: $e');
    }
  }

  static Future<void> cancel(String id, [DateTime? date]) async {
    try {
      await _ensureReady();
      await _client.cancel(getStableId(id, date));
    } catch (e) {
      debugPrint('[NotificationEngine] Safe cancel error: $e');
    }
  }

  static Future<void> cancelAll() async {
    try {
      await _ensureReady();
      await _client.cancelAll();
    } catch (e) {
      debugPrint('[NotificationEngine] Safe cancelAll error: $e');
    }
  }

  static Future<bool> show({
    required int id,
    required String title,
    required String body,
    String channelId = _smartChannel,
    String channelName = 'VitaCase Notifications',
    String? payload,
  }) async {
    await _ensureReady();
    return _createNotificationSafe(
      content: NotificationContent(
        id: id,
        channelKey: channelId,
        title: title,
        body: safeText(body),
        payload: payload != null ? {'payload': payload} : null,
      ),
    );
  }

  Future<void> cancelNotification(int id) async => cancelById(id);


  Future<void> showLimitReachedPush() async => show(
    id: 9993,
    title: 'Limit!',
    body: 'Vault full!',
    channelId: _smartChannel,
  );

  // Instance methods for Provider<NotificationEngine>
  Future<NotificationPermissionState> requestPermissionsInstance({bool requestExactAlarm = false}) =>
      requestPermissions(requestExactAlarm: requestExactAlarm);

  Future<NotificationPermissionState> requestPlatformPermissions({bool requestExactAlarm = false}) =>
      requestPermissions(requestExactAlarm: requestExactAlarm);
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
