import 'dart:async';

import 'package:uuid/uuid.dart';

import '../models/farmer_product_model.dart';
import '../models/farmer_order_model.dart';
import '../models/farmer_slot_model.dart';
import '../models/farmer_profile_model.dart';
import 'farmer_account_repository.dart';

/// In-memory mock implementation of [FarmerAccountRepository].
/// Replace this binding registration with FarmerFirestoreRepository when
/// Firebase integration is ready – no controller/view changes required.
class FarmerMockRepository implements FarmerAccountRepository {
  static const _uuid = Uuid();

  // ── In-memory stores ──────────────────────────────────────────────────────

  final List<FarmerProduct> _products = _seedProducts();
  final List<FarmerOrder> _orders = _seedOrders();

  // Stream controllers for reactive mock streams
  final _productsController =
      StreamController<List<FarmerProduct>>.broadcast();
  final _ordersController = StreamController<List<FarmerOrder>>.broadcast();

  int _lowStockThreshold = 5;

  void _broadcastProducts() {
    if (!_productsController.isClosed) {
      _productsController.add(List.unmodifiable(_products));
    }
  }

  void _broadcastOrders() {
    if (!_ordersController.isClosed) {
      _ordersController.add(List.unmodifiable(_orders));
    }
  }

  // ── Products ──────────────────────────────────────────────────────────────

  @override
  Future<List<FarmerProduct>> getProducts(String farmerId) async {
    await _fakeDelay();
    return _products.where((p) => p.farmerId == farmerId).toList();
  }

  @override
  Stream<List<FarmerProduct>> watchProducts(String farmerId) {
    // Emit current state immediately, then push updates via broadcast stream
    Future.delayed(const Duration(milliseconds: 300), _broadcastProducts);
    return _productsController.stream
        .map((list) => list.where((p) => p.farmerId == farmerId).toList());
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
    _broadcastProducts();
    return saved;
  }

  @override
  Future<FarmerProduct> updateProduct(FarmerProduct product) async {
    await _fakeDelay();
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx == -1) throw Exception('Product not found: ${product.id}');
    _products[idx] = product;
    _broadcastProducts();
    return product;
  }

  @override
  Future<void> updateStock(String productId, int newQty) async {
    await _fakeDelay();
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx == -1) throw Exception('Product not found: $productId');
    if (newQty < 0) throw Exception('Stock cannot go below 0');
    _products[idx] = _products[idx].copyWith(stockQty: newQty);
    _broadcastProducts();
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _fakeDelay();
    _products.removeWhere((p) => p.id == productId);
    _broadcastProducts();
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
  Stream<List<FarmerOrder>> watchOrders(
    String farmerId, {
    OrderStatus? status,
  }) {
    Future.delayed(const Duration(milliseconds: 300), _broadcastOrders);
    return _ordersController.stream.map((list) {
      var filtered = list.where((o) => o.farmerId == farmerId).toList();
      if (status != null) {
        filtered = filtered.where((o) => o.status == status).toList();
      }
      return filtered;
    });
  }

  @override
  Future<FarmerOrder> updateOrderStatus(
      String orderId, OrderStatus status) async {
    await _fakeDelay();
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) throw Exception('Order not found: $orderId');

    final order = _orders[idx];

    // Business rule: if cancelling, restore stock quantities
    if (status == OrderStatus.cancelled &&
        order.status != OrderStatus.cancelled) {
      for (final item in order.items) {
        final pIdx = _products.indexWhere((p) => p.id == item.productId);
        if (pIdx != -1) {
          _products[pIdx] =
              _products[pIdx].copyWith(stockQty: _products[pIdx].stockQty + item.quantity);
        }
      }
      _broadcastProducts();
    }

    _orders[idx].status = status;
    _orders[idx].updatedAt = DateTime.now();
    _broadcastOrders();
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

  // ── Farmer profile / settings ─────────────────────────────────────────────

  @override
  Future<int> getLowStockThreshold(String farmerId) async {
    await _fakeDelay();
    return _lowStockThreshold;
  }

  @override
  Future<void> setLowStockThreshold(String farmerId, int threshold) async {
    await _fakeDelay();
    _lowStockThreshold = threshold;
  }

  // ── Farmer profile ────────────────────────────────────────────────────────

  @override
  Future<FarmerProfile> getFarmerProfile(String farmerId) async {
    await _fakeDelay();
    return FarmerProfile(
      userId: farmerId,
      businessName: 'Green Valley Farm',
      description: 'Fresh organic produce direct from the farm.',
      marketId: 'market_001',
      lowStockThreshold: _lowStockThreshold,
      displayName: 'Ahmed Raza',
      phone: '+92 300 1234567',
    );
  }

  @override
  Future<void> saveFarmerProfile(FarmerProfile profile) async {
    await _fakeDelay();
    // In-memory: no-op for mock
  }

  @override
  Future<List<MarketInfo>> getMarkets() async {
    await _fakeDelay();
    return const [
      MarketInfo(id: 'market_001', name: 'Lahore Farmers Market', lat: 31.5204, lng: 74.3587),
      MarketInfo(id: 'market_002', name: 'Islamabad Green Bazaar', lat: 33.6844, lng: 73.0479),
      MarketInfo(id: 'market_003', name: 'Karachi Organic Hub', lat: 24.8607, lng: 67.0011),
    ];
  }

  // ── Pickup Slots ──────────────────────────────────────────────────────────

  final List<PickupSlot> _slots = _seedSlots();
  final _slotsController = StreamController<List<PickupSlot>>.broadcast();

  void _broadcastSlots() {
    if (!_slotsController.isClosed) {
      _slotsController.add(List.unmodifiable(_slots));
    }
  }

  @override
  Stream<List<PickupSlot>> watchSlots(String farmerId) {
    Future.delayed(const Duration(milliseconds: 300), _broadcastSlots);
    return _slotsController.stream
        .map((list) => list.where((s) => s.farmerId == farmerId).toList());
  }

  @override
  Future<PickupSlot> addSlot(PickupSlot slot) async {
    await _fakeDelay();
    final saved = PickupSlot(
      id: _uuid.v4(),
      farmerId: slot.farmerId,
      startTime: slot.startTime,
      endTime: slot.endTime,
      capacity: slot.capacity,
      bookedCount: 0,
      isActive: slot.isActive,
    );
    _slots.add(saved);
    _broadcastSlots();
    return saved;
  }

  @override
  Future<void> updateSlot(PickupSlot updated) async {
    await _fakeDelay();
    final idx = _slots.indexWhere((s) => s.id == updated.id);
    if (idx == -1) throw Exception('Slot not found: ${updated.id}');
    final current = _slots[idx];
    if (updated.capacity < current.bookedCount) {
      throw Exception(
          'Cannot reduce capacity below ${current.bookedCount} (already booked).');
    }
    final timeChanged = updated.startTime != current.startTime ||
        updated.endTime != current.endTime;
    if (timeChanged && current.bookedCount > 0) {
      throw Exception(
          'Cannot change times: ${current.bookedCount} order(s) already booked.');
    }
    _slots[idx] = updated.copyWith();
    _broadcastSlots();
  }

  @override
  Future<void> deleteSlot(String slotId, int bookedCount) async {
    await _fakeDelay();
    if (bookedCount > 0) {
      throw Exception(
          'Cannot delete slot: $bookedCount order(s) are already booked.');
    }
    _slots.removeWhere((s) => s.id == slotId);
    _broadcastSlots();
  }

  static List<PickupSlot> _seedSlots() {
    const farmerId = 'farmer_001';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      PickupSlot(
        id: 'slot_001',
        farmerId: farmerId,
        startTime: today.add(const Duration(hours: 8)),
        endTime: today.add(const Duration(hours: 10)),
        capacity: 10,
        bookedCount: 8,
        isActive: true,
      ),
      PickupSlot(
        id: 'slot_002',
        farmerId: farmerId,
        startTime: today.add(const Duration(hours: 14)),
        endTime: today.add(const Duration(hours: 16)),
        capacity: 12,
        bookedCount: 3,
        isActive: true,
      ),
    ];
  }



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
