import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PhonePrefixPicker extends StatelessWidget {
  final String selectedCode;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const PhonePrefixPicker({
    super.key,
    required this.selectedCode,
    required this.onChanged,
    required this.isDark,
  });

  static const Map<String, String> countryCodes = {
    '+1': '🇺🇸 USA / CAN',
    '+90': '🇹🇷 Turkey',
    '+49': '🇩🇪 Germany',
    '+34': '🇪🇸 Spain',
    '+33': '🇫🇷 France',
    '+55': '🇧🇷 Brazil',
    '+966': '🇸🇦 Saudi Arabia',
    '+86': '🇨🇳 China',
    '+81': '🇯🇵 Japan',
    '+82': '🇰🇷 South Korea',
    '+44': '🇬🇧 UK',
    '+7': '🇷🇺 Russia',
    '+91': '🇮🇳 India',
    '+39': '🇮🇹 Italy',
  };

  static String getDefaultPrefix(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return '+90';
      case 'de':
        return '+49';
      case 'es':
        return '+34';
      case 'fr':
        return '+33';
      case 'pt':
        return '+55';
      case 'ar':
        return '+966';
      case 'zh':
        return '+86';
      case 'ja':
        return '+81';
      case 'ko':
        return '+82';
      default:
        return '+1';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF1F5F9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value:
              countryCodes.containsKey(selectedCode)
                  ? selectedCode
                  : countryCodes.keys.first,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: AppColors.medicalBlue,
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
          items:
              countryCodes.entries.map((e) {
                return DropdownMenuItem(value: e.key, child: Text(e.key));
              }).toList(),
        ),
      ),
    );
  }
}
