import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/admin/markets/controllers/market_form_controller.dart';

class MarketFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarketFormController>(() => MarketFormController());
  }
}
