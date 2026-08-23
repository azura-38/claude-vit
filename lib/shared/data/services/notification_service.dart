import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import '../../../core/l10n/translations.dart';
import '../../../core/notifications/app_notification_payload.dart';
import '../../../core/types/runtime_types.dart';

class NotificationService {
  static NotificationService? _instance;
  static SharedPreferences? _prefs;
  static Future<void> Function(String id)? _onMedicineTaken;
  static Future<void> Function(String id)? _onMedicineSkipped;
  static void Function(String payload)? _onNotificationRoute;
  static const int engagementId = 9999;
  static const String _androidNotificationIcon = 'ic_notification';
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _useFallbackIcon = false;
  static bool _timezoneInitialized = false;

  static AndroidNotificationDetails get _androidDetails =>
      AndroidNotificationDetails(
        'vitacase_channel',
        'VitaCase Notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: _useFallbackIcon ? '@mipmap/ic_launcher' : 'ic_appointment_notification',
        visibility: NotificationVisibility.private,
      );

  static AndroidNotificationDetails get _medicationAndroidDetails =>
      AndroidNotificationDetails(
        'med_channel',
        'Medication',
        importance: Importance.max,
        priority: Priority.high,
        icon: _useFallbackIcon ? '@mipmap/ic_launcher' : 'ic_medication_notification',
        visibility: NotificationVisibility.private,
        actions: const [
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

  static void setRouteHandler(void Function(String payload) onRoute) {
    _onNotificationRoute = onRoute;
  }

  static NotificationService? get instance => _instance;

  static void ensureTimezoneInitialized() {
    if (_timezoneInitialized) return;
    try {
      tz_data.initializeTimeZones();
      _timezoneInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Timezone init warning: $e');
      }
    }
  }

  static Future<void> _configureLocalTimezone() async {
    ensureTimezoneInitialized();
    try {
      final String name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (e) {
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }
  }

  static Future<void> initCore() async {
    if (_isInitialized) return;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _configureLocalTimezone();

      const androidSettings = AndroidInitializationSettings(
        _androidNotificationIcon,
      );
      const ios = DarwinInitializationSettings();

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: ios,
        ),
        onDidReceiveNotificationResponse: _onTap,
      );
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('[NotificationService] Core initialized ✅');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Failed to initialize with ic_notification, trying fallback: $e');
      }
      try {
        _useFallbackIcon = true;
        const androidSettingsFallback = AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );
        const ios = DarwinInitializationSettings();
        await _plugin.initialize(
          settings: const InitializationSettings(
            android: androidSettingsFallback,
            iOS: ios,
          ),
          onDidReceiveNotificationResponse: _onTap,
        );
        _isInitialized = true;
      } catch (fallbackError) {
        if (kDebugMode) {
          debugPrint('[NotificationService] Fallback initialization error (non-fatal): $fallbackError');
        }
      }
    }
  }

  static Future<void> requestStartupPermissions() async {
    try {
      if (!_isInitialized) await initCore();

      final android =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();

      if (kDebugMode) {
        debugPrint('[NotificationService] Permissions requested ✅');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Permission request non-fatal warning: $e');
      }
    }
  }

  static Future<void> init({
    Future<void> Function(String id)? onMedicineTaken,
    Future<void> Function(String id)? onMedicineSkipped,
  }) async {
    if (onMedicineTaken != null) _onMedicineTaken = onMedicineTaken;
    if (onMedicineSkipped != null) _onMedicineSkipped = onMedicineSkipped;

    await initCore();
    await requestStartupPermissions();
  }

  Future<void> initialize() => NotificationService.init();

  static String safeText(String text) {
    final hide = _prefs?.getBool('notification_hide_sensitive_content') ?? true;
    if (hide) {
      final lang = _prefs?.getString('app_locale') ?? 'en';
      return Translations.data[lang]?['notification_details_hidden'] ??
          Translations.data['en']?['notification_details_hidden'] ??
          'You have a reminder';
    }
    return text;
  }

  String safeMedicationBody(String name) =>
      NotificationService.safeMedicationBodyStatic(name);

  Future<void> setHideSensitiveContent(bool hide) async {
    await _prefs?.setBool('notification_hide_sensitive_content', hide);
  }

  Future<NotificationPermissionState> requestPermissions({
    bool requestExactAlarm = false,
  }) async {
    try {
      final android =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      final granted = await android?.requestNotificationsPermission() ?? true;
      if (requestExactAlarm) await android?.requestExactAlarmsPermission();
      return granted
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    } catch (_) {
      return NotificationPermissionState.denied;
    }
  }

  static int getStableIdStatic(String uuid, [int offset = 0]) {
    int hash = 0x811c9dc5;
    for (int i = 0; i < uuid.length; i++) {
      hash ^= uuid.codeUnitAt(i);
      hash *= 0x01000193;
      hash &= 0xFFFFFFFF;
    }
    return ((hash.abs() ^ (offset * 0x01000193)) & 0x7FFFFFFF);
  }

  static String safeMedicationBodyStatic(String name) {
    final hide = _prefs?.getBool('notification_hide_sensitive_content') ?? true;
    if (hide) {
      final lang = _prefs?.getString('app_locale') ?? 'en';
      return Translations.data[lang]?['notification_details_hidden'] ??
          Translations.data['en']?['notification_details_hidden'] ??
          'Details hidden';
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
    AppNotificationPayload? payload,
  }) async {
    await init();
    ensureTimezoneInitialized();
    if (kDebugMode) debugPrint("Scheduling notification at: $date");

    final notifId = id.contains('engagement')
        ? engagementId
        : getStableIdStatic(buildKey(id, date));

    try {
      await _plugin.zonedSchedule(
        id: notifId,
        title: title,
        body: safeText(body),
        scheduledDate: tz.TZDateTime.from(date, tz.local),
        notificationDetails: NotificationDetails(android: _androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload?.encode() ?? id,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Schedule failed non-fatally: $e');
      }
    }
  }

  static Future<void> scheduleMedication({
    required String id,
    required String title,
    required String body,
    required DateTime date,
    AppNotificationPayload? payload,
  }) async {
    await init();
    ensureTimezoneInitialized();
    if (kDebugMode) debugPrint("Scheduling medication notification at: $date");
    final notifId = getStableIdStatic(buildKey(id, date));

    try {
      await _plugin.zonedSchedule(
        id: notifId,
        title: title,
        body: safeMedicationBodyStatic(body),
        scheduledDate: tz.TZDateTime.from(date, tz.local),
        notificationDetails: NotificationDetails(
          android: _medicationAndroidDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload?.encode() ?? id,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Medication schedule failed non-fatally: $e');
      }
    }
  }

  static Future<void> cancel(String id) async {
    try {
      await _plugin.cancel(id: getStableIdStatic(id));
    } catch (_) {}
  }

  static Future<void> cancelOccurrence({
    required String id,
    required DateTime date,
  }) async {
    final key = buildKey(id, date);
    final notifId = getStableIdStatic(key);
    try {
      await _plugin.cancel(id: notifId);
    } catch (_) {}
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (_) {}
  }

  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  Future<void> showStreakWarning() async => showNotification(
    id: 9991,
    title: 'VitaCase',
    body: 'Your health records stay safely on your device.',
    channelId: 'engagement',
    channelName: 'Engagement',
  );
  Future<void> showMissionReminder() async => showNotification(
    id: 9992,
    title: 'VitaCase',
    body: 'Check your health reminders and schedules.',
    channelId: 'engagement',
    channelName: 'Engagement',
  );
  Future<void> showLimitReachedPush() async => showNotification(
    id: 9993,
    title: 'Limit!',
    body: 'Vault full!',
    channelId: 'engagement',
    channelName: 'Engagement',
  );

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  }) async {
    try {
      final android = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        icon: _useFallbackIcon ? '@mipmap/ic_launcher' : _androidNotificationIcon,
        visibility: NotificationVisibility.private,
      );
      await _plugin.show(
        id: id,
        title: title,
        body: safeText(body),
        notificationDetails: NotificationDetails(android: android),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Show notification failed non-fatally: $e');
      }
    }
  }

  static void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    final decoded = AppNotificationPayload.decode(payload);
    final entityId = decoded.entityId.isEmpty ? payload : decoded.entityId;

    if (response.actionId == 'TAKEN') {
      _onMedicineTaken?.call(entityId);
      return;
    }

    if (response.actionId == 'SKIPPED') {
      _onMedicineSkipped?.call(entityId);
      return;
    }

    if (response.actionId == 'TAKEN') return;

    _onNotificationRoute?.call(payload);
  }
}
