import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/services/analytics_service.dart';
import 'package:go_router/go_router.dart';

class ComingSoonDialog extends StatelessWidget {
  const ComingSoonDialog({super.key});

  static void show(BuildContext context) {
    AnalyticsService.log(AnalyticsService.premiumClickDisabled);
    
    showDialog(
      context: context,
      builder: (context) => const ComingSoonDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryIndigo.withValues(alpha: 0.15),
              blurRadius: 40,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🚀 Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                color: AppColors.primaryIndigo,
                size: 64,
              ),
            ).animate(onPlay: (c) => c.repeat())
             .shimmer(duration: 2.seconds)
             .shake(duration: 2.seconds, curve: Curves.easeInOut),

            const SizedBox(height: 32),

            // 💎 Text
            const Text(
              "PREMIUM COMING SOON",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryIndigo,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Something powerful is under development! 🚀",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Be the first to unlock advanced encryption, unlimited storage, and priority access. We're polishing the final bits!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 40),

            // ✅ Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryIndigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: const Text(
                  "STAY TUNED! 🔥",
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale(curve: Curves.elasticOut, duration: 600.ms),
    );
  }
}
