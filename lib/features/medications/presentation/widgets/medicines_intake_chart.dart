import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';
import 'package:vitacase/core/utils/date_formatter.dart';
import '../../domain/entities/medicine.dart';

class MedicinesIntakeChart extends StatelessWidget {
  const MedicinesIntakeChart({
    super.key,
    required this.meds,
    required this.isDark,
    required this.visuals,
  });

  final List<Medicine> meds;
  final bool isDark;
  final ThemeVisuals visuals;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    var todayTotal = 0;
    var todayTaken = 0;

    for (final med in meds) {
      final isToday = med.frequency == 'daily'
          ? true
          : med.frequency == 'weekly'
              ? now.weekday == med.createdAt.weekday
              : DateFormatter.formatIso(now) == DateFormatter.formatIso(med.createdAt);
      if (!isToday) continue;
      todayTotal += med.reminderTimes.length;
      if (med.isTaken) todayTaken += med.reminderTimes.length;
    }

    final compliancePercent = todayTotal > 0 ? ((todayTaken / todayTotal) * 100).round() : 0;
    final progressValue = todayTotal > 0 ? (todayTaken / todayTotal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('intake_chart'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: visuals.softGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? Colors.white10 : visuals.primary.withValues(alpha: 0.12)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: visuals.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      compliancePercent == 100 ? Icons.check_circle_rounded : Icons.medication_rounded,
                      color: compliancePercent == 100 ? const Color(0xFF10B981) : visuals.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('today_summary'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white60 : Colors.blueGrey,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                            children: [
                              TextSpan(text: '$todayTaken', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                              TextSpan(
                                text: ' / $todayTotal',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white54 : Colors.blueGrey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: visuals.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$compliancePercent%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: visuals.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 8,
                  backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(compliancePercent == 100 ? const Color(0xFF10B981) : visuals.primary),
                ),
              ),
              if (todayTotal == 0) ...[
                const SizedBox(height: 16),
                Text(context.tr('no_scheduled_meds_today'), style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.blueGrey)),
              ],
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }
}
