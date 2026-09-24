import 'package:get/get.dart';

import '../../../../data/repositories/farmer_repo_factory.dart';
import '../../../farmer/dashboard/controllers/dashboard_controller.dart';
import '../../../farmer/products/controllers/products_controller.dart';
import '../../../farmer/inventory/controllers/inventory_controller.dart';
import '../../../farmer/orders/controllers/orders_controller.dart';
import '../../../farmer/reports/controllers/reports_controller.dart';
import '../../../farmer/profile/controllers/profile_controller.dart';

/// Root binding for the farmer shell – registers all tab controllers at once
/// so navigation between tabs is instantaneous.
///
/// Swap between Firestore and mock via [FarmerRepoFactory.useMock]:
///   FarmerRepoFactory.useMock = true;  // force in-memory mock
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Single shared repo instance for all tab controllers
    final repo = FarmerRepoFactory.create();

    Get.lazyPut<DashboardController>(() => DashboardController(repo));
    Get.lazyPut<ProductsController>(() => ProductsController(repo));
    Get.lazyPut<InventoryController>(() => InventoryController(repo));
    Get.lazyPut<OrdersController>(() => OrdersController(repo));
    Get.lazyPut<ReportsController>(() => ReportsController(repo));
    Get.lazyPut<ProfileController>(() => ProfileController(repo));
  }
}
