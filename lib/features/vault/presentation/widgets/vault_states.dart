import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/constants/app_routes.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';

class VaultHeader extends StatelessWidget {
  const VaultHeader({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.cardBorderLight),
          ),
          child: Image.asset(
            'assets/images/vitacase_brand_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(Icons.folder_copy_rounded, color: AppColors.medicalBlue),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(context.l10n.docsTitle, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900))),
        IconButton.filledTonal(
          onPressed: () => context.push(AppRoutes.documentAdd),
          icon: const Icon(Icons.add_rounded),
          tooltip: context.l10n.addDocument,
        ),
      ],
    );
  }
}

class NoMatchingDocumentsState extends StatelessWidget {
  const NoMatchingDocumentsState({super.key, required this.isDark, required this.onClear});

  final bool isDark;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.medicalBlue),
          const SizedBox(height: 12),
          Text(context.tr('docs_no_results'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(context.tr('docs_try_different'), textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary)),
          const SizedBox(height: 16),
          OutlinedButton.icon(onPressed: onClear, icon: const Icon(Icons.filter_alt_off_rounded), label: Text(context.tr('clear_filters'))),
        ],
      ),
    );
  }
}

class WebVaultPreviewState extends StatelessWidget {
  const WebVaultPreviewState({super.key, required this.isDark, required this.selectedTheme});

  final bool isDark;
  final dynamic selectedTheme;

  @override
  Widget build(BuildContext context) {
    final visuals = ThemeVisuals.of(selectedTheme);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: visuals.softGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorderLight),
        boxShadow: [BoxShadow(color: visuals.primary.withValues(alpha: 0.14), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: Column(
        children: [
          ThemePlaceholder(type: selectedTheme, size: 74, iconSize: 34, radius: 24),
          const SizedBox(height: 16),
          Text(context.l10n.docsSecureStorageTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(context.l10n.docsSecureStorageDesc, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary, height: 1.45)),
        ],
      ),
    );
  }
}

class EmptyVaultState extends StatelessWidget {
  const EmptyVaultState({super.key, required this.isDark, required this.selectedTheme, required this.onAdd});

  final bool isDark;
  final dynamic selectedTheme;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final visuals = ThemeVisuals.of(selectedTheme);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: visuals.softGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorderLight),
        boxShadow: [BoxShadow(color: visuals.primary.withValues(alpha: 0.14), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: Column(
        children: [
          ThemePlaceholder(type: selectedTheme, size: 80, iconSize: 38, radius: 26),
          const SizedBox(height: 18),
          Text(context.l10n.docsEmptyTitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(context.l10n.docsEmptySubtitle, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary, height: 1.45)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: visuals.primary),
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.docsAddTitle),
            ),
          ),
        ],
      ),
    );
  }
}
