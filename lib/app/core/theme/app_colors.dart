import 'package:flutter/material.dart';

abstract class AppColors {
  // ---------------------------------------------------------------------------
  // Design Specification Color Tokens
  // ---------------------------------------------------------------------------
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryButton = Color(0xFF43A047);
  static const Color primaryButtonPressed = Color(0xFF388E3C);
  static const Color accentGold = Color(0xFFFBC02D);
  static const Color accentRed = Color(0xFFE53935);
  static const Color accentOrange = Color(0xFFFB8C00);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF5F5F5);
  static const Color chipFruitsBg = Color(0xFFFFF3D6);
  static const Color chipGrainsBg = Color(0xFFF0E4C8);
  static const Color chipHerbsBg = Color(0xFFDDEFD9);
  static const Color bannerBgStart = Color(0xFFFCE8C5);
  static const Color bannerBgEnd = Color(0xFFF6C877);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color ratingStar = Color(0xFFFFB300);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color success = Color(0xFF2E7D32);
  static const Color shadowColor = Color(0x0F000000); // 6% opacity black

  // ---------------------------------------------------------------------------
  // Backwards-compatibility aliases for existing project code
  // ---------------------------------------------------------------------------
  static const Color lightScaffoldBg = surfaceWhite;
  static const Color lightSurface = surfaceWhite;
  static const Color lightPrimary = primaryDark;
  static const Color lightSecondary = primary;
  static const Color lightAccentGold = accentGold;
  static const Color lightTextPrimary = textPrimary;
  static const Color lightTextSecondary = textSecondary;
  static const Color lightBorder = divider;

  static const Color darkScaffoldBg = Color(0xFF0F1A15);
  static const Color darkSurface = Color(0xFF18261F);
  static const Color darkPrimary = Color(0xFF52D696);
  static const Color darkSecondary = Color(0xFF063B28);
  static const Color darkAccentGold = Color(0xFFD4A017);
  static const Color darkTextPrimary = Color(0xFFEDF2EE);
  static const Color darkTextSecondary = Color(0xFFA0B3A8);
  static const Color darkBorder = Color(0xFF283A30);

  static const Color background = surfaceWhite;
  static const Color surface = surfaceWhite;
  static const Color border = divider;
  static const Color textMuted = textSecondary;
  static const Color error = accentRed;
}