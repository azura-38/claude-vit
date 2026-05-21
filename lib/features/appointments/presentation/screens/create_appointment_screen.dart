import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

import '../../../../shared/data/services/usage_limit_service.dart';
import 'models/appointment_form_model.dart';
import 'providers/appointment_form_provider.dart';
import 'widgets/appointment_type_card.dart';
import 'widgets/expandable_notes.dart';
import 'widgets/floating_submit_button.dart';
import 'widgets/premium_input.dart';
import 'widgets/priority_selector.dart';
import 'widgets/smart_summary_card.dart';

class CreateAppointmentScreen extends ConsumerWidget {
  const CreateAppointmentScreen({super.key});

  Future<void> _pickDate(BuildContext context, AppointmentFormNotifier notifier, DateTime current) async {
    final picked = await showDatePicker(context: context, initialDate: current, firstDate: DateTime.now(), lastDate: DateTime(2035));
    if (picked == null) return;
    notifier.updateDate(DateTime(picked.year, picked.month, picked.day, current.hour, current.minute));
  }

  Future<void> _pickTime(BuildContext context, AppointmentFormNotifier notifier, DateTime current) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(current));
    if (picked != null) notifier.updateTime(picked);
  }



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appointmentFormProvider);
    final notifier = ref.read(appointmentFormProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subcategories = subcategoriesForAppointmentType(state.type);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 140),
              children: [
                Row(
                  children: [
                    _CircleIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => context.pop()),
                    const Spacer(),
                    _LogoMark(label: context.tr('app_name')),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ).animate().fadeIn().slideY(begin: -.12),
                const SizedBox(height: 22),
                SmartSummaryCard(model: state).animate().fadeIn().slideY(begin: .15),
                const SizedBox(height: 24),
                _card(
                  child: PremiumInput(
                    label: context.tr('appointment_title'),
                    hint: context.tr('hint_title'),
                    icon: Icons.edit_calendar_rounded,
                    onChanged: notifier.updateTitle,
                  ),
                ).animate(delay: 120.ms).fadeIn().slideY(begin: .15),
                const SizedBox(height: 24),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('type'), style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AppointmentType.values.map((type) {
                          return SizedBox(
                            width: 132,
                            child: AppointmentTypeCard(
                              title: _localizedType(context, type),
                              icon: _typeIcon(type),
                              selected: state.type == type,
                              onTap: () => notifier.updateType(type),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<AppointmentSubcategory>(
                        initialValue: subcategories.contains(state.subcategory) ? state.subcategory : subcategories.first,
                        decoration: InputDecoration(labelText: context.tr('subcategory')),
                        items: subcategories.map((subcategory) => DropdownMenuItem(value: subcategory, child: Text(_localizedSubcategory(context, subcategory)))).toList(),
                        onChanged: (value) {
                          if (value != null) notifier.updateSubcategory(value);
                        },
                      ),
                    ],
                  ),
                ).animate(delay: 220.ms).fadeIn().slideY(begin: .15),
                const SizedBox(height: 24),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('priority'), style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      PrioritySelector(
                        title: context.tr('importance_high'),
                        icon: Icons.priority_high_rounded,
                        selected: state.priority == AppointmentPriority.high,
                        color: Colors.red,
                        onTap: () => notifier.updatePriority(AppointmentPriority.high),
                      ),
                      const SizedBox(height: 12),
                      PrioritySelector(
                        title: context.tr('importance_normal'),
                        icon: Icons.low_priority_rounded,
                        selected: state.priority == AppointmentPriority.normal,
                        color: const Color(0xFF6B7280),
                        onTap: () => notifier.updatePriority(AppointmentPriority.normal),
                      ),
                    ],
                  ),
                ).animate(delay: 260.ms).fadeIn().slideY(begin: .15),
                const SizedBox(height: 24),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('label_date_time'), style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _dateButton(
                              icon: Icons.calendar_month_rounded,
                              text: DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(state.date),
                              onTap: () => _pickDate(context, notifier, state.date),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _dateButton(
                              icon: Icons.schedule_rounded,
                              text: DateFormat.jm(Localizations.localeOf(context).languageCode).format(state.date),
                              onTap: () => _pickTime(context, notifier, state.date),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 320.ms).fadeIn().slideY(begin: .15),
                const SizedBox(height: 24),
                _card(
                  child: PremiumInput(label: context.tr('location'), hint: context.tr('hint_location'), icon: Icons.location_on_outlined, onChanged: notifier.updateLocation),
                ).animate(delay: 420.ms).fadeIn().slideY(begin: .15),
                const SizedBox(height: 24),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active_outlined),
                          const SizedBox(width: 14),
                          Expanded(child: Text(context.tr('label_reminder'), style: const TextStyle(fontWeight: FontWeight.w600))),
                          DropdownButton<AppointmentReminder>(
                            value: state.reminder,
                            underline: const SizedBox.shrink(),
                            items: AppointmentReminder.values.map((reminder) => DropdownMenuItem(value: reminder, child: Text(_localizedReminder(context, reminder)))).toList(),
                            onChanged: (value) {
                              if (value != null) notifier.updateReminder(value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _ReminderHelperNote(isDark: isDark),
                    ],
                  ),
                ).animate(delay: 520.ms).fadeIn().slideY(begin: .15),
                const SizedBox(height: 24),
                ExpandableNotes(onChanged: notifier.updateNotes).animate(delay: 620.ms).fadeIn().slideY(begin: .15),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.brandMist,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.brandBlue.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded, color: AppColors.brandBlue),
                      const SizedBox(width: 12),
                      Expanded(child: Text(context.tr('morning_tip_appointment'), style: const TextStyle(height: 1.4))),
                    ],
                  ),
                ).animate(delay: 720.ms).fadeIn(),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 28,
              child: SafeArea(
                child: FloatingSubmitButton(
                  isLoading: state.isSubmitting,
                  onTap: state.isValid
                      ? () async {
                          try {
                            await notifier.submit();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('appointment_created_success'))));
                              context.pop();
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            final message = e is UsageLimitExceededException ? context.l10n.dailyLimitReachedMessage(e.limit) : context.tr('failed_create_appointment');
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                          }
                        }
                      : null,
                ).animate().fadeIn(delay: 820.ms).slideY(begin: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
              boxShadow: [if (!isDark) BoxShadow(color: AppColors.brandBlue.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 10))],
            ),
            child: child,
          );
        },
      );

  Widget _dateButton({required IconData icon, required String text, required VoidCallback onTap}) => Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Material(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.brandMist,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(children: [Icon(icon, color: AppColors.brandBlue), const SizedBox(width: 10), Expanded(child: Text(text, overflow: TextOverflow.ellipsis))]),
              ),
            ),
          );
        },
      );

  IconData _typeIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.medical:
        return Icons.medical_services_outlined;
      case AppointmentType.finance:
        return Icons.account_balance_wallet_outlined;
      case AppointmentType.legal:
        return Icons.gavel_outlined;
      case AppointmentType.insurance:
        return Icons.verified_user_outlined;
      case AppointmentType.meeting:
        return Icons.groups_outlined;
      case AppointmentType.personal:
        return Icons.person_outline;
      case AppointmentType.travel:
        return Icons.flight_takeoff_outlined;
      case AppointmentType.reminder:
        return Icons.notifications_active_outlined;
      case AppointmentType.other:
        return Icons.more_horiz_outlined;
    }
  }

  String _localizedType(BuildContext context, AppointmentType type) {
    switch (type) {
      case AppointmentType.meeting:
        return context.tr('category_meeting');
      case AppointmentType.reminder:
        return context.tr('category_reminder');
      case AppointmentType.other:
        return context.tr('category_other');
      case AppointmentType.medical:
        return context.tr('docs_category_health');
      case AppointmentType.finance:
        return context.tr('docs_category_finance');
      case AppointmentType.legal:
        return context.tr('docs_category_legal');
      case AppointmentType.insurance:
        return context.tr('appointment_type_insurance');
      case AppointmentType.personal:
        return context.tr('suggest_personal');
      case AppointmentType.travel:
        return context.tr('appointment_type_travel');
    }
  }

  String _localizedSubcategory(BuildContext context, AppointmentSubcategory subcategory) => context.tr('appointment_subcategory_${_enumKey(subcategory.name)}');

  String _localizedReminder(BuildContext context, AppointmentReminder reminder) {
    switch (reminder) {
      case AppointmentReminder.tenMinutes:
        return context.tr('reminder_10m');
      case AppointmentReminder.oneHour:
        return context.tr('reminder_1h');
      case AppointmentReminder.oneDay:
        return context.tr('reminder_1d');
      case AppointmentReminder.sevenDays:
        return context.tr('reminder_7d');
    }
  }

  String _enumKey(String value) {
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final char = value[i];
      final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
      if (i > 0 && isUpper) buffer.write('_');
      buffer.write(char.toLowerCase());
    }
    return buffer.toString();
  }
}

class _ReminderHelperNote extends StatelessWidget {
  const _ReminderHelperNote({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text = context.l10n.appointmentReminderPastNote;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.brandMist,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.brandBlue),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary, height: 1.35, fontWeight: FontWeight.w600))),
        ],
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
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 18))),
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
