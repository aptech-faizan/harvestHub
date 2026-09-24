import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pickup_slot_model.dart';

// Ye pickup slots collection se data fetch karne ka repository hai
class PickupSlotRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Specific farmer ke time slots fetch karne ke liye
  Future<List<PickupSlotModel>> getSlotsByFarmer(String farmerId) async {
    final snapshot = await _firestore
        .collection('pickup_slots')
        .where('farmerId', isEqualTo: farmerId)
        .get();

    return snapshot.docs
        .map((doc) => PickupSlotModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
