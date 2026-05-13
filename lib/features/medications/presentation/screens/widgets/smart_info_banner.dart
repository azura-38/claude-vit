import 'package:flutter/material.dart';
import 'package:vitacase/core/constants/app_colors.dart';

class SmartInfoBanner extends StatelessWidget {
  final String text;

  const SmartInfoBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.brandMist,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.brandBlue.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_rounded,
            color: AppColors.brandBlue,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                height: 1.4,
                color: isDark ? Colors.white70 : AppColors.brandNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
