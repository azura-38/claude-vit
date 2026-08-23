import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../../../../core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../shared/domain/entities/document.dart';
import '../../../../../shared/domain/enums/document_category.dart';
import '../../../../../shared/domain/enums/document_tag.dart';
import '../../../../../shared/providers/document_providers.dart';
import '../../../../../shared/providers/shared_prefs_provider.dart';
import '../../../../gamification/presentation/providers/achievement_providers.dart';
import '../../../../../shared/providers/daily_mission_providers.dart';

class AddDocumentSheet extends ConsumerStatefulWidget {
  final DocumentCategory? initialCategory;
  final Document? document;
  const AddDocumentSheet({super.key, this.initialCategory, this.document});

  @override
  ConsumerState<AddDocumentSheet> createState() => _AddDocumentSheetState();
}

class _AddDocumentSheetState extends ConsumerState<AddDocumentSheet> {
  File? _selectedFile;
  String? _fileName;
  DocumentFileType _fileType = DocumentFileType.image;
  late DocumentCategory _selectedCategory;
  final _hospitalController = TextEditingController();
  final _doctorController = TextEditingController();
  final _noteController = TextEditingController();
  final _fileNameController = TextEditingController();
  final String _date = DateFormatter.formatIso(DateTime.now());
  String? _selectedTagId;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.document != null) {
      final d = widget.document!;
      _selectedCategory = d.category;
      _hospitalController.text = d.hospitalName ?? '';
      _doctorController.text = d.doctorName ?? '';
      _noteController.text = d.note ?? '';
      _fileNameController.text = d.fileName;
      _selectedTagId = d.tagId;
      _fileName = d.fileName;
      _fileType = d.fileType;
    } else {
      _selectedCategory = widget.initialCategory ?? DocumentCategory.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prefs = ref.watch(sharedPreferencesProvider);
    final hasUploadedBefore = prefs.getBool('has_added_document_before') ?? prefs.getBool('has_uploaded_before') ?? false;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              _buildSecureHeader(isDark),
              const SizedBox(height: 8),
              Text(
                context.l10n.docsAddTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:
                      (_selectedFile == null && widget.document == null)
                          ? _buildFilePicker(!hasUploadedBefore)
                          : _buildForm(!hasUploadedBefore),
                ),
              ),

              if (_selectedFile != null || widget.document != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _handleUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryIndigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isUploading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                context.l10n.save.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                    ),
                  ),
                ),

              // Extra safety for bottom nav bars/safe areas
              SizedBox(
                height: MediaQuery.of(context).padding.bottom > 0 ? 0 : 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecureHeader(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.medicalBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shield_rounded,
              color: AppColors.medicalBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.docsSecureStorageTitle,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  context.l10n.docsSecureStorageDesc,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(bool showWarning) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        if (showWarning) _buildPrivacyWarning(isDark),
        if (showWarning) const SizedBox(height: 20),
        PickerButton(
          icon: Icons.note_add_rounded,
          label: context.l10n.docsAddPick,
          color: AppColors.medicalBlue,
          bgColor:
              isDark
                  ? AppColors.medicalBlue.withValues(alpha: 0.1)
                  : AppColors.blue50,
          onTap: () => _pickFile(),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.docsErrorSize,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPrivacyWarning(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, size: 18, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.docsSensitiveWarning,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isFirstUpload) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSensitive =
        _selectedCategory == DocumentCategory.healthPrescriptions ||
        _selectedCategory == DocumentCategory.healthReports ||
        _selectedCategory == DocumentCategory.healthTestResults ||
        _selectedCategory == DocumentCategory.healthImages ||
        _selectedCategory == DocumentCategory.identity ||
        _selectedCategory == DocumentCategory.legal;

    final showWarning = isFirstUpload || isSensitive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showWarning) ...[
          _buildPrivacyWarning(isDark),
          const SizedBox(height: 16),
        ],

        _buildTextField(
          context.l10n.docsAddFileSelected,
          _fileNameController,
          context.l10n.hintName,
        ),
        const SizedBox(height: 16),

        _buildCategorySelector(isDark),
        const SizedBox(height: 12),
        _buildTagSelector(isDark),
        const SizedBox(height: 12),

        _buildTextField(
          context.l10n.docsAddSource,
          _hospitalController,
          context.l10n.hintInstitution,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          context.l10n.docsAddPerson,
          _doctorController,
          context.l10n.hintPersonDetail,
        ),
        const SizedBox(height: 12),

        _buildTextField(
          context.l10n.docsAddNote,
          _noteController,
          context.l10n.hintAddNote,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          minLines: 2,
        ),
        const SizedBox(height: 12),
        _buildSecurityBadge(isDark),
        const SizedBox(height: 8),
        if (widget.document == null)
          GestureDetector(
            onTap:
                () => setState(() {
                  _selectedFile = null;
                  _fileName = null;
                  _fileNameController.clear();
                }),
            child: Text(
              context.l10n.docsAddPickDiff,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.docsAddCat,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                DocumentCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                        // Auto-select first available tag for this category if current tag is not valid
                        final available = _getAvailableTags();
                        if (!available.any((t) => t.id == _selectedTagId)) {
                          _selectedTagId = available.first.id;
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.primaryIndigo.withValues(alpha: 0.1)
                                : (isDark
                                    ? AppColors.cardBorderDark
                                    : AppColors.bgLight),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.primaryIndigo
                                  : (isDark
                                      ? AppColors.cardBorderDark
                                      : AppColors.cardBorderLight),
                        ),
                      ),
                      child: Text(
                        _getCategoryName(cat).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color:
                              isSelected
                                  ? AppColors.primaryIndigo
                                  : (isDark
                                      ? Colors.white54
                                      : AppColors.textSecondary),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  List<DocumentTag> _getAvailableTags() {
    switch (_selectedCategory) {
      case DocumentCategory.healthPrescriptions:
        return [DocumentTag.prescription, DocumentTag.other];
      case DocumentCategory.healthReports:
        return [DocumentTag.report, DocumentTag.other];
      case DocumentCategory.healthTestResults:
        return [DocumentTag.lab, DocumentTag.radiology, DocumentTag.other];
      case DocumentCategory.healthImages:
        return [DocumentTag.radiology, DocumentTag.other];
      default:
        return DocumentTag.values;
    }
  }

  Widget _buildTagSelector(bool isDark) {
    final availableTags = _getAvailableTags();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.docsAddType,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              availableTags.map((tag) {
                final isSelected = _selectedTagId == tag.id;
                return GestureDetector(
                  onTap:
                      () => setState(
                        () => _selectedTagId = isSelected ? null : tag.id,
                      ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.medicalBlue.withValues(alpha: 0.1)
                              : (isDark
                                  ? AppColors.cardBorderDark
                                  : AppColors.bgLight),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.medicalBlue
                                : (isDark
                                    ? AppColors.cardBorderDark
                                    : AppColors.cardBorderLight),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tag.icon, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          tag.localizedLabel(context),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSecurityBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDark
                ? AppColors.primaryIndigo.withValues(alpha: 0.1)
                : AppColors.blue50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_rounded,
            size: 16,
            color: AppColors.primaryIndigo,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.docsAddSecure,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    int? maxLines = 1,
    int? minLines,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: minLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  String _getCategoryName(DocumentCategory category) {
    return category.localizedLabel(context);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final size = await file.length();
      if (size > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.docsErrorSize)));
        }
        return;
      }
      setState(() {
        _selectedFile = file;
        _fileName = result.files.single.name;
        _fileNameController.text = _fileName!.split('.').first;
        _fileType =
            _fileName!.toLowerCase().endsWith('.pdf')
                ? DocumentFileType.pdf
                : DocumentFileType.image;
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_isUploading) return;
    if (_fileNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.hintName)));
      return;
    }

    final needsSource =
        _selectedCategory == DocumentCategory.healthPrescriptions ||
        _selectedCategory == DocumentCategory.healthReports ||
        _selectedCategory == DocumentCategory.healthTestResults;
    if (needsSource && _hospitalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.docsErrorSource)));
      return;
    }
    setState(() => _isUploading = true);
    try {
      final tag = DocumentTag.fromId(_selectedTagId);
      final finalFileName =
          _fileNameController.text.trim() +
          (_fileName != null ? ".${_fileName!.split('.').last}" : "");

      Document? resultDoc;
      if (widget.document != null) {
        final updated = widget.document!.copyWith(
          fileName: _fileNameController.text.trim(),
          category: _selectedCategory,
          hospitalName: _hospitalController.text.trim(),
          doctorName:
              _doctorController.text.trim().isEmpty
                  ? null
                  : _doctorController.text.trim(),
          tagId: _selectedTagId,
          tagLabel: tag?.localizedLabel(context),
          note:
              _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
        );
        await ref.read(documentListProvider.notifier).updateDocument(updated);
        resultDoc = updated;
      } else {
        resultDoc = await ref
            .read(documentListProvider.notifier)
            .addDocument(
              file: _selectedFile!,
              fileName: finalFileName,
              fileType: _fileType,
              category: _selectedCategory,
              hospitalName: _hospitalController.text.trim(),
              doctorName:
                  _doctorController.text.trim().isEmpty
                      ? null
                      : _doctorController.text.trim(),
              documentDate: _date,
              tagId: _selectedTagId,
              tagLabel: tag?.localizedLabel(context),
              note:
                  _noteController.text.trim().isEmpty
                      ? null
                      : _noteController.text.trim(),
            );
      }
      if (mounted) {
        // Track first document added
        ref
            .read(sharedPreferencesProvider)
            .setBool('has_added_document_before', true);

        // AI Ad Engine: Track action

        // Achievement: Track document added
        ref.read(achievementProvider.notifier).track("doc_added", value: 1);
        // Mission: Track document
        ref.read(dailyMissionProvider.notifier).track("doc_daily");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.docsSuccess)));
        Navigator.of(context).pop(resultDoc);
        _triggerReviewengangement();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.docsErrorSave)));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _triggerReviewengangement() {
    if (widget.document == null) {
      final docs = ref.read(documentListProvider).value;
      if (docs != null && (docs.length == 3 || docs.length == 4)) {
        Future.delayed(const Duration(seconds: 1), () async {
          final inAppReview = InAppReview.instance;
          if (await inAppReview.isAvailable()) inAppReview.requestReview();
        });
      }
    }
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _doctorController.dispose();
    _noteController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }
}

class PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  const PickerButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
