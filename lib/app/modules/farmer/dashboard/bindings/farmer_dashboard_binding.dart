import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/farmer/dashboard/controllers/farmer_dashboard_controller.dart';

class FarmerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmerDashboardController>(() => FarmerDashboardController());
  }
}
