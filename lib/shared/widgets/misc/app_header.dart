import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/ui_utils.dart';

/// Reusable header matching the React <Header> component.
class AppHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final Widget? action;
  final IconData? leadIcon;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.action,
    this.leadIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color:
                isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (showBack)
              GestureDetector(
                onTap: () => context.safePop(fallbackRoute: '/home'),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              )
            else if (leadIcon != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    leadIcon,
                    color: AppColors.primaryIndigo,
                    size: 20,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icons/logo.png',
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}
