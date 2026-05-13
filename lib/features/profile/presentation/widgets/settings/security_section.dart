import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'setting_tile.dart';
import 'settings_section_card.dart';
import '../../providers/settings_controller.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../../shared/domain/entities/lock_timeout.dart';
import '../../../../../shared/data/services/analytics_service.dart';
import '../../../../../shared/data/services/wipe_service.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class SecuritySection extends ConsumerWidget {
  final bool isDark;
  const SecuritySection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.watch(settingsControllerProvider.notifier);

    return SettingsSectionCard(
      title: context.l10n.dataSecurity,
      isDark: isDark,
      children: [
        SettingTile(
          icon: Icons.lock_rounded,
          iconColor: Colors.green,
          title: context.l10n.appLock,
          subtitle: settings.isLockEnabled ? context.l10n.active : context.l10n.inactive,
          trailing: Switch(
            value: settings.isLockEnabled,
            onChanged: (val) => _handleLockToggle(context, ref, controller, val),
          ),
          isDark: isDark,
        ),
        if (settings.isLockEnabled) ...[
          SettingTile(
            icon: Icons.pin_outlined,
            iconColor: Colors.indigo,
            title: context.l10n.changePin,
            subtitle: '6 ${context.l10n.digits}',
            onTap: () => _showPinChangeDialog(context, ref),
            isDark: isDark,
          ),
          SettingTile(
            icon: Icons.fingerprint_rounded,
            iconColor: Colors.teal,
            title: context.l10n.biometricLogin,
            subtitle: settings.biometricEnabled ? context.l10n.active : context.l10n.inactive,
            trailing: Switch(
              value: settings.biometricEnabled,
              onChanged: (val) => _handleBiometricToggle(context, ref, controller, val),
            ),
            isDark: isDark,
          ),
          SettingTile(
            icon: Icons.timer_outlined,
            iconColor: Colors.orange,
            title: context.l10n.lockTimeout,
            subtitle: settings.lockTimeout.localizedLabel(context),
            onTap: () => _showTimeoutSelector(context, ref, controller),
            isDark: isDark,
          ),
        ],
        SettingTile(
          icon: Icons.delete_forever_rounded,
          iconColor: Colors.red,
          title: context.l10n.clearAllData,
          onTap: () => _showWipeDialog(context, ref),
          isDark: isDark,
          isLast: true,
        ),
      ],
    );
  }

  Future<void> _handleLockToggle(BuildContext context, WidgetRef ref, SettingsController controller, bool val) async {
    if (val) {
      await controller.toggleLock(true);
      AnalyticsService.log(AnalyticsService.appLockEnabled);
    } else {
      await controller.toggleLock(false);
      await controller.toggleBiometric(false);
      AnalyticsService.log(AnalyticsService.appLockDisabled);
    }
  }

  Future<void> _handleBiometricToggle(BuildContext context, WidgetRef ref, SettingsController controller, bool val) async {
    if (val) {
      final service = ref.read(appLockServiceProvider);
      final available = await service.isAvailable();
      if (!available) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.biometricUnavailable)));
        }
        return;
      }
    }
    await controller.toggleBiometric(val);
  }

  void _showPinChangeDialog(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN Change Dialog Placeholder')));
  }

  void _showTimeoutSelector(BuildContext context, WidgetRef ref, SettingsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Text(ctx.l10n.lockTimeout, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              ...LockTimeout.values.map((timeout) {
                final currentSettings = ref.read(settingsControllerProvider);
                final isSelected = currentSettings.lockTimeout == timeout;
                return ListTile(
                  title: Text(timeout.localizedLabel(context), style: TextStyle(fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500)),
                  trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryIndigo) : null,
                  onTap: () {
                    controller.setTimeout(timeout);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showWipeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.clearAllData, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(context.l10n.wipeConfirm1),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await WipeService.fullWipe();
            },
            child: Text(context.l10n.wipeBtnFinal, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
