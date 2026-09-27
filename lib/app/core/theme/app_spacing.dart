import 'package:flutter/material.dart';

abstract class AppSpacing {
  // 8pt base unit scale
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;

  // Screen and Grid guidelines
  static const double screenHorizontalPadding = 16.0;
  static const double gridHorizontalGutter = 12.0;
  static const double gridVerticalGutter = 16.0;

  // Insets helpers
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: screenHorizontalPadding);
  static const EdgeInsets cardPadding = EdgeInsets.all(l);
  static const EdgeInsets cardPaddingDense = EdgeInsets.all(m);
}
