import '../models/farmer_product_model.dart';
import '../models/farmer_order_model.dart';
import '../models/farmer_slot_model.dart';
import '../models/farmer_profile_model.dart';

/// Abstract contract for all farmer data operations.
/// Controllers depend on this interface – swap to FirestoreRepository without
/// touching any controller or view.
abstract class FarmerAccountRepository {
  // ── Products ──────────────────────────────────────────────────────────────

  /// Fetches all products belonging to [farmerId].
  Future<List<FarmerProduct>> getProducts(String farmerId);

  /// Real-time stream of products for [farmerId], ordered by createdAt desc.
  Stream<List<FarmerProduct>> watchProducts(String farmerId);

  /// Creates a new product and returns the saved instance (with generated id).
  /// Writes farmerName, marketId, marketName, lat, lng from the farmer profile.
  Future<FarmerProduct> addProduct(FarmerProduct product);

  /// Updates mutable fields of an existing product.
  Future<FarmerProduct> updateProduct(FarmerProduct product);

  /// Updates stock quantity using a Firestore transaction (stockQty >= 0).
  /// Also sets restockedAt = serverTimestamp on the product document.
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

  /// Updates only the status + updatedAt fields of an order.
  /// If cancelling: restores item quantities to stock (no restockedAt).
  Future<FarmerOrder> updateOrderStatus(String orderId, OrderStatus status);

  // ── Dashboard stats ───────────────────────────────────────────────────────

  /// Returns a simple summary map used by the dashboard widget.
  /// Keys: totalProducts, totalOrders, pendingOrders, totalRevenue
  Future<Map<String, dynamic>> getDashboardStats(String farmerId);

  // ── Farmer profile ────────────────────────────────────────────────────────

  /// Reads the farmer profile from farmers/{farmerId}.
  Future<FarmerProfile> getFarmerProfile(String farmerId);

  /// Writes editable profile fields using set-with-merge.
  Future<void> saveFarmerProfile(FarmerProfile profile);

  /// Reads the low-stock threshold from farmers/{farmerId}.
  Future<int> getLowStockThreshold(String farmerId);

  /// Writes the low-stock threshold to farmers/{farmerId}.
  Future<void> setLowStockThreshold(String farmerId, int threshold);

  /// Returns all markets for the dropdown selector.
  Future<List<MarketInfo>> getMarkets();

  // ── Pickup Slots ──────────────────────────────────────────────────────────

  /// Real-time stream of the farmer's pickup slots, ordered by startTime.
  Stream<List<PickupSlot>> watchSlots(String farmerId);

  /// Creates a new slot (bookedCount is always set to 0 by repository).
  Future<PickupSlot> addSlot(PickupSlot slot);

  /// Updates capacity / time / isActive on an existing slot.
  /// Throws a friendly exception if business rules are violated:
  ///   - capacity < bookedCount
  ///   - time change on a booked slot
  Future<void> updateSlot(PickupSlot updated);

  /// Deletes a slot.
  /// Throws a friendly exception if bookedCount > 0.
  Future<void> deleteSlot(String slotId, int bookedCount);
}
