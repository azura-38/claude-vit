import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_provider.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';
import '../../../../shared/providers/navigation_provider.dart';

class CtaFeatureCard extends ConsumerWidget {
  const CtaFeatureCard({super.key});
  static const _featureOverviewAsset = 'assets/images/vitacase_feature_overview.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return GestureDetector(
      onTap: () => ref.read(navigationProvider.notifier).setIndex(1),
      child: Container(
        height: 232,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
          boxShadow: [
            if (!isDark)
              BoxShadow(color: visuals.primary.withValues(alpha: 0.12), blurRadius: 28, offset: const Offset(0, 16)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(top: 0, left: 0, right: 0, height: 126, child: Image.asset(_featureOverviewAsset, fit: BoxFit.cover)),
            Positioned(
              top: 82,
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0),
                      isDark ? AppColors.surfaceDark : Colors.white,
                      isDark ? AppColors.surfaceDark : Colors.white,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 130, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.allRecords,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.brandNavy),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: visuals.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: Icon(Icons.chevron_right_rounded, color: visuals.primary),
                      ),
                    ],
                  ),
                  Text(
                    context.l10n.vaultDesc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : AppColors.textSecondary, fontWeight: FontWeight.w500, height: 1.35),
                  ),
                  Row(
                    children: [
                      _HeroChip(icon: Icons.folder_rounded, label: context.l10n.vault),
                      const SizedBox(width: 8),
                      _HeroChip(icon: Icons.calendar_today_rounded, label: context.l10n.appointments),
                      const SizedBox(width: 8),
                      _HeroChip(icon: Icons.medication_rounded, label: context.l10n.medicines),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _HeroChip extends ConsumerWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : visuals.softBackground.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : visuals.primary.withValues(alpha: 0.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: visuals.primary),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : AppColors.brandNavy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
