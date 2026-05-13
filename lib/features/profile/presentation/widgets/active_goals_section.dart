import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/health_providers.dart';
import '../providers/legacy_providers.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class ActiveGoalsSection extends ConsumerWidget {
  final bool isDark;
  
  const ActiveGoalsSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(dailyHealthProgressProvider);
    final stepGoal = ref.watch(stepGoalProvider);
    final waterGoal = ref.watch(waterGoalProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context.l10n.activeGoals, isDark),
            const Icon(Icons.bolt_rounded, color: AppColors.medicalBlue, size: 18),
          ],
        ),
        const SizedBox(height: 16),
        _buildGoalProgress(
          context: context,
          icon: Icons.directions_walk_rounded,
          title: context.l10n.dailySteps,
          current: progress['steps']!.toInt(),
          target: stepGoal,
          unit: context.l10n.steps,
          accentColor: AppColors.medicalBlue,
          actionLabel: context.l10n.speedUp,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildGoalProgress(
          context: context,
          icon: Icons.water_drop_rounded,
          title: context.l10n.waterIntake,
          current: (progress['water']! / 1000).toInt(),
          target: (waterGoal / 1000).toInt(),
          unit: context.l10n.literUnit,
          accentColor: const Color(0xFF00B4D8),
          actionLabel: context.l10n.stayFresh,
          isDark: isDark,
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildGoalProgress({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int current,
    required int target,
    required String unit,
    required Color accentColor,
    required String actionLabel,
    required bool isDark,
  }) {
    final percent = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Manrope')),
                    Text('${context.l10n.targetLabel}: $target $unit', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Text('${(percent * 100).toInt()}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: accentColor)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: accentColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$current / $target $unit', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              Text(actionLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: isDark ? Colors.white70 : AppColors.textPrimary,
        fontFamily: 'Manrope',
      ),
    );
  }
}
