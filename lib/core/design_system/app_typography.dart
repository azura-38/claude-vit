import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Brightness brightness) {
    final base =
        brightness == Brightness.dark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme;
    return GoogleFonts.interTextTheme(base).copyWith(
      headlineSmall: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }
}
