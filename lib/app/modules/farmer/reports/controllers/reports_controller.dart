import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/repositories/farmer_repository.dart';

/// Controller for the reports/analytics screen.
class ReportsController extends GetxController {
  final FarmerRepository _repo;
  ReportsController(this._repo);

  String get currentFarmerId => FirebaseAuth.instance.currentUser?.uid ?? '';

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
      final msg = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = msg.contains('log in')
          ? 'Please log in again.'
          : 'Failed to load reports. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
