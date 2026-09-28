import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

/// Central notification helper for HarvestHub.
///
/// All four variants share the same presentation:
///  - Floating snackbar at BOTTOM (above any CTA bar via margin)
///  - Coloured background (never white/transparent)
///  - White icon + white text
///  - 16px margin, 12px corner radius, 3 s duration, dismissible
class AppSnackbar {
  AppSnackbar._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Green — saved / added / updated / completed
  static void success(
    String message, {
    String title = 'Success',
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      title: title,
      message: message,
      background: AppColors.primaryButton, // #43A047
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  /// Red — failures / exceptions / validation errors
  static void error(
    String message, {
    String title = 'Error',
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      title: title,
      message: message,
      background: AppColors.accentRed, // #E53935
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  /// Dark green — neutral informational messages
  static void info(
    String message, {
    String title = 'Info',
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      title: title,
      message: message,
      background: AppColors.primaryDark, // #1B5E20
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  /// Orange — cautions / warnings
  static void warning(
    String message, {
    String title = 'Warning',
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      title: title,
      message: message,
      background: AppColors.accentOrange, // #FB8C00
      icon: Icons.warning_amber_rounded,
      duration: duration,
    );
  }

  // ---------------------------------------------------------------------------
  // Private implementation
  // ---------------------------------------------------------------------------

  static void _show({
    required String title,
    required String message,
    required Color background,
    required IconData icon,
    required Duration duration,
  }) {
    // Dismiss any currently visible snackbar first to avoid stacking.
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        icon: Icon(icon, color: Colors.white, size: 24),
        backgroundColor: background,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80), // 80 keeps it above bottom bars
        borderRadius: 12,
        duration: duration,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        titleText: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Outfit',
          ),
        ),
        messageText: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            fontFamily: 'Outfit',
          ),
        ),
        boxShadows: const [
          BoxShadow(
            color: Color(0x26000000), // 15% opacity
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
