import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/farmer_product_model.dart';
import '../models/farmer_order_model.dart';
import '../models/farmer_slot_model.dart';
import '../models/farmer_profile_model.dart';
import 'farmer_repository.dart';

/// Firestore-backed implementation of [FarmerRepository].
///
/// ── Fixed Firestore schema ────────────────────────────────────────────────
/// products/{id}:
///   farmerId, farmerName, itemName, itemNameLower, description,
///   categoryId, categoryName, marketId, marketName,
///   pricePerUnit (number), unit, stockQty (number), imageUrl (string, never null),
///   lat (number), lng (number), isActive (bool, never string),
///   createdAt (serverTimestamp), updatedAt (serverTimestamp),
///   restockedAt (serverTimestamp – written only when FARMER changes stockQty)
///
/// orders/{id}:
///   farmerId, customerId, customerName (or items[].name),
///   items:[{productId,name,price,qty,unit}], totalPrice,
///   deliveryAddress, pickupSlotId, pickupSlotTime (String),
///   status, createdAt, updatedAt
///
/// pickup_slots/{id}:
///   farmerId, startTime (Timestamp), endTime (Timestamp),
///   capacity (number), bookedCount (number, init 0), isActive (bool)
///
/// farmers/{uid}:
///   userId, businessName, description, marketId, rating, lowStockThreshold
///
/// ── Required composite indexes ────────────────────────────────────────────
/// Create these in the Firebase Console → Firestore → Indexes tab:
///
///   1. Collection: products
///      Fields: farmerId ASC, createdAt DESC
///
///   2. Collection: orders
///      Fields: farmerId ASC, createdAt DESC
///
///   3. Collection: orders (with status filter)
///      Fields: farmerId ASC, status ASC, createdAt DESC
///
///   4. Collection: pickup_slots
///      Fields: farmerId ASC, startTime ASC
///
/// Firestore will also print a direct link to create missing indexes
/// in the debug console when a query first fails.
class FarmerFirestoreRepository implements FarmerRepository {
  FarmerFirestoreRepository()
      : _db = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  // ── Collection helpers ────────────────────────────────────────────────────

  String get _farmerId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Farmer is not signed in.');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  CollectionReference<Map<String, dynamic>> get _slots =>
      _db.collection('pickup_slots');

  DocumentReference<Map<String, dynamic>> _farmerDoc(String uid) =>
      _db.collection('farmers').doc(uid);

  CollectionReference<Map<String, dynamic>> get _markets =>
      _db.collection('markets');

  // ── Error helper ──────────────────────────────────────────────────────────

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
      // Index 1: farmerId ASC + createdAt DESC
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
    // Index 1: farmerId ASC + createdAt DESC
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
      final uid = _farmerId;

      // Enrich with farmer profile data (farmerName, marketId, marketName, lat, lng)
      final profileSnap = await _farmerDoc(uid).get();
      final profileData = profileSnap.data() ?? {};
      final farmerName = profileData['businessName'] as String? ?? '';
      final marketId = product.marketId.isNotEmpty
          ? product.marketId
          : (profileData['marketId'] as String? ?? '');

      double lat = product.lat;
      double lng = product.lng;
      String marketName = product.marketName;

      if (marketId.isNotEmpty && (lat == 0.0 || marketName.isEmpty)) {
        final mSnap = await _markets.doc(marketId).get();
        if (mSnap.exists) {
          final md = mSnap.data()!;
          lat = (md['lat'] as num?)?.toDouble() ?? 0.0;
          lng = (md['lng'] as num?)?.toDouble() ?? 0.0;
          marketName = md['name'] as String? ?? md['marketName'] as String? ?? '';
        }
      }

      final enrichedProduct = product.copyWith(
        farmerName: farmerName,
        marketId: marketId,
        marketName: marketName,
        lat: lat,
        lng: lng,
      );

      final data = {
        ...enrichedProduct.toMap(),
        'farmerId': uid,
        'farmerName': farmerName,
        // imageUrl is never null – ensure it's a string
        'imageUrl': product.imageUrl.isEmpty ? '' : product.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final ref = await _products.add(data);
      // Re-read to get server timestamps
      final saved = await ref.get();
      return FarmerProduct.fromMap(saved.data()!, ref.id);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<FarmerProduct> updateProduct(FarmerProduct product) async {
    try {
      final data = {
        ...product.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        // imageUrl is never null
        'imageUrl': product.imageUrl.isEmpty ? '' : product.imageUrl,
      };
      await _products.doc(product.id).update(data);
      product.updatedAt = DateTime.now();
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
        // restockedAt is set ONLY when farmer changes stockQty
        txn.update(ref, {
          'stockQty': newQty,
          'isActive': newQty > 0,
          'updatedAt': FieldValue.serverTimestamp(),
          'restockedAt': FieldValue.serverTimestamp(),
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
      // Index 2 or 3 depending on whether status is set
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

        final order = FarmerOrder.fromMap(orderSnap.data()!, orderSnap.id);
        final oldStatus = order.status;

        // Business rule: cancelling → restore item stock quantities
        // NOTE: do NOT set restockedAt here (customer cancel path)
        if (newStatus == OrderStatus.cancelled &&
            oldStatus != OrderStatus.cancelled) {
          for (final item in order.items) {
            final productRef = _products.doc(item.productId);
            final productSnap = await txn.get(productRef);
            if (productSnap.exists) {
              final currentQty =
                  (productSnap.data()!['stockQty'] as num?)?.toInt() ?? 0;
              final restoredQty = currentQty + item.quantity;
              // restockedAt is NOT set here – this is NOT a farmer restock
              txn.update(productRef, {
                'stockQty': restoredQty,
                'isActive': restoredQty > 0,
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
          }
        }

        // Only write status and updatedAt on the order
        txn.update(orderRef, {
          'status': newStatus.value,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        order.status = newStatus;
        order.updatedAt = DateTime.now();
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
          totalRevenue += (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
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

  // ── Farmer profile ────────────────────────────────────────────────────────

  @override
  Future<FarmerProfile> getFarmerProfile(String farmerId) async {
    try {
      final snap = await _farmerDoc(farmerId).get();
      if (!snap.exists) {
        return FarmerProfile(userId: farmerId);
      }
      return FarmerProfile.fromMap(snap.data()!, farmerId);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<void> saveFarmerProfile(FarmerProfile profile) async {
    try {
      await _farmerDoc(profile.userId).set(
        profile.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<int> getLowStockThreshold(String farmerId) async {
    try {
      final snap = await _farmerDoc(farmerId).get();
      if (!snap.exists) return 5;
      return (snap.data()?['lowStockThreshold'] as num?)?.toInt() ?? 5;
    } catch (_) {
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

  @override
  Future<List<MarketInfo>> getMarkets() async {
    try {
      final snap = await _markets.orderBy('name').get();
      return snap.docs
          .map((d) => MarketInfo.fromMap(d.data(), d.id))
          .toList();
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Pickup Slots ──────────────────────────────────────────────────────────

  @override
  Stream<List<PickupSlot>> watchSlots(String farmerId) {
    // Index 4: farmerId ASC + startTime ASC
    return _slots
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('startTime')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PickupSlot.fromMap(d.data(), d.id)).toList())
        .handleError((Object e) {
      throw Exception(_friendlyError(e));
    });
  }

  @override
  Future<PickupSlot> addSlot(PickupSlot slot) async {
    try {
      final uid = _farmerId;
      final data = {
        ...slot.toCreateMap(),
        'farmerId': uid,
      };
      final ref = await _slots.add(data);
      return PickupSlot.fromMap(data, ref.id);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<void> updateSlot(PickupSlot updated) async {
    try {
      await _db.runTransaction((txn) async {
        final ref = _slots.doc(updated.id);
        final snap = await txn.get(ref);
        if (!snap.exists) throw Exception('Slot not found: ${updated.id}');

        final current = PickupSlot.fromMap(snap.data()!, snap.id);

        // Business rule: capacity cannot go below bookedCount
        if (updated.capacity < current.bookedCount) {
          throw Exception(
            'Cannot reduce capacity below ${current.bookedCount} '
            '(already booked). Cancel orders first.',
          );
        }

        // Business rule: block time change if slot has bookings
        final timeChanged = updated.startTime != current.startTime ||
            updated.endTime != current.endTime;
        if (timeChanged && current.bookedCount > 0) {
          throw Exception(
            'Cannot change slot times: ${current.bookedCount} order(s) '
            'already booked for this slot.',
          );
        }

        // Never write bookedCount
        txn.update(ref, updated.toUpdateMap());
      });
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<void> deleteSlot(String slotId, int bookedCount) async {
    // Business rule: block deletion if slot has bookings
    if (bookedCount > 0) {
      throw Exception(
        'Cannot delete slot: $bookedCount order(s) are already booked. '
        'Wait for all orders to complete or be cancelled first.',
      );
    }
    try {
      await _slots.doc(slotId).delete();
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── DEV-ONLY: Backfill ────────────────────────────────────────────────────

  /// Backfills missing fields on all products owned by the current farmer.
  /// Call once from farmer_main.dart with backfillProducts = true, then
  /// set it back to false.
  ///
  /// Fields filled:
  ///   farmerName  ← farmers/{uid}.businessName
  ///   categoryId  ← '' (manual mapping not done automatically)
  ///   marketId    ← farmers/{uid}.marketId
  ///   marketName  ← markets/{marketId}.name
  ///   lat, lng    ← markets/{marketId}.lat/lng
  ///   imageUrl    ← '' if null or missing
  Future<void> backfillMyProducts() async {
    final uid = _farmerId;

    // Fetch farmer profile
    final profileSnap = await _farmerDoc(uid).get();
    final profileData = profileSnap.data() ?? {};
    final farmerName = profileData['businessName'] as String? ?? '';
    final marketId = profileData['marketId'] as String? ?? '';

    double marketLat = 0.0;
    double marketLng = 0.0;
    String marketName = '';

    if (marketId.isNotEmpty) {
      final mSnap = await _markets.doc(marketId).get();
      if (mSnap.exists) {
        final md = mSnap.data()!;
        marketLat = (md['lat'] as num?)?.toDouble() ?? 0.0;
        marketLng = (md['lng'] as num?)?.toDouble() ?? 0.0;
        marketName =
            md['name'] as String? ?? md['marketName'] as String? ?? '';
      }
    }

    // Fetch all my products
    final snap = await _products.where('farmerId', isEqualTo: uid).get();

    final batch = _db.batch();
    for (final doc in snap.docs) {
      final data = doc.data();
      final updates = <String, dynamic>{};

      if ((data['farmerName'] as String?)?.isEmpty ?? true) {
        updates['farmerName'] = farmerName;
      }
      if ((data['marketId'] as String?)?.isEmpty ?? true) {
        updates['marketId'] = marketId;
      }
      if ((data['marketName'] as String?)?.isEmpty ?? true) {
        updates['marketName'] = marketName;
      }
      if ((data['lat'] as num?) == null || (data['lat'] as num?) == 0) {
        updates['lat'] = marketLat;
      }
      if ((data['lng'] as num?) == null || (data['lng'] as num?) == 0) {
        updates['lng'] = marketLng;
      }
      // imageUrl must never be null
      if (data['imageUrl'] == null) {
        updates['imageUrl'] = '';
      }
      // isActive must be a bool
      if (data['isActive'] is! bool) {
        final qty = (data['stockQty'] as num?)?.toInt() ?? 0;
        updates['isActive'] = qty > 0;
      }

      if (updates.isNotEmpty) {
        batch.update(doc.reference, updates);
      }
    }

    await batch.commit();
    // ignore: avoid_print
    print('[FarmerDev] backfillMyProducts: updated ${snap.docs.length} docs.');
  }
}
