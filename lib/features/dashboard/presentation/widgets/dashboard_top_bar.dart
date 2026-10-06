import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/core/theme/theme_provider.dart';
import 'package:vitacase/core/theme/theme_visuals.dart';
import '../../../profile/presentation/providers/legacy_providers.dart';

class DashboardTopBar extends ConsumerWidget {
  const DashboardTopBar({super.key, required this.userName});

  final String userName;
  static const _brandLogoAsset = 'assets/images/vitacase_brand_logo.png';

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.l10n.goodMorning;
    if (hour < 17) return context.l10n.goodAfternoon;
    if (hour < 21) return context.l10n.goodEvening;
    return context.l10n.goodNight;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final photo = ref.watch(profilePhotoProvider);
    final selectedTheme = ref.watch(themeTypeProvider);
    final visuals = ThemeVisuals.of(selectedTheme);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: visuals.primary.withValues(alpha: 0.16), blurRadius: 14),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _buildAvatar(photo, selectedTheme),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(context),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.cardBorderLight,
            ),
          ),
          child: Image.asset(_brandLogoAsset, fit: BoxFit.contain),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildAvatar(String? value, dynamic selectedTheme) {
    final bytes = _decodeDataUri(value);
    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover);
    }
    return ThemePlaceholder(type: selectedTheme, size: 48, iconSize: 22, radius: 24);
  }

  static Uint8List? _decodeDataUri(String? value) {
    if (value == null || !value.startsWith('data:image/')) return null;
    final marker = 'base64,';
    final index = value.indexOf(marker);
    if (index == -1) return null;
    try {
      return base64Decode(value.substring(index + marker.length));
    } catch (_) {
      return null;
    }
  }
}
