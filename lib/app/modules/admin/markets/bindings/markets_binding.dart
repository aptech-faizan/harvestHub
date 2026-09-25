import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/admin/markets/controllers/markets_controller.dart';

class MarketsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarketsController>(() => MarketsController(), fenix: true);
  }
}
