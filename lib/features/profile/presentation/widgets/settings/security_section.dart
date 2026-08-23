import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_routes.dart';
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

    final hasPinAsync = ref.watch(hasPinProvider);
    final hasPin = hasPinAsync.valueOrNull ?? false;

    return SettingsSectionCard(
      title: context.l10n.dataSecurity,
      isDark: isDark,
      children: [
        if (!hasPin) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.gpp_maybe_rounded, color: Colors.orange, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.pinNotSet,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.pinNotSetDesc,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showPinSetupDialog(context, ref, controller),
                  child: Text(
                    context.l10n.create,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
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
      final pinService = ref.read(pinServiceProvider);
      final hasPin = await pinService.hasPin();
      if (!hasPin) {
        if (context.mounted) {
          _showPinSetupDialog(context, ref, controller);
        }
      } else {
        await controller.toggleLock(true);
        AnalyticsService.log(AnalyticsService.appLockEnabled);
      }
    } else {
      await controller.toggleLock(false);
      await controller.toggleBiometric(false);
      AnalyticsService.log(AnalyticsService.appLockDisabled);
    }
  }

  void _showPinSetupDialog(BuildContext rootContext, WidgetRef ref, SettingsController controller) {
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    var isSaving = false;
    var errorText = '';

    showDialog<void>(
      context: rootContext,
      barrierDismissible: !isSaving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> save() async {
              final newPin = newPinController.text.trim();
              final confirmPin = confirmPinController.text.trim();

              if (newPin.length != 6 || confirmPin.length != 6) {
                setState(() => errorText = context.l10n.enter6DigitPin);
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

              try {
                final pinService = ref.read(pinServiceProvider);
                await pinService.setPin(newPin);
                await controller.toggleLock(true);
                ref.invalidate(hasPinProvider); // Refresh hasPin provider status
                HapticFeedback.mediumImpact();

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (rootContext.mounted) {
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    SnackBar(content: Text(rootContext.l10n.success)),
                  );
                }
              } catch (e) {
                setState(() {
                  isSaving = false;
                  errorText = e.toString();
                });
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(context.l10n.createNewPin, style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PinField(controller: newPinController, label: context.l10n.enter6DigitPin, enabled: !isSaving),
                    const SizedBox(height: 12),
                    _PinField(controller: confirmPinController, label: context.l10n.confirmPin, enabled: !isSaving),
                    if (errorText.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(errorText, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: isSaving ? null : () => Navigator.pop(dialogContext), child: Text(context.l10n.cancel)),
                FilledButton(
                  onPressed: isSaving ? null : save,
                  child: isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(context.l10n.save),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      newPinController.dispose();
      confirmPinController.dispose();
    });
  }



  void _showPinChangeDialog(BuildContext rootContext, WidgetRef ref) {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    var isSaving = false;
    var errorText = '';

    showDialog<void>(
      context: rootContext,
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
              if (rootContext.mounted) {
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  SnackBar(content: Text(rootContext.l10n.success)),
                );
              }
            }

            return AlertDialog(
              title: Text(context.l10n.changePin),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PinField(controller: currentPinController, label: context.l10n.lockSetPin, enabled: !isSaving),
                    const SizedBox(height: 12),
                    _PinField(controller: newPinController, label: context.l10n.lockSetPin, enabled: !isSaving),
                    const SizedBox(height: 12),
                    _PinField(controller: confirmPinController, label: context.l10n.lockConfirmPin, enabled: !isSaving),
                    if (errorText.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(errorText, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: isSaving ? null : () => Navigator.pop(dialogContext), child: Text(context.l10n.cancel)),
                FilledButton(
                  onPressed: isSaving ? null : save,
                  child: isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).cardTheme.color ?? Theme.of(ctx).colorScheme.surface,
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
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.clearAllData, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(dialogContext.l10n.wipeConfirm1),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(dialogContext.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
              await WipeService.fullWipe();
              if (context.mounted) {
                context.go(AppRoutes.onboarding);
              }
            },
            child: Text(dialogContext.l10n.wipeBtnFinal, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _PinField extends StatelessWidget {
  const _PinField({required this.controller, required this.label, required this.enabled});

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
      decoration: InputDecoration(labelText: label, counterText: '', border: const OutlineInputBorder()),
    );
  }
}
