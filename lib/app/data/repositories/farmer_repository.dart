import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farmer_model.dart';

// Ye farmers collection se data fetch karne ka repository hai
class FarmerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tamaam farmers fetch karne ke liye
  Future<List<FarmerModel>> getFarmers() async {
    final snapshot = await _firestore.collection('farmers').get();
    return snapshot.docs
        .map((doc) => FarmerModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
