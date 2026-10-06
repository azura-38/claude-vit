import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/date_formatter.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../../shared/domain/enums/document_category.dart';
import '../../../../../shared/domain/entities/document.dart';
import '../../../../../shared/domain/enums/document_tag.dart';
import '../../../../../shared/widgets/misc/app_card.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr =
        document.documentDate ?? document.createdAt.toIso8601String();
    final date = DateTime.tryParse(dateStr) ?? document.createdAt;
    final tag = DocumentTag.fromId(document.tagId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... icon row ...
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.blue700, AppColors.blue900],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.day.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      DateFormatter.monthShort(date),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.hospitalName ?? document.fileName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (tag != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _tagBgColor(tag),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _tagBorderColor(tag)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tag.icon,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tag.label,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: _tagTextColor(tag),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? AppColors.cardBorderDark
                                    : AppColors.bgLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isDark
                                      ? AppColors.cardBorderDark
                                      : AppColors.cardBorderLight,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 12,
                                color:
                                    isDark
                                        ? Colors.white54
                                        : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                document.fileType == DocumentFileType.pdf
                                    ? 'PDF'
                                    : 'IMAGE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isDark
                                          ? Colors.white54
                                          : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (document.note != null && document.note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? AppColors.noteMarqueeText.withValues(
                                    alpha: 0.1,
                                  )
                                  : AppColors.noteMarqueeBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isDark
                                    ? AppColors.noteMarqueeText.withValues(
                                      alpha: 0.2,
                                    )
                                    : const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Text(
                          document.note!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark
                                    ? const Color(0xFFFBBF24)
                                    : AppColors.noteMarqueeText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_horiz_rounded,
                            size: 20,
                            color: Colors.blueGrey,
                          ),
                          onSelected: (val) {
                            if (val == 'edit') {
                              onEdit();
                            } else if (val == 'delete') {
                              onDelete();
                            }
                          },
                          itemBuilder:
                              (ctx) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit_rounded, size: 18),
                                      const SizedBox(width: 8),
                                      Text(context.l10n.edit),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete_rounded,
                                        size: 18,
                                        color: AppColors.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.l10n.delete,
                                        style: const TextStyle(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? Colors.white24 : AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _tagBgColor(DocumentTag tag) {
    switch (tag) {
      case DocumentTag.lab:
        return AppColors.tagLabBg;
      case DocumentTag.radiology:
        return AppColors.tagRadiologyBg;
      case DocumentTag.prescription:
        return AppColors.tagPrescriptionBg;
      case DocumentTag.report:
        return AppColors.tagReportBg;
      case DocumentTag.operation:
        return AppColors.tagOperationBg;
      case DocumentTag.vaccination:
        return AppColors.tagVaccinationBg;
      case DocumentTag.insurance:
        return AppColors.tagInsuranceBg;
      case DocumentTag.invoice:
        return AppColors.tagInvoiceBg;
      case DocumentTag.other:
        return AppColors.tagOtherBg;
    }
  }

  Color _tagTextColor(DocumentTag tag) {
    switch (tag) {
      case DocumentTag.lab:
        return AppColors.tagLabText;
      case DocumentTag.radiology:
        return AppColors.tagRadiologyText;
      case DocumentTag.prescription:
        return AppColors.tagPrescriptionText;
      case DocumentTag.report:
        return AppColors.tagReportText;
      case DocumentTag.operation:
        return AppColors.tagOperationText;
      case DocumentTag.vaccination:
        return AppColors.tagVaccinationText;
      case DocumentTag.insurance:
        return AppColors.tagInsuranceText;
      case DocumentTag.invoice:
        return AppColors.tagInvoiceText;
      case DocumentTag.other:
        return AppColors.tagOtherText;
    }
  }

  Color _tagBorderColor(DocumentTag tag) =>
      _tagTextColor(tag).withValues(alpha: 0.2);
}

class DocumentGridItem extends ConsumerWidget {
  final Document document;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DocumentGridItem({
    super.key,
    required this.document,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                blurRadius: 20,
                offset: const Offset(0, 10),
                color: Colors.black.withValues(alpha: 0.04),
              ),
          ],
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.02),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? Colors.white.withValues(alpha: 0.03)
                              : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      document.fileType == DocumentFileType.pdf
                          ? Icons.picture_as_pdf_rounded
                          : Icons.image_outlined,
                      size: 48,
                      color:
                          isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      onSelected: (val) {
                        if (val == 'edit') {
                          onEdit();
                        } else if (val == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder:
                          (ctx) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(ctx.l10n.edit),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete_rounded,
                                    size: 18,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    ctx.l10n.delete,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                    ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Text(
                document.hospitalName ?? document.fileName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
