import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';
import 'package:vitacase/core/utils/date_formatter.dart';
import 'package:vitacase/shared/widgets/misc/app_empty_state.dart';
import '../../../../shared/providers/medicine_providers.dart';
import '../../domain/entities/medicine.dart';

class MedicinesDailyRoutine extends ConsumerWidget {
  const MedicinesDailyRoutine({
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final morning = <Medicine>[];
    final afternoon = <Medicine>[];
    final night = <Medicine>[];
    final now = DateTime.now();

    for (final med in meds) {
      final isToday = med.frequency == 'daily'
          ? true
          : med.frequency == 'weekly'
              ? now.weekday == med.createdAt.weekday
              : DateFormatter.formatIso(now) == DateFormatter.formatIso(med.createdAt);
      if (!isToday) continue;
      for (final time in med.reminderTimes) {
        final hour = int.tryParse(time.split(':').first) ?? 0;
        if (hour < 11) {
          morning.add(med);
        } else if (hour < 18) {
          afternoon.add(med);
        } else {
          night.add(med);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('daily_routine'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 24),
        if (morning.isEmpty && afternoon.isEmpty && night.isEmpty)
          AppEmptyState(
            icon: Icons.schedule_rounded,
            title: context.tr('no_scheduled_meds_today'),
            subtitle: context.tr('safety_footer_med'),
            actionLabel: context.tr('add_medicine'),
            onAction: onAddMedicine,
          )
        else ...[
          if (morning.isNotEmpty) _buildRoutineSection(context, ref, context.tr('morning'), Icons.wb_sunny_rounded, morning, true),
          if (afternoon.isNotEmpty) _buildRoutineSection(context, ref, context.tr('afternoon'), Icons.light_mode_rounded, afternoon, night.isNotEmpty),
          if (night.isNotEmpty) _buildRoutineSection(context, ref, context.tr('night'), Icons.bedtime_rounded, night, false),
        ],
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRoutineSection(BuildContext context, WidgetRef ref, String title, IconData icon, List<Medicine> routineMeds, bool showLine) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(gradient: visuals.gradient, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: visuals.primary.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: visuals.primary)),
                const SizedBox(height: 12),
                ...routineMeds.map((m) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildRoutineCard(ref, m))),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(WidgetRef ref, Medicine med) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: visuals.primary.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(Icons.medication_rounded, color: visuals.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('${med.hungerStatus.label}, ${med.dosage}', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              if (med.isTaken) {
                ref.read(medicineListProvider.notifier).markAsSkipped(med.id);
              } else {
                ref.read(medicineListProvider.notifier).markAsTaken(med.id);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Icon(
              med.isTaken ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: med.isTaken ? visuals.primary : Colors.blueGrey.withValues(alpha: 0.4),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
