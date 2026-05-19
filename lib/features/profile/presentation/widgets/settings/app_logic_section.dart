import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../notifications/presentation/providers/notification_controller.dart';
import '../../providers/settings_controller.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'setting_tile.dart';
import 'settings_section_card.dart';

class AppLogicSection extends ConsumerWidget {
  const AppLogicSection({super.key, required this.isDark});

  final bool isDark;

  bool _isTr(BuildContext context) => Localizations.localeOf(context).languageCode == 'tr';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.watch(settingsControllerProvider.notifier);
    final notificationController = ref.watch(notificationControllerProvider);
    final isTr = _isTr(context);

    return SettingsSectionCard(
      title: context.l10n.appSection,
      isDark: isDark,
      children: [
        SettingTile(
          icon: Icons.bolt_rounded,
          iconColor: Colors.amber,
          title: context.l10n.quickActions,
          subtitle: settings.quickActionsEnabled ? context.l10n.active : context.l10n.inactive,
          trailing: Switch(
            value: settings.quickActionsEnabled,
            onChanged: (val) => controller.toggleQuickActions(val),
          ),
          isDark: isDark,
        ),
        SettingTile(
          icon: Icons.notifications_active_outlined,
          iconColor: Colors.blue,
          title: context.l10n.smartNotifications,
          subtitle: settings.notificationSettings.smartNotificationsEnabled ? '${context.l10n.active} 🔔' : context.l10n.inactive,
          trailing: Switch(
            value: settings.notificationSettings.smartNotificationsEnabled,
            onChanged: (value) async {
              await controller.updateNotificationSettings(settings.notificationSettings.copyWith(smartNotificationsEnabled: value));
              await notificationController.setSmartNotificationsEnabled(value);
              if (value && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.notificationsActiveMsg)));
              }
            },
          ),
          isDark: isDark,
        ),
        SettingTile(
          icon: Icons.visibility_off_outlined,
          iconColor: Colors.deepOrange,
          title: context.l10n.showSensitiveDetails,
          subtitle: settings.notificationSettings.showSensitiveDetails ? context.l10n.sensitiveDetailsVisible : context.l10n.sensitiveDetailsHidden,
          trailing: Switch(
            value: settings.notificationSettings.showSensitiveDetails,
            onChanged: (value) async {
              await controller.updateNotificationSettings(settings.notificationSettings.copyWith(showSensitiveDetails: value));
              await notificationController.setHideSensitiveContent(!value);
            },
          ),
          isDark: isDark,
        ),
        SettingTile(
          icon: Icons.do_not_disturb_on_rounded,
          iconColor: Colors.deepPurple,
          title: context.l10n.quietHours,
          subtitle: settings.notificationSettings.quietHoursEnabled
              ? '${_timeLabel(settings.notificationSettings.quietHoursStart, settings.notificationSettings.quietHoursStartMinute).format(context)} - ${_timeLabel(settings.notificationSettings.quietHoursEnd, settings.notificationSettings.quietHoursEndMinute).format(context)}'
              : '${context.l10n.inactive} 🌙',
          onTap: () => _showQuietHoursSelector(context, ref, controller),
          trailing: Switch(
            value: settings.notificationSettings.quietHoursEnabled,
            onChanged: (value) async {
              await controller.updateNotificationSettings(settings.notificationSettings.copyWith(quietHoursEnabled: value));
              if (value && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.quietHoursMsg)));
              }
            },
          ),
          isDark: isDark,
        ),
        SettingTile(
          icon: Icons.alarm_on_rounded,
          iconColor: AppColors.medicalBlue,
          title: isTr ? 'Hatırlatma Sorun Giderme' : 'Reminder Troubleshooting',
          subtitle: isTr ? 'Bildirim, exact alarm ve pil ayarlarını kontrol et' : 'Check notification, exact alarm, and battery settings',
          onTap: () => context.push(AppRoutes.reminderTroubleshooting),
          isDark: isDark,
          isLast: true,
        ),
      ],
    );
  }

  void _showQuietHoursSelector(BuildContext context, WidgetRef ref, SettingsController controller) {
    final currentSettings = ref.read(settingsControllerProvider).notificationSettings;
    final startTime = _timeLabel(currentSettings.quietHoursStart, currentSettings.quietHoursStartMinute);
    final endTime = _timeLabel(currentSettings.quietHoursEnd, currentSettings.quietHoursEndMinute);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(ctx).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.quietHours, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            ListTile(
              title: Text(context.l10n.startTime),
              subtitle: Text(startTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: startTime);
                if (time != null) {
                  controller.updateNotificationSettings(currentSettings.copyWith(quietHoursStart: time.hour, quietHoursStartMinute: time.minute));
                }
              },
            ),
            ListTile(
              title: Text(context.l10n.endTime),
              subtitle: Text(endTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: endTime);
                if (time != null) {
                  controller.updateNotificationSettings(currentSettings.copyWith(quietHoursEnd: time.hour, quietHoursEndMinute: time.minute));
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.ok)),
          ],
        ),
      ),
    );
  }

  TimeOfDay _timeLabel(int hour, int minute) => TimeOfDay(hour: hour, minute: minute);
}
