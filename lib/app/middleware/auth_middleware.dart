import 'package:flutter/material.dart' show RouteSettings;
import 'package:get/get.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Requires a signed-in user of *any* role.
///
/// The per-role middlewares (Admin/Farmer/Customer) each redirect anyone who is
/// not that role, so they cannot guard screens that more than one role must
/// reach - chat being the obvious case, since a customer and a farmer use the
/// same room and inbox.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthService>()) {
      return const RouteSettings(name: Routes.login);
    }
    if (Get.find<AuthService>().isAuthenticated) return null;
    return const RouteSettings(name: Routes.login);
  }
}
