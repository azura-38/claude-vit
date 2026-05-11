import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/legal_data.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../../../shared/domain/entities/health_metric.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../shared/providers/health_providers.dart';

import '../../../gamification/presentation/providers/achievement_providers.dart';
import '../../../../shared/providers/daily_mission_providers.dart';

class HealthDataAddScreen extends ConsumerStatefulWidget {
  const HealthDataAddScreen({super.key});

  @override
  ConsumerState<HealthDataAddScreen> createState() =>
      _HealthDataAddScreenState();
}

class _HealthDataAddScreenState extends ConsumerState<HealthDataAddScreen> {
  final _waterController = TextEditingController();
  final _sleepController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _stepsController = TextEditingController();
  bool _isLiter = false;

  @override
  void dispose() {
    _waterController.dispose();
    _sleepController.dispose();
    _heartRateController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final List<HealthMetric> newMetrics = [];

    if (_waterController.text.isNotEmpty) {
      double waterVal = double.tryParse(_waterController.text) ?? 0;
      if (_isLiter) waterVal *= 1000; // Convert L to ML
      newMetrics.add(
        HealthMetric(
          id: generateUuid(),
          type: HealthMetricType.water,
          value: waterVal,
          timestamp: now,
        ),
      );
    }

    if (_sleepController.text.isNotEmpty) {
      newMetrics.add(
        HealthMetric(
          id: generateUuid(),
          type: HealthMetricType.sleep,
          value: double.tryParse(_sleepController.text) ?? 0,
          timestamp: now,
        ),
      );
    }

    if (_heartRateController.text.isNotEmpty) {
      newMetrics.add(
        HealthMetric(
          id: generateUuid(),
          type: HealthMetricType.heartRate,
          value: double.tryParse(_heartRateController.text) ?? 0,
          timestamp: now,
        ),
      );
    }

    if (_stepsController.text.isNotEmpty) {
      newMetrics.add(
        HealthMetric(
          id: generateUuid(),
          type: HealthMetricType.steps,
          value: double.tryParse(_stepsController.text) ?? 0,
          timestamp: now,
        ),
      );
    }

    if (newMetrics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseEnterAtLeastOneData)),
      );
      return;
    }

    // ⚠️ DISCLAIMER TRIGGER (Elite Audit FIX)
    final existingMetrics = ref.read(healthListProvider).value ?? [];
    if (existingMetrics.isEmpty) {
      final shown = await _showMedicalDisclaimer();
      if (!shown) return;
    }

    for (var m in newMetrics) {
      await ref.read(healthListProvider.notifier).addMetric(m);
    }

    // AI Ad Engine: Track action

    // Achievement: Track health data added
    ref.read(achievementProvider.notifier).track("health_data_added", value: 1);
    // Mission: Track health (if applicable)
    ref.read(dailyMissionProvider.notifier).track("health_daily");

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.dataSavedSuccess)));
      context.pop();
    }
  }

  Future<bool> _showMedicalDisclaimer() async {
    final locale = Localizations.localeOf(context).languageCode;
    final content = LegalData.getDisclaimer(locale);

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(context.l10n.legalDisclaimer),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(false),
                    child: Text(context.l10n.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () => context.pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.medicalBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(context.l10n.accept),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = ref.watch(dailyHealthProgressProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: (isDark ? Colors.black : Colors.white).withValues(
          alpha: 0.8,
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : AppColors.medicalBlue,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.l10n.addData,
          style: TextStyle(
            fontFamily: 'Manrope',
            color: isDark ? Colors.white : const Color(0xFF001C39),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              context.l10n.btnSave,
              style: TextStyle(
                fontFamily: 'Manrope',
                color: isDark ? AppColors.medicalBlue : const Color(0xFF005DA7),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.dailyEntry,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Manrope',
                  ),
                ),
                Text(
                  context.l10n.dailyEntryDesc,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 32),

            // Entry Cards
            _buildEntryCard(
              label: context.l10n.waterTracker,
              unit: _isLiter ? context.l10n.unitL : context.l10n.unitMl,
              icon: Icons.water_drop_rounded,
              iconColor: Colors.blue,
              bgColor: Colors.blue.withValues(alpha: 0.1),
              controller: _waterController,
              hint: _isLiter ? '2.5' : '2500',
              isDark: isDark,
              delay: 100.ms,
              unitToggle: Row(
                children: [
                  _buildUnitToggle(
                    'ML',
                    !_isLiter,
                    () => setState(() => _isLiter = false),
                  ),
                  const SizedBox(width: 4),
                  _buildUnitToggle(
                    'L',
                    _isLiter,
                    () => setState(() => _isLiter = true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildEntryCard(
              label: context.l10n.sleepDuration,
              unit: context.l10n.hours,
              icon: Icons.bedtime_rounded,
              iconColor: Colors.indigo,
              bgColor: Colors.indigo.withValues(alpha: 0.1),
              controller: _sleepController,
              hint: '8',
              isDark: isDark,
              delay: 200.ms,
            ),
            const SizedBox(height: 16),
            _buildEntryCard(
              label: context.l10n.heartRate,
              unit: 'BPM',
              icon: Icons.favorite_rounded,
              iconColor: Colors.red,
              bgColor: Colors.red.withValues(alpha: 0.1),
              controller: _heartRateController,
              hint: '72',
              isDark: isDark,
              delay: 300.ms,
            ),
            const SizedBox(height: 16),
            _buildEntryCard(
              label: context.l10n.steps,
              unit: context.l10n.stepUnit,
              icon: Icons.directions_walk_rounded,
              iconColor: Colors.teal,
              bgColor: Colors.teal.withValues(alpha: 0.1),
              controller: _stepsController,
              hint: '10000',
              isDark: isDark,
              delay: 400.ms,
            ),

            const SizedBox(height: 32),
            // Save Button
            SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005DA7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Colors.blue.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      context.l10n.saveData,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms)
                .scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 32),
            // Summary Card
            _buildSummaryCard(progress, isDark),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard({
    required String label,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required Duration delay,
    Widget? unitToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    if (unitToggle != null) unitToggle,
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: hint,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: delay).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildUnitToggle(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.medicalBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                active
                    ? AppColors.medicalBlue
                    : Colors.blueGrey.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, double> progress, bool isDark) {
    final waterTarget = 2500.0;
    final stepsTarget = 10000.0;
    final currentWater = progress['water'] ?? 0;
    final currentSteps = progress['steps'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.todaySummary,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildProgressColumn(
                  label: context.l10n.targetWater,
                  current: currentWater,
                  target: waterTarget,
                  unit: 'ML',
                  color: Colors.blue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildProgressColumn(
                  label: context.l10n.targetSteps,
                  current: currentSteps,
                  target: stepsTarget,
                  unit: context.l10n.stepUnit,
                  color: Colors.teal,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildProgressColumn({
    required String label,
    required double current,
    required double target,
    required String unit,
    required Color color,
    required bool isDark,
  }) {
    final percent = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Colors.blueGrey,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${current.toInt()} / ${target.toInt()} $unit',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color:
                isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
