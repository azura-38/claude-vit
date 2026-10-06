import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/ui_utils.dart';

import '../../../../core/bootstrap/app_bootstrap_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/l10n_extension.dart';
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
    final msg = context.l10n.snackNotifChecked;
    await _runBusy(() async {
      await NotificationEngine.requestPermissions();
      await _refreshStatus();
      _snack(msg);
    });
  }

  Future<void> _requestExactAlarmPermission() async {
    final msg = context.l10n.snackExactAlarmRequested;
    await _runBusy(() async {
      await NotificationEngine.requestPermissions(requestExactAlarm: true);
      await _refreshStatus();
      _snack(msg);
    });
  }

  Future<void> _scheduleOneMinuteTest() async {
    final title = context.l10n.testNotifTitle;
    final body = context.l10n.testNotifBody;
    final msg = context.l10n.snackTestSched;
    await _runBusy(() async {
      final when = DateTime.now().add(const Duration(minutes: 1));
      await NotificationEngine.scheduleAppointment(
        id: 'troubleshooting_test',
        title: title,
        body: body,
        scheduleTime: when,
        payload: AppNotificationPayload(
          type: NotificationType.appointment,
          entityId: 'troubleshooting_test',
          occurrenceAt: when,
        ),
      );
      _snack(msg);
    });
  }

  Future<void> _rescheduleSavedReminders() async {
    final msg = context.l10n.snackReschedCompleted;
    await _runBusy(() async {
      await ref.read(appBootstrapProvider.notifier).forceRescheduleNotifications();
      _snack(msg);
    });
  }

  Future<void> _openSystemSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusText = _notificationsAllowed == null
        ? context.l10n.statusChecking
        : _notificationsAllowed!
            ? context.l10n.statusEnabled
            : context.l10n.statusDisabled;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.safePop(fallbackRoute: AppRoutes.home), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        title: Text(context.l10n.reminderTroubleshooting),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _InfoCard(
            isDark: isDark,
            icon: Icons.alarm_rounded,
            title: context.l10n.whyNoReminders,
            body: context.l10n.whyNoRemindersDesc,
          ),
          const SizedBox(height: 16),
          _StatusCard(isDark: isDark, title: context.l10n.statusCardTitle, value: statusText),
          const SizedBox(height: 16),
          _ActionCard(
            isDark: isDark,
            title: context.l10n.checkNotifPermission,
            subtitle: context.l10n.checkNotifPermissionDesc,
            icon: Icons.notifications_active_rounded,
            buttonText: context.l10n.reqNotifPermission,
            busy: _isBusy,
            onPressed: _requestNotificationPermission,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            isDark: isDark,
            title: context.l10n.checkExactAlarm,
            subtitle: context.l10n.checkExactAlarmDesc,
            icon: Icons.schedule_rounded,
            buttonText: context.l10n.reqExactAlarm,
            busy: _isBusy,
            onPressed: _requestExactAlarmPermission,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            isDark: isDark,
            title: context.l10n.reschedSaved,
            subtitle: context.l10n.reschedSavedDesc,
            icon: Icons.restart_alt_rounded,
            buttonText: context.l10n.reschedBtn,
            busy: _isBusy,
            onPressed: _rescheduleSavedReminders,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            isDark: isDark,
            title: context.l10n.schedTest,
            subtitle: context.l10n.schedTestDesc,
            icon: Icons.timer_rounded,
            buttonText: context.l10n.schedTestBtn,
            busy: _isBusy,
            onPressed: _scheduleOneMinuteTest,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            isDark: isDark,
            title: context.l10n.lastStepBattery,
            subtitle: context.l10n.lastStepBatteryDesc,
            icon: Icons.battery_alert_rounded,
            buttonText: context.l10n.openAppSettings,
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
