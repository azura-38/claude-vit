import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/entities/document.dart';
import '../../../domain/enums/document_tag.dart';
import '../../providers/document_providers.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_header.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/banner_ad_container.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final String id;
  const DocumentDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final docsAsync = ref.watch(documentListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: docsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n('error'))),
        data: (documents) {
          final document = documents.where((d) => d.id == id).firstOrNull;
          if (document == null) {
            return Center(child: Text(context.l10n('page_not_found')));
          }

          final tag = DocumentTag.fromId(document.tagId);

// ...
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                const BannerAdContainer(),
                AppHeader(
                  title: document.fileName,
                  showBack: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          context,
                          label: context.l10n('basic_info'),
                          isDark: isDark,
                          children: [
                             _infoRow(context, Icons.business_rounded, context.l10n('docs_add_source'), document.hospitalName ?? '-', isDark),
                             _infoRow(context, Icons.person_rounded, context.l10n('docs_add_person'), document.doctorName ?? '-', isDark),
                             _infoRow(context, Icons.calendar_today_rounded, context.l10n('birth_date'), document.documentDate ?? '-', isDark),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (tag != null) ...[
                          _buildSection(
                            context,
                            label: context.l10n('category'),
                            isDark: isDark,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.medicalBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(tag.icon, style: const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text(tag.label, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.medicalBlue)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (document.note != null && document.note!.isNotEmpty)
                          _buildSection(
                            context,
                            label: context.l10n('docs_add_note'),
                            isDark: isDark,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
                                ),
                                child: Text(
                                  document.note!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _viewDocument(context, ref, document),
                            icon: const Icon(Icons.remove_red_eye_rounded, color: Colors.white),
                            label: Text(context.l10n('docs_loading_open').toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryIndigo,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms).scale(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String label, required List<Widget> children, required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: isDark ? Colors.white38 : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white38 : AppColors.textTertiary),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : AppColors.textTertiary)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _viewDocument(BuildContext context, WidgetRef ref, Document document) async {
    try {
      final storage = ref.read(fileStorageServiceProvider);
      final absolutePath = await storage.getAbsolutePath(document.localPath);
      await storage.openAndCleanFile(absolutePath);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n('error'))),
        );
      }
    }
  }
}
