import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/farmer/orders/controllers/farmer_orders_controller.dart';

class FarmerOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmerOrdersController>(() => FarmerOrdersController());
  }
}
