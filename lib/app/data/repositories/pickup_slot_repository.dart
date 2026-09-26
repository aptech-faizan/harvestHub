import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import '../models/pickup_slot_model.dart';

class PickupSlotRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PickupSlotModel>> getSlotsByFarmer(String farmerId) async {
    final snapshot = await _firestore
        .collection(Db.pickupSlots)
        .where('farmerId', isEqualTo: farmerId)
        .get();

    final list = snapshot.docs
        .map((doc) => PickupSlotModel.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  Future<String> addSlot(PickupSlotModel slot) async {
    final ref = await _firestore.collection(Db.pickupSlots).add(slot.toMap());
    return ref.id;
  }

  Future<void> updateSlot(PickupSlotModel slot) {
    return _firestore.collection(Db.pickupSlots).doc(slot.id).update(slot.toMap());
  }

  Future<void> deleteSlot(PickupSlotModel slot) {
    if (slot.bookedCount > 0) {
      throw Exception('Cannot delete a slot that already has bookings.');
    }
    return _firestore.collection(Db.pickupSlots).doc(slot.id).delete();
  }
}
