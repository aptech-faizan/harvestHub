import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/admin/farmers/controllers/farmers_controller.dart';

class FarmersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmersController>(() => FarmersController(), fenix: true);
  }
}
