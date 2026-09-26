import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/farmer/inventory/controllers/farmer_inventory_controller.dart';

class FarmerInventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmerInventoryController>(() => FarmerInventoryController());
  }
}
