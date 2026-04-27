import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import '../../core/l10n/translations.dart';
import '../../core/types/runtime_types.dart';

class NotificationService {
  static NotificationService? _instance;
  static SharedPreferences? _prefs;
  static Future<void> Function(String id)? _onMedicineTaken;
  static Future<void> Function(String id)? _onMedicineSkipped;
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'vitacase_channel',
    'VitaCase Notifications',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    visibility: NotificationVisibility.private,
  );
  static const AndroidNotificationDetails _medicationAndroidDetails =
      AndroidNotificationDetails(
    'med_channel',
    'Medication',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    visibility: NotificationVisibility.private,
    actions: [
      AndroidNotificationAction('TAKEN', 'Taken'),
      AndroidNotificationAction('SKIPPED', 'Skipped'),
    ],
  );
  
  static bool _isInitialized = false;

  NotificationService(SharedPreferences prefs) {
    _prefs = prefs;
    _instance = this;
  }

  static void setMedicineActionHandlers({
    required Future<void> Function(String id) onTaken,
    required Future<void> Function(String id) onSkipped,
  }) {
    _onMedicineTaken = onTaken;
    _onMedicineSkipped = onSkipped;
  }

  static NotificationService? get instance => _instance;

  // 🔥 CORE INIT
  static Future<void> init() async {
    if (_isInitialized) return;
    _prefs ??= await SharedPreferences.getInstance();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: ios),
      onDidReceiveNotificationResponse: _onTap,
    );

    // 🔥 TIMEZONE
    tz.initializeTimeZones();
    try {
      final String name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 🔥 PERMISSIONS (Garantili Fix)
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    _isInitialized = true;
    if (kDebugMode) debugPrint("Notification Engine Initialized & Permissions Requested ✅");
  }

  // ⚡ INSTANCE METHODS
  Future<void> initialize() => NotificationService.init();

  String safeMedicationBody(String name) => NotificationService.safeMedicationBodyStatic(name);

  Future<void> setHideSensitiveContent(bool hide) async {
    await _prefs?.setBool('notification_hide_sensitive_content', hide);
  }

  Future<NotificationPermissionState> requestPermissions({bool requestExactAlarm = false}) async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ?? true;
    if (requestExactAlarm) await android?.requestExactAlarmsPermission();
    return granted ? NotificationPermissionState.granted : NotificationPermissionState.denied;
  }

  // 🔔 STATIC METHODS (Positional Argument Fix for v21.0.0)
  static int getStableIdStatic(String uuid, [int offset = 0]) {
    int hash = 0x811c9dc5;
    for (int i = 0; i < uuid.length; i++) {
      hash ^= uuid.codeUnitAt(i); hash *= 0x01000193; hash &= 0xFFFFFFFF;
    }
    return ((hash.abs() ^ (offset * 0x01000193)) & 0x7FFFFFFF);
  }

  static String safeMedicationBodyStatic(String name) {
    final hide = _prefs?.getBool('notification_hide_sensitive_content') ?? true;
    if (hide) {
      final lang = _prefs?.getString('app_locale') ?? 'en';
      return Translations.data[lang]?['notification_details_hidden'] ?? Translations.data['en']?['notification_details_hidden'] ?? 'Details hidden';
    }
    return name;
  }

  static String buildKey(String id, DateTime date) {
    return "${id}_${date.millisecondsSinceEpoch}";
  }

  static Future<void> schedule({
    required String id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    await init();
    if (kDebugMode) debugPrint("Scheduling notification at: $date");
    final key = buildKey(id, date);
    final notifId = getStableIdStatic(key);

    await _plugin.zonedSchedule(
      notifId,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      const NotificationDetails(android: _androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: id,
    );
  }

  static Future<void> scheduleMedication({
    required String id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    await init();
    if (kDebugMode) debugPrint("Scheduling medication notification at: $date");
    final key = buildKey(id, date);
    final notifId = getStableIdStatic(key);

    await _plugin.zonedSchedule(
      notifId,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      const NotificationDetails(android: _medicationAndroidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: id,
    );
  }

  static Future<void> cancel(String id) async { await _plugin.cancel(id: getStableIdStatic(id)); }

  static Future<void> cancelOccurrence({
    required String id,
    required DateTime date,
  }) async {
    final key = buildKey(id, date);
    final notifId = getStableIdStatic(key);
    await _plugin.cancel(notifId);
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async { await _plugin.cancelAll(); }

  // 🎯 ENGAGEMENT (Instance)
  Future<void> showStreakWarning() async => showNotification(id: 9991, title: 'Streak!', body: 'Keep it up!', channelId: 'engagement', channelName: 'Engagement');
  Future<void> showMissionReminder() async => showNotification(id: 9992, title: 'Mission!', body: 'Daily tasks!', channelId: 'engagement', channelName: 'Engagement');
  Future<void> showLimitReachedPush() async => showNotification(id: 9993, title: 'Limit!', body: 'Vault full!', channelId: 'engagement', channelName: 'Engagement');

  Future<void> showNotification({required int id, required String title, required String body, required String channelId, required String channelName}) async {
    final android = AndroidNotificationDetails(channelId, channelName, importance: Importance.max, priority: Priority.high, icon: '@mipmap/ic_launcher', visibility: NotificationVisibility.private);
    await _plugin.show(id, title, body, notificationDetails: NotificationDetails(android: android));
  }

  static void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    if (response.actionId == 'TAKEN') {
      _onMedicineTaken?.call(payload);
    }

    if (response.actionId == 'SKIPPED') {
      _onMedicineSkipped?.call(payload);
    }
  }
}
