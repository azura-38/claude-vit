import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BloodGroupSelector extends StatelessWidget {
  final String selectedGroup;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final String? label;

  const BloodGroupSelector({
    super.key,
    required this.selectedGroup,
    required this.onChanged,
    required this.isDark,
    this.label,
  });

  static const List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  static String normalize(String? raw) {
    if (raw == null) return '';
    final trimmed = raw.trim();
    if (trimmed == '0+') return 'O+';
    if (trimmed == '0-') return 'O-';
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final inputBg = isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E8F0);
    final normalized = normalize(selectedGroup);
    final selectedValue = bloodGroups.contains(normalized) ? normalized : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              hint: Row(
                children: [
                  const Icon(Icons.bloodtype_rounded, size: 20, color: AppColors.error),
                  const SizedBox(width: 10),
                  Text(
                    normalized.isNotEmpty ? normalized : 'Select blood group',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      fontWeight: normalized.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.medicalBlue),
              dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              items: bloodGroups.map((group) {
                return DropdownMenuItem<String>(
                  value: group,
                  child: Row(
                    children: [
                      const Icon(Icons.bloodtype_rounded, size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(group, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
