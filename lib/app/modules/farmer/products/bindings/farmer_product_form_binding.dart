import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/farmer/products/controllers/farmer_product_form_controller.dart';

class FarmerProductFormBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<FarmerProductFormController>()) {
      Get.delete<FarmerProductFormController>();
    }
    Get.put(FarmerProductFormController());
  }
}
