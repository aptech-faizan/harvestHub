import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/models/order_model.dart';
import 'package:harvest_hub/app/data/repositories/order_repository.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';

class FarmerReportsController extends GetxController {
  static const periods = ['Daily', 'Weekly', 'Monthly', 'All'];

  final AuthService authService = Get.find<AuthService>();
  final _orderRepo = OrderRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final period = 'Weekly'.obs;
  final orders = <OrderModel>[].obs;

  String get uid => authService.currentUser?.uid ?? '';

  List<OrderModel> get periodOrders {
    final now = DateTime.now();
    DateTime? from;
    if (period.value == 'Daily') {
      from = DateTime(now.year, now.month, now.day);
    } else if (period.value == 'Weekly') {
      from = now.subtract(const Duration(days: 7));
    } else if (period.value == 'Monthly') {
      from = now.subtract(const Duration(days: 30));
    }
    if (from == null) return orders.toList();
    return orders.where((o) => !o.createdAt.isBefore(from!)).toList();
  }

  List<OrderModel> get valid =>
      periodOrders.where((o) => o.status != OrderStatus.cancelled).toList();

  double get revenue => valid.fold(0.0, (sum, o) => sum + o.totalPrice);

  Map<String, int> get byStatus {
    final map = <String, int>{};
    for (final s in OrderStatus.all) {
      map[s] = periodOrders.where((o) => o.status == s).length;
    }
    return map;
  }

  Map<String, int> get qtyByProduct {
    final map = <String, int>{};
    for (final o in valid) {
      for (final item in o.items) {
        final name = (item['name'] ?? item['itemName'] ?? 'Item').toString();
        final qty = (item['qty'] ?? item['quantity'] ?? 0) as num;
        map[name] = (map[name] ?? 0) + qty.toInt();
      }
    }
    return map;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (uid.isEmpty) return;
    isLoading.value = true;
    error.value = '';
    try {
      orders.assignAll(await _orderRepo.getOrdersByFarmer(uid));
    } catch (e) {
      error.value = 'Could not load reports: ${errorText(e)}';
    } finally {
      isLoading.value = false;
    }
  }
}
