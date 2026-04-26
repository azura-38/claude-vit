import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../providers/navigation_provider.dart';
import '../../core/utils/external_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Quick access grid matching the React "Keşfet" floating menu.
class ExploreMenu extends ConsumerWidget {
  final VoidCallback onClose;

  const ExploreMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onClose,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Backdrop blur
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: (isDark ? Colors.black : Colors.white).withValues(
                  alpha: isDark ? 0.7 : 0.4,
                ),
              ),
            ),
            // Menu
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 80,
                    ),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n('quick_access'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color:
                                    isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                              ),
                            ),
                            GestureDetector(
                              onTap: onClose,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? AppColors.bgDark
                                          : AppColors.bgLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color:
                                      isDark
                                          ? Colors.white54
                                          : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ExploreItem(
                              icon: Icons.description_rounded,
                              label: context.l10n('vault'),
                              color: AppColors.medicalBlue,
                              onTap: () {
                                ref
                                    .read(navigationProvider.notifier)
                                    .setIndex(1);
                                onClose();
                              },
                              index: 0,
                            ),
                            _ExploreItem(
                              icon: Icons.location_on_rounded,
                              label: context.l10n('pharmacies'),
                              color: AppColors.success,
                              onTap: () => ExternalLauncher.launchMapSearch(context.l10n('pharmacies')),
                              index: 1,
                            ),
                            _ExploreItem(
                              icon: Icons.medication_rounded,
                              label: context.l10n('medicines'),
                              color: AppColors.orange400,
                              onTap: () {
                                context.pushNamed('medicines');
                                onClose();
                              },
                              index: 2,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ExploreItem(
                              icon: Icons.calendar_month_rounded,
                              label: context.l10n('appointments'),
                              color: const Color(0xFFF43F5E),
                              onTap: () {
                                ref
                                    .read(navigationProvider.notifier)
                                    .setIndex(3);
                                onClose();
                              },
                              index: 3,
                            ),
                            _ExploreItem(
                              icon: Icons.favorite_rounded,
                              label: context.l10n('health_data'),
                              color: const Color(0xFF14B8A6),
                              onTap: () {
                                context.pushNamed('healthStats');
                                onClose();
                              },
                              index: 4,
                            ),
                            _ExploreItem(
                              icon: Icons.info_outline_rounded,
                              label: context.l10n('important_info'),
                              color: const Color(0xFFEF4444),
                              onTap: () {
                                context.pushNamed('medicalInfo');
                                onClose();
                              },
                              index: 5,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _ExploreItem(
                              icon: Icons.emoji_events_rounded,
                              label: "Medals",
                              color: Colors.amber,
                              onTap: () {
                                context.pushNamed('achievements');
                                onClose();
                              },
                              index: 6,
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int index;

  const _ExploreItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ],
      ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
    );
  }
}
