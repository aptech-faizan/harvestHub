import 'package:get/get.dart';
import '../controllers/farmers_controller.dart';

// Ye FarmersController ko memory mein inject karta hai
class FarmersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FarmersController>(() => FarmersController());
  }
}
