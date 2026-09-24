import 'package:flutter/material.dart';

/// Centralised design tokens and theme configuration for the Farmer module.
/// Scoped to the farmer module only.
class FarmerColors {
  FarmerColors._();

  // Core brand palette
  static const Color primaryDark = Color(0xFF1B5E20);   // deep forest green
  static const Color primary = Color(0xFF2E7D32);       // brand green
  static const Color primaryLight = Color(0xFF43A047);  // vibrant green
  static const Color secondary = Color(0xFF8BC34A);     // fresh lime
  static const Color secondaryLight = Color(0xFFDCEDC8);// soft lime tint
  static const Color accent = Color(0xFFFF9800);        // warm vibrant orange
  static const Color accentLight = Color(0xFFFFE0B2);   // warm amber tint

  // Neutral palette
  static const Color background = Color(0xFFF6FAF3);    // ultra-soft organic green-white
  static const Color surface = Colors.white;            // crisp white card surface
  static const Color surfaceMuted = Color(0xFFF0F5EE);   // light container fill
  static const Color text = Color(0xFF1F2A1F);          // rich dark organic text
  static const Color textSecondary = Color(0xFF4A554A); // readable medium text
  static const Color muted = Color(0xFF6B7A6B);         // soft muted text
  static const Color border = Color(0xFFE2EBE0);        // 1px subtle card/divider border
  static const Color divider = Color(0xFFEBF1EA);

  // Status & Feedback colors
  static const Color error = Color(0xFFD32F2F);
  static const Color errorBg = Color(0xFFFFEBEE);

  static const Color statusPending = Color(0xFFF57C00);
  static const Color statusPendingBg = Color(0xFFFFF3E0);

  static const Color statusConfirmed = Color(0xFF1976D2);
  static const Color statusConfirmedBg = Color(0xFFE3F2FD);

  static const Color statusReady = Color(0xFF7B1FA2);
  static const Color statusReadyBg = Color(0xFFF3E5F5);

  static const Color statusCompleted = Color(0xFF2E7D32);
  static const Color statusCompletedBg = Color(0xFFE8F5E9);

  static const Color statusCancelled = Color(0xFFD32F2F);
  static const Color statusCancelledBg = Color(0xFFFFEBEE);

  // Stock indicator highlights
  static const Color inStock = Color(0xFF2E7D32);
  static const Color inStockBg = Color(0xFFE8F5E9);
  static const Color lowStock = Color(0xFFE65100);
  static const Color lowStockBg = Color(0xFFFFF3E0);
  static const Color outOfStock = Color(0xFFD32F2F);
  static const Color outOfStockBg = Color(0xFFFFEBEE);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF144D18), Color(0xFF2E7D32), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softCardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFAFCF8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Subtle layered shadows (blur 16, opacity 0.06)
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF1F2A1F).withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardElevatedShadow => [
        BoxShadow(
          color: const Color(0xFF1F2A1F).withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}

/// Standardised single currency formatter for the entire Farmer module ("PKR 600").
class FarmerCurrency {
  FarmerCurrency._();

  static String format(num amount, {int fractionDigits = 0}) {
    if (fractionDigits > 0) {
      return 'PKR ${amount.toStringAsFixed(fractionDigits)}';
    }
    return 'PKR ${amount.round()}';
  }
}

/// Shared typography scale for the Farmer module.
/// Clear scale: 28 bold headings, 18 semibold titles, 14 body, 12 captions (min 12, body 14+).
class FarmerTextStyles {
  FarmerTextStyles._();

  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: FarmerColors.text,
    letterSpacing: -0.6,
    height: 1.25,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: FarmerColors.text,
    letterSpacing: -0.4,
    height: 1.3,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: FarmerColors.text,
    letterSpacing: -0.3,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: FarmerColors.text,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: FarmerColors.text,
    height: 1.35,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: FarmerColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: FarmerColors.text,
    height: 1.4,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: FarmerColors.text,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: FarmerColors.muted,
    height: 1.3,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: FarmerColors.muted,
    letterSpacing: 0.2,
  );

  static const TextStyle price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: FarmerColors.primaryDark,
    letterSpacing: -0.2,
  );
}

/// Central Material 3 Theme setup for Farmer Module
class FarmerTheme {
  FarmerTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: FarmerColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FarmerColors.primary,
        primary: FarmerColors.primary,
        secondary: FarmerColors.secondary,
        surface: FarmerColors.surface,
        error: FarmerColors.error,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: FarmerColors.text),
        titleTextStyle: TextStyle(
          color: FarmerColors.text,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: FarmerColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: FarmerColors.border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: FarmerColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
