import 'package:flutter/material.dart';

import 'package:vitacase/core/constants/app_colors.dart';

class VitaCaseBottomNav extends StatelessWidget {
  const VitaCaseBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? 
        (isDark ? const Color(0xFF1C252E) : Colors.white);
    final shadowColor = isDark ? Colors.black26 : Colors.black.withValues(alpha: .04);

    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: navBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 30),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_outlined, label: "HOME"),
          _NavItem(icon: Icons.folder_outlined, label: "VAULT"),
          _NavItem(icon: Icons.shield_outlined, label: "SECURITY"),
          _NavItem(icon: Icons.settings, label: "SETTINGS", active: true),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = isDark ? Colors.white38 : AppColors.navInactive;
    final activeBgColor = primaryColor.withValues(alpha: 0.1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? activeBgColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? primaryColor : inactiveColor),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? primaryColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
