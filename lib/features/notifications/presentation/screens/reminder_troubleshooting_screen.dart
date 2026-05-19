import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/bootstrap/app_bootstrap_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_providers.dart';
import '../../../../core/notifications/app_notification_payload.dart';
import '../../../../shared/data/services/notification_engine.dart';

class ReminderTroubleshootingScreen extends ConsumerStatefulWidget {
  const ReminderTroubleshootingScreen({super.key});

  @override
  ConsumerState<ReminderTroubleshootingScreen> createState() => _ReminderTroubleshootingScreenState();
}

class _ReminderTroubleshootingScreenState extends ConsumerState<ReminderTroubleshootingScreen> {
  bool? _notificationsAllowed;
  bool _isBusy = false;

  bool get _isTr => Localizations.localeOf(context).languageCode == 'tr';

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!mounted) return;
    setState(() => _notificationsAllowed = allowed);
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    setState(() => _isBusy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _requestNotificationPermission() async {
    await _runBusy(() async {
      await ref.read(notificationServiceProvider).requestPermissions();
      await NotificationEngine.requestPermissions();
      await _refreshStatus();
      _snack(_isTr ? 'Bildirim izni kontrol edildi.' : 'Notification permission checked.');
    });
  }

  Future<void> _requestExactAlarmPermission() async {
    await _runBusy(() async {
      await ref.read(notificationServiceProvider).requestPermissions(requestExactAlarm: true);
      await NotificationEngine.requestPermissions();
      await _refreshStatus();
      _snack(_isTr ? 'Kesin alarm izni istendi. Cihaz ayarında izin vermen gerekebilir.' : 'Exact alarm permission requested. You may need to allow it in device settings.');
    });
  }

  Future<void> _scheduleOneMinuteTest() async {
    await _runBusy(() async {
      final when = DateTime.now().add(const Duration(minutes: 1));
      await NotificationEngine.scheduleAppointment(
        id: 'troubleshooting_test',
        title: _isTr ? '⏰ VitaCase Hatırlatma Testi' : '⏰ VitaCase Reminder Test',
        body: _isTr ? 'Bu test hatırlatması 1 dakika sonrası için kuruldu.' : 'This test reminder was scheduled for 1 minute later.',
        scheduleTime: when,
        payload: AppNotificationPayload(
          type: NotificationType.appointment,
          entityId: 'troubleshooting_test',
          occurrenceAt: when,
        ).encode(),
      );
      _snack(_isTr ? 'Test hatırlatması 1 dakika sonrasına kuruldu.' : 'Test reminder scheduled for 1 minute later.');
    });
  }

  Future<void> _rescheduleSavedReminders() async {
    await _runBusy(() async {
      await ref.read(appBootstrapProvider.notifier).forceRescheduleNotifications();
      _snack(_isTr ? 'Mevcut ilaç ve randevu hatırlatmaları yeniden kuruldu.' : 'Saved medicine and appointment reminders were rescheduled.');
    });
  }

  Future<void> _openSystemSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusText = _notificationsAllowed == null
        ? (_isTr ? 'Kontrol ediliyor...' : 'Checking...')
        : _notificationsAllowed!
            ? (_isTr ? 'Bildirim izni açık' : 'Notification permission is enabled')
            : (_isTr ? 'Bildirim izni kapalı' : 'Notification permission is disabled');

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        title: Text(_isTr ? 'Hatırlatma Sorun Giderme' : 'Reminder Troubleshooting'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _InfoCard(
            isDark: isDark,
            icon: Icons.alarm_rounded,
            title: _isTr ? 'Hatırlatmalar neden gelmeyebilir?' : 'Why reminders may not arrive',
            body: _isTr
                ? 'Bildirim izni, kesin alarm izni veya cihazın pil yönetimi randevu ve ilaç hatırlatmalarını engelleyebilir. Önce izinleri kontrol et, pil optimizasyonunu sadece testler başarısızsa son seçenek olarak değerlendir.'
                : 'Notification permission, exact alarm permission, or device battery management can block appointment and medicine reminders. Check permissions first; consider battery optimization only as a last step if tests fail.',
          ),
          const SizedBox(height: 16),
          _StatusCard(isDark: isDark, title: _isTr ? 'Bildirim Durumu' : 'Notification Status', value: statusText),
          const SizedBox(height: 16),
          _ActionCard(
            isDark: isDark,
            title: _isTr ? '1. Bildirim iznini kontrol et' : '1. Check notification permission',
            subtitle: _isTr ? 'Anlık bildirimler kapalıysa hiçbir hatırlatma görünmez.' : 'If instant notifications are disabled, no reminders will appear.',
            icon: Icons.notifications_active_rounded,
            buttonText: _isTr ? 'Bildirim İznini İste' : 'Request Notification Permission',
            busy: _isBusy,
            onPressed: _requestNotificationPermission,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            isDark: isDark,
            title: _isTr ? '2. Kesin alarm iznini kontrol et' : '2. Check exact alarm permission',
            subtitle: _isTr ? 'Randevu ve ilaç saatlerinin tam zamanında çalışması için gereklidir.' : 'Required for appointment and medicine reminders to run on time.',
            icon: Icons.schedule_rounded,
            buttonText: _isTr ? 'Exact Alarm İznini İste' : 'Request Exact Alarm Permission',
            busy: _isBusy,
            onPressed: _requestExactAlarmPermission,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            isDark: isDark,
            title: _isTr ? '3. Mevcut hatırlatmaları yeniden kur' : '3. Reschedule saved reminders',
            subtitle: _isTr ? 'İzin verdikten sonra kayıtlı ilaç ve randevu hatırlatmalarını tekrar kurar.' : 'After granting permissions, schedules your saved medicine and appointment reminders again.',
            icon: Icons.restart_alt_rounded,
            buttonText: _isTr ? 'Hatırlatmaları Yeniden Kur' : 'Reschedule Reminders',
            busy: _isBusy,
            onPressed: _rescheduleSavedReminders,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            isDark: isDark,
            title: _isTr ? '4. 1 dakika test hatırlatması kur' : '4. Schedule a 1-minute test reminder',
            subtitle: _isTr ? 'Bu gelirse alarm sistemi çalışıyor demektir.' : 'If this arrives, the reminder system is working.',
            icon: Icons.timer_rounded,
            buttonText: _isTr ? '1 Dakika Testi Kur' : 'Schedule 1-Minute Test',
            busy: _isBusy,
            onPressed: _scheduleOneMinuteTest,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            isDark: isDark,
            title: _isTr ? '5. Son seçenek: pil ayarlarını kontrol et' : '5. Last step: check battery settings',
            subtitle: _isTr
                ? 'Sadece yukarıdaki testler başarısızsa cihazın VitaCase için pil kısıtlamasını kontrol et.'
                : 'Only if the tests above fail, check whether the device is restricting VitaCase battery usage.',
            icon: Icons.battery_alert_rounded,
            buttonText: _isTr ? 'Uygulama Ayarlarını Aç' : 'Open App Settings',
            busy: _isBusy,
            onPressed: _openSystemSettings,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.isDark, required this.icon, required this.title, required this.body});

  final bool isDark;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.medicalBlue, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(body, style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary, height: 1.45, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.isDark, required this.title, required this.value});

  final bool isDark;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.medicalBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.fact_check_rounded, color: AppColors.medicalBlue),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900))),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonText,
    required this.busy,
    required this.onPressed,
  });

  final bool isDark;
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonText;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.medicalBlue),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary, height: 1.35)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: busy ? null : onPressed,
              icon: busy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.play_arrow_rounded),
              label: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
