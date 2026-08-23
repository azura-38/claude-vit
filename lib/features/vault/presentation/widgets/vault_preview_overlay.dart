import 'package:flutter/material.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/constants/app_colors.dart';

class VaultPreviewOverlay extends StatelessWidget {
  const VaultPreviewOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.brandMist,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_off_rounded,
            size: 48,
            color: isDark ? Colors.white38 : AppColors.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.previewComingSoon,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.previewComingSoonDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
