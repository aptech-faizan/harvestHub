import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/services/sales_report_pdf.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/models/order_model.dart';
import 'package:harvest_hub/app/data/repositories/order_repository.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:intl/intl.dart';

class FarmerReportsController extends GetxController {
  static const periods = ['Daily', 'Weekly', 'Monthly', 'All'];

  final AuthService authService = Get.find<AuthService>();
  final _orderRepo = OrderRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final isExporting = false.obs;
  final period = 'Weekly'.obs;
  final orders = <OrderModel>[].obs;

  String get uid => authService.currentUser?.uid ?? '';

  String get farmerName {
    final name = authService.currentUserModel.value?.name ?? '';
    return name.isEmpty ? 'Farmer' : name;
  }

  /// Start of the selected window, or null for "All".
  ///
  /// Single definition so the on-screen figures and the exported PDF can never
  /// describe different ranges.
  DateTime? get _from {
    final now = DateTime.now();
    switch (period.value) {
      case 'Daily':
        return DateTime(now.year, now.month, now.day);
      case 'Weekly':
        return now.subtract(const Duration(days: 7));
      case 'Monthly':
        return now.subtract(const Duration(days: 30));
      default:
        return null;
    }
  }

  /// Human readable range for the report header.
  String get rangeLabel {
    final from = _from;
    if (from == null) return 'All time';
    final fmt = DateFormat('dd MMM yyyy');
    return '${fmt.format(from)} to ${fmt.format(DateTime.now())}';
  }

  List<OrderModel> get periodOrders {
    final from = _from;
    if (from == null) return orders.toList();
    return orders.where((o) => !o.createdAt.isBefore(from)).toList();
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

  /// Exports the currently selected period as a shareable PDF.
  ///
  /// Reuses the same getters the screen renders, so the document always matches
  /// what the farmer is looking at.
  Future<void> exportPdf() async {
    if (isExporting.value) return;
    isExporting.value = true;
    try {
      final shared = await SalesReportPdf.share(
        farmerName: farmerName,
        periodLabel: period.value,
        rangeLabel: rangeLabel,
        orders: periodOrders,
        byStatus: byStatus,
        qtyByProduct: qtyByProduct,
        revenue: revenue,
      );
      if (!shared) {
        showError('PDF sharing is not supported on this device.');
      }
    } catch (e) {
      showError('Could not create the report: ${errorText(e)}');
    } finally {
      isExporting.value = false;
    }
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
