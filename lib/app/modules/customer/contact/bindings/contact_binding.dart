import 'package:get/get.dart';
import '../controllers/contact_controller.dart';

// Dependency injection binding for Contact Us and Feedback screen
class ContactBinding extends Bindings {
  // Registers ContactController lazily in GetX memory
  @override
  void dependencies() {
    Get.lazyPut<ContactController>(() => ContactController());
  }
}
