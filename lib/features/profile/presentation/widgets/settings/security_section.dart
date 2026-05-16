import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/data/services/analytics_service.dart';
import '../../../../../shared/data/services/wipe_service.dart';
import '../../../../../shared/domain/entities/lock_timeout.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../providers/settings_controller.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'setting_tile.dart';
import 'settings_section_card.dart';

class SecuritySection extends ConsumerWidget {
  const SecuritySection({super.key, required this.isDark});

  final bool isDark;

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
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    var isSaving = false;
    var errorText = '';

    showDialog<void>(
      context: context,
      barrierDismissible: !isSaving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> save() async {
              final currentPin = currentPinController.text.trim();
              final newPin = newPinController.text.trim();
              final confirmPin = confirmPinController.text.trim();

              if (currentPin.length != 6 || newPin.length != 6 || confirmPin.length != 6) {
                setState(() => errorText = context.l10n.lockPinMismatch);
                return;
              }

              if (newPin != confirmPin) {
                setState(() => errorText = context.l10n.lockPinMismatch);
                return;
              }

              setState(() {
                isSaving = true;
                errorText = '';
              });

              final pinService = ref.read(pinServiceProvider);
              final verified = await pinService.verifyPin(currentPin);
              if (!verified) {
                setState(() {
                  isSaving = false;
                  errorText = context.l10n.lockPinIncorrect;
                });
                return;
              }

              await pinService.setPin(newPin);
              HapticFeedback.mediumImpact();

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(content: Text(context.l10n.success)),
              );
            }

            return AlertDialog(
              title: Text(context.l10n.changePin),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PinField(
                    controller: currentPinController,
                    label: context.l10n.lockSetPin,
                    enabled: !isSaving,
                  ),
                  const SizedBox(height: 12),
                  _PinField(
                    controller: newPinController,
                    label: context.l10n.lockSetPin,
                    enabled: !isSaving,
                  ),
                  const SizedBox(height: 12),
                  _PinField(
                    controller: confirmPinController,
                    label: context.l10n.lockConfirmPin,
                    enabled: !isSaving,
                  ),
                  if (errorText.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorText,
                      style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: Text(context.l10n.cancel),
                ),
                FilledButton(
                  onPressed: isSaving ? null : save,
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.l10n.save),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      currentPinController.dispose();
      newPinController.dispose();
      confirmPinController.dispose();
    });
  }

  void _showTimeoutSelector(BuildContext context, WidgetRef ref, SettingsController controller) {
    final currentSettings = ref.read(settingsControllerProvider).notificationSettings;
    final startTime = _timeLabel(currentSettings.quietHoursStart, currentSettings.quietHoursStartMinute);
    final endTime = _timeLabel(currentSettings.quietHoursEnd, currentSettings.quietHoursEndMinute);

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

  TimeOfDay _timeLabel(int hour, int minute) => TimeOfDay(hour: hour, minute: minute);

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

class _PinField extends StatelessWidget {
  const _PinField({
    required this.controller,
    required this.label,
    required this.enabled,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        border: const OutlineInputBorder(),
      ),
    );
  }
}
