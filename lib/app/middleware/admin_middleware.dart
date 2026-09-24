import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthService>();
    if (auth.isAdmin) return null;
    return const RouteSettings(name: Routes.adminLogin);
  }
}
