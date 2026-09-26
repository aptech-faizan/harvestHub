import 'package:get/get.dart';
import '../controllers/assistant_controller.dart';

// Dependency injection binding for farm products assistant
class AssistantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssistantController>(() => AssistantController());
  }
}
