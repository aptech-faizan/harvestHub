import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/services/admin_report_pdf.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/modules/admin/models/order_model.dart';
import 'package:harvest_hub/app/modules/admin/repositories/admin_repository.dart';
import 'package:intl/intl.dart';

class ReportsController extends GetxController {
  final repo = AdminRepository();

  static const periods = ['All', 'Daily', 'Weekly', 'Monthly'];

  final isLoading = false.obs;
  final error = ''.obs;
  final isExporting = false.obs;
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
  /// Start of the selected window, or null for "All".
  ///
  /// One definition shared by the on-screen figures and the exported PDF, so
  /// the two can never describe different ranges.
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

  /// Human readable range for the report header and the screen.
  String get rangeLabel {
    final from = _from;
    if (from == null) return 'All time';
    final fmt = DateFormat('dd MMM yyyy');
    return '${fmt.format(from)} to ${fmt.format(DateTime.now())}';
  }

  List<OrderModel> get periodOrders {
    final from = _from;
    if (from == null) return allOrders.toList();
    return allOrders.where((o) => o.createdAt != null && o.createdAt!.isAfter(from)).toList();
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

  /// Exports the selected period as a shareable platform report.
  ///
  /// Reuses the same getters the screen renders, so the document always matches
  /// what the administrator is looking at.
  Future<void> exportPdf() async {
    if (isExporting.value) return;
    isExporting.value = true;
    try {
      final orders = periodOrders;
      final shared = await AdminReportPdf.share(
        periodLabel: period.value,
        rangeLabel: rangeLabel,
        orders: orders,
        byStatus: ordersByStatus(orders),
        revenueByMarket: revenueByMarket(orders),
        topFarmers: topFarmers(orders),
        revenue: revenueOf(orders),
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
}
