import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/farmer/pickup_slots/controllers/farmer_slots_controller.dart';

class FarmerSlotsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmerSlotsController>(() => FarmerSlotsController());
  }
}
