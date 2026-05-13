import 'package:flutter/material.dart';

class PrioritySelector extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const PrioritySelector({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.color,
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
                  ? color.withValues(alpha: 0.1)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                selected
                    ? color
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
