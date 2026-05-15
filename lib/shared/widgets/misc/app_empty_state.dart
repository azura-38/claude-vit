import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_visuals.dart';

class EmptyStateShortcut {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  EmptyStateShortcut({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class AppEmptyState extends ConsumerWidget {
  final IconData? icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<EmptyStateShortcut>? shortcuts;

  const AppEmptyState({
    super.key,
    this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.shortcuts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTheme = ref.watch(themeTypeProvider);
    final visuals = ThemeVisuals.of(selectedTheme);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: visuals.softGradient,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.04),
            ),
            boxShadow: [
              BoxShadow(
                color: visuals.primary.withValues(alpha: isDark ? 0.18 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: visuals.gradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: visuals.primary.withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  icon ?? visuals.placeholderIcon,
                  size: 46,
                  color: Colors.white,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(
                      actionLabel!,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: visuals.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
              ],
              if (shortcuts != null && shortcuts!.isNotEmpty) ...[
                const SizedBox(height: 40),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: shortcuts!.map((s) => _buildShortcut(s, isDark, visuals)).toList(),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcut(EmptyStateShortcut s, bool isDark, ThemeVisuals visuals) {
    return InkWell(
      onTap: s.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(s.icon, size: 14, color: visuals.primary),
            const SizedBox(width: 8),
            Text(
              s.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
