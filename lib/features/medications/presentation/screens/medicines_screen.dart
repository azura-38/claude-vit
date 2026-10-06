import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/theme_visuals.dart';
import '../../../../shared/data/services/limit_service.dart';
import '../../../../shared/providers/limit_providers.dart';
import '../../../../shared/providers/medicine_providers.dart';
import '../../../../shared/providers/premium_provider.dart';
import '../../../../shared/widgets/misc/app_empty_state.dart';
import '../../../../shared/widgets/dialogs/limit_dialog.dart';
import '../../../profile/presentation/providers/legacy_providers.dart';
import '../widgets/medicines_cabinet.dart';
import '../widgets/medicines_daily_routine.dart';
import '../widgets/medicines_hero_header.dart';
import '../widgets/medicines_intake_chart.dart';

class MedicinesScreen extends ConsumerStatefulWidget {
  const MedicinesScreen({super.key});

  @override
  ConsumerState<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends ConsumerState<MedicinesScreen> {
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
                      MedicinesHeroHeader(
                        name: userName,
                        meds: medicines,
                        isDark: isDark,
                        visuals: visuals,
                      ),
                      const SizedBox(height: 28),
                      MedicinesIntakeChart(
                        meds: medicines,
                        isDark: isDark,
                        visuals: visuals,
                      ),
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
                        MedicinesCabinet(
                          meds: medicines,
                          isDark: isDark,
                          visuals: visuals,
                          onAddMedicine: () => _showAddMedicine(context),
                        ),
                        const SizedBox(height: 28),
                        MedicinesDailyRoutine(
                          meds: medicines,
                          isDark: isDark,
                          visuals: visuals,
                          onAddMedicine: () => _showAddMedicine(context),
                        ),
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
