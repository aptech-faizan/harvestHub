import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/farmer/reports/controllers/farmer_reports_controller.dart';

class FarmerReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmerReportsController>(() => FarmerReportsController());
  }
}
