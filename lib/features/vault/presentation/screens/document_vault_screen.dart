import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/domain/entities/document.dart';
import '../../../../shared/domain/enums/document_category.dart';
import '../../../../shared/providers/custom_tag_providers.dart';
import '../providers/vault_controller.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/constants/app_routes.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_provider.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';
import '../widgets/vault_swipe_card.dart';
import '../widgets/secure_banner.dart';
import '../widgets/vault_controls.dart';
import '../widgets/vault_states.dart';
import '../../../../shared/providers/shared_prefs_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class DocumentVaultScreen extends ConsumerStatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  ConsumerState<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends ConsumerState<DocumentVaultScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  DocumentCategory? _selectedCategory;
  String? _selectedTag;
  VaultSortMode _sortMode = VaultSortMode.newest;

  @override
  void initState() {
    super.initState();
    _checkPinPromotion();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkPinPromotion() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final hasPinValue = await ref.read(hasPinProvider.future);
      if (!hasPinValue) {
        final prefs = ref.read(sharedPreferencesProvider);
        final shownBefore = prefs.getBool('vault_pin_promotion_shown') ?? false;
        if (!shownBefore && mounted) {
          await prefs.setBool('vault_pin_promotion_shown', true);
          if (mounted) {
            _showPinPromotionDialog();
          }
        }
      }
    });
  }

  void _showPinPromotionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gpp_maybe_rounded,
              color: Colors.amber,
              size: 40,
            ),
          ),
          title: Text(
            context.l10n.dataSecurity,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          content: Text(
            context.tr('pin_not_set_desc'),
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(),
              child: Text(
                context.l10n.btnNotNow,
                style: TextStyle(
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                dialogContext.pop();
                context.push(AppRoutes.settings);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                context.l10n.settings,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openQuickView(BuildContext context, Document doc) {
    context.push(AppRoutes.documentQuickView, extra: doc);
  }

  Future<void> _confirmDelete(BuildContext context, Document doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteConfirmDialogTitle),
        content: Text(context.l10n.deleteConfirmDialogDesc),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(false), child: Text(context.l10n.cancel)),
          FilledButton.tonal(onPressed: () => dialogContext.pop(true), child: Text(context.l10n.delete)),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(vaultControllerProvider.notifier).deleteDocument(doc.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.documentDeletedMsg)));
  }

  List<Document> _visibleDocuments(List<Document> documents) {
    final normalizedQuery = _query.trim().toLowerCase();
    var result = documents.where((doc) {
      final matchesCategory = _selectedCategory == null || doc.category == _selectedCategory;
      if (!matchesCategory) return false;

      final matchesTag = _selectedTag == null ||
          doc.tags.any((t) => t.toLowerCase() == _selectedTag!.toLowerCase()) ||
          (doc.tagId != null &&
              doc.tagId!.toLowerCase() == _selectedTag!.toLowerCase());
      if (!matchesTag) return false;

      if (normalizedQuery.isEmpty) return true;

      final haystack = [
        doc.fileName,
        doc.hospitalName ?? '',
        doc.doctorName ?? '',
        doc.note ?? '',
        doc.tagLabel ?? '',
        ...doc.tags,
        doc.category.name,
      ].join(' ').toLowerCase();
      return haystack.contains(normalizedQuery);
    }).toList();

    switch (_sortMode) {
      case VaultSortMode.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case VaultSortMode.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case VaultSortMode.nameAZ:
        result.sort((a, b) => a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()));
        break;
    }
    return result;
  }

  String _sortLabel(BuildContext context, VaultSortMode mode) {
    return switch (mode) {
      VaultSortMode.newest => context.l10n.sortNewestFirst,
      VaultSortMode.oldest => context.l10n.sortOldestFirst,
      VaultSortMode.nameAZ => context.l10n.sortAZ,
    };
  }

  String _allLabel(BuildContext context) => context.l10n.all;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTheme = ref.watch(themeTypeProvider);
    final availableTags = ref.watch(allKnownTagsProvider);

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
            VaultHeader(isDark: isDark),
            const SizedBox(height: 12),
            Text(
              context.l10n.docsInfoSecure,
              style: TextStyle(fontSize: 15, color: isDark ? Colors.white60 : AppColors.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 20),
            const SecureBanner(),
            const SizedBox(height: 20),
            VaultControls(
              isDark: isDark,
              controller: _searchController,
              query: _query,
              selectedCategory: _selectedCategory,
              sortMode: _sortMode,
              selectedTag: _selectedTag,
              availableTags: availableTags,
              allLabel: _allLabel(context),
              sortLabel: (mode) => _sortLabel(context, mode),
              categoryLabel: (category) => _localizedCategory(context, category),
              onSearchChanged: (value) => setState(() => _query = value),
              onCategoryChanged: (value) => setState(() => _selectedCategory = value),
              onSortChanged: (value) => setState(() => _sortMode = value),
              onTagChanged: (value) => setState(() => _selectedTag = value),
              onClear: () {
                setState(() {
                  _query = '';
                  _searchController.clear();
                  _selectedCategory = null;
                  _selectedTag = null;
                  _sortMode = VaultSortMode.newest;
                });
              },
            ),
            const SizedBox(height: 24),
            documentsAsync.when(
              data: (documents) {
                final visibleDocuments = _visibleDocuments(documents);
                if (documents.isEmpty) {
                  return EmptyVaultState(isDark: isDark, selectedTheme: selectedTheme, onAdd: () => context.push(AppRoutes.documentAdd));
                }
                if (visibleDocuments.isEmpty) {
                  return NoMatchingDocumentsState(isDark: isDark, onClear: () {
                    setState(() {
                      _query = '';
                      _searchController.clear();
                      _selectedCategory = null;
                      _selectedTag = null;
                      _sortMode = VaultSortMode.newest;
                    });
                  });
                }
                return Column(
                  children: visibleDocuments
                      .map(
                        (doc) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: VaultSwipeCard(
                            document: doc,
                            onDelete: () => _confirmDelete(context, doc),
                            onEdit: () => _openQuickView(context, doc),
                            onTap: () => _openQuickView(context, doc),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
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

  String _localizedCategory(BuildContext context, DocumentCategory category) {
    return switch (category) {
      DocumentCategory.documents => context.tr('docs_title'),
      DocumentCategory.healthPrescriptions => context.tr('docs_category_prescriptions'),
      DocumentCategory.healthReports => context.tr('docs_category_reports'),
      DocumentCategory.healthTestResults => context.tr('docs_category_test_results'),
      DocumentCategory.healthImages => context.tr('docs_category_images'),
      DocumentCategory.identity => context.tr('docs_category_identity'),
      DocumentCategory.finance => context.tr('docs_category_finance'),
      DocumentCategory.legal => context.tr('docs_category_legal'),
      DocumentCategory.notes => context.tr('docs_category_notes'),
      DocumentCategory.other => context.tr('docs_category_other'),
    };
  }
}
