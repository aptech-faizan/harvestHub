import 'package:get/get.dart';
import '../controllers/about_controller.dart';

// Dependency injection binding for About Us screen
class AboutBinding extends Bindings {
  // Binds the AboutController instance lazily in GetX memory
  @override
  void dependencies() {
    Get.lazyPut<AboutController>(() => AboutController());
  }
}
