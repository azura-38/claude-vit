import 'package:flutter/material.dart';
import '../models/medication_form_model.dart';
import 'package:vitacase/core/constants/app_colors.dart';

class AnimatedSegmentedControl extends StatelessWidget {
  final MedicationFrequency selected;
  final ValueChanged<MedicationFrequency> onChanged;

  const AnimatedSegmentedControl({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children:
            MedicationFrequency.values.map((frequency) {
              final isSelected = selected == frequency;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(frequency),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow:
                          isSelected
                              ? const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.04),
                                  blurRadius: 10,
                                ),
                              ]
                              : [],
                    ),
                    child: Center(
                      child: Text(
                        frequency.name.toUpperCase(),
                        style: TextStyle(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
