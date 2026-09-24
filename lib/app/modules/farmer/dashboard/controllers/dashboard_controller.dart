import 'package:get/get.dart';

import '../../../../data/repositories/farmer_repository.dart';

/// Controls the dashboard overview cards and bottom-nav index.
class DashboardController extends GetxController {
  final FarmerRepository _repo;
  DashboardController(this._repo);

  final String currentFarmerId = 'farmer_001';

  // Bottom navigation index (0=Dashboard, 1=Products, 2=Orders,
  //                          3=Reports, 4=Profile)
  final RxInt currentIndex = 0.obs;

  // Dashboard stats
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
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
      errorMessage.value = 'Failed to load dashboard. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) => currentIndex.value = index;
}
