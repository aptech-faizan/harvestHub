import 'package:get/get.dart';

import '../../../../data/repositories/farmer_repo_factory.dart';
import '../controllers/slots_controller.dart';

class SlotsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SlotsController>(
      () => SlotsController(FarmerRepoFactory.create()),
    );
  }
}
