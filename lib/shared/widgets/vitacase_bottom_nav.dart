import 'package:flutter/material.dart';

import '../../core/theme/vitacase_theme.dart';

class VitaCaseBottomNav extends StatelessWidget {
  const VitaCaseBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(34),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 30,
          )
        ],
      ),
      child: const Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            label: "HOME",
          ),
          _NavItem(
            icon: Icons.folder_outlined,
            label: "VAULT",
          ),
          _NavItem(
            icon: Icons.shield_outlined,
            label: "SECURITY",
          ),
          _NavItem(
            icon: Icons.settings,
            label: "SETTINGS",
            active: true,
          ),
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
    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: active
            ? VitaColors.softBlue
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active
                ? VitaColors.primary
                : VitaColors.secondary,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active
                  ? VitaColors.primary
                  : VitaColors.secondary,
            ),
          )
        ],
      ),
    );
  }
}
