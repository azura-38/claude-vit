import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/constants/app_routes.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_provider.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';
import 'package:vitacase/core/utils/external_launcher.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../profile/presentation/providers/settings_controller.dart';

class ConditionalQuickAccess extends ConsumerWidget {
  const ConditionalQuickAccess({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickActionsEnabled = ref.watch(
      settingsControllerProvider.select((s) => s.quickActionsEnabled),
    );
    if (!quickActionsEnabled) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.only(bottom: 32),
      child: QuickAccess(),
    );
  }
}

class QuickAccess extends ConsumerWidget {
  const QuickAccess({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visuals = ThemeVisuals.of(ref.watch(themeTypeProvider));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => showDashboardQuickActionsMenu(context, ref),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.quickAccess,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isDark ? Colors.white38 : Colors.black38, letterSpacing: 1.5),
                ),
                Icon(Icons.add_rounded, size: 20, color: visuals.primary),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 800.ms),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Row(
            children: [
              QuickActionItem(label: context.l10n.vault, icon: Icons.description_rounded, onTap: () => ref.read(navigationProvider.notifier).setIndex(1), delay: 900.ms),
              const SizedBox(width: 20),
              QuickActionItem(label: context.l10n.pharmacies, icon: Icons.location_on_rounded, onTap: () => ExternalLauncher.launchMapSearch(context.l10n.pharmacies), delay: 1000.ms),
              const SizedBox(width: 20),
              QuickActionItem(label: context.l10n.medicines, icon: Icons.medication_rounded, onTap: () => context.pushNamed('medicines'), delay: 1100.ms),
              const SizedBox(width: 20),
              QuickActionItem(label: context.l10n.appointments, icon: Icons.calendar_today_rounded, onTap: () => ref.read(navigationProvider.notifier).setIndex(3), delay: 1200.ms),
            ],
          ),
        ),
      ],
    );
  }
}

class QuickActionItem extends ConsumerWidget {
  const QuickActionItem({super.key, required this.label, required this.icon, required this.onTap, required this.delay});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Duration delay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTheme = ref.watch(themeTypeProvider);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ThemePlaceholder(type: selectedTheme, size: 64, iconSize: 28, radius: 24, icon: icon),
          const SizedBox(height: 12),
          SizedBox(
            width: 78,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).scale(begin: const Offset(0.8, 0.8));
  }
}

void showDashboardQuickActionsMenu(BuildContext context, WidgetRef ref) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final visuals = ThemeVisuals.of(ref.read(themeTypeProvider));

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 32),
          Text(context.l10n.quickActions, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 32),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              MenuActionItem(label: context.l10n.addMedicine, icon: Icons.medication_rounded, visuals: visuals, onTap: () { ctx.pop(); context.push(AppRoutes.medicineAdd); }),
              MenuActionItem(label: context.l10n.addAppointment, icon: Icons.calendar_today_rounded, visuals: visuals, onTap: () { ctx.pop(); context.push(AppRoutes.appointmentAdd); }),
              MenuActionItem(label: context.l10n.addDoctor, icon: Icons.person_add_rounded, visuals: visuals, onTap: () { ctx.pop(); context.push(AppRoutes.doctorAdd); }),
              MenuActionItem(label: context.l10n.addDocument, icon: Icons.upload_file_rounded, visuals: visuals, onTap: () { ctx.pop(); context.push(AppRoutes.documentAdd); }),
              MenuActionItem(label: context.l10n.addData, icon: Icons.analytics_rounded, visuals: visuals, onTap: () { ctx.pop(); context.push(AppRoutes.healthDataAdd); }),
              MenuActionItem(label: context.l10n.settings, icon: Icons.settings_rounded, visuals: visuals, onTap: () { ctx.pop(); context.push(AppRoutes.settings); }),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

class MenuActionItem extends StatelessWidget {
  const MenuActionItem({super.key, required this.label, required this.icon, required this.visuals, required this.onTap});

  final String label;
  final IconData icon;
  final ThemeVisuals visuals;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(gradient: visuals.gradient, borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black87),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
