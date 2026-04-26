import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/enums/document_category.dart';
import '../../../domain/entities/document.dart';
import '../../providers/document_providers.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_header.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/app_empty_state.dart';
import '../../providers/limit_providers.dart';
import '../../widgets/limits/limit_dialog.dart';
import '../../widgets/app_search_bar.dart';
import '../../../data/services/limit_service.dart';
import '../../../data/services/analytics_service.dart';
import '../../providers/premium_provider.dart';

import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'widgets/document_items.dart';
import 'widgets/add_document_sheet.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  String _searchTerm = '';
  String _filter = 'all';
  // Not final – updated by category filter chips
  DocumentCategory _categoryFilter = DocumentCategory.other;
  bool _isAllCategories = true;
  bool _isGridView = false;
  bool _isDecrypting = false;

  Future<void> _showAddSheet(BuildContext context, {DocumentCategory? initialCategory}) async {
    // If not in update mode (widget.document == null), check limit
    final docs = ref.read(documentListProvider).asData?.value ?? [];
    
    final canAdd = LimitService.canAdd(
      current: docs.length,
      baseLimit: LimitService.documentLimit,
      extra: ref.read(limitProvider).extraDocs,
      isPremium: ref.read(premiumProvider),
    );

    if (!canAdd) {
      if (mounted) {
        showLimitDialog(
          context,
          title: context.l10n('limit_docs_title'),
          description: context.l10n('limit_docs_desc'),
          onRewardEarned: () {
            ref.read(limitProvider.notifier).increaseExtraDocs(5);
            ref.read(limitProvider.notifier).onRewardedAdCompleted();
          },
        );
      }
      return;
    }

    await showModalBottomSheet<Document?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddDocumentSheet(initialCategory: initialCategory),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final docsAsync = ref.watch(documentListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        AppHeader(
                          title: context.l10n('docs_title'),
                          leadIcon: Icons.folder_shared_rounded, // Vault icon
                          action: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (docsAsync.asData?.value.length ?? 0) >= (25 + ref.watch(limitProvider).extraDocs) 
                                      ? AppColors.error.withValues(alpha: 0.1) 
                                      : AppColors.primaryIndigo.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${docsAsync.asData?.value.length ?? 0} / ${25 + ref.watch(limitProvider).extraDocs}",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: (docsAsync.asData?.value.length ?? 0) >= (25 + ref.watch(limitProvider).extraDocs) 
                                        ? AppColors.error 
                                        : AppColors.primaryIndigo,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _showAddSheet(context),
                                icon: const Icon(Icons.add, size: 14),
                                label: Text(context.l10n('btn_add'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryIndigo,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  minimumSize: const Size(0, 32),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              AppSearchBar(
                                hint: context.l10n('docs_search_hint'),
                                onChanged: (v) => setState(() => _searchTerm = v),
                              ),
                              const SizedBox(height: 12),
                              // Filter and Toggle row
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.bgDark : AppColors.bgLight,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _filter,
                                          isExpanded: true,
                                          icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white54 : AppColors.textTertiary),
                                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
                                          dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                                          items: [
                                            DropdownMenuItem(value: 'all', child: Text(context.l10n('docs_sort_all'))),
                                            DropdownMenuItem(value: 'newest', child: Text(context.l10n('docs_sort_newest'))),
                                            DropdownMenuItem(value: 'oldest', child: Text(context.l10n('docs_sort_oldest'))),
                                          ],
                                          onChanged: (v) => setState(() => _filter = v ?? 'all'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => setState(() => _isGridView = !_isGridView),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.bgDark : AppColors.bgLight,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                                        ),
                                      ),
                                      child: Icon(
                                        _isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
                                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Info banner
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.medicalBlue.withValues(alpha: 0.1) : AppColors.blue50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? AppColors.medicalBlue.withValues(alpha: 0.2) : AppColors.blue50,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n('docs_info_secure'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.info.withValues(alpha: 0.7) : AppColors.medicalBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.l10n('docs_info_encrypted'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? AppColors.info : AppColors.medicalBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Category Filter Chips
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: Text(context.l10n('docs_sort_all')),
                                      selected: _isAllCategories,
                                      onSelected: (val) => setState(() => _isAllCategories = true),
                                      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                                      selectedColor: AppColors.primaryIndigo.withValues(alpha: 0.2),
                                      labelStyle: TextStyle(
                                        fontSize: 12,
                                        color: _isAllCategories ? AppColors.primaryIndigo : (isDark ? Colors.white70 : AppColors.textSecondary),
                                        fontWeight: _isAllCategories ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(DocumentCategory.healthPrescriptions, _getCategoryName(context, DocumentCategory.healthPrescriptions), isDark),
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(DocumentCategory.healthReports, _getCategoryName(context, DocumentCategory.healthReports), isDark),
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(DocumentCategory.healthTestResults, _getCategoryName(context, DocumentCategory.healthTestResults), isDark),
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(DocumentCategory.identity, _getCategoryName(context, DocumentCategory.identity), isDark),
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(DocumentCategory.finance, _getCategoryName(context, DocumentCategory.finance), isDark),
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(DocumentCategory.legal, _getCategoryName(context, DocumentCategory.legal), isDark),
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(DocumentCategory.notes, _getCategoryName(context, DocumentCategory.notes), isDark),
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(DocumentCategory.other, _getCategoryName(context, DocumentCategory.other), isDark),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Document List ──
              docsAsync.when(
                loading: () => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: List.generate(3, (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          height: 96,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardBorderDark : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      )),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('${context.l10n('error')}: $e'))),
                data: (documents) {
                  var filtered = _applyFilters(documents);

                  if (documents.isEmpty) {
                    return SliverToBoxAdapter(
                      child: AppEmptyState(
                        title: context.l10n('docs_empty_title'),
                        subtitle: context.l10n('docs_empty_subtitle'),
                        actionLabel: context.l10n('docs_add_btn'),
                        onAction: () => _showAddSheet(context),
                        shortcuts: [
                          EmptyStateShortcut(
                            label: context.l10n('docs_category_identity'),
                            icon: Icons.badge_rounded,
                            onTap: () => _showAddSheet(context, initialCategory: DocumentCategory.identity),
                          ),
                          EmptyStateShortcut(
                            label: context.l10n('docs_category_finance'),
                            icon: Icons.account_balance_wallet_rounded,
                            onTap: () => _showAddSheet(context, initialCategory: DocumentCategory.finance),
                          ),
                          EmptyStateShortcut(
                            label: context.l10n('docs_category_legal'),
                            icon: Icons.gavel_rounded,
                            onTap: () => _showAddSheet(context, initialCategory: DocumentCategory.legal),
                          ),
                          EmptyStateShortcut(
                            label: context.l10n('docs_category_notes'),
                            icon: Icons.note_add_rounded,
                            onTap: () => _showAddSheet(context, initialCategory: DocumentCategory.notes),
                          ),
                          EmptyStateShortcut(
                            label: context.l10n('docs_category_other'),
                            icon: Icons.folder_open_rounded,
                            onTap: () => _showAddSheet(context, initialCategory: DocumentCategory.other),
                          ),
                        ],
                      ),
                    );
                  }

                  if (filtered.isEmpty) {
                    return SliverToBoxAdapter(
                      child: AppEmptyState(
                        icon: Icons.search_off_rounded,
                        title: _searchTerm.isNotEmpty ? context.l10n('docs_no_results') : context.l10n('docs_no_matching'),
                        subtitle: _searchTerm.isNotEmpty
                            ? context.l10n('docs_try_different')
                            : context.l10n('docs_no_filter_match'),
                        actionLabel: _searchTerm.isNotEmpty ? context.l10n('show_all').toUpperCase() : context.l10n('docs_show_all'),
                        onAction: () => setState(() {
                          _searchTerm = '';
                          _isAllCategories = true;
                        }),
                      ),
                    );
                  }

                  if (_isGridView) {
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => DocumentGridItem(
                            document: filtered[index],
                            onTap: () => _showDocumentDetailDialog(filtered[index]),
                            onEdit: () => _showEditSheet(context, filtered[index]),
                            onDelete: () => _deleteDocument(filtered[index].id),
                          ).animate().fadeIn(delay: (index * 50).ms).scale(begin: const Offset(0.9, 0.9)),
                          childCount: filtered.length,
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => DocumentCard(
                          document: filtered[index],
                          onTap: () => _showDocumentDetailDialog(filtered[index]),
                          onEdit: () => _showEditSheet(context, filtered[index]),
                          onDelete: () => _deleteDocument(filtered[index].id),
                        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1),
                        childCount: filtered.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          // ── Decryption Overlay ──
          if (_isDecrypting)
            Container(
              color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primaryIndigo),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n('docs_loading_open'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n('docs_loading_decrypt'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ).animate().scale(begin: const Offset(0.9, 0.9)).fadeIn(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.primaryIndigo,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          context.l10n('docs_add_btn'),
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.white),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
      ).animate().fadeIn(delay: 800.ms).scale(),
    );
  }

  List<Document> _applyFilters(List<Document> docs) {
    var result = docs.where((d) {
      // Search filter
      bool matchesSearch = true;
      if (_searchTerm.isNotEmpty) {
        final q = _searchTerm.toLowerCase();
        matchesSearch = d.fileName.toLowerCase().contains(q) ||
            (d.hospitalName?.toLowerCase().contains(q) ?? false) ||
            (d.doctorName?.toLowerCase().contains(q) ?? false) ||
            (d.tagLabel?.toLowerCase().contains(q) ?? false) ||
            (d.note?.toLowerCase().contains(q) ?? false);
      }

      // Category filter
      bool matchesCategory = _isAllCategories || d.category == _categoryFilter;

      return matchesSearch && matchesCategory;
    }).toList();

    if (_filter == 'newest') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_filter == 'oldest') {
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return result;
  }

  String _getCategoryName(BuildContext context, DocumentCategory category) {
    switch (category) {
      case DocumentCategory.documents: return context.l10n('docs_title');
      case DocumentCategory.healthPrescriptions: return context.l10n('docs_category_prescriptions');
      case DocumentCategory.healthReports: return context.l10n('docs_category_reports');
      case DocumentCategory.healthTestResults: return context.l10n('docs_category_test_results');
      case DocumentCategory.healthImages: return context.l10n('docs_category_images');
      case DocumentCategory.identity: return context.l10n('docs_category_identity');
      case DocumentCategory.finance: return context.l10n('docs_category_finance');
      case DocumentCategory.legal: return context.l10n('docs_category_legal');
      case DocumentCategory.notes: return context.l10n('docs_category_notes');
      case DocumentCategory.other: return context.l10n('docs_category_other');
    }
  }

  void _showDocumentDetailDialog(Document document) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      document.fileType == DocumentFileType.pdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                      color: AppColors.primaryIndigo,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.hospitalName ?? document.fileName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getCategoryName(context, document.category),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _detailRow(Icons.calendar_today_rounded, context.l10n('label_date_added'), 
                DateFormat('dd MMM yyyy, HH:mm').format(document.createdAt)),
              const SizedBox(height: 12),
              if (document.documentDate != null)
                _detailRow(Icons.history_rounded, context.l10n('label_document_date'), 
                  DateFormat('dd MMM yyyy').format(DateTime.parse(document.documentDate!))),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewDocument(document),
                      icon: const Icon(Icons.remove_red_eye_rounded, color: Colors.white),
                      label: Text(context.l10n('open').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryIndigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadDocument(document),
                      icon: const Icon(Icons.download_rounded),
                      label: Text(context.l10n('download_to_device').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _deleteDocument(document.id);
                      },
                      icon: const Icon(Icons.delete_rounded, color: AppColors.error),
                      label: Text(context.l10n('delete_permanently').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.error)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Future<void> _downloadDocument(Document document) async {
    Navigator.pop(context); // Close dialog
    try {
      final storage = ref.read(fileStorageServiceProvider);
      final decryptedFile = await storage.getFile(document.localPath);
      
      if (!mounted) return;
      
      final result = await FilePicker.saveFile(
        dialogTitle: context.l10n('save_document'),
        fileName: document.fileName,
      );

      if (result != null) {
        final targetFile = File(result);
        await targetFile.writeAsBytes(await decryptedFile.readAsBytes());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n('success_doc_saved'))),
          );
        }
      }
      
      // Cleanup the temp decrypted file
      await storage.cleanupTempFile(decryptedFile.path);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n('error_failed_download', extra: {'error': e.toString()}))),
        );
      }
    }
  }

  Future<void> _viewDocument(Document document) async {
    Navigator.pop(context); // Close dialog
    setState(() => _isDecrypting = true);
    try {
      final storage = ref.read(fileStorageServiceProvider);
      final absolutePath = await storage.getAbsolutePath(document.localPath);
      
      // Artificial delay to ensure user sees the feedback if decryption is too fast
      // (Pre-decryption phase usually takes some ms, this ensures stability)
      await Future.delayed(const Duration(milliseconds: 300));
      
      AnalyticsService.log(AnalyticsService.documentDecrypted);
      await storage.openAndCleanFile(absolutePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n('error'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isDecrypting = false);
    }
  }

  Future<void> _deleteDocument(String id) async {
    await ref.read(documentListProvider.notifier).deleteDocument(id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n('success'))),
      );
    }
  }

  void _showEditSheet(BuildContext context, Document document) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddDocumentSheet(document: document),
      ),
    );
  }

  Widget _buildCategoryChip(DocumentCategory category, String label, bool isDark) {

    bool isSelected = !_isAllCategories && _categoryFilter == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() {
        _isAllCategories = false;
        _categoryFilter = category;
      }),
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      selectedColor: AppColors.primaryIndigo.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? AppColors.primaryIndigo : (isDark ? Colors.white70 : AppColors.textSecondary),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
