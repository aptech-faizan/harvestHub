import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/pickup_slot_model.dart';

// Ye orders collection ki transactions aur queries handle karne ka repository hai
class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Customer ke orders fetch karke Dart mein latest-first sort karta hai
  Future<List<OrderModel>> getOrdersByCustomer(String uid) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('customerId', isEqualTo: uid)
        .get();

    final orders = snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
    final defaultDate = DateTime(0);
    orders.sort((a, b) => (b.createdAt ?? defaultDate).compareTo(a.createdAt ?? defaultDate));
    return orders;
  }

  // Multiple orders ko atomic transaction ke zariye place karta hai
  Future<void> placeOrders(List<OrderModel> orders) async {
    final orderRefs = orders.map((_) => _firestore.collection('orders').doc()).toList();

    await _firestore.runTransaction((transaction) async {
      // 1. SAB READS PEHLE — products
      final Map<String, DocumentSnapshot<Map<String, dynamic>>> pSnaps = {};
      for (final o in orders) {
        for (final item in o.items) {
          final pid = item['productId'] as String;
          if (!pSnaps.containsKey(pid)) {
            pSnaps[pid] = await transaction.get(
              _firestore.collection('products').doc(pid),
            );
          }
        }
      }

      // 1b. SAB READS PEHLE — pickup slots
      final Map<String, DocumentSnapshot<Map<String, dynamic>>> sSnaps = {};
      for (final o in orders) {
        if (o.pickupSlotId.isNotEmpty && !sSnaps.containsKey(o.pickupSlotId)) {
          sSnaps[o.pickupSlotId] = await transaction.get(
            _firestore.collection('pickup_slots').doc(o.pickupSlotId),
          );
        }
      }

      // 2. VALIDATION — stock check (num se int safe cast)
      final Map<String, int> pDeducts = {};
      for (final o in orders) {
        for (final item in o.items) {
          final pid = item['productId'] as String;
          final name = (item['name'] ?? 'Product') as String;
          final qty = (item['qty'] as num).toInt();
          final snap = pSnaps[pid];
          if (snap == null || !snap.exists || snap.data() == null) {
            throw Exception('$name ka stock kam hai');
          }
          final stock = (snap.data()!['stockQty'] as num).toInt();
          final needed = (pDeducts[pid] ?? 0) + qty;
          if (stock < needed) throw Exception('$name ka stock kam hai');
          pDeducts[pid] = needed;
        }
      }

      // 2b. VALIDATION — slot capacity check
      final Map<String, int> sIncrements = {};
      for (final o in orders) {
        if (o.pickupSlotId.isNotEmpty) {
          final sid = o.pickupSlotId;
          final snap = sSnaps[sid];
          if (snap == null || !snap.exists || snap.data() == null) {
            throw Exception('Slot full hai');
          }
          // fix: null-safe cast prevents crash when old slot docs lack capacity/bookedCount
          final cap = (snap.data()!['capacity'] as num?)?.toInt() ?? 0;
          final booked = (snap.data()!['bookedCount'] as num?)?.toInt() ?? 0;
          final next = booked + (sIncrements[sid] ?? 0) + 1;
          if (next > cap) throw Exception('Slot full hai');
          sIncrements[sid] = (sIncrements[sid] ?? 0) + 1;
        }
      }

      // 3. SAB WRITES BAAD MEIN — product stock deduct
      for (final entry in pDeducts.entries) {
        final stock = (pSnaps[entry.key]!.data()!['stockQty'] as num).toInt();
        transaction.update(
          _firestore.collection('products').doc(entry.key),
          {'stockQty': stock - entry.value},
        );
      }

      // 3b. WRITES — slot bookedCount increment
      for (final entry in sIncrements.entries) {
        // fix: null-safe cast for bookedCount write-back
        final booked = (sSnaps[entry.key]!.data()!['bookedCount'] as num?)?.toInt() ?? 0;
        transaction.update(
          _firestore.collection('pickup_slots').doc(entry.key),
          {'bookedCount': booked + entry.value},
        );
      }

      // 3c. WRITES — naye orders docs set karna
      for (int i = 0; i < orders.length; i++) {
        transaction.set(orderRefs[i], orders[i].toMap());
      }
    });
  }


  // Order cancel karke stock aur slot booked count restore karta hai
  Future<void> cancelOrder(OrderModel o) async {
    final orderRef = _firestore.collection('orders').doc(o.id);
    final slotRef = o.pickupSlotId.isNotEmpty
        ? _firestore.collection('pickup_slots').doc(o.pickupSlotId)
        : null;

    await _firestore.runTransaction((transaction) async {
      final oSnap = await transaction.get(orderRef);
      if (!oSnap.exists || oSnap.data() == null) throw Exception('Order nahi mila');
      final status = oSnap.data()!['status'] as String? ?? '';
      if (status != 'pending' && status != 'confirmed') {
        throw Exception('Sirf pending ya confirmed order cancel ho sakta hai');
      }

      final sSnap = slotRef != null ? await transaction.get(slotRef) : null;
      final Map<String, DocumentSnapshot<Map<String, dynamic>>> pSnaps = {};
      for (final item in o.items) {
        final pid = item['productId'] as String;
        if (!pSnaps.containsKey(pid)) {
          pSnaps[pid] = await transaction.get(_firestore.collection('products').doc(pid));
        }
      }

      transaction.update(orderRef, {'status': 'cancelled'});
      if (slotRef != null && sSnap != null && sSnap.exists && sSnap.data() != null) {
        final booked = (sSnap.data()!['bookedCount'] ?? 0) as num;
        transaction.update(slotRef, {'bookedCount': booked > 0 ? booked - 1 : 0});
      }
      for (final item in o.items) {
        final pid = item['productId'] as String;
        final qty = (item['qty'] ?? 0) as num;
        final snap = pSnaps[pid];
        if (snap != null && snap.exists && snap.data() != null) {
          final stock = (snap.data()!['stockQty'] ?? 0) as num;
          transaction.update(_firestore.collection('products').doc(pid), {'stockQty': stock + qty});
        }
      }
    });
  }

  // Order ka pickup slot dusre slot mein transfer karta hai
  Future<void> changeSlot(OrderModel o, PickupSlotModel newSlot) async {
    final orderRef = _firestore.collection('orders').doc(o.id);
    final oldSlotRef = o.pickupSlotId.isNotEmpty
        ? _firestore.collection('pickup_slots').doc(o.pickupSlotId)
        : null;
    final newSlotRef = _firestore.collection('pickup_slots').doc(newSlot.id);

    await _firestore.runTransaction((transaction) async {
      final oSnap = await transaction.get(orderRef);
      if (!oSnap.exists || oSnap.data() == null) throw Exception('Order nahi mila');
      final status = oSnap.data()!['status'] as String? ?? '';
      if (status != 'pending' && status != 'confirmed') {
        throw Exception('Sirf pending ya confirmed order ka slot badal sakte hain');
      }

      final oldSnap = oldSlotRef != null ? await transaction.get(oldSlotRef) : null;
      final newSnap = await transaction.get(newSlotRef);
      if (!newSnap.exists || newSnap.data() == null) throw Exception('Naya slot nahi mila');
      final cap = (newSnap.data()!['capacity'] ?? 0) as num;
      final booked = (newSnap.data()!['bookedCount'] ?? 0) as num;
      if (booked >= cap) throw Exception('Slot full hai');

      if (oldSlotRef != null && oldSnap != null && oldSnap.exists && oldSnap.data() != null) {
        final oldBooked = (oldSnap.data()!['bookedCount'] ?? 0) as num;
        transaction.update(oldSlotRef, {'bookedCount': oldBooked > 0 ? oldBooked - 1 : 0});
      }
      transaction.update(newSlotRef, {'bookedCount': booked + 1});
      transaction.update(orderRef, {
        'pickupSlotId': newSlot.id,
        'pickupSlotTime': newSlot.label,
      });
    });
  }
}
