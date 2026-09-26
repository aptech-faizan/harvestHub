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
    final doc = await _firestore.collection(Db.farmers).doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return FarmerModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> upsertFarmer(FarmerModel farmer) {
    return _firestore.collection(Db.farmers).doc(farmer.id).set(
          farmer.toMap(),
          SetOptions(merge: true),
        );
  }
}
