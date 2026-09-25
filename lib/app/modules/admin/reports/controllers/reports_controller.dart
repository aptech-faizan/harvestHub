import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/modules/admin/models/order_model.dart';
import 'package:harvest_hub/app/modules/admin/repositories/admin_repository.dart';

class ReportsController extends GetxController {
  final repo = AdminRepository();

  static const periods = ['All', 'Daily', 'Weekly', 'Monthly'];

  final isLoading = false.obs;
  final error = ''.obs;
  final period = 'All'.obs;
  final allOrders = <OrderModel>[].obs;
  final farmerNames = <String, String>{}.obs;
  final farmerMarket = <String, String>{}.obs; // farmerId -> marketId
  final marketNames = <String, String>{}.obs; // marketId -> name

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      allOrders.assignAll(await repo.getOrders());
      farmerNames.assignAll(await repo.getFarmerNames());
      final farmers = await repo.getFarmers();
      farmerMarket.assignAll({for (final f in farmers) f.id: f.marketId});
      final markets = await repo.getMarkets();
      marketNames.assignAll({for (final m in markets) m.id: m.marketName});
    } catch (e) {
      error.value = 'Could not load reports: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }

  // Daily = today, Weekly = last 7 days, Monthly = last 30 days.
  List<OrderModel> get periodOrders {
    final now = DateTime.now();
    DateTime? from;
    if (period.value == 'Daily') from = DateTime(now.year, now.month, now.day);
    if (period.value == 'Weekly') from = now.subtract(const Duration(days: 7));
    if (period.value == 'Monthly') from = now.subtract(const Duration(days: 30));
    if (from == null) return allOrders.toList();
    return allOrders.where((o) => o.createdAt != null && o.createdAt!.isAfter(from!)).toList();
  }

  // Total valid orders count excluding cancelled orders
  int validOrdersCount(List<OrderModel> orders) =>
      orders.where((o) => o.status != OrderStatus.cancelled).length;

  double revenueOf(List<OrderModel> orders) => repo.totalRevenue(orders);

  Map<String, int> ordersByStatus(List<OrderModel> orders) {
    final result = {for (final s in OrderStatus.all) s: 0};
    for (final o in orders) {
      result[o.status] = (result[o.status] ?? 0) + 1;
    }
    return result;
  }

  // Revenue per market: order -> farmer -> market.
  Map<String, double> revenueByMarket(List<OrderModel> orders) {
    final result = <String, double>{};
    for (final o in orders.where((o) => o.status != OrderStatus.cancelled)) {
      final marketId = farmerMarket[o.farmerId] ?? '';
      final name = marketNames[marketId] ?? 'No market';
      result[name] = (result[name] ?? 0) + o.totalPrice;
    }
    return result;
  }

  List<MapEntry<String, int>> topFarmers(List<OrderModel> orders) {
    return repo
        .mostActiveFarmers(orders)
        .map((e) => MapEntry(farmerNames[e.key] ?? e.key, e.value))
        .toList();
  }
}
