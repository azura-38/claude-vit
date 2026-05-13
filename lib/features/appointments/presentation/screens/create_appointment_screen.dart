import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'models/appointment_form_model.dart';
import 'providers/appointment_form_provider.dart';
import 'widgets/appointment_type_card.dart';
import 'widgets/expandable_notes.dart';
import 'widgets/floating_submit_button.dart';
import 'widgets/premium_input.dart';
import 'widgets/priority_selector.dart';
import 'widgets/smart_summary_card.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class CreateAppointmentScreen extends ConsumerWidget {
  const CreateAppointmentScreen({super.key});

  Future<void> _pickDate(
    BuildContext context,
    AppointmentFormNotifier notifier,
    DateTime current,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;
    notifier.updateDate(
      DateTime(
        picked.year,
        picked.month,
        picked.day,
        current.hour,
        current.minute,
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    AppointmentFormNotifier notifier,
    DateTime current,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );

    if (picked != null) {
      notifier.updateTime(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appointmentFormProvider);
    final notifier = ref.read(appointmentFormProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    _CircleIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => context.pop(),
                    ),
                    const Spacer(),
                    _LogoMark(label: context.l10n.appName),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ).animate().fadeIn().slideY(begin: -.12),
                const SizedBox(height: 22),

                SmartSummaryCard(
                  model: state,
                ).animate().fadeIn().slideY(begin: .15),

                const SizedBox(height: 24),

                _card(
                  child: PremiumInput(
                    label: context.l10n.appointmentTitle,
                    hint: context.l10n.hintTitle,
                    icon: Icons.edit_calendar_rounded,
                    onChanged: notifier.updateTitle,
                  ),
                ).animate(delay: 120.ms).fadeIn().slideY(begin: .15),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.type,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children:
                                  AppointmentType.values.map((type) {
                                    return SizedBox(
                                      width: 132,
                                      child: AppointmentTypeCard(
                                        title: _localizedType(context, type),
                                        icon: _typeIcon(type),
                                        selected: state.type == type,
                                        onTap: () {
                                          notifier.updateType(type);
                                        },
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.priority,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            PrioritySelector(
                              title: context.l10n.importanceHigh,
                              icon: Icons.priority_high_rounded,
                              selected:
                                  state.priority == AppointmentPriority.high,
                              color: Colors.red,
                              onTap: () {
                                notifier.updatePriority(
                                  AppointmentPriority.high,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            PrioritySelector(
                              title: context.l10n.importanceLow,
                              icon: Icons.low_priority_rounded,
                              selected:
                                  state.priority == AppointmentPriority.normal,
                              color: const Color(0xFF6B7280),
                              onTap: () {
                                notifier.updatePriority(
                                  AppointmentPriority.normal,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 220.ms).fadeIn().slideY(begin: .15),

                const SizedBox(height: 24),

                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.labelDateTime,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _dateButton(
                              icon: Icons.calendar_month_rounded,
                              text: DateFormat(
                                'MMM d, yyyy',
                              ).format(state.date),
                              onTap:
                                  () =>
                                      _pickDate(context, notifier, state.date),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _dateButton(
                              icon: Icons.schedule_rounded,
                              text: DateFormat('hh:mm a').format(state.date),
                              onTap:
                                  () =>
                                      _pickTime(context, notifier, state.date),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 320.ms).fadeIn().slideY(begin: .15),

                const SizedBox(height: 24),

                _card(
                  child: PremiumInput(
                    label: context.l10n.location,
                    hint: context.l10n.hintLocation,
                    icon: Icons.location_on_outlined,
                    onChanged: notifier.updateLocation,
                  ),
                ).animate(delay: 420.ms).fadeIn().slideY(begin: .15),

                const SizedBox(height: 24),

                _card(
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          context.l10n.labelReminder,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DropdownButton<AppointmentReminder>(
                        value: state.reminder,
                        underline: const SizedBox.shrink(),
                        items:
                            AppointmentReminder.values
                                .map(
                                  (reminder) => DropdownMenuItem(
                                    value: reminder,
                                    child: Text(
                                      _localizedReminder(context, reminder),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            notifier.updateReminder(value);
                          }
                        },
                      ),
                    ],
                  ),
                ).animate(delay: 520.ms).fadeIn().slideY(begin: .15),

                const SizedBox(height: 24),

                ExpandableNotes(
                  onChanged: notifier.updateNotes,
                ).animate(delay: 620.ms).fadeIn().slideY(begin: .15),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : AppColors.brandMist,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.brandBlue.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.brandBlue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.l10n.morningTipAppointment,
                          style: const TextStyle(height: 1.4),
                        ),
                      ),
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
                  onTap:
                      state.isValid
                          ? () async {
                            try {
                              await notifier.submit();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n.appointmentCreatedSuccess,
                                    ),
                                  ),
                                );
                                context.pop();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n.failedCreateAppointment,
                                    ),
                                  ),
                                );
                              }
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

  Widget _card({required Widget child}) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
                  isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: AppColors.brandBlue.withValues(alpha: 0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  Widget _dateButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Material(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.brandMist,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.brandBlue),
                  const SizedBox(width: 10),
                  Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
        return context.l10n.categoryMeeting;
      case AppointmentType.reminder:
        return context.l10n.categoryReminder;
      case AppointmentType.other:
        return context.l10n.categoryOther;
      case AppointmentType.medical:
        return context.l10n.docsCategoryHealth;
      case AppointmentType.finance:
        return context.l10n.docsCategoryFinance;
      case AppointmentType.legal:
        return context.l10n.docsCategoryLegal;
      case AppointmentType.personal:
        return context.l10n.suggestPersonal;
      default:
        return type.label;
    }
  }

  String _localizedReminder(
    BuildContext context,
    AppointmentReminder reminder,
  ) {
    switch (reminder) {
      case AppointmentReminder.tenMinutes:
        return context.l10n.reminder10m;
      case AppointmentReminder.oneHour:
        return context.l10n.reminder1h;
      case AppointmentReminder.oneDay:
        return context.l10n.reminder1d;
      default:
        return reminder.label;
    }
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

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
  final String label;

  const _LogoMark({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/vitacase_brand_logo.png',
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.brandBlue,
            fontFamily: 'Manrope',
          ),
        ),
      ],
    );
  }
}
