import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/domain/entities/document.dart';
import '../../../../shared/domain/enums/document_category.dart';
import '../providers/vault_controller.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/constants/app_routes.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_provider.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';
import '../widgets/vault_swipe_card.dart';
import '../widgets/secure_banner.dart';
import 'document_quick_view_screen.dart';

enum _VaultSortMode { newest, oldest, nameAZ }

class DocumentVaultScreen extends ConsumerStatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  ConsumerState<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends ConsumerState<DocumentVaultScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  DocumentCategory? _selectedCategory;
  _VaultSortMode _sortMode = _VaultSortMode.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openQuickView(BuildContext context, Document doc) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentQuickViewScreen(document: doc)));
  }

  Future<void> _confirmDelete(BuildContext context, Document doc) async {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isTr ? 'Belge silinsin mi?' : 'Delete document?'),
        content: Text(isTr ? 'Bu belge kasadan kaldırılacak. Bu işlem geri alınamaz.' : 'This document will be removed from the vault. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(isTr ? 'İptal' : 'Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(dialogContext, true), child: Text(isTr ? 'Sil' : 'Delete')),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(vaultControllerProvider.notifier).deleteDocument(doc.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isTr ? 'Belge silindi.' : 'Document deleted.')));
  }

  List<Document> _visibleDocuments(List<Document> documents) {
    final normalizedQuery = _query.trim().toLowerCase();
    var result = documents.where((doc) {
      final matchesCategory = _selectedCategory == null || doc.category == _selectedCategory;
      if (!matchesCategory) return false;
      if (normalizedQuery.isEmpty) return true;

      final haystack = [
        doc.fileName,
        doc.hospitalName ?? '',
        doc.doctorName ?? '',
        doc.note ?? '',
        doc.tagLabel ?? '',
        doc.category.name,
      ].join(' ').toLowerCase();
      return haystack.contains(normalizedQuery);
    }).toList();

    switch (_sortMode) {
      case _VaultSortMode.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _VaultSortMode.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case _VaultSortMode.nameAZ:
        result.sort((a, b) => a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()));
        break;
    }
    return result;
  }

  String _sortLabel(BuildContext context, _VaultSortMode mode) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    return switch (mode) {
      _VaultSortMode.newest => isTr ? 'Yeni → Eski' : 'Newest first',
      _VaultSortMode.oldest => isTr ? 'Eski → Yeni' : 'Oldest first',
      _VaultSortMode.nameAZ => isTr ? 'A-Z' : 'A-Z',
    };
  }

  String _allLabel(BuildContext context) => Localizations.localeOf(context).languageCode == 'tr' ? 'Tümü' : 'All';

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(fontSize: 15, color: isDark ? Colors.white60 : AppColors.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 20),
            const SecureBanner(),
            const SizedBox(height: 20),
            _VaultControls(
              isDark: isDark,
              controller: _searchController,
              query: _query,
              selectedCategory: _selectedCategory,
              sortMode: _sortMode,
              allLabel: _allLabel(context),
              sortLabel: (mode) => _sortLabel(context, mode),
              categoryLabel: (category) => _localizedCategory(context, category),
              onSearchChanged: (value) => setState(() => _query = value),
              onCategoryChanged: (value) => setState(() => _selectedCategory = value),
              onSortChanged: (value) => setState(() => _sortMode = value),
              onClear: () {
                setState(() {
                  _query = '';
                  _searchController.clear();
                  _selectedCategory = null;
                  _sortMode = _VaultSortMode.newest;
                });
              },
            ),
            const SizedBox(height: 24),
            documentsAsync.when(
              data: (documents) {
                final visibleDocuments = _visibleDocuments(documents);
                if (documents.isEmpty) {
                  return _EmptyVaultState(isDark: isDark, selectedTheme: selectedTheme, onAdd: () => context.push(AppRoutes.documentAdd));
                }
                if (visibleDocuments.isEmpty) {
                  return _NoMatchingDocumentsState(isDark: isDark, onClear: () {
                    setState(() {
                      _query = '';
                      _searchController.clear();
                      _selectedCategory = null;
                      _sortMode = _VaultSortMode.newest;
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

class _VaultControls extends StatelessWidget {
  const _VaultControls({
    required this.isDark,
    required this.controller,
    required this.query,
    required this.selectedCategory,
    required this.sortMode,
    required this.allLabel,
    required this.sortLabel,
    required this.categoryLabel,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onSortChanged,
    required this.onClear,
  });

  final bool isDark;
  final TextEditingController controller;
  final String query;
  final DocumentCategory? selectedCategory;
  final _VaultSortMode sortMode;
  final String allLabel;
  final String Function(_VaultSortMode mode) sortLabel;
  final String Function(DocumentCategory category) categoryLabel;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DocumentCategory?> onCategoryChanged;
  final ValueChanged<_VaultSortMode> onSortChanged;
  final VoidCallback onClear;

  bool get _hasActiveFilter => query.trim().isNotEmpty || selectedCategory != null || sortMode != _VaultSortMode.newest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: context.l10n.docsSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: query.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.brandMist,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<DocumentCategory?>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    labelText: context.l10n.category,
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.brandMist,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                  ),
                  items: [
                    DropdownMenuItem<DocumentCategory?>(value: null, child: Text(allLabel)),
                    ...DocumentCategory.values.map((category) => DropdownMenuItem<DocumentCategory?>(value: category, child: Text(categoryLabel(category)))),
                  ],
                  onChanged: onCategoryChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<_VaultSortMode>(
                  initialValue: sortMode,
                  decoration: InputDecoration(
                    labelText: Localizations.localeOf(context).languageCode == 'tr' ? 'Sırala' : 'Sort',
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.brandMist,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                  ),
                  items: _VaultSortMode.values.map((mode) => DropdownMenuItem(value: mode, child: Text(sortLabel(mode)))).toList(),
                  onChanged: (value) {
                    if (value != null) onSortChanged(value);
                  },
                ),
              ),
            ],
          ),
          if (_hasActiveFilter) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: Text(context.tr('clear_filters')),
              ),
            ),
          ],
        ],
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
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.cardBorderLight),
          ),
          child: Image.asset(
            'assets/images/vitacase_brand_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.folder_copy_rounded, color: AppColors.medicalBlue),
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

class _NoMatchingDocumentsState extends StatelessWidget {
  const _NoMatchingDocumentsState({required this.isDark, required this.onClear});

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

class _EmptyVaultState extends StatelessWidget {
  const _EmptyVaultState({required this.isDark, required this.selectedTheme, required this.onAdd});

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
