import 'package:flutter/material.dart';

/// Centralised colour tokens for the Farmer module.
/// These are scoped to the farmer module only; do not import in other modules.
class FarmerColors {
  FarmerColors._();

  static const Color primary = Color(0xFF2E7D32);       // deep green
  static const Color primaryLight = Color(0xFF4CAF50);  // medium green
  static const Color secondary = Color(0xFF8BC34A);     // light green
  static const Color background = Color(0xFFF1F8E9);    // pale green-white
  static const Color surface = Colors.white;
  static const Color accent = Color(0xFFFF9800);        // amber/orange
  static const Color error = Color(0xFFD32F2F);

  // Status chip colours
  static const Color statusPending = Color(0xFFFFA000);
  static const Color statusConfirmed = Color(0xFF1976D2);
  static const Color statusReady = Color(0xFF7B1FA2);
  static const Color statusCompleted = Color(0xFF2E7D32);
  static const Color statusCancelled = Color(0xFFD32F2F);

  // Low stock highlight
  static const Color lowStock = Color(0xFFE65100);
  static const Color outOfStock = Color(0xFFD32F2F);
}

/// Shared text-style helpers for the farmer module.
class FarmerTextStyles {
  FarmerTextStyles._();

  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: FarmerColors.primary,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: FarmerColors.primary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF333333),
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF757575),
  );

  static const TextStyle price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: FarmerColors.primary,
  );
}
