import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import '../models/farmer_model.dart';

class FarmerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FarmerModel>> getFarmers() async {
    final snapshot = await _firestore.collection(Db.farmers).get();
    return snapshot.docs
        .map((doc) => FarmerModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<FarmerModel?> getFarmerById(String id) async {
    if (id.isEmpty) return null;
    final doc = await _firestore.collection(Db.farmers).doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return FarmerModel.fromMap(doc.data()!, doc.id);
  }

  /// Resolves a farmer by the auth uid stored in `farmers.userId`.
  ///
  /// Registration writes the farmer doc at `farmers/{uid}`, so the document id
  /// and the userId are normally identical. They diverge for farmers created by
  /// other tooling, which is why callers may need to try both.
  Future<FarmerModel?> getFarmerByUserId(String userId) async {
    if (userId.isEmpty) return null;
    final snap = await _firestore
        .collection(Db.farmers)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return FarmerModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  Future<void> upsertFarmer(FarmerModel farmer) {
    return _firestore.collection(Db.farmers).doc(farmer.id).set(
          farmer.toMap(),
          SetOptions(merge: true),
        );
  }
}
