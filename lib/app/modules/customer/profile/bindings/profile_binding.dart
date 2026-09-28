import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

// Ye ProfileController ko memory mein inject karta hai
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put<ProfileController>(ProfileController(), permanent: true);
    } else {
      final existing = Get.find<ProfileController>();
      if (existing.isClosed || existing.isDisposed) {
        Get.delete<ProfileController>(force: true);
        Get.put<ProfileController>(ProfileController(), permanent: true);
      }
    }
  }
}
