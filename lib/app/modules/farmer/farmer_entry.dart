import 'package:get/get.dart';

import 'dashboard/bindings/dashboard_binding.dart';
import 'dashboard/views/farmer_dashboard_view.dart';

/// Single entry point for the Farmer module.
///
/// Can be called directly from SplashController or AuthController:
/// ```dart
/// FarmerEntry.open();
/// ```
class FarmerEntry {
  FarmerEntry._();

  /// Navigates to the Farmer module root shell and registers [DashboardBinding].
  static void open() {
    Get.offAll(
      () => const FarmerDashboardView(),
      binding: DashboardBinding(),
    );
  }
}
