import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// A compact, premium-looking responsibility notice widget.
///
/// Displays a short (1–2 sentence) legal reminder without disrupting
/// form flow. Full legal texts live in `assets/legal/`.
class MiniResponsibilityNotice extends StatelessWidget {
  const MiniResponsibilityNotice({
    super.key,
    required this.icon,
    required this.text,
    required this.accentColor,
  });

  final IconData icon;
  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? accentColor.withValues(alpha: 0.12)
            : accentColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
