import 'package:get/get.dart';

import '../../../../data/repositories/farmer_repo_factory.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(FarmerRepoFactory.create()),
    );
  }
}
