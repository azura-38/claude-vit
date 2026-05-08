import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/types/runtime_types.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../providers/auth_providers.dart';

class AppLockGate extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndAuth();
    });
  }

  Future<void> _checkAndAuth() async {
    final lockEnabled = ref.read(appLockEnabledProvider);
    final lockState = ref.read(appLockStateProvider);
    final biometricEnabled = ref.read(biometricEnabledProvider);

    if (lockEnabled && lockState == AppLockState.locked && !_isAuthenticating) {
      // Only attempt biometric if it's enabled
      if (!biometricEnabled) return;
      
      setState(() => _isAuthenticating = true);
      final success = await ref.read(appLockServiceProvider).authenticate();
      if (success && mounted) {
        ref.read(appLockStateProvider.notifier).setUnlocked();
      }
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(appLockStateProvider);
    final isEnabled = ref.watch(appLockEnabledProvider);

    // Listen for state changes to re-trigger if needed (e.g. manual lock)
    ref.listen(appLockStateProvider, (prev, next) {
      if (next == AppLockState.locked) {
        _checkAndAuth();
      }
    });

    if (!isEnabled || lockState == AppLockState.unlocked) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_rounded, 
                size: 64, 
                color: isDark ? Colors.blue.shade400 : Colors.blue.shade700
              ),
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n('lock_gate_title'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                context.l10n('lock_gate_desc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 48),
            if (_isAuthenticating)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _checkAndAuth,
                icon: const Icon(Icons.fingerprint_rounded),
                label: Text(context.l10n('lock_gate_unlock')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
