import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../shared/domain/entities/document.dart';
import '../../../../shared/domain/enums/document_category.dart';
import '../../../../shared/providers/document_providers.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../providers/vault_controller.dart';
import '../widgets/vault_action_button.dart';
import '../widgets/vault_preview_overlay.dart';
import '../widgets/vault_tag_chip.dart';
import '../../../../core/utils/mime_type_helper.dart';

class DocumentQuickViewScreen extends ConsumerStatefulWidget {
  const DocumentQuickViewScreen({super.key, required this.document});

  final Document document;

  @override
  ConsumerState<DocumentQuickViewScreen> createState() => _DocumentQuickViewScreenState();
}

class _DocumentQuickViewScreenState extends ConsumerState<DocumentQuickViewScreen> {
  late Document _document;

  @override
  void initState() {
    super.initState();
    _document = widget.document;
  }

  String get _title => context.l10n.documentVault;
  String get _subtitle => context.l10n.documentVaultViewSubtitle;
  String get _editLabel => context.l10n.edit;
  String get _openLabel => context.l10n.open;
  String get _saveLabel => context.l10n.save;
  String get _cancelLabel => context.l10n.cancel;
  String get _nameLabel => context.l10n.documentName;
  String get _institutionLabel => context.l10n.institutionHospital;
  String get _personLabel => context.l10n.doctorRelatedPerson;
  String get _notesLabel => context.l10n.notes;
  String get _savedLabel => context.l10n.documentUpdated;
  String get _failedLabel => context.l10n.documentUpdateFailed;
  String get _openFailedLabel => context.l10n.documentOpenFailed;
  String get _unknownLabel => context.l10n.unknown;
  String get _emptyNoteLabel => context.l10n.noAdditionalNotes;

  Future<void> _showEditDialog() async {
    final nameController = TextEditingController(text: _document.fileName);
    final hospitalController = TextEditingController(text: _document.hospitalName ?? '');
    final doctorController = TextEditingController(text: _document.doctorName ?? '');
    final noteController = TextEditingController(text: _document.note ?? '');

    final result = await showDialog<Document>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_editLabel),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: _nameLabel)),
                const SizedBox(height: 12),
                TextField(controller: hospitalController, decoration: InputDecoration(labelText: _institutionLabel)),
                const SizedBox(height: 12),
                TextField(controller: doctorController, decoration: InputDecoration(labelText: _personLabel)),
                const SizedBox(height: 12),
                TextField(controller: noteController, maxLines: 4, decoration: InputDecoration(labelText: _notesLabel, alignLabelWithHint: true)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(_cancelLabel)),
            FilledButton(
              onPressed: () {
                final updated = _document.copyWith(
                  fileName: nameController.text.trim().isEmpty ? _document.fileName : nameController.text.trim(),
                  hospitalName: _emptyToNull(hospitalController.text),
                  doctorName: _emptyToNull(doctorController.text),
                  note: _emptyToNull(noteController.text),
                );
                Navigator.pop(dialogContext, updated);
              },
              child: Text(_saveLabel),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    hospitalController.dispose();
    doctorController.dispose();
    noteController.dispose();

    if (result == null) return;

    try {
      await ref.read(documentListProvider.notifier).updateDocument(result);
      ref.invalidate(vaultControllerProvider);
      if (!mounted) return;
      setState(() => _document = result);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_savedLabel)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_failedLabel)));
    }
  }

  Future<void> _openDocument() async {
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.openingFile), duration: const Duration(seconds: 1)));
      
      final fileStorage = ref.read(fileStorageServiceProvider);
      final decryptedFile = await fileStorage.getFile(_document.localPath);
      final filePath = (decryptedFile as dynamic).path as String;
      
      final result = await OpenFilex.open(filePath);
      if (!mounted) return;
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_openFailedLabel)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_openFailedLabel)));
    }
  }

  Future<void> _downloadDocument() async {
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.downloadingFile), duration: const Duration(seconds: 1)));

      final fileStorage = ref.read(fileStorageServiceProvider);
      final mimeType = MimeTypeHelper.getMimeType(_document.fileName);

      final result = await fileStorage.saveDecryptedCopyToDownloads(
        relativePath: _document.localPath,
        originalFileName: _document.fileName,
        mimeType: mimeType,
      );

      if (!mounted) return;
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.fileSavedToDownloads)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.fileDownloadFailed)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.fileDownloadFailed)));
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final document = _document;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = document.createdAt;
    final month = DateFormat('MMM', Localizations.localeOf(context).languageCode).format(date).toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
                Expanded(child: Text(_title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800))),
                IconButton.filledTonal(onPressed: _showEditDialog, icon: const Icon(Icons.edit_rounded), tooltip: _editLabel),
              ],
            ),
            const SizedBox(height: 10),
            Text(_subtitle, style: const TextStyle(fontSize: 17, color: AppColors.secondary)),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.border),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 90,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F4FA),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(month, style: TextStyle(color: isDark ? Colors.white54 : AppColors.secondary)),
                              Text(date.day.toString(), style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.primary)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(document.fileName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary)),
                              const SizedBox(height: 8),
                              Text('${document.hospitalName ?? _unknownLabel} • ${document.category.localizedLabel(context)}', style: const TextStyle(color: AppColors.secondary)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (document.tags.isNotEmpty)
                                    ...document.tags.map((tag) => VaultTagChip(
                                      label: tag,
                                      bg: isDark ? AppColors.primaryIndigo.withValues(alpha: 0.2) : AppColors.chipBlue,
                                      text: isDark ? AppColors.primaryIndigo : AppColors.primary,
                                    ))
                                  else if (document.tagLabel != null)
                                    VaultTagChip(
                                      label: document.tagLabel!,
                                      bg: isDark ? AppColors.primaryIndigo.withValues(alpha: 0.2) : AppColors.chipBlue,
                                      text: isDark ? AppColors.primaryIndigo : AppColors.primary,
                                    ),
                                  VaultTagChip(
                                    label: document.fileType.name.toUpperCase(),
                                    bg: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F4FA),
                                    text: isDark ? Colors.white54 : AppColors.secondary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF9FBFF),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _InfoColumn(label: context.l10n.createdAtLabel, value: DateFormat('dd.MM.yyyy').format(date))),
                            Expanded(child: _InfoColumn(label: context.l10n.physicianLabel, value: document.doctorName ?? 'N/A')),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _InfoColumn(label: _notesLabel.toUpperCase(), value: document.note ?? _emptyNoteLabel, expanded: true),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amber.withValues(alpha: isDark ? 0.3 : 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  context.l10n.externalAppWarning,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.amber[200] : Colors.amber[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        const VaultPreviewOverlay(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            VaultActionButton(
                              label: _editLabel,
                              icon: Icons.edit_rounded,
                              bg: isDark ? Colors.white10 : const Color(0xFFF1F4FA),
                              text: isDark ? Colors.white70 : AppColors.secondary,
                              onTap: _showEditDialog,
                            ),
                            const SizedBox(width: 16),
                            VaultActionButton(
                              label: _openLabel,
                              icon: Icons.open_in_new_rounded,
                              bg: AppColors.primary,
                              text: Colors.white,
                              onTap: _openDocument,
                            ),
                            const SizedBox(width: 16),
                            VaultActionButton(
                              label: context.l10n.download,
                              icon: Icons.file_download_rounded,
                              bg: isDark ? Colors.white10 : const Color(0xFFE2F4ED),
                              text: isDark ? Colors.green[300]! : Colors.green[700]!,
                              onTap: _downloadDocument,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.label, required this.value, this.expanded = false});

  final String label;
  final String value;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, letterSpacing: 2, color: AppColors.secondary)),
        const SizedBox(height: 10),
        Container(
          width: expanded ? double.infinity : null,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: expanded ? (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF3F6FB)) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(value, style: TextStyle(fontSize: 16, height: 1.6, color: isDark ? Colors.white70 : AppColors.textPrimary)),
        ),
      ],
    );
  }
}
