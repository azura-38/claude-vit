import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_behavior.dart';
import 'notification_service.dart';
import '../../core/l10n/app_localizations.dart';

final smartNotificationServiceProvider = Provider(
  (ref) => SmartNotificationService(),
);

class SmartMessageEngine {
  static String get(UserBehavior user) {
    if (user.lastActiveDays >= 3) {
      return "smart_streak_warning";
    }

    if (user.adsWatched >= 10) {
      return "smart_ad_reward";
    }

    if (user.actionsCount >= 5) {
      return "smart_doc_bonus";
    }

    return "smart_default";
  }
}

class SmartNotificationService {
  static const _enabledKey = 'notification_smart_enabled';
  static bool enabled = true;
  static NotificationService? _notificationService;
  static DateTime? _lastImmediateNotificationAt;
  static const Duration _immediateCooldown = Duration(seconds: 90);
  static String _currentLang = 'en';

  static const _lastEngagementKey = 'last_engagement_notif_time';
  static DateTime? _lastEngagementAt;

  static String _translate(String key, {Map<String, String>? extra}) {
    return AppLocalizations(Locale(_currentLang)).translate(key, extra: extra);
  }

  static void configure(NotificationService notificationService) {
    _notificationService = notificationService;
  }

  static NotificationService get _service {
    final service = _notificationService;
    if (service == null) {
      throw StateError('SmartNotificationService not configured');
    }
    return service;
  }

  static Future<void> init() async {
    await _service.initialize();
  }

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    enabled = prefs.getBool(_enabledKey) ?? true;
    _currentLang = prefs.getString('app_locale') ?? 'en';
    
    final lastTime = prefs.getInt(_lastEngagementKey);
    if (lastTime != null) {
      _lastEngagementAt = DateTime.fromMillisecondsSinceEpoch(lastTime);
    }
  }

  static Future<void> setEnabled(bool value) async {
    enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  static String safeMedicationBody(String name) => _service.safeMedicationBody(name);

  static Future<void> _updateLastEngagement() async {
    _lastEngagementAt = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastEngagementKey, _lastEngagementAt!.millisecondsSinceEpoch);
  }

  static bool _canShowEngagement() {
    if (_lastEngagementAt == null) return true;
    final now = DateTime.now();
    return now.difference(_lastEngagementAt!).inHours >= 24;
  }

  static Future<void> showNow(String message, {String? payload}) async {
    if (!enabled) return;
    if (!_canShowEngagement()) return;

    final now = DateTime.now();
    final lastShown = _lastImmediateNotificationAt;
    if (lastShown != null && now.difference(lastShown) < _immediateCooldown) {
      return;
    }
    _lastImmediateNotificationAt = now;
    await _updateLastEngagement();

    await _service.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'VitaCase',
      body: _translate(message),
      channelId: 'smart_engagement_channel',
      channelName: 'Smart Engagement',
    );
  }

  static Future<void> showMedReminder(int id, String medName) async {
    if (!enabled) return;

    await _service.showNotification(
      id: id,
      title: _translate('medication_reminder'),
      body: _service.safeMedicationBody(medName),
      channelId: 'medicine_reminders',
      channelName: 'Medicine Reminders',
      bypassQuietHours: true,
    );
  }

  static Future<void> triggerSmart(UserBehavior user) async {
    final msg = SmartMessageEngine.get(user);
    await showNow(msg, payload: "home");
  }

  static Future<void> scheduleCloseReminder() async {
    if (!_canShowEngagement()) return;

    await _service.scheduleSimple(
      id: 9999,
      date: DateTime.now().add(const Duration(hours: 6)),
      title: 'VitaCase',
      body: _translate('smart_default'),
      channelId: 'smart_engagement',
      channelName: 'Engagement',
    );
    // Note: We don't update _lastEngagementAt here because it's scheduled, 
    // it will be updated when it actually fires (if we had a callback) or 
    // we just consider scheduling as an engagement attempt.
    // For now, let's treat scheduling as one too.
    await _updateLastEngagement();
  }

  static void handleMedicationTaken(String? payload) {
    debugPrint("İlaç alındı: $payload");
    // Analytics/Streak logic here
    NotificationTriggers.onAdWatched(); // Reward user with a positive message
  }

  static void handleMedicationSkipped(String? payload) {
    debugPrint("İlaç atlandı: $payload");
    // Behavioral logic here
  }
}

class NotificationTriggers {
  static void onAppOpen(UserBehavior user) {
    if (user.lastActiveDays >= 2) {
      SmartNotificationService.triggerSmart(user);
    }
  }

  static void onAdWatched() {
    SmartNotificationService.showNow("notif_bonus_ready");
  }

  static void onDataAdded() {
    SmartNotificationService.showNow("notif_doc_safe");
  }

  static void onAppClose() {
    // Schedule a reminder for 6 hours later
    SmartNotificationService.scheduleCloseReminder().catchError(
      (e) => debugPrint('Schedule error: $e'),
    );
  }
}
