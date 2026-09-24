import 'package:get/get.dart';
import '../controllers/home_controller.dart';

// Ye HomeController ko memory mein inject karta hai
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Controller ko lazily load karne ke liye
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
