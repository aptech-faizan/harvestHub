/// Standalone entry point for running the Farmer module in isolation.
/// Use this file during development: `flutter run -t lib/farmer_main.dart`
/// This file is NOT part of the shared app – do NOT modify main.dart.
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/modules/farmer/dashboard/bindings/dashboard_binding.dart';
import 'app/modules/farmer/dashboard/views/farmer_dashboard_view.dart';
import 'app/modules/farmer/farmer_pages.dart';
import 'app/modules/farmer/farmer_routes.dart';

void main() {
  runApp(const FarmerApp());
}

class FarmerApp extends StatelessWidget {
  const FarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HarvestHub – Farmer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D32),
        fontFamily: 'Roboto',
      ),
      initialRoute: FarmerRoutes.farmerDashboard,
      initialBinding: DashboardBinding(),
      getPages: FarmerPages.farmerPages,
      home: const FarmerDashboardView(),
    );
  }
}
