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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: Gender.values.map((gender) {
          final isSelected = selected == gender;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(gender),
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 220),
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    gender.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF005DA7)
                          : const Color(0xFF6B7280),
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
