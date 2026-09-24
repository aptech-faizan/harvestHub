import 'package:get/get.dart';

import '../../../../data/repositories/farmer_repository.dart';

/// Controller for the reports/analytics screen.
class ReportsController extends GetxController {
  final FarmerRepository _repo;
  ReportsController(this._repo);

  final String currentFarmerId = 'farmer_001';

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Summary stats
  final RxInt totalProducts = 0.obs;
  final RxInt totalOrders = 0.obs;
  final RxInt pendingOrders = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final stats = await _repo.getDashboardStats(currentFarmerId);
      totalProducts.value = stats['totalProducts'] as int;
      totalOrders.value = stats['totalOrders'] as int;
      pendingOrders.value = stats['pendingOrders'] as int;
      totalRevenue.value = (stats['totalRevenue'] as num).toDouble();
    } catch (e) {
      errorMessage.value = 'Failed to load reports. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
