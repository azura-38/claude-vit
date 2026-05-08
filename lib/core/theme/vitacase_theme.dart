import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VitaColors {
  static const background = Color(0xFFF8F9FF);
  static const surface = Colors.white;
  static const primary = Color(0xFF005DA7);
  static const primaryLight = Color(0xFFD4E3FF);
  static const outline = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF191C21);
  static const textSecondary = Color(0xFF6B7280);

  // Added from Code Packs
  static const secondary = Color(0xFF505F76);
  static const border = Color(0xFFE5EAF3);
  static const softBlue = Color(0xFFDCEBFF);
  static const danger = Color(0xFFBA1A1A);
  static const chipBlue = Color(0xFFDCEBFF);
  static const successBg = Color(0xFFEAF4FF);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const glass = Color(0xCCFFFFFF);
}

class VitaTheme {
  static ThemeData light = ThemeData(
    scaffoldBackgroundColor: VitaColors.background,
    useMaterial3: true,
    textTheme: TextTheme(
      headlineMedium: GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: VitaColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: VitaColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: VitaColors.textSecondary,
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF121212),
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: VitaColors.primaryLight,
      secondary: VitaColors.secondary,
      surface: Color(0xFF1E1E1E),
    ),
    textTheme: TextTheme(
      headlineMedium: GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: Colors.white70,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: Colors.white54,
      ),
    ),
  );
}
