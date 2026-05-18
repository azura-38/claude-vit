import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

import '../../../../shared/data/services/usage_limit_service.dart';
import 'providers/medication_form_provider.dart';
import 'widgets/animated_segmented_control.dart';
import 'widgets/premium_card.dart';
import 'widgets/quantity_stepper.dart';
import 'widgets/reminder_chip.dart';
import 'widgets/smart_info_banner.dart';

class AddMedicationScreen extends ConsumerWidget {
  const AddMedicationScreen({super.key});

  Future<void> _pickReminderTime(BuildContext context, WidgetRef ref) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null) return;
    final value = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    ref.read(medicationFormProvider.notifier).addTime(value);
  }

  String _limitMessage(BuildContext context, int limit) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    return isTr
        ? 'Günlük ekleme limitine ulaştın ($limit). Yarın tekrar ekleyebilirsin.'
        : 'You reached today\'s create limit ($limit). You can add more tomorrow.';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicationFormProvider);
    final notifier = ref.read(medicationFormProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
              children: [
                Row(
                  children: [
                    _CircleIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => context.pop()),
                    const Spacer(),
                    _LogoMark(label: context.l10n.appName),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ),
                const SizedBox(height: 22),
                _MedicationHero(
                  title: context.l10n.addMedication,
                  description: context.l10n.stayConsistentDesc,
                  reminderCount: state.reminderTimes.length,
                ).animate().fadeIn().slideY(begin: .12),
                const SizedBox(height: 22),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(icon: Icons.medication_outlined, title: context.l10n.medicineName),
                      const SizedBox(height: 14),
                      TextField(
                        onChanged: notifier.updateName,
                        decoration: InputDecoration(
                          hintText: context.l10n.searchMedHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.brandMist,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 80.ms).fadeIn().slideY(begin: .15),
                const SizedBox(height: 18),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(icon: Icons.repeat_rounded, title: context.l10n.frequency),
                      const SizedBox(height: 14),
                      AnimatedSegmentedControl(selected: state.frequency, onChanged: notifier.updateFrequency),
                    ],
                  ),
                ).animate(delay: 160.ms).fadeIn().slideY(begin: .15),
                const SizedBox(height: 18),
                PremiumCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SectionTitle(icon: Icons.inventory_2_outlined, title: context.l10n.currentStock),
                          Text(context.l10n.lastsApproxDays(12), style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          QuantityStepper(value: state.quantity, onPlus: notifier.increaseQuantity, onMinus: notifier.decreaseQuantity),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.brandMist,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [Text(context.l10n.tablet), const Icon(Icons.expand_more_rounded)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 240.ms).fadeIn().slideY(begin: .15),
                const SizedBox(height: 18),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SectionTitle(icon: Icons.notifications_active_outlined, title: context.l10n.reminderTimes),
                          Text(
                            '${state.reminderTimes.length} ${context.l10n.times_a_day ?? "times a day"}',
                            style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ...state.reminderTimes.map((time) => ReminderChip(time: time, onRemove: () => notifier.removeTime(time))),
                          _AddTimeChip(label: context.l10n.addTime, onTap: () => _pickReminderTime(context, ref)),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 320.ms).fadeIn().slideY(begin: .15),
                const SizedBox(height: 18),
                SmartInfoBanner(text: context.l10n.supplyReminderDesc).animate(delay: 400.ms).fadeIn(),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    context.l10n.dailyReminderSummary(state.reminderTimes.join(', ')),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white60 : AppColors.textSecondary, height: 1.35),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 28,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () async {
                    try {
                      await notifier.submit();
                      if (context.mounted) context.pop();
                    } catch (e) {
                      if (!context.mounted) return;
                      final message = e is UsageLimitExceededException ? _limitMessage(context, e.limit) : context.l10n.failedAddMedication;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                    }
                  },
                  child: Container(
                    height: 62,
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: AppColors.brandBlue.withValues(alpha: 0.24), blurRadius: 24, offset: const Offset(0, 12))],
                    ),
                    child: Center(
                      child: Text(context.l10n.addMedication, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ).animate().fadeIn(delay: 520.ms).slideY(begin: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationHero extends StatelessWidget {
  const _MedicationHero({required this.title, required this.description, required this.reminderCount});

  final String title;
  final String description;
  final int reminderCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
        boxShadow: [if (!isDark) BoxShadow(color: AppColors.brandBlue.withValues(alpha: 0.08), blurRadius: 28, offset: const Offset(0, 14))],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.brandBlue, AppColors.brandCyan], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.medication_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.brandNavy)),
                const SizedBox(height: 6),
                Text(description, style: TextStyle(fontSize: 13, height: 1.35, color: isDark ? Colors.white60 : AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.brandMist, borderRadius: BorderRadius.circular(999)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.notifications_active_rounded, size: 15, color: AppColors.brandBlue),
                const SizedBox(width: 4),
                Text(reminderCount.toString(), style: const TextStyle(color: AppColors.brandBlue, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.brandBlue),
        const SizedBox(width: 8),
        Flexible(child: Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.brandNavy, fontWeight: FontWeight.w800))),
      ],
    );
  }
}

class _AddTimeChip extends StatelessWidget {
  const _AddTimeChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, size: 18, color: AppColors.brandBlue),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: AppColors.brandBlue, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 18)),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/vitacase_brand_logo.png', width: 28, height: 28, fit: BoxFit.contain),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.brandBlue)),
      ],
    );
  }
}
