import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_bootstrap_controller.dart';
import '../constants/app_colors.dart';
import '../splash/cyber_radar_splash.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

/// Root entry widget for the app.
/// 
/// Shows an animated splash while bootstrap is running,
/// transitions to the real app when done, and shows an error
/// screen with retry if an unrecoverable failure occurs.
class BootstrapScreen extends ConsumerWidget {
  final Widget child;

  const BootstrapScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(appBootstrapProvider);

    return bootstrap.when(
      loading: () => const _SplashLoadingScreen(),
      error: (error, _) => _StartupErrorScreen(
        error: error,
        onRetry: () => ref.invalidate(appBootstrapProvider),
      ),
      data: (_) => child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Splash Screen (Cyber Radar Light / Dark)
// ─────────────────────────────────────────────────────────────────────────────

class _SplashLoadingScreen extends ConsumerWidget {
  const _SplashLoadingScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeTypeProvider);
    final isDark = switch (themeType) {
      AppThemeType.dark => true,
      AppThemeType.system => MediaQuery.platformBrightnessOf(context) == Brightness.dark,
      _ => false,
    };

    return CyberRadarSplash(isDarkMode: isDark);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Startup Error Screen (Matching Light Theme)
// ─────────────────────────────────────────────────────────────────────────────

class _StartupErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _StartupErrorScreen({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Startup Failed',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'VitaCase encountered an issue while starting up.\n'
                'Your data is safe.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryIndigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
