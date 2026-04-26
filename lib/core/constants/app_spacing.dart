import 'package:flutter/material.dart';

/// Spacing constants matching the React app's Tailwind spacing scale.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 28.0;

  // Page padding
  static const double pagePaddingH = 20.0; // px-5
  static const double pagePaddingV = 24.0; // p-6

  // Card border radius
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 28.0;
  static const double radiusFull = 999.0;

  // Bottom nav height
  static const double bottomNavHeight = 80.0;
  static const double bottomNavPadding = 80.0;

  // Card
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pagePaddingH,
    vertical: pagePaddingV,
  );
}
