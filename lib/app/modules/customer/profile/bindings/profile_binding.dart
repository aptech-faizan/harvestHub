import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

// Ye ProfileController ko memory mein inject karta hai
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // ProfileController inject karna
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
