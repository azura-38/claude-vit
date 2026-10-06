import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';
import '../../domain/entities/medicine.dart';

class MedicinesHeroHeader extends StatelessWidget {
  const MedicinesHeroHeader({
    super.key,
    required this.name,
    required this.meds,
    required this.isDark,
    required this.visuals,
  });

  final String name;
  final List<Medicine> meds;
  final bool isDark;
  final ThemeVisuals visuals;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greetingKey = 'good_morning';
    if (hour >= 12 && hour < 18) {
      greetingKey = 'good_afternoon';
    } else if (hour >= 18 && hour < 22) {
      greetingKey = 'good_evening';
    } else if (hour >= 22 || hour < 5) {
      greetingKey = 'good_night';
    }

    final lowStockMed = meds.cast<Medicine?>().firstWhere(
      (m) =>
          m != null &&
          m.currentStock != null &&
          m.totalStock != null &&
          m.totalStock != 0 &&
          (m.currentStock! / m.totalStock! < 0.2),
      orElse: () => null,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: visuals.gradient,
        boxShadow: [
          BoxShadow(
            color: visuals.primary.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.medication_liquid_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${context.tr(greetingKey)}, $name',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('med_count_desc', extra: {'count': meds.length.toString()}),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.86),
                ),
              ),
              if (lowStockMed != null) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white.withValues(alpha: 0.12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning_rounded, color: Colors.red, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('low_stock_warning'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                ),
                                Text(
                                  context.tr('critical_level', extra: {'name': lowStockMed.name}),
                                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.78)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}
