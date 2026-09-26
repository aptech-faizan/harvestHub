import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/farmer/profile/controllers/farmer_profile_controller.dart';

class FarmerProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmerProfileController>(() => FarmerProfileController());
  }
}
