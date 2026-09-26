import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market_model.dart';

// Ye markets collection se data fetch karne ka repository hai
class MarketRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Active markets fetch karne ke liye
  Future<List<MarketModel>> getActiveMarkets() async {
    final snapshot = await _firestore
        .collection('markets')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => MarketModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<MarketModel?> getMarketById(String id) async {
    if (id.isEmpty) return null;
    final doc = await _firestore.collection('markets').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return MarketModel.fromMap(doc.data()!, doc.id);
  }
}
