import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import '../../../core/l10n/translations.dart';
import '../../../core/notifications/app_notification_payload.dart';
import '../../../core/notifications/notification_id_manager.dart';
import '../../../core/types/runtime_types.dart';

/// Platform-level adapter interface for notifications.
///
/// Isolates platform-channel dependencies so that the core logic, timezone
/// safety, idempotency, and error handling can be tested reliably without
/// an Android device or emulator.
abstract class NotificationPlatformAdapter {
  Future<bool> initialize({
    required void Function(NotificationResponse) onDidReceiveNotificationResponse,
    bool useFallbackIcon = false,
  });

  Future<NotificationPermissionState> requestPermissions({
    bool requestExactAlarm = false,
  });

  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    String? payload,
    bool useFallbackIcon = false,
  });

  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    required String channelName,
    String? payload,
    bool useFallbackIcon = false,
    bool isMedication = false,
  });

  Future<void> cancel({required int id});

  Future<void> cancelAll();

  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async => const [];
}

/// Default implementation delegating to [FlutterLocalNotificationsPlugin].
class DefaultNotificationPlatformAdapter implements NotificationPlatformAdapter {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<bool> initialize({
    required void Function(NotificationResponse) onDidReceiveNotificationResponse,
    bool useFallbackIcon = false,
  }) async {
    final androidSettings = AndroidInitializationSettings(
      useFallbackIcon ? '@mipmap/ic_launcher' : 'ic_notification',
    );
    const ios = DarwinInitializationSettings();

    final result = await _plugin.initialize(
      settings: InitializationSettings(
        android: androidSettings,
        iOS: ios,
      ),
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
    return result ?? true;
  }

  @override
  Future<NotificationPermissionState> requestPermissions({
    bool requestExactAlarm = false,
  }) async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ?? true;
    if (requestExactAlarm) {
      await android?.requestExactAlarmsPermission();
    }
    return granted
        ? NotificationPermissionState.granted
        : NotificationPermissionState.denied;
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    String? payload,
    bool useFallbackIcon = false,
  }) async {
    final android = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      icon: useFallbackIcon ? '@mipmap/ic_launcher' : 'ic_notification',
      visibility: NotificationVisibility.private,
    );
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: android),
      payload: payload,
    );
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    required String channelName,
    String? payload,
    bool useFallbackIcon = false,
    bool isMedication = false,
  }) async {
    final androidDetails = isMedication
        ? AndroidNotificationDetails(
            'med_channel',
            'Medication',
            importance: Importance.max,
            priority: Priority.high,
            icon: useFallbackIcon ? '@mipmap/ic_launcher' : 'ic_medication_notification',
            visibility: NotificationVisibility.private,
            actions: const [
              AndroidNotificationAction('TAKEN', 'Taken'),
              AndroidNotificationAction('SKIPPED', 'Skipped'),
            ],
          )
        : AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.max,
            priority: Priority.high,
            icon: useFallbackIcon ? '@mipmap/ic_launcher' : 'ic_appointment_notification',
            visibility: NotificationVisibility.private,
          );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  @override
  Future<void> cancel({required int id}) async {
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  @override
  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    try {
      return await _plugin.pendingNotificationRequests();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] pendingNotificationRequests error: $e');
      }
      return const [];
    }
  }
}

class NotificationService {
  static NotificationService? _instance;
  static SharedPreferences? _prefs;
  static Future<void> Function(String id)? _onMedicineTaken;
  static Future<void> Function(String id)? _onMedicineSkipped;
  static void Function(String payload)? _onNotificationRoute;
  static const int engagementId = 9999;
  static bool _useFallbackIcon = false;
  static bool _isInitialized = false;
  static bool _permissionsRequested = false;
  static Future<void>? _initCoreFuture;

  static NotificationPlatformAdapter _adapter = DefaultNotificationPlatformAdapter();

  @visibleForTesting
  static void setAdapterForTesting(NotificationPlatformAdapter adapter) {
    _adapter = adapter;
  }

  @visibleForTesting
  static void resetForTesting() {
    _isInitialized = false;
    _initCoreFuture = null;
    _permissionsRequested = false;
    _useFallbackIcon = false;
    _adapter = DefaultNotificationPlatformAdapter();
    _instance = null;
    _prefs = null;
  }

  NotificationService(SharedPreferences prefs) {
    _prefs = prefs;
    _instance = this;
  }

  static bool get isInitialized => _isInitialized;
  bool get initialized => _isInitialized;

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

  /// Ensures timezone data is loaded and local location is set safely.
  ///
  /// Never throws [LocationNotFoundException]. Uses [tz.UTC] if local lookup fails.
  static void ensureTimezoneInitialized() {
    try {
      tz.initializeTimeZones();
    } catch (_) {}
    try {
      // Accessing tz.local verifies it is valid
      final _ = tz.local;
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Safe, idempotent initialization of core notification resources.
  ///
  /// Calling multiple times does not recreate state or crash the app.
  /// Does NOT block or prompt the user for permissions.
  static Future<void> initCore() async {
    if (_isInitialized) return;
    if (_initCoreFuture != null) {
      await _initCoreFuture;
      return;
    }

    _initCoreFuture = _performInitCore();
    try {
      await _initCoreFuture;
    } finally {
      _initCoreFuture = null;
    }
  }

  static Future<void> _performInitCore() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] SharedPreferences init warning: $e');
      }
    }

    ensureTimezoneInitialized();
    try {
      final String name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // Safe fallback: NEVER use tz.getLocation('UTC')
      tz.setLocalLocation(tz.UTC);
    }

    try {
      await _adapter.initialize(
        onDidReceiveNotificationResponse: _onTap,
        useFallbackIcon: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Failed to initialize with ic_notification, trying fallback: $e');
      }
      try {
        _useFallbackIcon = true;
        await _adapter.initialize(
          onDidReceiveNotificationResponse: _onTap,
          useFallbackIcon: true,
        );
      } catch (fallbackError) {
        if (kDebugMode) {
          debugPrint('[NotificationService] Fallback initialization failed: $fallbackError');
        }
      }
    }

    _isInitialized = true;
    if (kDebugMode) {
      debugPrint('[NotificationService] Core initialized ✅ (no permissions requested)');
    }
  }

  /// Non-blocking, safe permission request at startup.
  ///
  /// Idempotent: will not spam the user on repeated calls.
  static Future<void> requestStartupPermissions() async {
    if (_permissionsRequested) return;
    _permissionsRequested = true;

    try {
      if (!_isInitialized) await initCore();
      await _adapter.requestPermissions();
      if (kDebugMode) {
        debugPrint('[NotificationService] Permissions requested ✅');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Startup permission request warning: $e');
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
      if (!_isInitialized) await initCore();
      return await _adapter.requestPermissions(
        requestExactAlarm: requestExactAlarm,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Permission request warning: $e');
      }
      return NotificationPermissionState.denied;
    }
  }

  static int getStableIdStatic(String uuid, [int offset = 0]) {
    return NotificationIdManager.getStableIdLegacy(uuid, offset);
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
    return NotificationIdManager.buildKey(id, date);
  }

  /// Core scheduling method.
  ///
  /// Guarantees timezone initialization, safe input handling, error containment,
  /// and non-colliding deterministic notification IDs.
  static Future<bool> schedule({
    required String id,
    required String title,
    required String body,
    required DateTime date,
    AppNotificationPayload? payload,
    NotificationType? type,
  }) async {
    try {
      if (!_isInitialized) {
        await initCore();
      } else {
        ensureTimezoneInitialized();
      }

      // Safe date validation: Reject dates before epoch or invalid timestamps
      if (date.millisecondsSinceEpoch <= 0) {
        if (kDebugMode) {
          debugPrint('[NotificationService] Scheduling rejected: invalid timestamp');
        }
        return false;
      }

      final resolvedType = type ?? payload?.type ?? NotificationType.unknown;
      final notifId = id.contains('engagement')
          ? engagementId
          : NotificationIdManager.getId(
              key: NotificationIdManager.buildKey(id, date),
              type: resolvedType,
            );

      final scheduledDate = tz.TZDateTime.from(date, tz.local);

      await _adapter.zonedSchedule(
        id: notifId,
        title: title,
        body: safeText(body),
        scheduledDate: scheduledDate,
        channelId: 'vitacase_channel',
        channelName: 'VitaCase Notifications',
        payload: payload?.encode() ?? id,
        useFallbackIcon: _useFallbackIcon,
        isMedication: false,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Scheduling failed safely: $e');
      }
      return false;
    }
  }

  static Future<bool> scheduleMedication({
    required String id,
    required String title,
    required String body,
    required DateTime date,
    AppNotificationPayload? payload,
    int? explicitId,
  }) async {
    try {
      if (!_isInitialized) {
        await initCore();
      } else {
        ensureTimezoneInitialized();
      }

      if (date.millisecondsSinceEpoch <= 0) {
        return false;
      }

      final notifId = explicitId ??
          NotificationIdManager.getId(
            key: NotificationIdManager.buildKey(id, date),
            type: NotificationType.medication,
          );

      final scheduledDate = tz.TZDateTime.from(date, tz.local);

      await _adapter.zonedSchedule(
        id: notifId,
        title: title,
        body: safeMedicationBodyStatic(body),
        scheduledDate: scheduledDate,
        channelId: 'med_channel',
        channelName: 'Medication',
        payload: payload?.encode() ?? id,
        useFallbackIcon: _useFallbackIcon,
        isMedication: true,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Medication scheduling failed safely: $e');
      }
      return false;
    }
  }

  static Future<bool> scheduleAppointment({
    required String id,
    required String title,
    required String body,
    required DateTime date,
    AppNotificationPayload? payload,
    int? explicitId,
  }) async {
    try {
      if (!_isInitialized) {
        await initCore();
      } else {
        ensureTimezoneInitialized();
      }

      if (date.millisecondsSinceEpoch <= 0) {
        return false;
      }

      final notifId = explicitId ??
          NotificationIdManager.getId(
            key: NotificationIdManager.buildKey(id, date),
            type: NotificationType.appointment,
          );

      final scheduledDate = tz.TZDateTime.from(date, tz.local);

      await _adapter.zonedSchedule(
        id: notifId,
        title: title,
        body: safeText(body),
        scheduledDate: scheduledDate,
        channelId: 'vitacase_channel',
        channelName: 'VitaCase Notifications',
        payload: payload?.encode() ?? id,
        useFallbackIcon: _useFallbackIcon,
        isMedication: false,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Appointment scheduling failed safely: $e');
      }
      return false;
    }
  }

  static Future<bool> cancel(String id) async {
    try {
      final notifId = getStableIdStatic(id);
      await _adapter.cancel(id: notifId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Cancel failed safely: $e');
      }
      return false;
    }
  }

  static Future<bool> cancelById(int id) async {
    try {
      await _adapter.cancel(id: id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] CancelById failed safely: $e');
      }
      return false;
    }
  }

  static Future<bool> cancelOccurrence({
    required String id,
    required DateTime date,
  }) async {
    try {
      final key = buildKey(id, date);
      final notifId = getStableIdStatic(key);
      await _adapter.cancel(id: notifId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] CancelOccurrence failed safely: $e');
      }
      return false;
    }
  }

  Future<void> cancelNotification(int id) async {
    await cancelById(id);
  }

  static Future<bool> cancelAll() async {
    try {
      await _adapter.cancelAll();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] CancelAll failed safely: $e');
      }
      return false;
    }
  }

  Future<void> showStreakWarning() async => showNotification(
    id: 9991,
    title: 'Streak!',
    body: 'Keep it up!',
    channelId: 'engagement',
    channelName: 'Engagement',
  );

  Future<void> showMissionReminder() async => showNotification(
    id: 9992,
    title: 'Mission!',
    body: 'Daily tasks!',
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

  static Future<bool> show({
    required int id,
    required String title,
    required String body,
    String channelId = 'vitacase_channel',
    String channelName = 'VitaCase Notifications',
    String? payload,
  }) async {
    try {
      if (!_isInitialized) {
        await initCore();
      }
      await _adapter.show(
        id: id,
        title: title,
        body: safeText(body),
        channelId: channelId,
        channelName: channelName,
        payload: payload,
        useFallbackIcon: _useFallbackIcon,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Show notification failed safely: $e');
      }
      return false;
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  }) async {
    await show(
      id: id,
      title: title,
      body: body,
      channelId: channelId,
      channelName: channelName,
    );
  }

  /// Retrieves all currently pending notification requests.
  static Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    try {
      if (!_isInitialized) {
        await initCore();
      }
      return await _adapter.getPendingNotificationRequests();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Failed to get pending notifications: $e');
      }
      return const [];
    }
  }

  /// Checks if a notification with [id] is already pending.
  static Future<bool> isNotificationPending(int id) async {
    final pending = await getPendingNotificationRequests();
    return pending.any((p) => p.id == id);
  }

  static void _onTap(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload == null || payload.isEmpty) return;
      final decoded = AppNotificationPayload.decode(payload);
      final entityId = decoded.entityId.isEmpty ? payload : decoded.entityId;

      if (response.actionId == 'TAKEN') {
        _onMedicineTaken?.call(entityId).catchError((e) {
          if (kDebugMode) {
            debugPrint('[NotificationService] _onMedicineTaken callback error: $e');
          }
        });
        return;
      }

      if (response.actionId == 'SKIPPED') {
        _onMedicineSkipped?.call(entityId).catchError((e) {
          if (kDebugMode) {
            debugPrint('[NotificationService] _onMedicineSkipped callback error: $e');
          }
        });
        return;
      }

      _onNotificationRoute?.call(payload);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Safe error in _onTap handler: $e');
      }
    }
  }
}
