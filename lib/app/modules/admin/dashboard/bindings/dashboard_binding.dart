import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/admin/dashboard/controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
  }
}
