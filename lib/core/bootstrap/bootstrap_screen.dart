import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_bootstrap_controller.dart';
import '../constants/app_colors.dart';
import '../splash/cyber_radar_splash.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../../shared/data/datasources/sembast_database.dart';

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
      error: (error, _) => StartupErrorScreen(
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

@visibleForTesting
class StartupErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const StartupErrorScreen({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDbRecovery = error is DatabaseRecoveryRequiredException;

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
                child: Icon(
                  isDbRecovery ? Icons.lock_outline_rounded : Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isDbRecovery ? 'Veritabanı Başlatılamadı' : 'Başlatma Hatası',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isDbRecovery
                    ? 'Şifrelenmiş yerel veritabanına şu anda erişilemedi. Mevcut dosyalarınız otomatik olarak silinmemiştir ve korunmaktadır.\n\nKalıcı veri kaybını önlemek için lütfen uygulama verilerini temizlemeyin ve uygulamayı cihazınızdan kaldırmayın. Cihazınızı yeniden başlatıp tekrar deneyebilirsiniz.'
                    : 'VitaCase başlatılırken beklenmeyen bir sorunla karşılaştı.\n\nKalıcı veri kaybını önlemek için lütfen uygulama verilerini temizlemeyin ve uygulamayı cihazınızdan kaldırmayın. Lütfen tekrar deneyin.',
                style: const TextStyle(
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
                  child: Text(
                    isDbRecovery ? 'Yeniden Dene' : 'Try Again',
                    style: const TextStyle(
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
