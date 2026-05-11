import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_providers.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../../shared/providers/shared_prefs_provider.dart';
import '../../../../../shared/data/services/analytics_service.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with SingleTickerProviderStateMixin {
  bool _isAuthenticating = false;
  String _enteredPin = "";
  bool _isSetupMode = false;
  String _setupPin = "";
  bool _hasError = false;

  // Brute-force protection
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;
  static const _failedAttemptsKey = 'pin_failed_attempts';
  static const _lockoutUntilKey = 'pin_lockout_until';

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadBruteForceState();
    _checkPinStatus();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
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
      // Only try biometrics if enabled
      final biometricEnabled = ref.read(biometricEnabledProvider);
      if (biometricEnabled) {
        _authenticateBiometrics();
      }
    }
  }

  Future<void> _authenticateBiometrics() async {
    if (_isAuthenticating) return;
    final biometricEnabled = ref.read(biometricEnabledProvider);
    if (!biometricEnabled) return;

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
        SnackBar(
          content: Text(
            context.l10n.lockTooManyAttempts.replaceFirst(
              '{seconds}',
              '$remaining',
            ),
          ),
        ),
      );
      return;
    }

    if (_enteredPin.length >= 6) return;

    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin += value;
      _hasError = false;
    });

    if (_enteredPin.length == 6) {
      if (_isSetupMode) {
        if (_setupPin.isEmpty) {
          _setupPin = _enteredPin;
          setState(() => _enteredPin = "");
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.lockConfirmPin)));
        } else {
          if (_setupPin == _enteredPin) {
            await ref.read(pinServiceProvider).setPin(_enteredPin);
            ref.read(appLockStateProvider.notifier).setUnlocked();
          } else {
            _shakeController.forward(from: 0);
            setState(() {
              _enteredPin = "";
              _setupPin = "";
              _hasError = true;
            });
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.lockPinMismatch)),
            );
          }
        }
      } else {
        final success = await ref
            .read(pinServiceProvider)
            .verifyPin(_enteredPin);
        if (success) {
          _failedAttempts = 0;
          _lockoutUntil = null;
          _persistBruteForceState();
          ref.read(appLockStateProvider.notifier).setUnlocked();
        } else {
          _failedAttempts++;
          AnalyticsService.log(AnalyticsService.appLockAuthFail, {
            'attempts': _failedAttempts,
          });
          final lockoutDuration = _getLockoutDuration();
          if (lockoutDuration > Duration.zero) {
            _lockoutUntil = DateTime.now().add(lockoutDuration);
          }
          _persistBruteForceState();

          _shakeController.forward(from: 0);
          setState(() {
            _enteredPin = "";
            _hasError = true;
          });
          if (!mounted) return;

          if (_lockoutUntil != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.l10n.lockTooManyAttempts.replaceFirst(
                    '{seconds}',
                    '${lockoutDuration.inSeconds}',
                  ),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.lockPinIncorrect)),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [const Color(0xFF0A1628), const Color(0xFF162544)]
                    : [const Color(0xFF1A56DB), const Color(0xFF3B82F6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Lock icon with glow
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.08),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  _isSetupMode ? Icons.security_rounded : Icons.lock_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ).animate().scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                _isSetupMode
                    ? (_setupPin.isEmpty
                        ? context.l10n.lockSetPin
                        : context.l10n.lockConfirmPin)
                    : context.l10n.lockTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Manrope',
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 200.ms),
              if (_isSetupMode) ...[
                const SizedBox(height: 8),
                Text(
                  '6 ${context.l10n.digits}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 36),
              // PIN dots with shake animation
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final shake =
                      _shakeController.isAnimating
                          ? 12.0 *
                              (0.5 - _shakeController.value).abs() *
                              (_shakeController.value < 0.5 ? 1 : -1)
                          : 0.0;
                  return Transform.translate(
                    offset: Offset(shake, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    final isFilled = index < _enteredPin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: isFilled ? 18 : 14,
                      height: isFilled ? 18 : 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _hasError
                                ? AppColors.error
                                : (isFilled
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.2)),
                        border: Border.all(
                          color:
                              _hasError
                                  ? AppColors.error.withValues(alpha: 0.6)
                                  : Colors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow:
                            isFilled
                                ? [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                                : null,
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),
              // Keypad
              _buildKeypad(),
              const SizedBox(height: 16),
              // Biometric button
              if (!_isSetupMode && biometricEnabled)
                TextButton.icon(
                  onPressed: _authenticateBiometrics,
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  label: Text(
                    context.l10n.lockUseBiometrics,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          for (var row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    row
                        .map(
                          (key) => _KeyButton(
                            val: key,
                            onTap: () => _handleKeyPress(key),
                          ),
                        )
                        .toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 76, height: 76),
                _KeyButton(val: '0', onTap: () => _handleKeyPress('0')),
                _BackspaceButton(
                  onTap: () {
                    if (_enteredPin.isNotEmpty) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _enteredPin = _enteredPin.substring(
                          0,
                          _enteredPin.length - 1,
                        );
                        _hasError = false;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(38),
        splashColor: Colors.white.withValues(alpha: 0.15),
        highlightColor: Colors.white.withValues(alpha: 0.08),
        child: Container(
          width: 76,
          height: 76,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Text(
            val,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Manrope',
            ),
          ),
        ),
      ),
    );
  }
}

class _BackspaceButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackspaceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(38),
        splashColor: Colors.white.withValues(alpha: 0.15),
        child: SizedBox(
          width: 76,
          height: 76,
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.white.withValues(alpha: 0.7),
            size: 26,
          ),
        ),
      ),
    );
  }
}
