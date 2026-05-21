import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../../shared/domain/entities/document.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'vault_tag_chip.dart';

class VaultSwipeCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const VaultSwipeCard({
    super.key,
    required this.document,
    required this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = document.createdAt;
    final month = DateFormat('MMM', Localizations.localeOf(context).languageCode).format(date).toUpperCase();
    final doctorLabel = document.doctorName?.trim().isNotEmpty == true ? document.doctorName! : context.tr('no_doctor');
    final hospitalLabel = document.hospitalName?.trim().isNotEmpty == true ? document.hospitalName! : context.tr('no_institution');

    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: .45,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit?.call(),
            backgroundColor: isDark ? Colors.white10 : const Color(0xFFE9EDF5),
            foregroundColor: isDark ? Colors.white70 : AppColors.secondary,
            icon: Icons.edit_outlined,
            label: context.tr('edit'),
          ),
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: context.tr('delete'),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F4FA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(month, style: TextStyle(color: isDark ? Colors.white54 : AppColors.secondary, fontSize: 12)),
                    Text(
                      date.day.toString(),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$doctorLabel • $hospitalLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: isDark ? Colors.white54 : AppColors.secondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        VaultTagChip(
                          label: document.category.name.toUpperCase(),
                          bg: isDark ? AppColors.primaryIndigo.withValues(alpha: 0.2) : AppColors.chipBlue,
                          text: isDark ? AppColors.primaryIndigo : AppColors.primary,
                        ),
                        if (document.pending)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: VaultTagChip(
                              label: context.tr('pending'),
                              bg: const Color(0xFFFFF2D8),
                              text: const Color(0xFFA06900),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: isDark ? Colors.white24 : AppColors.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
