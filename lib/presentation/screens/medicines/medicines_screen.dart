import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/entities/medicine.dart';
import '../../providers/medicine_providers.dart';
import '../../providers/profile_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/limit_providers.dart';
import '../../widgets/limits/limit_dialog.dart';
import '../../../data/services/limit_service.dart';
import '../../providers/premium_provider.dart';
import '../../widgets/banner_ad_container.dart';

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
    final userName = ref.watch(profileNameProvider) ?? context.l10n('guest_user');

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Column(
        children: [
          const BannerAdContainer(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, isDark),
                SliverToBoxAdapter(
                  child: medsAsync.when(
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
                    error: (e, _) => Center(child: Text('${context.l10n('error')}: $e')),
                    data: (medicines) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildHeroHeader(userName, medicines, isDark),
                            const SizedBox(height: 32),
                            _buildIntakeChart(isDark),
                            const SizedBox(height: 32),
                            _buildMedicineCabinet(medicines, isDark),
                            const SizedBox(height: 32),
                            _buildDailyRoutine(medicines, isDark),
                            const SizedBox(height: 120),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStickyDisclaimer(isDark),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMedicine(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.medicalBlue, AppColors.medicalBlue.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF005DA7).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          const SizedBox(width: 12),
          Text(
            context.l10n('my_medicines'),
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              color: AppColors.medicalBlue,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, color: Colors.blueGrey.shade600),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeroHeader(String name, List<Medicine> meds, bool isDark) {
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
          (m) => m != null && m.currentStock != null && m.totalStock != null && (m.currentStock! / m.totalStock! < 0.2),
          orElse: () => null,
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [AppColors.medicalBlue, AppColors.medicalBlue.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005DA7).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
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
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${context.l10n(greetingKey)}, $name",
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n('med_count_desc').replaceFirst('{count}', meds.length.toString()),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              if (lowStockMed != null) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white.withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
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
                                  context.l10n('low_stock_warning'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  context.l10n('critical_level').replaceFirst('{name}', lowStockMed.name),
                                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005DA7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text(context.l10n('refill'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ]
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildIntakeChart(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n('intake_chart'),
          style: const TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildChartBar(context.l10n('day_monday_very_short'), 0.6, false),
                  _buildChartBar(context.l10n('day_tuesday_very_short'), 0.85, false),
                  _buildChartBar(context.l10n('day_wednesday_very_short'), 1.0, true),
                  _buildChartBar(context.l10n('day_thursday_very_short'), 0.7, false),
                  _buildChartBar(context.l10n('day_friday_very_short'), 0.95, true),
                  _buildChartBar(context.l10n('day_saturday_very_short'), 0.9, false),
                  _buildChartBar(context.l10n('day_sunday_very_short'), 0.4, false),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF006766), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(context.l10n('success'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                    ],
                  ),
                  Text(
                    context.l10n('weekly_avg').replaceFirst('{perc}', '82'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF005DA7)),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildChartBar(String day, double heightFactor, bool isSuccess) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blueGrey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 24,
            height: 100 * heightFactor,
            decoration: BoxDecoration(
              color: isSuccess ? const Color(0xFF006766) : const Color(0xFF005DA7).withValues(alpha: 0.4 + (0.6 * heightFactor)),
              borderRadius: BorderRadius.circular(6),
            ),
          ).animate().scaleY(begin: 0, end: 1, duration: 800.ms, curve: Curves.easeOutCubic),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
      ],
    );
  }

  Widget _buildMedicineCabinet(List<Medicine> meds, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n('medicine_cabinet'), style: const TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800)),
                Text(context.l10n('active_inventory'), style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54)),
              ],
            ),
            TextButton.icon(
              onPressed: () => _showAddMedicine(context),
              icon: const Icon(Icons.add, size: 18),
              label: Text(context.l10n('add'), style: const TextStyle(fontWeight: FontWeight.w800)),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF005DA7)),
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
          itemBuilder: (context, index) {
            if (index == meds.length) {
              return _buildAddMedicinePlaceholder(isDark);
            }
            return _buildMedicineCard(meds[index], isDark);
          },
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildMedicineCard(Medicine med, bool isDark) {
    final current = med.currentStock ?? 0;
    final total = med.totalStock ?? 1;
    final progress = (current / total).clamp(0.0, 1.0);
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
                PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit_rounded, size: 18), const SizedBox(width: 8), Text(context.l10n('edit'))])),
                PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete_rounded, size: 18, color: Colors.red), const SizedBox(width: 8), Text(context.l10n('delete'), style: const TextStyle(color: Colors.red))])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.medicalBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  med.dosage.toLowerCase().contains("syrup") || med.dosage.toLowerCase().contains("şurup")
                      ? Icons.vaccines_rounded
                      : Icons.medication_rounded,
                  color: AppColors.medicalBlue,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(med.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(med.dosage, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      color: isLow ? Colors.red : const Color(0xFF005DA7),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLow
                        ? context.l10n('low_stock_warning').toUpperCase()
                        : context.l10n('stock_left').replaceFirst('{count}', current.toString()),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: isLow ? Colors.red : Colors.blueGrey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddMedicinePlaceholder(bool isDark) {
    return GestureDetector(
      onTap: () => _showAddMedicine(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.2), width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, size: 32, color: Colors.blueGrey.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Text(
              context.l10n('med_cabinet_add'),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.blueGrey.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyRoutine(List<Medicine> meds, bool isDark) {
    final morning = <Medicine>[];
    final afternoon = <Medicine>[];
    final night = <Medicine>[];

    final now = DateTime.now();
    for (var med in meds) {
      // Filter based on frequency
      bool isToday = false;
      if (med.frequency == 'daily') {
        isToday = true;
      } else if (med.frequency == 'weekly') {
        // Simple logic: if today is same weekday as creation
        isToday = now.weekday == med.createdAt.weekday;
      } else {
        // For custom or others, we might need more logic, 
        // but for now let's assume if it's not daily/weekly, 
        // it only shows on the day it was created (one-time logic).
        isToday = DateFormatter.formatIso(now) == DateFormatter.formatIso(med.createdAt);
      }

      if (!isToday) continue;

      for (var time in med.reminderTimes) {
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
        Text(context.l10n('daily_routine'), style: const TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 24),
        if (morning.isNotEmpty) _buildRoutineSection(context.l10n('morning'), Icons.wb_sunny_rounded, morning, true, isDark),
        if (afternoon.isNotEmpty) _buildRoutineSection(context.l10n('afternoon'), Icons.light_mode_rounded, afternoon, night.isNotEmpty, isDark),
        if (night.isNotEmpty) _buildRoutineSection(context.l10n('night'), Icons.bedtime_rounded, night, false, isDark),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRoutineSection(String title, IconData icon, List<Medicine> meds, bool showLine, bool isDark) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: AppColors.medicalBlue, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFD4E3FF), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF005DA7))),
                const SizedBox(height: 12),
                ...meds.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRoutineCard(m, isDark),
                )),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(Medicine med, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.medication_rounded, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("${med.hungerStatus.label}, ${med.dosage}", style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.medicalBlue, size: 24),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, Medicine med) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n('delete'), style: const TextStyle(color: AppColors.error)),
        content: Text(context.l10n('delete_medicine_confirm')),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text(context.l10n('cancel'))),
          TextButton(
            onPressed: () {
              ref.read(medicineListProvider.notifier).deleteMedicine(med.id);
              context.pop();
            },
            child: Text(context.l10n('delete'), style: const TextStyle(color: AppColors.error)),
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
        title: context.l10n('limit_medicine_title'),
        description: context.l10n('limit_medicine_desc'),
        onRewardEarned: () {
          ref.read(limitProvider.notifier).increaseExtraMedicine(5);
          ref.read(limitProvider.notifier).onRewardedAdCompleted();
        },
      );
      return;
    }

    context.push(AppRoutes.medicineAdd).then((_) => ref.read(medicineListProvider.notifier).refresh());
  }

  Widget _buildStickyDisclaimer(bool isDark) {
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
            Icon(Icons.info_outline_rounded, size: 14, color: const Color(0xFF005DA7)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n('safety_footer_med'),
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
