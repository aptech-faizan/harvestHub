import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/modules/admin/models/order_model.dart';
import 'package:harvest_hub/app/modules/admin/repositories/admin_repository.dart';

class DashboardController extends GetxController {
  final repo = AdminRepository();

  final isLoading = false.obs;
  final error = ''.obs;

  final customers = 0.obs;
  final farmers = 0.obs;
  final products = 0.obs;
  final categories = 0.obs;
  final markets = 0.obs;
  final totalOrders = 0.obs;
  final revenue = 0.0.obs;

  final recentOrders = <OrderModel>[].obs;
  final topFarmers = <MapEntry<String, int>>[].obs; // farmer name -> order count
  final userNames = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      final counts = await Future.wait([
        repo.count(Db.users, role: Roles.customer),
        repo.count(Db.farmers),
        repo.count(Db.products),
        repo.count(Db.categories),
        repo.count(Db.markets),
      ]);
      customers.value = counts[0];
      farmers.value = counts[1];
      products.value = counts[2];
      categories.value = counts[3];
      markets.value = counts[4];

      final orders = await repo.getOrders();
      totalOrders.value = orders.length;
      revenue.value = repo.totalRevenue(orders);
      recentOrders.assignAll(orders.take(5));

      userNames.assignAll(await repo.getUserNames());
      final farmerNames = await repo.getFarmerNames();
      topFarmers.assignAll(repo
          .mostActiveFarmers(orders)
          .map((e) => MapEntry(farmerNames[e.key] ?? e.key, e.value)));
    } catch (e) {
      error.value = 'Could not load dashboard: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }
}
