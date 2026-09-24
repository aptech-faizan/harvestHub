import 'package:uuid/uuid.dart';

import '../models/farmer_product_model.dart';
import '../models/farmer_order_model.dart';
import 'farmer_repository.dart';

/// In-memory mock implementation of [FarmerRepository].
/// Replace this binding registration with FarmerFirestoreRepository when
/// Firebase integration is ready – no controller/view changes required.
class FarmerMockRepository implements FarmerRepository {
  static const _uuid = Uuid();

  // ── In-memory stores ──────────────────────────────────────────────────────

  final List<FarmerProduct> _products = _seedProducts();
  final List<FarmerOrder> _orders = _seedOrders();

  // ── Products ──────────────────────────────────────────────────────────────

  @override
  Future<List<FarmerProduct>> getProducts(String farmerId) async {
    await _fakeDelay();
    return _products.where((p) => p.farmerId == farmerId).toList();
  }

  @override
  Future<FarmerProduct> addProduct(FarmerProduct product) async {
    await _fakeDelay();
    final saved = FarmerProduct(
      id: _uuid.v4(),
      farmerId: product.farmerId,
      name: product.name,
      category: product.category,
      pricePerUnit: product.pricePerUnit,
      unit: product.unit,
      stockQty: product.stockQty,
      description: product.description,
      imageUrl: product.imageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _products.add(saved);
    return saved;
  }

  @override
  Future<FarmerProduct> updateProduct(FarmerProduct product) async {
    await _fakeDelay();
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx == -1) throw Exception('Product not found: ${product.id}');
    _products[idx] = product;
    return product;
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _fakeDelay();
    _products.removeWhere((p) => p.id == productId);
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  @override
  Future<List<FarmerOrder>> getOrders(
    String farmerId, {
    OrderStatus? status,
  }) async {
    await _fakeDelay();
    var list = _orders.where((o) => o.farmerId == farmerId).toList();
    if (status != null) {
      list = list.where((o) => o.status == status).toList();
    }
    return list;
  }

  @override
  Future<FarmerOrder> updateOrderStatus(
      String orderId, OrderStatus status) async {
    await _fakeDelay();
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) throw Exception('Order not found: $orderId');
    _orders[idx].status = status;
    _orders[idx].updatedAt = DateTime.now();
    return _orders[idx];
  }

  // ── Dashboard stats ───────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getDashboardStats(String farmerId) async {
    await _fakeDelay();
    final myProducts = _products.where((p) => p.farmerId == farmerId).toList();
    final myOrders = _orders.where((o) => o.farmerId == farmerId).toList();
    final pendingOrders =
        myOrders.where((o) => o.status == OrderStatus.pending).length;
    final totalRevenue = myOrders
        .where((o) => o.status == OrderStatus.completed)
        .fold<double>(0.0, (sum, o) => sum + o.totalAmount);

    return {
      'totalProducts': myProducts.length,
      'totalOrders': myOrders.length,
      'pendingOrders': pendingOrders,
      'totalRevenue': totalRevenue,
    };
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Simulates a short network delay so the UI loading states are visible.
  Future<void> _fakeDelay() =>
      Future.delayed(const Duration(milliseconds: 600));

  // ── Seed data ─────────────────────────────────────────────────────────────

  static List<FarmerProduct> _seedProducts() {
    const farmerId = 'farmer_001';
    final now = DateTime.now();
    return [
      FarmerProduct(
        id: 'prod_001',
        farmerId: farmerId,
        name: 'Fresh Tomatoes',
        category: 'Vegetables',
        pricePerUnit: 80.0,
        unit: 'kg',
        stockQty: 50,
        description: 'Locally grown, pesticide-free tomatoes.',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
      ),
      FarmerProduct(
        id: 'prod_002',
        farmerId: farmerId,
        name: 'Organic Eggs',
        category: 'Poultry',
        pricePerUnit: 180.0,
        unit: 'dozen',
        stockQty: 30,
        description: 'Free-range organic eggs from healthy hens.',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now,
      ),
      FarmerProduct(
        id: 'prod_003',
        farmerId: farmerId,
        name: 'Raw Honey',
        category: 'Honey & Dairy',
        pricePerUnit: 450.0,
        unit: 'kg',
        stockQty: 5,
        description: 'Pure wildflower honey, unprocessed.',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
      FarmerProduct(
        id: 'prod_004',
        farmerId: farmerId,
        name: 'Spinach',
        category: 'Vegetables',
        pricePerUnit: 40.0,
        unit: 'bunch',
        stockQty: 0, // Out of stock – business rule demonstration
        description: 'Fresh baby spinach, hand-picked.',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      ),
      FarmerProduct(
        id: 'prod_005',
        farmerId: farmerId,
        name: 'Basmati Rice',
        category: 'Grains',
        pricePerUnit: 120.0,
        unit: 'kg',
        stockQty: 200,
        description: 'Premium long-grain basmati rice from the farm.',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),
    ];
  }

  static List<FarmerOrder> _seedOrders() {
    const farmerId = 'farmer_001';
    final now = DateTime.now();
    return [
      FarmerOrder(
        id: 'ord_001',
        farmerId: farmerId,
        customerId: 'cust_001',
        customerName: 'Ali Khan',
        items: [
          const OrderItem(
            productId: 'prod_001',
            productName: 'Fresh Tomatoes',
            pricePerUnit: 80.0,
            quantity: 3,
            unit: 'kg',
          ),
        ],
        status: OrderStatus.pending,
        totalAmount: 240.0,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      FarmerOrder(
        id: 'ord_002',
        farmerId: farmerId,
        customerId: 'cust_002',
        customerName: 'Sara Ahmed',
        items: [
          const OrderItem(
            productId: 'prod_002',
            productName: 'Organic Eggs',
            pricePerUnit: 180.0,
            quantity: 2,
            unit: 'dozen',
          ),
          const OrderItem(
            productId: 'prod_003',
            productName: 'Raw Honey',
            pricePerUnit: 450.0,
            quantity: 1,
            unit: 'kg',
          ),
        ],
        status: OrderStatus.confirmed,
        totalAmount: 810.0,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      FarmerOrder(
        id: 'ord_003',
        farmerId: farmerId,
        customerId: 'cust_003',
        customerName: 'Usman Malik',
        items: [
          const OrderItem(
            productId: 'prod_005',
            productName: 'Basmati Rice',
            pricePerUnit: 120.0,
            quantity: 5,
            unit: 'kg',
          ),
        ],
        status: OrderStatus.completed,
        totalAmount: 600.0,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      FarmerOrder(
        id: 'ord_004',
        farmerId: farmerId,
        customerId: 'cust_004',
        customerName: 'Fatima Noor',
        items: [
          const OrderItem(
            productId: 'prod_001',
            productName: 'Fresh Tomatoes',
            pricePerUnit: 80.0,
            quantity: 2,
            unit: 'kg',
          ),
        ],
        status: OrderStatus.readyForPickup,
        totalAmount: 160.0,
        createdAt: now.subtract(const Duration(hours: 10)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        notes: 'Please pack carefully.',
      ),
      FarmerOrder(
        id: 'ord_005',
        farmerId: farmerId,
        customerId: 'cust_005',
        customerName: 'Bilal Raza',
        items: [
          const OrderItem(
            productId: 'prod_003',
            productName: 'Raw Honey',
            pricePerUnit: 450.0,
            quantity: 2,
            unit: 'kg',
          ),
        ],
        status: OrderStatus.cancelled,
        totalAmount: 900.0,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
