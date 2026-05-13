import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

import 'package:vitacase/core/extensions/l10n_extension.dart';

enum AppThemeType {
  light,
  dark,
  purple,
  nature,
  ocean,
  amber,
  system;

  String localizedLabel(BuildContext context) {
    switch (this) {
      case AppThemeType.light:
        return context.l10n.themeLuxeSanctuary;
      case AppThemeType.dark:
        return context.l10n.themeMidnightNeon;
      case AppThemeType.purple:
        return context.l10n.themeAmethystAura;
      case AppThemeType.nature:
        return context.l10n.themeEmeraldGarden;
      case AppThemeType.ocean:
        return context.l10n.themeOceanSerenity;
      case AppThemeType.amber:
        return context.l10n.themeAmberGlow;
      case AppThemeType.system:
        return context.l10n.themeSystem;
    }
  }

  String get label {
    switch (this) {
      case AppThemeType.light:
        return 'Luxe Sanctuary';
      case AppThemeType.dark:
        return 'Midnight Neon';
      case AppThemeType.purple:
        return 'Amethyst Aura';
      case AppThemeType.nature:
        return 'Emerald Garden';
      case AppThemeType.ocean:
        return 'Ocean Serenity';
      case AppThemeType.amber:
        return 'Amber Glow';
      case AppThemeType.system:
        return 'System Default';
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        primary: AppColors.luxePrimary,
        background: AppColors.luxeBg,
        surface: Colors.white,
        fontFamily: GoogleFonts.inter().fontFamily,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        primary: AppColors.neonPrimary,
        background: Colors.black,
        surface: const Color(0xFF121212),
        isAmoled: true,
        fontFamily: GoogleFonts.outfit().fontFamily,
      );

  static ThemeData getThemeByType(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return light;
      case AppThemeType.dark:
        return dark;
      case AppThemeType.purple:
        return _buildTheme(
          brightness: Brightness.light,
          primary: AppColors.purplePrimary,
          background: AppColors.purpleBg,
          surface: Colors.white,
          fontFamily: GoogleFonts.epilogue().fontFamily,
        );
      case AppThemeType.nature:
        return _buildTheme(
          brightness: Brightness.light,
          primary: AppColors.naturePrimary,
          background: AppColors.natureBg,
          surface: Colors.white,
          fontFamily: GoogleFonts.outfit().fontFamily,
        );
      case AppThemeType.ocean:
        return _buildTheme(
          brightness: Brightness.light,
          primary: AppColors.oceanPrimary,
          background: AppColors.oceanBg,
          surface: Colors.white,
          fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        );
      case AppThemeType.amber:
        return _buildTheme(
          brightness: Brightness.light,
          primary: AppColors.amberPrimary,
          background: AppColors.amberBg,
          surface: Colors.white,
          fontFamily: GoogleFonts.manrope().fontFamily,
        );
      case AppThemeType.system:
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark ? dark : light;
    }
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color background,
    required Color surface,
    bool isAmoled = false,
    String? fontFamily,
  }) {
    final isDark = brightness == Brightness.dark;
    
    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: primary,
            secondary: primary.withValues(alpha: 0.7),
            surface: isAmoled ? Colors.black : surface,
            onSurface: Colors.white,
            error: AppColors.error,
          )
        : ColorScheme.fromSeed(
            seedColor: primary,
            brightness: Brightness.light,
            surface: surface,
            primary: primary,
          );

    final textTheme = (isDark ? ThemeData.dark() : ThemeData.light()).textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isAmoled ? Colors.black : background,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      textTheme: GoogleFonts.getTextTheme(fontFamily ?? 'Inter', textTheme).copyWith(
        titleLarge: GoogleFonts.getTextTheme(fontFamily ?? 'Inter', textTheme).titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: isDark
            ? (isAmoled ? Colors.black : AppColors.cardDark)
            : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark 
                ? (isAmoled ? Colors.white.withValues(alpha: 0.1) : AppColors.cardBorderDark) 
                : AppColors.cardBorderLight,
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? (isAmoled ? Colors.black : AppColors.cardDark) : AppColors.bgLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? (isAmoled ? Colors.black : AppColors.cardDark) : Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: isDark ? Colors.white38 : AppColors.navInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        thickness: 1,
      ),
    );
  }
}
