import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

class RewardDialog extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const RewardDialog({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.emoji_events_rounded,
    this.color = Colors.amber,
  });

  static void show(BuildContext context, {
    required String title,
    required String description,
    IconData icon = Icons.emoji_events_rounded,
    Color color = Colors.amber,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => RewardDialog(
        title: title,
        description: description,
        icon: icon,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDark : Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🌟 Animated Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 64),
            ).animate(onPlay: (c) => c.repeat())
             .shimmer(duration: 2.seconds)
             .scale(duration: 1.seconds, curve: Curves.elasticOut),
            
            const SizedBox(height: 24),
            
            // 🎉 Text Info
            Text(
              "CONGRATULATIONS!",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // ✅ Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.medicalBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text(
                  "AWESOME!",
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
