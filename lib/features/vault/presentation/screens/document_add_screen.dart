import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../shared/data/services/usage_limit_service.dart';
import '../../../../shared/domain/enums/document_category.dart';
import '../../../../shared/providers/document_providers.dart';
import '../../../../shared/widgets/mini_responsibility_notice.dart';

import '../widgets/tag_selector_widget.dart';

class DocumentAddScreen extends ConsumerStatefulWidget {
  const DocumentAddScreen({super.key});

  @override
  ConsumerState<DocumentAddScreen> createState() => _DocumentAddScreenState();
}

class _DocumentAddScreenState extends ConsumerState<DocumentAddScreen> {
  final _nameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _doctorController = TextEditingController();
  final _noteController = TextEditingController();

  PlatformFile? _selectedFile;
  DocumentCategory _category = DocumentCategory.medicalReport;
  DocumentSubcategory _subcategory = DocumentSubcategory.report;
  List<String> _selectedTags = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _hospitalController.dispose();
    _doctorController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _documentNameLabel => context.l10n.documentName;
  String get _documentNameHint => context.l10n.documentNameHint;

  String _limitMessage(int limit) {
    return context.tr('daily_limit_reached_message', extra: {'limit': limit.toString()});
  }

  Future<void> _pickFile() async {
    if (kIsWeb) {
      _showSnack(context.l10n.webUploadInfo);
      return;
    }

    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.isEmpty) return;
    setState(() {
      _selectedFile = result.files.single;
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = _cleanFileName(result.files.single.name);
      }
    });
  }

  String _cleanFileName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0) return fileName;
    return fileName.substring(0, dot);
  }

  DocumentFileType _fileTypeFor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return DocumentFileType.pdf;
    return DocumentFileType.image;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final file = _selectedFile;
    final sourcePath = file?.path;
    if (file == null || sourcePath == null || sourcePath.isEmpty) {
      _showSnack(context.l10n.chooseFileFirst);
      return;
    }

    final displayName = _nameController.text.trim().isEmpty ? file.name : _nameController.text.trim();

    setState(() => _isSaving = true);

    try {
      await ref.read(documentListProvider.notifier).addDocument(
            file: sourcePath,
            fileName: displayName,
            fileType: _fileTypeFor(file.name),
            category: _category,
            tags: _selectedTags,
            hospitalName: _emptyToNull(_hospitalController.text),
            doctorName: _emptyToNull(_doctorController.text),
            note: _emptyToNull(_noteController.text),
            documentDate: DateTime.now().toIso8601String(),
            tagId: _subcategory.name,
            tagLabel: _subcategory.name,
          );

      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (e is UsageLimitExceededException) {
        _showSnack(_limitMessage(e.limit));
      } else {
        _showSnack(context.l10n.saveDocumentFailed(e.toString()));
      }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subcategories = subcategoriesForDocumentCategory(_category);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(title: Text(context.l10n.addDocument), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            _SecureDocumentCard(selectedFile: _selectedFile, onPickFile: _pickFile, isDark: isDark),
            const SizedBox(height: 14),
            MiniResponsibilityNotice(
              icon: Icons.privacy_tip_outlined,
              accentColor: AppColors.medicalBlue,
              text: context.l10n.documentResponsibilityNotice,
            ),
            const SizedBox(height: 24),
            _SectionCard(
              isDark: isDark,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: _documentNameLabel,
                    hintText: _documentNameHint,
                    prefixIcon: const Icon(Icons.drive_file_rename_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DocumentCategory>(
                  initialValue: _category,
                  decoration: InputDecoration(labelText: context.l10n.category),
                  items: DocumentCategory.values.map((category) => DropdownMenuItem(value: category, child: Text(_localizedCategory(context, category)))).toList(),
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
                TagSelectorWidget(
                  selectedTags: _selectedTags,
                  onTagsChanged: (tags) => setState(() => _selectedTags = tags),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DocumentSubcategory>(
                  initialValue: subcategories.contains(_subcategory) ? _subcategory : subcategories.first,
                  decoration: InputDecoration(labelText: context.l10n.subcategory),
                  items: subcategories.map((subcategory) => DropdownMenuItem(value: subcategory, child: Text(_localizedSubcategory(context, subcategory)))).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _subcategory = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(controller: _hospitalController, decoration: InputDecoration(labelText: context.l10n.hospitalInstitution)),
                const SizedBox(height: 16),
                TextField(controller: _doctorController, decoration: InputDecoration(labelText: context.l10n.doctorContact)),
                const SizedBox(height: 16),
                TextField(controller: _noteController, maxLines: 4, decoration: InputDecoration(labelText: context.l10n.notes, alignLabelWithHint: true)),
              ],
            ),
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
              icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.lock_rounded),
              label: Text(_isSaving ? context.l10n.saving : context.l10n.saveSecurely),
            ),
          ),
        ),
      ),
    );
  }

  String _localizedCategory(BuildContext context, DocumentCategory category) {
    return category.localizedLabel(context);
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

class _SecureDocumentCard extends StatelessWidget {
  const _SecureDocumentCard({required this.selectedFile, required this.onPickFile, required this.isDark});

  final PlatformFile? selectedFile;
  final VoidCallback onPickFile;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPickFile,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: selectedFile == null ? AppColors.medicalBlue.withValues(alpha: 0.18) : Colors.green.withValues(alpha: 0.35), width: 1.2),
        ),
        child: Column(
          children: [
            Icon(selectedFile == null ? Icons.note_add_rounded : Icons.verified_rounded, color: selectedFile == null ? AppColors.medicalBlue : Colors.green, size: 52),
            const SizedBox(height: 16),
            Text(selectedFile?.name ?? context.l10n.choosePdfOrImage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              kIsWeb ? context.l10n.webPreviewNoUpload : context.l10n.encryptedLocalFileInfo,
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, height: 1.4),
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


