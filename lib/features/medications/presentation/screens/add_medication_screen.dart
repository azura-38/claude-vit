import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/medication_form_provider.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'widgets/animated_segmented_control.dart';
import 'widgets/premium_card.dart';
import 'widgets/quantity_stepper.dart';
import 'widgets/reminder_chip.dart';
import 'widgets/smart_info_banner.dart';
import 'package:go_router/go_router.dart';

class AddMedicationScreen extends ConsumerWidget {
  const AddMedicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicationFormProvider);
    final notifier = ref.read(medicationFormProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Spacer(),
                    Text(
                      'VitaCase',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 24, color: AppColors.primary),
                    ),
                    const Spacer(),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Add Medication',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 6),

                Text(
                  'Stay consistent with your treatment',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 28),

                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Medicine Name',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        onChanged: notifier.updateName,
                        decoration: InputDecoration(
                          hintText: 'Search or enter medicine name',
                          prefixIcon: const Icon(Icons.medication_outlined),
                          filled: true,
                          fillColor: AppColors.primaryLight.withValues(
                            alpha: 0.18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: .15),

                const SizedBox(height: 24),

                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Frequency',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 14),
                      AnimatedSegmentedControl(
                        selected: state.frequency,
                        onChanged: notifier.updateFrequency,
                      ),
                    ],
                  ),
                ).animate(delay: 120.ms).fadeIn().slideY(begin: .15),

                const SizedBox(height: 24),

                PremiumCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Supply',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Lasts ~12 days',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          QuantityStepper(
                            value: state.quantity,
                            onPlus: notifier.increaseQuantity,
                            onMinus: notifier.decreaseQuantity,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(
                                  alpha: 0.18,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('tablet'),
                                  Icon(Icons.expand_more_rounded),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 240.ms).fadeIn().slideY(begin: .15),

                const SizedBox(height: 24),

                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Reminder Times',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text('${state.reminderTimes.length} times a day'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ...state.reminderTimes.map(
                            (time) => ReminderChip(
                              time: time,
                              onRemove: () {
                                notifier.removeTime(time);
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              notifier.addTime('12:00');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.outline,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, size: 18),
                                  SizedBox(width: 4),
                                  Text('Add Time'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 360.ms).fadeIn().slideY(begin: .15),

                const SizedBox(height: 24),

                SmartInfoBanner(
                  text:
                      'We’ll remind you before your supply runs out based on your current inventory.',
                ).animate(delay: 460.ms).fadeIn(),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'You will be reminded at 08:00 and 20:00 daily.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
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
                      if (context.mounted) {
                        context.pop();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to add medication.'),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    height: 62,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 93, 167, 0.24),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Add Medication',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
