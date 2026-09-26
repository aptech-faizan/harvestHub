import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/farmer/products/controllers/farmer_products_controller.dart';

class FarmerProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmerProductsController>(() => FarmerProductsController());
  }
}
