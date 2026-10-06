import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CountryPhoneInfo {
  final String code;
  final String name;
  final String flag;

  const CountryPhoneInfo({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class PhoneCountryCodes {
  static const List<CountryPhoneInfo> all = [
    CountryPhoneInfo(code: '+90', name: 'Turkey', flag: '🇹🇷'),
    CountryPhoneInfo(code: '+1', name: 'USA / Canada', flag: '🇺🇸'),
    CountryPhoneInfo(code: '+44', name: 'United Kingdom', flag: '🇬🇧'),
    CountryPhoneInfo(code: '+49', name: 'Germany', flag: '🇩🇪'),
    CountryPhoneInfo(code: '+33', name: 'France', flag: '🇫🇷'),
    CountryPhoneInfo(code: '+34', name: 'Spain', flag: '🇪🇸'),
    CountryPhoneInfo(code: '+39', name: 'Italy', flag: '🇮🇹'),
    CountryPhoneInfo(code: '+7', name: 'Russia / Kazakhstan', flag: '🇷🇺'),
    CountryPhoneInfo(code: '+20', name: 'Egypt', flag: '🇪🇬'),
    CountryPhoneInfo(code: '+27', name: 'South Africa', flag: '🇿🇦'),
    CountryPhoneInfo(code: '+31', name: 'Netherlands', flag: '🇳🇱'),
    CountryPhoneInfo(code: '+32', name: 'Belgium', flag: '🇧🇪'),
    CountryPhoneInfo(code: '+41', name: 'Switzerland', flag: '🇨🇭'),
    CountryPhoneInfo(code: '+43', name: 'Austria', flag: '🇦🇹'),
    CountryPhoneInfo(code: '+45', name: 'Denmark', flag: '🇩🇰'),
    CountryPhoneInfo(code: '+46', name: 'Sweden', flag: '🇸🇪'),
    CountryPhoneInfo(code: '+47', name: 'Norway', flag: '🇳🇴'),
    CountryPhoneInfo(code: '+48', name: 'Poland', flag: '🇵🇱'),
    CountryPhoneInfo(code: '+52', name: 'Mexico', flag: '🇲🇽'),
    CountryPhoneInfo(code: '+55', name: 'Brazil', flag: '🇧🇷'),
    CountryPhoneInfo(code: '+60', name: 'Malaysia', flag: '🇲🇾'),
    CountryPhoneInfo(code: '+61', name: 'Australia', flag: '🇦🇺'),
    CountryPhoneInfo(code: '+62', name: 'Indonesia', flag: '🇮🇩'),
    CountryPhoneInfo(code: '+65', name: 'Singapore', flag: '🇸🇬'),
    CountryPhoneInfo(code: '+81', name: 'Japan', flag: '🇯🇵'),
    CountryPhoneInfo(code: '+82', name: 'South Korea', flag: '🇰🇷'),
    CountryPhoneInfo(code: '+86', name: 'China', flag: '🇨🇳'),
    CountryPhoneInfo(code: '+91', name: 'India', flag: '🇮🇳'),
    CountryPhoneInfo(code: '+92', name: 'Pakistan', flag: '🇵🇰'),
    CountryPhoneInfo(code: '+94', name: 'Sri Lanka', flag: '🇱🇰'),
    CountryPhoneInfo(code: '+966', name: 'Saudi Arabia', flag: '🇸🇦'),
    CountryPhoneInfo(code: '+971', name: 'United Arab Emirates', flag: '🇦🇪'),
    CountryPhoneInfo(code: '+974', name: 'Qatar', flag: '🇶🇦'),
    CountryPhoneInfo(code: '+351', name: 'Portugal', flag: '🇵🇹'),
    CountryPhoneInfo(code: '+353', name: 'Ireland', flag: '🇮🇪'),
    CountryPhoneInfo(code: '+380', name: 'Ukraine', flag: '🇺🇦'),
  ];

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
      case 'it':
        return '+39';
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
      case 'ru':
        return '+7';
      case 'hi':
        return '+91';
      default:
        return '+90';
    }
  }

  /// Safely parses an existing phone number string into (countryCode, localNumber).
  /// Backward compatible with raw numbers without code or previously formatted strings.
  static ({String countryCode, String localNumber}) parse(
    String? raw, {
    String defaultCode = '+90',
  }) {
    if (raw == null || raw.trim().isEmpty) {
      return (countryCode: defaultCode, localNumber: '');
    }

    final trimmed = raw.trim();

    // Try to match longest country code prefix first
    final sortedByLength = List<CountryPhoneInfo>.from(all)
      ..sort((a, b) => b.code.length.compareTo(a.code.length));

    for (final info in sortedByLength) {
      if (trimmed.startsWith(info.code)) {
        var remainder = trimmed.substring(info.code.length).trim();
        // Remove leading dash, slash, or space if present
        if (remainder.startsWith('-') || remainder.startsWith('/')) {
          remainder = remainder.substring(1).trim();
        }
        return (countryCode: info.code, localNumber: remainder);
      }
    }

    // If starts with '+' but not in our predefined list, extract prefix up to first space or 4 chars
    if (trimmed.startsWith('+')) {
      final spaceIdx = trimmed.indexOf(' ');
      if (spaceIdx > 1 && spaceIdx <= 5) {
        return (
          countryCode: trimmed.substring(0, spaceIdx),
          localNumber: trimmed.substring(spaceIdx + 1).trim(),
        );
      }
    }

    // Default case: whole string is local number
    return (countryCode: defaultCode, localNumber: trimmed);
  }
}

class VitaPhoneInput extends StatelessWidget {
  final String countryCode;
  final TextEditingController controller;
  final ValueChanged<String> onCountryCodeChanged;
  final ValueChanged<String>? onChanged;
  final String? label;
  final String hintText;
  final bool isDark;

  const VitaPhoneInput({
    super.key,
    required this.countryCode,
    required this.controller,
    required this.onCountryCodeChanged,
    this.onChanged,
    this.label,
    this.hintText = '5XX XXX XX XX',
    required this.isDark,
  });

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = PhoneCountryCodes.all.where((info) {
              final query = searchQuery.toLowerCase();
              return info.name.toLowerCase().contains(query) ||
                  info.code.contains(query);
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: TextField(
                        onChanged: (val) => setModalState(() => searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search country or code...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          filled: true,
                          fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        ),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSelected = item.code == countryCode;
                          return ListTile(
                            leading: Text(item.flag, style: const TextStyle(fontSize: 22)),
                            title: Text(item.name, style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500)),
                            trailing: Text(
                              item.code,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.medicalBlue : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                            selected: isSelected,
                            onTap: () {
                              onCountryCodeChanged(item.code);
                              Navigator.pop(bottomSheetContext);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCountry = PhoneCountryCodes.all.firstWhere(
      (c) => c.code == countryCode,
      orElse: () => CountryPhoneInfo(code: countryCode, name: '', flag: '🌐'),
    );

    final inputBg = isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            InkWell(
              onTap: () => _showCountryPicker(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(currentCountry.flag, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      currentCountry.code,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.brandNavy,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.medicalBlue,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  filled: true,
                  fillColor: inputBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.medicalBlue, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
