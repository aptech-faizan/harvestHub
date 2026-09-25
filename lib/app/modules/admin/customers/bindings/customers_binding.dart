import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/admin/customers/controllers/customers_controller.dart';

class CustomersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomersController>(() => CustomersController(), fenix: true);
  }
}
