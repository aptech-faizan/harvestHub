import '../models/farmer_product_model.dart';
import '../models/farmer_order_model.dart';

/// Abstract contract for all farmer data operations.
/// Controllers depend on this interface – swap to FirestoreRepository without
/// touching any controller or view.
abstract class FarmerRepository {
  // ── Products ──────────────────────────────────────────────────────────────

  /// Fetches all products belonging to [farmerId].
  Future<List<FarmerProduct>> getProducts(String farmerId);

  /// Real-time stream of products for [farmerId], ordered by createdAt desc.
  Stream<List<FarmerProduct>> watchProducts(String farmerId);

  /// Creates a new product and returns the saved instance (with generated id).
  Future<FarmerProduct> addProduct(FarmerProduct product);

  /// Updates mutable fields of an existing product.
  Future<FarmerProduct> updateProduct(FarmerProduct product);

  /// Updates stock quantity using a Firestore transaction (stockQty >= 0).
  Future<void> updateStock(String productId, int newQty);

  /// Permanently deletes a product by [productId].
  Future<void> deleteProduct(String productId);

  // ── Orders ────────────────────────────────────────────────────────────────

  /// Fetches all orders for [farmerId], optionally filtered by [status].
  Future<List<FarmerOrder>> getOrders(
    String farmerId, {
    OrderStatus? status,
  });

  /// Real-time stream of orders for [farmerId], optionally filtered by [status].
  Stream<List<FarmerOrder>> watchOrders(
    String farmerId, {
    OrderStatus? status,
  });

  /// Updates only the status field of an order.
  /// If cancelled, adds item quantities back to stock in a single transaction.
  Future<FarmerOrder> updateOrderStatus(String orderId, OrderStatus status);

  // ── Dashboard stats ───────────────────────────────────────────────────────

  /// Returns a simple summary map used by the dashboard widget.
  /// Keys: totalProducts, totalOrders, pendingOrders, totalRevenue
  Future<Map<String, dynamic>> getDashboardStats(String farmerId);

  // ── Farmer profile / settings ─────────────────────────────────────────────

  /// Reads the low-stock threshold from farmers/{farmerId}.
  Future<int> getLowStockThreshold(String farmerId);

  /// Writes the low-stock threshold to farmers/{farmerId}.
  Future<void> setLowStockThreshold(String farmerId, int threshold);
}
