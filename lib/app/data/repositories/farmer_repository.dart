import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farmer_model.dart';

// Ye farmers collection se data fetch karne ka repository hai
class FarmerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users + farmers collection dono se merge karke farmers list banata hai
  Future<List<FarmerModel>> getFarmers() async {
    // Step 1: users collection se role=farmer wale fetch karo
    final userSnap = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'farmer')
        .get();

    // isActive != false wale rakho (missing field bhi active maano)
    final activeDocs =
        userSnap.docs.where((d) => d.data()['isActive'] != false).toList();

    final result = <FarmerModel>[];
    final seen = <String>{};

    for (final userDoc in activeDocs) {
      final uid = userDoc.id;
      if (seen.contains(uid)) continue;
      seen.add(uid);

      final userData = userDoc.data();

      // Step 2: farmers/{uid} doc padhne ki koshish karo
      final farmerDoc =
          await _firestore.collection('farmers').doc(uid).get();

      if (farmerDoc.exists && farmerDoc.data() != null) {
        // farmers doc mile to uski fields use karo, id = uid
        final fd = farmerDoc.data()!;
        result.add(FarmerModel(
          id: uid,
          userId: uid,
          businessName: (fd['businessName'] ?? userData['name'] ?? '').toString(),
          description: (fd['description'] ?? '').toString(),
          rating: (fd['rating'] ?? 0).toDouble(),
          marketId: (fd['marketId'] ?? '').toString(),
          lowStockThreshold: (fd['lowStockThreshold'] ?? 0).toInt(),
        ));
      } else {
        // farmers doc na mile to user doc se fallback banao
        result.add(FarmerModel(
          id: uid,
          userId: uid,
          businessName: (userData['name'] ?? '').toString(),
          description: '',
          rating: 0,
          marketId: '',
          lowStockThreshold: 0,
        ));
      }
    }

    return result;
  }
}