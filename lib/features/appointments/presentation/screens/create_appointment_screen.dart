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

class CreateAppointmentScreen extends ConsumerWidget {
  const CreateAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appointmentFormProvider);
    final notifier = ref.read(appointmentFormProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 140),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Create Appointment',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 28),

                SmartSummaryCard(model: state)
                    .animate()
                    .fadeIn()
                    .slideY(begin: .15),

                const SizedBox(height: 24),

                _card(
                  child: PremiumInput(
                    label: 'Appointment Title',
                    hint: 'e.g. Annual Checkup',
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
                            const Text(
                              'Type',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppointmentTypeCard(
                              title: 'Doctor',
                              icon: Icons.medical_services_outlined,
                              selected:
                                  state.type == AppointmentType.doctor,
                              onTap: () {
                                notifier.updateType(
                                    AppointmentType.doctor);
                              },
                            ),
                            const SizedBox(height: 12),
                            AppointmentTypeCard(
                              title: 'Test',
                              icon: Icons.monitor_heart_outlined,
                              selected: state.type == AppointmentType.test,
                              onTap: () {
                                notifier.updateType(AppointmentType.test);
                              },
                            )
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
                            const Text(
                              'Priority',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            PrioritySelector(
                              title: 'High',
                              icon: Icons.priority_high_rounded,
                              selected:
                                  state.priority == AppointmentPriority.high,
                              color: Colors.red,
                              onTap: () {
                                notifier.updatePriority(
                                    AppointmentPriority.high);
                              },
                            ),
                            const SizedBox(height: 12),
                            PrioritySelector(
                              title: 'Normal',
                              icon: Icons.low_priority_rounded,
                              selected:
                                  state.priority ==
                                      AppointmentPriority.normal,
                              color: const Color(0xFF6B7280),
                              onTap: () {
                                notifier.updatePriority(
                                    AppointmentPriority.normal);
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ).animate(delay: 220.ms).fadeIn().slideY(begin: .15),

                const SizedBox(height: 24),

                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date & Time',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _dateButton(
                              icon: Icons.calendar_month_rounded,
                              text: DateFormat('MMM d, yyyy')
                                  .format(state.date),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _dateButton(
                              icon: Icons.schedule_rounded,
                              text: DateFormat('hh:mm a')
                                  .format(state.date),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ).animate(delay: 320.ms).fadeIn().slideY(begin: .15),

                const SizedBox(height: 24),

                _card(
                  child: PremiumInput(
                    label: 'Location',
                    hint: 'City Medical Center',
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
                      const Expanded(
                        child: Text(
                          'Reminder',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DropdownButton<String>(
                        value: state.reminder,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(
                            value: '1 hour before',
                            child: Text('1 hour before'),
                          ),
                          DropdownMenuItem(
                            value: '1 day before',
                            child: Text('1 day before'),
                          ),
                          DropdownMenuItem(
                            value: '30 minutes before',
                            child: Text('30 minutes before'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            notifier.updateReminder(value);
                          }
                        },
                      )
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
                    color: const Color(0xFFDCEBFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: Color(0xFF005DA7)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Morning appointments usually reduce missed reminders and delays.',
                          style: TextStyle(
                            height: 1.4,
                          ),
                        ),
                      )
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
                  onTap: () {},
                )
                    .animate()
                    .fadeIn(delay: 820.ms)
                    .slideY(begin: 1),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 93, 167, 0.04),
            blurRadius: 24,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _dateButton({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6B7280)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}
