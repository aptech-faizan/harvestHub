import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

class CustomerMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthService>()) {
      return const RouteSettings(name: Routes.login);
    }
    final auth = Get.find<AuthService>();
    if (auth.isCustomer) return null;
    return const RouteSettings(name: Routes.login);
  }
}
