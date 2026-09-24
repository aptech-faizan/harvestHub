import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/farmer_product_model.dart';
import '../models/farmer_order_model.dart';
import 'farmer_repository.dart';

/// Firestore-backed implementation of [FarmerRepository].
///
/// Firestore schema:
/// ─ products/{productId}  fields: farmerId, itemName, itemNameLower,
///     description, categoryName, pricePerUnit, unit, stockQty, imageUrl,
///     isActive, createdAt, updatedAt
/// ─ orders/{orderId}      fields: farmerId, customerId, customerName,
///     items:[{productId,name,price,qty,unit}], totalPrice, status,
///     createdAt, updatedAt, notes
/// ─ farmers/{farmerId}    fields: businessName, description, rating,
///     lowStockThreshold, marketId, isActive
///
/// Required composite index (Firestore will show a link on first query):
///   Collection: orders  |  farmerId ASC, createdAt DESC
///   Collection: products |  farmerId ASC, createdAt DESC
class FarmerFirestoreRepository implements FarmerRepository {
  FarmerFirestoreRepository()
      : _db = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the authenticated farmer's UID or throws if not signed in.
  String get _farmerId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Farmer is not signed in.');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  DocumentReference<Map<String, dynamic>> _farmerDoc(String farmerId) =>
      _db.collection('farmers').doc(farmerId);

  /// Converts a Firestore [FirebaseException] to a user-friendly message.
  String _friendlyError(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'You do not have permission to perform this action.';
        case 'not-found':
          return 'The requested item was not found.';
        case 'unavailable':
          return 'Service temporarily unavailable. Please try again.';
        case 'deadline-exceeded':
          return 'The request timed out. Check your internet connection.';
        default:
          return 'Firestore error (${e.code}): ${e.message}';
      }
    }
    return e.toString();
  }

  // ── Products ──────────────────────────────────────────────────────────────

  @override
  Future<List<FarmerProduct>> getProducts(String farmerId) async {
    try {
      // Composite index required: farmerId ASC + createdAt DESC
      final snap = await _products
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((d) => FarmerProduct.fromMap(d.data(), d.id))
          .toList();
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Stream<List<FarmerProduct>> watchProducts(String farmerId) {
    // Composite index required: farmerId ASC + createdAt DESC
    return _products
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => FarmerProduct.fromMap(d.data(), d.id)).toList())
        .handleError((Object e) {
      throw Exception(_friendlyError(e));
    });
  }

  @override
  Future<FarmerProduct> addProduct(FarmerProduct product) async {
    try {
      final farmerId = _farmerId;
      final now = DateTime.now();
      final data = {
        ...product.toMap(),
        'farmerId': farmerId,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };
      final ref = await _products.add(data);
      return FarmerProduct.fromMap(data, ref.id);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<FarmerProduct> updateProduct(FarmerProduct product) async {
    try {
      final now = DateTime.now();
      final data = {
        ...product.toMap(),
        'updatedAt': Timestamp.fromDate(now),
      };
      await _products.doc(product.id).update(data);
      product.updatedAt = now;
      return product;
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<void> updateStock(String productId, int newQty) async {
    if (newQty < 0) throw Exception('Stock cannot go below 0.');
    try {
      await _db.runTransaction((txn) async {
        final ref = _products.doc(productId);
        final snap = await txn.get(ref);
        if (!snap.exists) throw Exception('Product not found: $productId');
        txn.update(ref, {
          'stockQty': newQty,
          'isActive': newQty > 0,
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _products.doc(productId).delete();
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  @override
  Future<List<FarmerOrder>> getOrders(
    String farmerId, {
    OrderStatus? status,
  }) async {
    try {
      // Composite index required: farmerId ASC + createdAt DESC
      Query<Map<String, dynamic>> query = _orders
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('createdAt', descending: true);
      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }
      final snap = await query.get();
      return snap.docs
          .map((d) => FarmerOrder.fromMap(d.data(), d.id))
          .toList();
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Stream<List<FarmerOrder>> watchOrders(
    String farmerId, {
    OrderStatus? status,
  }) {
    // Composite index required: farmerId ASC + status ASC + createdAt DESC
    Query<Map<String, dynamic>> query = _orders
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('createdAt', descending: true);
    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }
    return query
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => FarmerOrder.fromMap(d.data(), d.id)).toList())
        .handleError((Object e) {
      throw Exception(_friendlyError(e));
    });
  }

  @override
  Future<FarmerOrder> updateOrderStatus(
      String orderId, OrderStatus newStatus) async {
    try {
      final orderRef = _orders.doc(orderId);

      late FarmerOrder updatedOrder;

      await _db.runTransaction((txn) async {
        final orderSnap = await txn.get(orderRef);
        if (!orderSnap.exists) throw Exception('Order not found: $orderId');

        final order =
            FarmerOrder.fromMap(orderSnap.data()!, orderSnap.id);
        final oldStatus = order.status;

        // Business rule: cancelling → restore item stock quantities
        if (newStatus == OrderStatus.cancelled &&
            oldStatus != OrderStatus.cancelled) {
          for (final item in order.items) {
            final productRef = _products.doc(item.productId);
            final productSnap = await txn.get(productRef);
            if (productSnap.exists) {
              final currentQty =
                  (productSnap.data()!['stockQty'] as num?)?.toInt() ?? 0;
              final restoredQty = currentQty + item.quantity;
              txn.update(productRef, {
                'stockQty': restoredQty,
                'isActive': restoredQty > 0,
                'updatedAt': Timestamp.now(),
              });
            }
          }
        }

        final now = Timestamp.now();
        txn.update(orderRef, {
          'status': newStatus.value,
          'updatedAt': now,
        });

        order.status = newStatus;
        order.updatedAt = now.toDate();
        updatedOrder = order;
      });

      return updatedOrder;
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Dashboard stats ───────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getDashboardStats(String farmerId) async {
    try {
      // Run both queries concurrently
      final results = await Future.wait([
        _products.where('farmerId', isEqualTo: farmerId).get(),
        _orders.where('farmerId', isEqualTo: farmerId).get(),
      ]);

      final productsSnap = results[0];
      final ordersSnap = results[1];

      int pendingOrders = 0;
      double totalRevenue = 0.0;

      for (final doc in ordersSnap.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? '';
        if (status == OrderStatus.pending.value) pendingOrders++;
        if (status == OrderStatus.completed.value) {
          totalRevenue +=
              (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
        }
      }

      return {
        'totalProducts': productsSnap.docs.length,
        'totalOrders': ordersSnap.docs.length,
        'pendingOrders': pendingOrders,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Farmer profile / settings ─────────────────────────────────────────────

  @override
  Future<int> getLowStockThreshold(String farmerId) async {
    try {
      final snap = await _farmerDoc(farmerId).get();
      if (!snap.exists) return 5; // default
      return (snap.data()?['lowStockThreshold'] as num?)?.toInt() ?? 5;
    } catch (e) {
      return 5; // graceful fallback
    }
  }

  @override
  Future<void> setLowStockThreshold(String farmerId, int threshold) async {
    try {
      await _farmerDoc(farmerId).set(
        {'lowStockThreshold': threshold},
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }
}
