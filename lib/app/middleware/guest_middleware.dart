import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Prevents already-authenticated users from viewing Login or Register screens.
class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthService>()) return null;
    final auth = Get.find<AuthService>();
    if (auth.isAuthenticated) {
      if (auth.isCustomer) {
        return const RouteSettings(name: Routes.customerShell);
      }
      if (auth.isFarmer) {
        return const RouteSettings(name: Routes.farmerDashboard);
      }
      if (auth.isAdmin) {
        return const RouteSettings(name: Routes.adminDashboard);
      }
    }
    return null;
  }
}
