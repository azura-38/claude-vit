import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/theme_visuals.dart';
import '../../../../core/utils/uuid_generator.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../shared/providers/health_providers.dart';
import '../../../../shared/domain/entities/health_metric.dart';
import '../../../../shared/widgets/misc/app_empty_state.dart';
import 'package:vitacase/features/profile/presentation/providers/legacy_providers.dart';

class HealthStatsScreen extends ConsumerStatefulWidget {
  const HealthStatsScreen({super.key});

  @override
  ConsumerState<HealthStatsScreen> createState() => _HealthStatsScreenState();
}

class _HealthStatsScreenState extends ConsumerState<HealthStatsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final healthData = ref.watch(healthListProvider).asData?.value ?? [];
    final progress = ref.watch(dailyHealthProgressProvider);
    final userName = ref.watch(profileNameProvider) ?? context.tr('guest_user');
    final selectedTheme = ref.watch(themeTypeProvider);
    final visuals = ThemeVisuals.of(selectedTheme);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, userName, isDark, visuals),
                  const SizedBox(height: 32),
                  _buildDailyRingSection(context, progress, isDark, visuals),
                  const SizedBox(height: 32),
                  _buildMetricsGrid(context, healthData, isDark),
                  const SizedBox(height: 24),
                  _buildSafetyNote(context, isDark, visuals),
                  const SizedBox(height: 32),
                  _buildHistorySection(context, healthData, isDark),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'healthStatsFab',
        onPressed: () => _showAddMetric(context),
        backgroundColor: visuals.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ).animate().scale(curve: Curves.easeOutBack, duration: 500.ms),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        context.tr('health_stats'),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader(BuildContext context, String name, bool isDark, ThemeVisuals visuals) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: visuals.softGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          ThemePlaceholder(type: visuals.type, size: 58, iconSize: 28, radius: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${context.tr('hi')}, $name 👋",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('safety_footer_health'),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildDailyRingSection(
    BuildContext context,
    Map<String, double> progress,
    bool isDark,
    ThemeVisuals visuals,
  ) {
    final stepsPercent = (progress['steps']! / 10000).clamp(0.0, 1.0);
    final waterPercent = (progress['water']! / 2500).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: visuals.primary.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: stepsPercent,
                      strokeWidth: 12,
                      backgroundColor: visuals.secondary.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(visuals.secondary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: waterPercent,
                      strokeWidth: 12,
                      backgroundColor: visuals.primary.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(visuals.primary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Center(
                  child: Icon(Icons.bolt_rounded, color: visuals.primary, size: 24),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildRingLegend(
                  context.tr('steps'),
                  "${progress['steps']!.toInt()}/10000",
                  visuals.secondary,
                ),
                const SizedBox(height: 12),
                _buildRingLegend(
                  context.tr('water'),
                  "${progress['water']!.toInt()}/2500 ${context.tr('unit_ml')}",
                  visuals.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildRingLegend(String label, String value, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
              ),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, List<HealthMetric> data, bool isDark) {
    HealthMetric? latest(HealthMetricType type) {
      final filtered = data.where((m) => m.type == type).toList();
      return filtered.isNotEmpty ? filtered.first : null;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildMetricCard(
          context.tr('heart'),
          "${latest(HealthMetricType.heartRate)?.value.toInt() ?? '--'}",
          context.tr('unit_bpm'),
          Icons.favorite_rounded,
          const Color(0xFFEF4444),
          isDark,
        ),
        _buildMetricCard(
          context.tr('sleep'),
          "${latest(HealthMetricType.sleep)?.value.toInt() ?? '--'}",
          context.tr('unit_hours'),
          Icons.bedtime_rounded,
          const Color(0xFF6366F1),
          isDark,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, String unit, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      unit,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildSafetyNote(BuildContext context, bool isDark, ThemeVisuals visuals) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: visuals.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.tr('safety_footer_health'),
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, List<HealthMetric> data, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('recent_activity'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        if (data.isEmpty)
          AppEmptyState(
            icon: Icons.history_rounded,
            title: context.tr('no_health_records'),
            subtitle: context.tr('safety_footer_health'),
            actionLabel: context.tr('add_health_data'),
            onAction: () => _showAddMetric(context),
          )
        else
          ...data.take(5).map((m) => _buildHistoryItem(context, m, isDark)),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildHistoryItem(BuildContext context, HealthMetric m, bool isDark) {
    final color = switch (m.type) {
      HealthMetricType.water => AppColors.medicalBlue,
      HealthMetricType.steps => AppColors.primaryGreen,
      HealthMetricType.heartRate => const Color(0xFFEF4444),
      HealthMetricType.sleep => const Color(0xFF6366F1),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(
              switch (m.type) {
                HealthMetricType.water => Icons.water_drop_rounded,
                HealthMetricType.steps => Icons.directions_walk_rounded,
                HealthMetricType.heartRate => Icons.favorite_rounded,
                HealthMetricType.sleep => Icons.bedtime_rounded,
              },
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr(m.type.labelKey), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                Text(
                  "${m.timestamp.day}/${m.timestamp.month} • ${m.timestamp.hour}:${m.timestamp.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            "${m.value.toInt()} ${context.tr(m.type.unitKey)}",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }

  void _showAddMetric(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const _AddHealthMetricSheet(),
      ),
    );
  }
}

class _AddHealthMetricSheet extends ConsumerStatefulWidget {
  const _AddHealthMetricSheet();

  @override
  ConsumerState<_AddHealthMetricSheet> createState() => _AddHealthMetricSheetState();
}

class _AddHealthMetricSheetState extends ConsumerState<_AddHealthMetricSheet> {
  final _valueC = TextEditingController();
  bool _isMl = true;
  HealthMetricType _type = HealthMetricType.water;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTheme = ref.watch(themeTypeProvider);
    final visuals = ThemeVisuals.of(selectedTheme);

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 32),
              Text(context.tr('add_health_data'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: HealthMetricType.values.map((t) {
                    final active = _type == t;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _type = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: active
                                ? visuals.primary
                                : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            context.tr(t.labelKey),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: active ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _valueC,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                        decoration: InputDecoration(
                          hintText: '0',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black12),
                        ),
                      ),
                    ),
                    if (_type == HealthMetricType.water)
                      GestureDetector(
                        onTap: () => setState(() => _isMl = !_isMl),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: visuals.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _isMl ? context.tr('unit_ml') : context.tr('unit_l'),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: visuals.primary),
                          ),
                        ),
                      )
                    else
                      Text(
                        context.tr(_type.unitKey),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: visuals.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(context.tr('save'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final val = double.tryParse(_valueC.text.trim());
    if (val == null) return;

    final metric = HealthMetric(
      id: generateUuid(),
      type: _type,
      value: (_type == HealthMetricType.water && !_isMl) ? val * 1000 : val,
      timestamp: DateTime.now(),
    );

    await ref.read(healthListProvider.notifier).addMetric(metric);
    if (mounted) context.safePop(fallbackRoute: AppRoutes.home);
  }
}
