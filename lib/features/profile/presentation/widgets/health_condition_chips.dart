import 'package:flutter/material.dart';

class HealthConditionChips extends StatelessWidget {
  final List<String> selected;
  final Function(String) onTap;

  const HealthConditionChips({
    super.key,
    required this.selected,
    required this.onTap,
  });

  static const items = [
    'Diabetes',
    'Asthma',
    'Hypertension',
    'Allergy',
    'Migraine',
    'Anxiety',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((e) {
        final active = selected.contains(e);

        return GestureDetector(
          onTap: () => onTap(e),
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF005DA7)
                  : const Color(0xFFF2F3FB),
              borderRadius:
                  BorderRadius.circular(999),
            ),
            child: Text(
              e,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : const Color(0xFF374151),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
