import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../providers/shared_prefs_provider.dart';
import '../../../data/services/analytics_service.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _isAuthenticating = false;
  String _enteredPin = "";
  bool _isSetupMode = false;
  String _setupPin = "";

  // Brute-force protection
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;
  static const _failedAttemptsKey = 'pin_failed_attempts';
  static const _lockoutUntilKey = 'pin_lockout_until';

  @override
  void initState() {
    super.initState();
    _loadBruteForceState();
    _checkPinStatus();
  }

  void _loadBruteForceState() {
    final prefs = ref.read(sharedPreferencesProvider);
    _failedAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;
    final lockoutStr = prefs.getString(_lockoutUntilKey);
    if (lockoutStr != null) {
      _lockoutUntil = DateTime.tryParse(lockoutStr);
      if (_lockoutUntil != null && DateTime.now().isAfter(_lockoutUntil!)) {
        _lockoutUntil = null;
        _failedAttempts = 0;
        _persistBruteForceState();
      }
    }
  }

  Future<void> _persistBruteForceState() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_failedAttemptsKey, _failedAttempts);
    if (_lockoutUntil != null) {
      await prefs.setString(_lockoutUntilKey, _lockoutUntil!.toIso8601String());
    } else {
      await prefs.remove(_lockoutUntilKey);
    }
  }

  Duration _getLockoutDuration() {
    if (_failedAttempts >= 15) return const Duration(minutes: 5);
    if (_failedAttempts >= 10) return const Duration(minutes: 2);
    if (_failedAttempts >= 5) return const Duration(seconds: 30);
    return Duration.zero;
  }

  Future<void> _checkPinStatus() async {
    final hasPin = await ref.read(hasPinProvider.future);
    if (!hasPin) {
      setState(() => _isSetupMode = true);
    } else {
      _authenticateBiometrics();
    }
  }

  Future<void> _authenticateBiometrics() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    final service = ref.read(appLockServiceProvider);
    final success = await service.authenticate();

    if (mounted && success) {
      _failedAttempts = 0;
      _lockoutUntil = null;
      _persistBruteForceState();
      ref.read(appLockStateProvider.notifier).setUnlocked();
    } else if (mounted && !success) {
      AnalyticsService.log(AnalyticsService.biometricAuthFailed);
    }
    if (mounted) setState(() => _isAuthenticating = false);
  }

  void _handleKeyPress(String value) async {
    // Check lockout
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remaining = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          context.l10n('lock_too_many_attempts')
              .replaceFirst('{seconds}', '$remaining'),
        )),
      );
      return;
    }

    if (_enteredPin.length >= 4) return;
    
    setState(() => _enteredPin += value);

    if (_enteredPin.length == 4) {
      if (_isSetupMode) {
        if (_setupPin.isEmpty) {
          _setupPin = _enteredPin;
          setState(() => _enteredPin = "");
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n('lock_confirm_pin'))),
          );
        } else {
          if (_setupPin == _enteredPin) {
            await ref.read(pinServiceProvider).setPin(_enteredPin);
            ref.read(appLockStateProvider.notifier).setUnlocked();
          } else {
            setState(() {
              _enteredPin = "";
              _setupPin = "";
            });
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n('lock_pin_mismatch'))),
            );
          }
        }
      } else {
        final success = await ref.read(pinServiceProvider).verifyPin(_enteredPin);
        if (success) {
          _failedAttempts = 0;
          _lockoutUntil = null;
          _persistBruteForceState();
          ref.read(appLockStateProvider.notifier).setUnlocked();
        } else {
          _failedAttempts++;
          AnalyticsService.log(AnalyticsService.appLockAuthFail, {'attempts': _failedAttempts});
          final lockoutDuration = _getLockoutDuration();
          if (lockoutDuration > Duration.zero) {
            _lockoutUntil = DateTime.now().add(lockoutDuration);
          }
          _persistBruteForceState();

          setState(() => _enteredPin = "");
          if (!mounted) return;

          if (_lockoutUntil != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(
                context.l10n('lock_too_many_attempts')
                    .replaceFirst('{seconds}', '${lockoutDuration.inSeconds}'),
              )),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n('lock_pin_incorrect'))),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.heroStart,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Icon(
              _isSetupMode ? Icons.security_rounded : Icons.lock_person_rounded,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              _isSetupMode 
                ? (_setupPin.isEmpty ? context.l10n('lock_set_pin') : context.l10n('lock_confirm_pin'))
                : context.l10n('lock_title'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => _PinDot(filled: index < _enteredPin.length)),
            ),
            const Spacer(),
            _buildKeypad(),
            const SizedBox(height: 20),
            if (!_isSetupMode)
              TextButton.icon(
                onPressed: _authenticateBiometrics,
                icon: const Icon(Icons.fingerprint, color: Colors.white70),
                label: Text(context.l10n('lock_use_biometrics'), style: const TextStyle(color: Colors.white70)),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        for (var row in [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) => _KeyButton(val: key, onTap: () => _handleKeyPress(key))).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 80),
            _KeyButton(val: '0', onTap: () => _handleKeyPress('0')),
            IconButton(
              onPressed: () => setState(() => _enteredPin = _enteredPin.isNotEmpty ? _enteredPin.substring(0, _enteredPin.length - 1) : ""),
              icon: const Icon(Icons.backspace_outlined, color: Colors.white, size: 28),
              style: IconButton.styleFrom(fixedSize: const Size(80, 80)),
            ),
          ],
        ),
      ],
    );
  }
}

class _PinDot extends StatelessWidget {
  final bool filled;
  const _PinDot({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Colors.white : Colors.white24,
        border: Border.all(color: Colors.white54, width: 2),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String val;
  final VoidCallback onTap;
  const _KeyButton({required this.val, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        child: Text(
          val,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
