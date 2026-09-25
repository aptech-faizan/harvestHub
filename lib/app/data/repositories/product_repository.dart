import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

// Ye products collection se data fetch karne ka repository hai
class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Active products fetch karne ke liye
  Future<List<ProductModel>> getActiveProducts() async {
    final snapshot = await _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Single product ID ke zariye fetch karne ke liye
  Future<ProductModel?> getProductById(String id) async {
    final doc = await _firestore.collection('products').doc(id).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return ProductModel.fromMap(doc.data()!, doc.id);
  }
}
