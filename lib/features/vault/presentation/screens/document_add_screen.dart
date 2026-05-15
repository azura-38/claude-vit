import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/vita_strings.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../shared/domain/enums/document_category.dart';
import '../../../../shared/providers/document_providers.dart';

class DocumentAddScreen extends ConsumerStatefulWidget {
  const DocumentAddScreen({super.key});

  @override
  ConsumerState<DocumentAddScreen> createState() => _DocumentAddScreenState();
}

class _DocumentAddScreenState extends ConsumerState<DocumentAddScreen> {
  final _hospitalController = TextEditingController();
  final _doctorController = TextEditingController();
  final _noteController = TextEditingController();

  PlatformFile? _selectedFile;
  DocumentCategory _category = DocumentCategory.healthReports;
  DocumentSubcategory _subcategory = DocumentSubcategory.report;
  bool _isSaving = false;

  @override
  void dispose() {
    _hospitalController.dispose();
    _doctorController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final strings = VitaStrings.of(context);
    if (kIsWeb) {
      _showSnack(strings.webUploadInfo);
      return;
    }

    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.isEmpty) return;
    setState(() => _selectedFile = result.files.single);
  }

  DocumentFileType _fileTypeFor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return DocumentFileType.pdf;
    return DocumentFileType.image;
  }

  Future<void> _save() async {
    final strings = VitaStrings.of(context);
    final file = _selectedFile;
    if (file == null || file.path == null) {
      _showSnack(strings.chooseFileFirst);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(documentListProvider.notifier).uploadDocument(
            file: File(file.path!),
            fileName: file.name,
            fileType: _fileTypeFor(file.name),
            category: _category,
            hospitalName: _emptyToNull(_hospitalController.text),
            doctorName: _emptyToNull(_doctorController.text),
            note: _emptyToNull(_noteController.text),
            documentDate: DateTime.now().toIso8601String(),
            tagId: _subcategory.name,
            tagLabel: _subcategory.name,
          );

      if (!mounted) return;
      _showSnack(strings.documentSaved);
      context.pop();
    } catch (e) {
      _showSnack(strings.saveDocumentFailed(e));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final strings = VitaStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subcategories = subcategoriesForDocumentCategory(_category);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text(strings.addDocument),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            _SecureUploadCard(
              selectedFile: _selectedFile,
              onPickFile: _pickFile,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            _SectionCard(
              isDark: isDark,
              children: [
                DropdownButtonFormField<DocumentCategory>(
                  initialValue: _category,
                  decoration: InputDecoration(labelText: strings.category),
                  items: DocumentCategory.values
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(_localizedCategory(context, category)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    final nextSubs = subcategoriesForDocumentCategory(value);
                    setState(() {
                      _category = value;
                      _subcategory = nextSubs.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DocumentSubcategory>(
                  initialValue: subcategories.contains(_subcategory)
                      ? _subcategory
                      : subcategories.first,
                  decoration: InputDecoration(labelText: strings.subcategory),
                  items: subcategories
                      .map((subcategory) => DropdownMenuItem(
                            value: subcategory,
                            child: Text(_localizedSubcategory(context, subcategory)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _subcategory = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _hospitalController,
                  decoration: InputDecoration(labelText: strings.hospitalInstitution),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _doctorController,
                  decoration: InputDecoration(labelText: strings.doctorContact),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: strings.notes,
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _PrivacyNotice(isDark: isDark),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_rounded),
              label: Text(_isSaving ? strings.saving : strings.saveSecurely),
            ),
          ),
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

  String _localizedSubcategory(BuildContext context, DocumentSubcategory subcategory) {
    return switch (subcategory) {
      DocumentSubcategory.general => context.tr('general'),
      DocumentSubcategory.invoice => context.tr('docs_category_finance'),
      DocumentSubcategory.receipt => context.tr('docs_category_finance'),
      DocumentSubcategory.report => context.tr('docs_category_reports'),
      DocumentSubcategory.prescription => context.tr('docs_category_prescriptions'),
      DocumentSubcategory.labResult => context.tr('docs_tag_lab'),
      DocumentSubcategory.image => context.tr('docs_category_images'),
      DocumentSubcategory.insurance => context.tr('appointment_type_insurance'),
      DocumentSubcategory.bankStatement => context.tr('docs_category_finance'),
      DocumentSubcategory.tax => context.tr('appointment_subcategory_tax'),
      DocumentSubcategory.contract => context.tr('appointment_subcategory_contract'),
      DocumentSubcategory.certificate => context.tr('docs_category_identity'),
      DocumentSubcategory.personalNote => context.tr('personal_notes'),
      DocumentSubcategory.other => context.tr('docs_category_other'),
    };
  }
}

class _SecureUploadCard extends StatelessWidget {
  const _SecureUploadCard({
    required this.selectedFile,
    required this.onPickFile,
    required this.isDark,
  });

  final PlatformFile? selectedFile;
  final VoidCallback onPickFile;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final strings = VitaStrings.of(context);
    return InkWell(
      onTap: onPickFile,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selectedFile == null
                ? AppColors.medicalBlue.withValues(alpha: 0.18)
                : Colors.green.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              selectedFile == null
                  ? Icons.upload_file_rounded
                  : Icons.verified_rounded,
              color: selectedFile == null ? AppColors.medicalBlue : Colors.green,
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              selectedFile?.name ?? strings.choosePdfOrImage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              kIsWeb ? strings.webPreviewNoUpload : strings.encryptedLocalFileInfo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children, required this.isDark});

  final List<Widget> children;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorderLight),
      ),
      child: Column(children: children),
    );
  }
}

class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final strings = VitaStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.medicalBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.medicalBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strings.localOrganizerDisclaimer,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
