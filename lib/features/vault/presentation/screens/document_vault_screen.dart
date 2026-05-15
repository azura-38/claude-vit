import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/vault_controller.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/constants/app_routes.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_provider.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';
import '../widgets/vault_swipe_card.dart';
import '../widgets/secure_banner.dart';
import 'document_quick_view_screen.dart';

class DocumentVaultScreen extends ConsumerWidget {
  const DocumentVaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTheme = ref.watch(themeTypeProvider);

    if (kIsWeb) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              _VaultHeader(isDark: isDark),
              const SizedBox(height: 20),
              const SecureBanner(),
              const SizedBox(height: 32),
              _WebVaultPreviewState(isDark: isDark, selectedTheme: selectedTheme),
            ],
          ),
        ),
      );
    }

    final documentsAsync = ref.watch(vaultControllerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'documentVaultFab',
        onPressed: () => context.push(AppRoutes.documentAdd),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.add),
        backgroundColor: ThemeVisuals.of(selectedTheme).primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            _VaultHeader(isDark: isDark),
            const SizedBox(height: 12),
            Text(
              context.l10n.docsInfoSecure,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            const SecureBanner(),
            const SizedBox(height: 24),
            documentsAsync.when(
              data: (documents) => documents.isEmpty
                  ? _EmptyVaultState(
                      isDark: isDark,
                      selectedTheme: selectedTheme,
                      onAdd: () => context.push(AppRoutes.documentAdd),
                    )
                  : Column(
                      children: documents
                          .map(
                            (doc) => Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: VaultSwipeCard(
                                document: doc,
                                onDelete: () => ref
                                    .read(vaultControllerProvider.notifier)
                                    .deleteDocument(doc.id),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DocumentQuickViewScreen(document: doc),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    '${context.l10n.error}: $err',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaultHeader extends StatelessWidget {
  const _VaultHeader({required this.isDark});

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
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.cardBorderLight,
            ),
          ),
          child: Image.asset(
            'assets/images/vitacase_brand_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.folder_copy_rounded, color: AppColors.medicalBlue),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            context.l10n.docsTitle,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => context.push(AppRoutes.documentAdd),
          icon: const Icon(Icons.add_rounded),
          tooltip: context.l10n.addDocument,
        ),
      ],
    );
  }
}

class _WebVaultPreviewState extends StatelessWidget {
  const _WebVaultPreviewState({required this.isDark, required this.selectedTheme});

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
        boxShadow: [
          BoxShadow(
            color: visuals.primary.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          ThemePlaceholder(type: selectedTheme, size: 74, iconSize: 34, radius: 24),
          const SizedBox(height: 16),
          Text(
            context.l10n.docsSecureStorageTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.docsSecureStorageDesc,
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _EmptyVaultState extends StatelessWidget {
  const _EmptyVaultState({
    required this.isDark,
    required this.selectedTheme,
    required this.onAdd,
  });

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
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.cardBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: visuals.primary.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          ThemePlaceholder(
            type: selectedTheme,
            size: 80,
            iconSize: 38,
            radius: 26,
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.docsEmptyTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.docsEmptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              height: 1.45,
            ),
          ),
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
