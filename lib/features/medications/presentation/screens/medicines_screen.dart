import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/theme_visuals.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/data/services/limit_service.dart';
import '../../../../shared/providers/limit_providers.dart';
import '../../../../shared/providers/medicine_providers.dart';
import '../../../../shared/providers/premium_provider.dart';
import '../../../../shared/widgets/misc/app_empty_state.dart';
import '../../../gamification/presentation/widgets/limits/limit_dialog.dart';
import '../../../profile/presentation/providers/legacy_providers.dart';
import '../../domain/entities/medicine.dart';

class MedicinesScreen extends ConsumerStatefulWidget {
  const MedicinesScreen({super.key});

  @override
  ConsumerState<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends ConsumerState<MedicinesScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final medsAsync = ref.watch(medicineListProvider);
    final userName = ref.watch(profileNameProvider) ?? context.tr('guest_user');
    final selectedTheme = ref.watch(themeTypeProvider);
    final visuals = ThemeVisuals.of(selectedTheme);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isDark, visuals),
          SliverToBoxAdapter(
            child: medsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(child: Text('${context.tr('error')}: $e')),
              data: (medicines) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildHeroHeader(userName, medicines, isDark, visuals),
                      const SizedBox(height: 28),
                      _buildIntakeChart(medicines, isDark, visuals),
                      const SizedBox(height: 28),
                      if (medicines.isEmpty)
                        AppEmptyState(
                          icon: Icons.medication_rounded,
                          title: context.tr('my_medicines'),
                          subtitle: context.tr('no_scheduled_meds_today'),
                          actionLabel: context.tr('add_medicine'),
                          onAction: () => _showAddMedicine(context),
                        )
                      else ...[
                        _buildMedicineCabinet(medicines, isDark, visuals),
                        const SizedBox(height: 28),
                        _buildDailyRoutine(medicines, isDark, visuals),
                      ],
                      const SizedBox(height: 120),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStickyDisclaimer(isDark, visuals),
      floatingActionButton: FloatingActionButton(
        heroTag: 'medicinesFab',
        onPressed: () => _showAddMedicine(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: visuals.gradient,
            boxShadow: [
              BoxShadow(
                color: visuals.primary.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark, ThemeVisuals visuals) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.86),
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          ThemePlaceholder(type: visuals.type, size: 34, iconSize: 17, radius: 12),
          const SizedBox(width: 12),
          Text(
            context.tr('my_medicines'),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: visuals.primary,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_rounded,
            color: isDark ? Colors.white70 : Colors.blueGrey.shade600,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeroHeader(String name, List<Medicine> meds, bool isDark, ThemeVisuals visuals) {
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
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
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

  Widget _buildIntakeChart(List<Medicine> meds, bool isDark, ThemeVisuals visuals) {
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

  Widget _buildMedicineCabinet(List<Medicine> meds, bool isDark, ThemeVisuals visuals) {
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
              onPressed: () => _showAddMedicine(context),
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
              ? _buildAddMedicinePlaceholder(isDark, visuals)
              : _buildMedicineCard(meds[index], isDark, visuals),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildMedicineCard(Medicine med, bool isDark, ThemeVisuals visuals) {
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

  Widget _buildAddMedicinePlaceholder(bool isDark, ThemeVisuals visuals) {
    return GestureDetector(
      onTap: () => _showAddMedicine(context),
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

  Widget _buildDailyRoutine(List<Medicine> meds, bool isDark, ThemeVisuals visuals) {
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
            onAction: () => _showAddMedicine(context),
          )
        else ...[
          if (morning.isNotEmpty) _buildRoutineSection(context.tr('morning'), Icons.wb_sunny_rounded, morning, true, isDark, visuals),
          if (afternoon.isNotEmpty) _buildRoutineSection(context.tr('afternoon'), Icons.light_mode_rounded, afternoon, night.isNotEmpty, isDark, visuals),
          if (night.isNotEmpty) _buildRoutineSection(context.tr('night'), Icons.bedtime_rounded, night, false, isDark, visuals),
        ],
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRoutineSection(String title, IconData icon, List<Medicine> meds, bool showLine, bool isDark, ThemeVisuals visuals) {
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
                ...meds.map((m) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildRoutineCard(m, isDark, visuals))),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(Medicine med, bool isDark, ThemeVisuals visuals) {
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

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, Medicine med) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('delete'), style: const TextStyle(color: AppColors.error)),
        content: Text(context.tr('delete_medicine_confirm')),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text(context.tr('cancel'))),
          TextButton(
            onPressed: () {
              ref.read(medicineListProvider.notifier).deleteMedicine(med.id);
              context.pop();
            },
            child: Text(context.tr('delete'), style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showAddMedicine(BuildContext context) {
    final meds = ref.read(medicineListProvider).asData?.value ?? [];
    final canAdd = LimitService.canAdd(
      current: meds.length,
      baseLimit: LimitService.medicineLimit,
      extra: ref.read(limitProvider).extraMedicine,
      isPremium: ref.read(premiumProvider),
    );

    if (!canAdd) {
      showLimitDialog(
        context,
        title: context.tr('limit_medicine_title'),
        description: context.tr('limit_medicine_desc'),
        onRewardEarned: () {
          ref.read(limitProvider.notifier).increaseExtraMedicine(5);
          ref.read(limitProvider.notifier).onRewardedAdCompleted();
        },
      );
      return;
    }

    context.push(AppRoutes.medicineAdd).then((_) => ref.read(medicineListProvider.notifier).refresh());
  }

  Widget _buildStickyDisclaimer(bool isDark, ThemeVisuals visuals) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 14, color: visuals.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.tr('safety_footer_med'),
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
