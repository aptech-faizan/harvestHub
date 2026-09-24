import 'package:get/get.dart';

import 'farmer_routes.dart';
import 'dashboard/bindings/dashboard_binding.dart';
import 'dashboard/views/farmer_dashboard_view.dart';
import 'inventory/bindings/inventory_binding.dart';
import 'inventory/views/inventory_view.dart';
import 'orders/bindings/orders_binding.dart';
import 'orders/views/orders_view.dart';
import 'reports/bindings/reports_binding.dart';
import 'reports/views/reports_view.dart';
import 'profile/bindings/profile_binding.dart';
import 'profile/views/profile_view.dart';
import 'slots/bindings/slots_binding.dart';
import 'slots/views/slots_view.dart';

/// GetPage definitions for the Farmer module.
/// Append [farmerPages] to the global AppPages list in the shared routes file.
/// Ask the Auth/Routes teammate to add:
///   ...FarmerPages.farmerPages
/// inside the global GetMaterialApp pages list.
abstract class FarmerPages {
  static final farmerPages = <GetPage>[
    GetPage(
      name: FarmerRoutes.farmerDashboard,
      page: () => const FarmerDashboardView(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: FarmerRoutes.farmerInventory,
      page: () => const InventoryView(),
      binding: InventoryBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: FarmerRoutes.farmerOrders,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: FarmerRoutes.farmerReports,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: FarmerRoutes.farmerProfile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: FarmerRoutes.farmerSlots,
      page: () => const SlotsView(),
      binding: SlotsBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
