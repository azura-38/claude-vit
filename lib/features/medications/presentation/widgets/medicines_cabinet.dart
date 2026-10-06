import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/constants/app_routes.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';
import '../../../../shared/providers/medicine_providers.dart';
import '../../domain/entities/medicine.dart';

class MedicinesCabinet extends ConsumerWidget {
  const MedicinesCabinet({
    super.key,
    required this.meds,
    required this.isDark,
    required this.visuals,
    required this.onAddMedicine,
  });

  final List<Medicine> meds;
  final bool isDark;
  final ThemeVisuals visuals;
  final VoidCallback onAddMedicine;

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, Medicine med) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('delete'), style: const TextStyle(color: AppColors.error)),
        content: Text(dialogContext.tr('delete_medicine_confirm')),
        actions: [
          TextButton(
            onPressed: () {
              if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(dialogContext.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              ref.read(medicineListProvider.notifier).deleteMedicine(med.id);
              if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(dialogContext.tr('delete'), style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('medicine_cabinet'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                Text(context.tr('active_inventory'), style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54)),
              ],
            ),
            TextButton.icon(
              onPressed: onAddMedicine,
              icon: const Icon(Icons.add, size: 18),
              label: Text(context.tr('add'), style: const TextStyle(fontWeight: FontWeight.w800)),
              style: TextButton.styleFrom(foregroundColor: visuals.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: meds.length + 1,
          itemBuilder: (context, index) => index == meds.length
              ? _buildAddMedicinePlaceholder(context, isDark, visuals)
              : _buildMedicineCard(context, ref, meds[index], isDark, visuals),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildMedicineCard(BuildContext context, WidgetRef ref, Medicine med, bool isDark, ThemeVisuals visuals) {
    final current = med.currentStock ?? 0;
    final total = med.totalStock ?? 1;
    final progress = total == 0 ? 0.0 : (current / total).clamp(0.0, 1.0);
    final isLow = progress < 0.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -4,
            right: -12,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, size: 18, color: Colors.blueGrey),
              onSelected: (val) {
                if (val == 'edit') {
                  context.push(AppRoutes.medicineAdd, extra: med);
                } else if (val == 'delete') {
                  _showDeleteConfirm(context, ref, med);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text(context.tr('edit'))),
                PopupMenuItem(value: 'delete', child: Text(context.tr('delete'), style: const TextStyle(color: Colors.red))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: visuals.primary.withValues(alpha: 0.09), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.medication_rounded, color: visuals.primary, size: 24),
              ),
              const SizedBox(height: 12),
              Text(med.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(med.dosage, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  color: isLow ? Colors.red : visuals.primary,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isLow ? context.tr('low_stock_warning').toUpperCase() : context.tr('stock_left', extra: {'count': current.toString()}),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isLow ? Colors.red : Colors.blueGrey, letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddMedicinePlaceholder(BuildContext context, bool isDark, ThemeVisuals visuals) {
    return GestureDetector(
      onTap: onAddMedicine,
      child: Container(
        decoration: BoxDecoration(
          gradient: visuals.softGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: visuals.primary.withValues(alpha: 0.22), width: 1.4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThemePlaceholder(type: visuals.type, size: 58, iconSize: 26, radius: 18),
            const SizedBox(height: 12),
            Text(
              context.tr('med_cabinet_add'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
