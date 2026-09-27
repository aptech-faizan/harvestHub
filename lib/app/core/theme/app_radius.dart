import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppRadius {
  // Radius values
  static const double chip = 999.0;
  static const double input = 12.0;
  static const double card = 16.0;
  static const double buttonSmall = 10.0;
  static const double buttonPrimary = 16.0;

  // BorderRadius objects
  static final BorderRadius chipRadius = BorderRadius.circular(chip);
  static final BorderRadius inputRadius = BorderRadius.circular(input);
  static final BorderRadius cardRadius = BorderRadius.circular(card);
  static final BorderRadius buttonSmallRadius = BorderRadius.circular(buttonSmall);
  static final BorderRadius buttonPrimaryRadius = BorderRadius.circular(buttonPrimary);

  // Elevation token: y:2 blur:8 shadowColor (0x0F000000)
  static const List<BoxShadow> cardElevation = [
    BoxShadow(
      color: AppColors.shadowColor,
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
}
