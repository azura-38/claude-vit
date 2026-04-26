import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/translations.dart';
import '../../core/types/runtime_types.dart';

class NotificationService {
  static NotificationService? _instance;
  static SharedPreferences? _prefs;
  static ProviderContainer? _container;
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;

  NotificationService(SharedPreferences prefs) {
    _prefs = prefs;
    _instance = this;
  }

  static void setContainer(ProviderContainer container) {
    _container = container;
  }

  static NotificationService? get instance => _instance;

  // 🔥 CORE INIT
  static Future<void> init() async {
    if (_isInitialized) return;
    _prefs ??= await SharedPreferences.getInstance();
    
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
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
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    _isInitialized = true;
    if (kDebugMode) debugPrint("Notification Engine Initialized & Permissions Requested ✅");
  }

  // ⚡ INSTANCE METHODS
  Future<void> initialize() => NotificationService.init();
  
  int getStableId(String uuid, [int offset = 0]) => NotificationService.getStableIdStatic(uuid, offset);

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

  // 🔔 SCHEDULING (Positional Argument Fix for v21.0.0)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    required String channelName,
    bool useExactAlarm = false,
  }) async {
    await NotificationService.init();
    
    final androidDetails = AndroidNotificationDetails(
      channelId, channelName, 
      importance: Importance.max, priority: Priority.high, icon: '@mipmap/ic_launcher'
    );

    await _plugin.zonedSchedule(
      id, title, body, 
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: useExactAlarm ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleMedicineReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    DateTimeComponents? matchComponents,
  }) async {
    await NotificationService.init();
    
    const androidDetails = AndroidNotificationDetails(
      'med_channel', 'Medication',
      importance: Importance.max, priority: Priority.high,
      actions: [
        AndroidNotificationAction('TAKEN', 'Taken', showsUserInterface: true),
        AndroidNotificationAction('SKIPPED', 'Skipped', showsUserInterface: true),
      ],
    );

    await _plugin.zonedSchedule(
      id, title, body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchComponents,
    );
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

  static Future<void> schedule({
    required String id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    await init();
    
    final androidDetails = AndroidNotificationDetails(
      'vitacase_channel', 'VitaCase Notifications',
      importance: Importance.max, priority: Priority.high, icon: '@mipmap/ic_launcher'
    );

    await _plugin.zonedSchedule(
      getStableIdStatic(id), title, body,
      tz.TZDateTime.from(date, tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleMedication({
    required String id,
    required String medicineName,
    required DateTime date,
  }) async {
    await init();
    final lang = _prefs?.getString('app_locale') ?? 'en';
    final title = Translations.data[lang]?['medication_reminder'] ?? 'Medication Reminder';
    
    const androidDetails = AndroidNotificationDetails(
      'med_channel', 'Medication',
      importance: Importance.max, priority: Priority.high,
      actions: [
        AndroidNotificationAction('TAKEN', 'Taken', showsUserInterface: true),
        AndroidNotificationAction('SKIPPED', 'Skipped', showsUserInterface: true),
      ],
    );

    await _plugin.zonedSchedule(
      getStableIdStatic(id), "💊 $title", safeMedicationBodyStatic(medicineName),
      tz.TZDateTime.from(date, tz.local),
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: id,
    );
  }

  static Future<void> scheduleAppointment({
    required String id,
    required String title,
    required DateTime date,
  }) async {
    await schedule(id: id, title: "📅 Appointment", body: title, date: date);
  }

  static Future<void> cancel(String id) async { await _plugin.cancel(id: getStableIdStatic(id)); }

  static Future<void> rescheduleAll(List<Map<String, dynamic>> items) async {
    await _plugin.cancelAll();
    final now = DateTime.now();
    for (final item in items) {
      final DateTime date = item['date'];
      if (date.isAfter(now)) {
        await schedule(id: item['id'], title: item['title'], body: item['body'], date: date);
      }
    }
  }

  // 🎯 ENGAGEMENT (Instance)
  Future<void> showStreakWarning() async => showNotification(id: 9991, title: 'Streak!', body: 'Keep it up!', channelId: 'engagement', channelName: 'Engagement');
  Future<void> showMissionReminder() async => showNotification(id: 9992, title: 'Mission!', body: 'Daily tasks!', channelId: 'engagement', channelName: 'Engagement');
  Future<void> showLimitReachedPush() async => showNotification(id: 9993, title: 'Limit!', body: 'Vault full!', channelId: 'engagement', channelName: 'Engagement');

  Future<void> showNotification({required int id, required String title, required String body, required String channelId, required String channelName}) async {
    final android = AndroidNotificationDetails(channelId, channelName, importance: Importance.max, priority: Priority.high, icon: '@mipmap/ic_launcher');
    await _plugin.show(id, title, body, notificationDetails: NotificationDetails(android: android));
  }

  static void _onTap(NotificationResponse response) { /* Action Handlers */ }
}
