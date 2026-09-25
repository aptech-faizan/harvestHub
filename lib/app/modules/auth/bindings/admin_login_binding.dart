import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/auth/controllers/admin_login_controller.dart';

class AdminLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminLoginController>(() => AdminLoginController());
  }
}
