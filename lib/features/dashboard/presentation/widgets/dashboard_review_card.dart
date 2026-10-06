import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/data/services/review_service.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_provider.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';
import '../../../../shared/providers/shared_prefs_provider.dart';

class DashboardReviewCard extends ConsumerStatefulWidget {
  const DashboardReviewCard({super.key});

  static const String keyDismissed = 'review_card_dismissed';
  static const String keyCompleted = 'review_card_completed';
  static const String keyLaunchCount = 'app_launch_count';

  @override
  ConsumerState<DashboardReviewCard> createState() => _DashboardReviewCardState();
}

class _DashboardReviewCardState extends ConsumerState<DashboardReviewCard> {
  bool _dismissedLocally = false;

  Future<void> _handleDismiss() async {
    setState(() => _dismissedLocally = true);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(DashboardReviewCard.keyDismissed, true);
  }

  Future<void> _handleReview() async {
    setState(() => _dismissedLocally = true);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(DashboardReviewCard.keyCompleted, true);

    await ref.read(reviewServiceProvider).requestReviewOrOpenStore();
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissedLocally) return const SizedBox.shrink();

    final prefs = ref.watch(sharedPreferencesProvider);
    final launchCount = prefs.getInt(DashboardReviewCard.keyLaunchCount) ?? 0;
    final isDismissed = prefs.getBool(DashboardReviewCard.keyDismissed) ?? false;
    final isCompleted = prefs.getBool(DashboardReviewCard.keyCompleted) ?? false;

    // Show only on the 5th launch, and only if not dismissed or completed before
    if (launchCount < 5 || isDismissed || isCompleted) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: visuals.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: visuals.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: visuals.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('review_prompt_title'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.brandNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('review_prompt_desc'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _handleDismiss,
                icon: const Icon(Icons.close_rounded, size: 20),
                color: isDark ? Colors.white54 : AppColors.textSecondary,
                tooltip: context.tr('cancel'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.icon(
              onPressed: _handleReview,
              icon: const Icon(Icons.rate_review_rounded, size: 18),
              label: Text(
                context.tr('review_prompt_action'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: visuals.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
}
}
