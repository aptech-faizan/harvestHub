import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/admin/reports/controllers/reports_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportsController>(() => ReportsController(), fenix: true);
  }
}
