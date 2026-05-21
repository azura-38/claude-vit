import 'package:flutter/material.dart';

import '../../domain/models/user_profile.dart';

class GenderSelector extends StatelessWidget {
  final Gender selected;
  final ValueChanged<Gender> onChanged;

  const GenderSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBgColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final containerBgColor = isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF2F3FB);
    final unselectedColor = isDark ? Colors.white38 : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: containerBgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children:
            Gender.values.map((gender) {
              final isSelected = selected == gender;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(gender),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? cardBgColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        gender.name.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? primaryColor : unselectedColor,
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
