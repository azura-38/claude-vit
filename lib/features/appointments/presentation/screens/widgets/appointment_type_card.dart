import 'package:flutter/material.dart';
import 'package:vitacase/core/constants/app_colors.dart';

class AppointmentTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const AppointmentTypeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppColors.brandMist
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                selected
                    ? AppColors.brandBlue
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.brandBlue : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color:
                      selected
                          ? AppColors.brandBlue
                          : (isDark ? Colors.white70 : AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
