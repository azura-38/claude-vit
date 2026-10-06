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
import '../../../../../shared/data/services/pin_service.dart';
import '../../providers/settings_controller.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'setting_tile.dart';
import 'settings_section_card.dart';

void _popDialog(BuildContext ctx) {
  try {
    ctx.pop();
  } catch (_) {
    final nav = Navigator.maybeOf(ctx);
    nav?.pop();
  }
}

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
                        context.tr('pin_not_set'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('pin_not_set_desc'),
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
                    context.tr('btn_create'),
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
      final pinService = ref.read(pinServiceProvider);
      final hasPin = await pinService.hasPin();
      if (hasPin) {
        if (context.mounted) {
          _showPinDisableDialog(context, ref, controller);
        }
      } else {
        await controller.toggleLock(false);
        await controller.toggleBiometric(false);
        AnalyticsService.log(AnalyticsService.appLockDisabled);
      }
    }
  }

  void _showPinSetupDialog(BuildContext rootContext, WidgetRef ref, SettingsController controller) {
    showDialog<void>(
      context: rootContext,
      builder: (dialogContext) => _PinSetupDialog(
        ref: ref,
        controller: controller,
        rootContext: rootContext,
      ),
    );
  }

  void _showPinDisableDialog(BuildContext rootContext, WidgetRef ref, SettingsController controller) {
    showDialog<void>(
      context: rootContext,
      builder: (dialogContext) => _PinDisableDialog(
        ref: ref,
        controller: controller,
        rootContext: rootContext,
      ),
    );
  }

  void _showPinChangeDialog(BuildContext rootContext, WidgetRef ref) {
    showDialog<void>(
      context: rootContext,
      builder: (dialogContext) => _PinChangeDialog(
        ref: ref,
        rootContext: rootContext,
      ),
    );
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
                    ctx.pop();
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
            onPressed: () => _popDialog(dialogContext),
            child: Text(dialogContext.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              _popDialog(dialogContext);
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

class _PinSetupDialog extends StatefulWidget {
  const _PinSetupDialog({
    required this.ref,
    required this.controller,
    required this.rootContext,
  });

  final WidgetRef ref;
  final SettingsController controller;
  final BuildContext rootContext;

  @override
  State<_PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<_PinSetupDialog> {
  late final TextEditingController _newPinController;
  late final TextEditingController _confirmPinController;
  bool _isSaving = false;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _newPinController = TextEditingController();
    _confirmPinController = TextEditingController();
  }

  @override
  void dispose() {
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (!PinService.isValidPinFormat(newPin) || !PinService.isValidPinFormat(confirmPin)) {
      setState(() => _errorText = context.tr('enter_6_digit_pin'));
      return;
    }

    if (newPin != confirmPin) {
      setState(() => _errorText = context.l10n.lockPinMismatch);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = '';
    });

    try {
      final pinService = widget.ref.read(pinServiceProvider);
      await pinService.setPin(newPin);
      await widget.controller.toggleLock(true);
      widget.ref.invalidate(hasPinProvider);
      HapticFeedback.mediumImpact();

      if (!mounted) return;
      _popDialog(context);
      if (widget.rootContext.mounted) {
        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
          SnackBar(content: Text(widget.rootContext.l10n.success)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorText = 'PIN kaydedilemedi: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(context.tr('create_new_pin'), style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PinField(controller: _newPinController, label: context.l10n.lockSetPin, enabled: !_isSaving),
            const SizedBox(height: 12),
            _PinField(controller: _confirmPinController, label: context.l10n.lockConfirmPin, enabled: !_isSaving),
            if (_errorText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_errorText, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isSaving ? null : () => _popDialog(context), child: Text(context.l10n.cancel)),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(context.l10n.save),
        ),
      ],
    );
  }
}

class _PinDisableDialog extends StatefulWidget {
  const _PinDisableDialog({
    required this.ref,
    required this.controller,
    required this.rootContext,
  });

  final WidgetRef ref;
  final SettingsController controller;
  final BuildContext rootContext;

  @override
  State<_PinDisableDialog> createState() => _PinDisableDialogState();
}

class _PinDisableDialogState extends State<_PinDisableDialog> {
  late final TextEditingController _pinController;
  bool _isVerifying = false;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _confirmDisable() async {
    final pin = _pinController.text.trim();
    if (!PinService.isValidPinFormat(pin)) {
      setState(() => _errorText = context.l10n.lockPinIncorrect);
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorText = '';
    });

    try {
      final pinService = widget.ref.read(pinServiceProvider);
      final verified = await pinService.verifyPin(pin);
      if (!verified) {
        if (mounted) {
          setState(() {
            _isVerifying = false;
            _errorText = context.l10n.lockPinIncorrect;
          });
        }
        return;
      }

      await widget.controller.toggleLock(false);
      await widget.controller.toggleBiometric(false);
      AnalyticsService.log(AnalyticsService.appLockDisabled);
      HapticFeedback.mediumImpact();

      if (!mounted) return;
      _popDialog(context);
      if (widget.rootContext.mounted) {
        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
          SnackBar(content: Text(widget.rootContext.l10n.success)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorText = context.l10n.lockPinIncorrect;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(context.l10n.appLock, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('pin_disable_desc'),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            _PinField(controller: _pinController, label: context.tr('current_pin'), enabled: !_isVerifying),
            if (_errorText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_errorText, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => _popDialog(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: _isVerifying ? null : _confirmDisable,
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: _isVerifying
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(context.tr('btn_disable')),
        ),
      ],
    );
  }
}

class _PinChangeDialog extends StatefulWidget {
  const _PinChangeDialog({
    required this.ref,
    required this.rootContext,
  });

  final WidgetRef ref;
  final BuildContext rootContext;

  @override
  State<_PinChangeDialog> createState() => _PinChangeDialogState();
}

class _PinChangeDialogState extends State<_PinChangeDialog> {
  late final TextEditingController _currentPinController;
  late final TextEditingController _newPinController;
  late final TextEditingController _confirmPinController;
  bool _isSaving = false;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _currentPinController = TextEditingController();
    _newPinController = TextEditingController();
    _confirmPinController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final currentPin = _currentPinController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (currentPin.length != 6 || newPin.length != 6 || confirmPin.length != 6) {
      setState(() => _errorText = context.l10n.lockPinMismatch);
      return;
    }

    if (newPin != confirmPin) {
      setState(() => _errorText = context.l10n.lockPinMismatch);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = '';
    });

    try {
      final pinService = widget.ref.read(pinServiceProvider);
      final verified = await pinService.verifyPin(currentPin);
      if (!verified) {
        if (mounted) {
          setState(() {
            _isSaving = false;
            _errorText = context.l10n.lockPinIncorrect;
          });
        }
        return;
      }

      await pinService.setPin(newPin);
      HapticFeedback.mediumImpact();

      if (!mounted) return;
      _popDialog(context);
      if (widget.rootContext.mounted) {
        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
          SnackBar(content: Text(widget.rootContext.l10n.success)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorText = context.l10n.lockPinIncorrect;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.changePin),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PinField(controller: _currentPinController, label: context.tr('current_pin'), enabled: !_isSaving),
            const SizedBox(height: 12),
            _PinField(controller: _newPinController, label: context.tr('new_pin'), enabled: !_isSaving),
            const SizedBox(height: 12),
            _PinField(controller: _confirmPinController, label: context.l10n.lockConfirmPin, enabled: !_isSaving),
            if (_errorText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_errorText, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isSaving ? null : () => _popDialog(context), child: Text(context.l10n.cancel)),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(context.l10n.save),
        ),
      ],
    );
  }
}
