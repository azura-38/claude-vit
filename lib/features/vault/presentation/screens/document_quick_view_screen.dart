import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/domain/entities/document.dart';
import '../../../../shared/providers/document_providers.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import '../providers/vault_controller.dart';
import '../widgets/vault_action_button.dart';
import '../widgets/vault_preview_overlay.dart';
import '../widgets/vault_tag_chip.dart';

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

  bool get _isTr => Localizations.localeOf(context).languageCode == 'tr';

  String get _title => _isTr ? 'Belge Kasası' : 'Document Vault';
  String get _subtitle => _isTr ? 'Belge detaylarını güvenli şekilde görüntülüyorsun.' : 'Reviewing expanded document details.';
  String get _editLabel => _isTr ? 'Düzenle' : 'Edit';
  String get _saveLabel => _isTr ? 'Kaydet' : 'Save';
  String get _cancelLabel => _isTr ? 'İptal' : 'Cancel';
  String get _nameLabel => _isTr ? 'Belge adı' : 'Document name';
  String get _institutionLabel => _isTr ? 'Kurum / Hastane' : 'Institution / Hospital';
  String get _personLabel => _isTr ? 'Doktor / İlgili kişi' : 'Doctor / Related person';
  String get _notesLabel => _isTr ? 'Notlar' : 'Notes';
  String get _savedLabel => _isTr ? 'Belge güncellendi.' : 'Document updated.';
  String get _failedLabel => _isTr ? 'Belge güncellenemedi.' : 'Could not update document.';
  String get _unknownLabel => _isTr ? 'Bilinmiyor' : 'Unknown';
  String get _emptyNoteLabel => _isTr ? 'Ek not yok.' : 'No additional notes provided.';

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
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: _nameLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hospitalController,
                  decoration: InputDecoration(labelText: _institutionLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: doctorController,
                  decoration: InputDecoration(labelText: _personLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: _notesLabel, alignLabelWithHint: true),
                ),
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

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final document = _document;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = document.createdAt;
    final month = DateFormat('MMM').format(date).toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
                Expanded(
                  child: Text(_title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                ),
                IconButton.filledTonal(
                  onPressed: _showEditDialog,
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: _editLabel,
                ),
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
                              Text(
                                date.day.toString(),
                                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                document.fileName,
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary),
                              ),
                              const SizedBox(height: 8),
                              Text('${document.hospitalName ?? _unknownLabel} • ${document.category.name}', style: const TextStyle(color: AppColors.secondary)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  VaultTagChip(
                                    label: document.tagLabel ?? 'Lab',
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
                            Expanded(child: _InfoColumn(label: _isTr ? 'OLUŞTURULDU' : 'CREATED AT', value: DateFormat('dd.MM.yyyy').format(date))),
                            Expanded(child: _InfoColumn(label: _isTr ? 'İLGİLİ KİŞİ' : 'PHYSICIAN', value: document.doctorName ?? 'N/A')),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _InfoColumn(label: _notesLabel.toUpperCase(), value: document.note ?? _emptyNoteLabel, expanded: true),
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
                              label: _isTr ? 'İndir' : 'Download',
                              icon: Icons.download,
                              bg: AppColors.primary,
                              text: Colors.white,
                              onTap: () {},
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
