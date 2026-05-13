import 'package:flutter/material.dart';
import 'package:vitacase/core/constants/app_colors.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;

  const PremiumCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: AppColors.brandBlue.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: child,
    );
  }
}
