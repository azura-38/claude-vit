import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

/// Bottom navigation matching the React BottomNavigation component:
/// 5 tabs with a floating Keşfet FAB in the center.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onExploreTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const double barHeight = 64.0;
    const double fabSize = 54.0;
    const double fabTopOffset = 8.0; // Floats 8px above the bar top

    return SizedBox(
      height: barHeight + fabTopOffset + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Background Bar Container
          Container(
            height: barHeight + bottomInset,
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
                  (isDark ? const Color(0xFF1F2937) : Colors.white),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.cardBorderLight,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              bottom: true,
              child: SizedBox(
                height: barHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.home_rounded,
                        label: context.l10n.home,
                        isActive: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                      _NavItem(
                        icon: Icons.description_rounded,
                        label: context.l10n.vault,
                        isActive: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                      // Spacer preserving exact footprint for the floating center Explore button
                      const SizedBox(width: fabSize + 8),
                      _NavItem(
                        icon: Icons.calendar_today_rounded,
                        label: context.l10n.appointments,
                        isActive: currentIndex == 3,
                        onTap: () => onTap(3),
                      ),
                      _NavItem(
                        icon: Icons.person_outline_rounded,
                        label: context.l10n.profile,
                        isActive: currentIndex == 4,
                        onTap: () => onTap(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Floating Center Explore Button
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onExploreTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: fabSize,
                height: fabSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.exploreFabStart,
                      AppColors.exploreFabEnd,
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryIndigo.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.explore_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          context.l10n.explore.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = AppColors.navInactive;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isActive ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isActive ? activeColor : inactiveColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? activeColor : inactiveColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
