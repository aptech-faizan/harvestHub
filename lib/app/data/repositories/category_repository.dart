import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

// Ye categories collection se data fetch karne ka repository hai
class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Active categories fetch karne ke liye
  Future<List<CategoryModel>> getActiveCategories() async {
    final snapshot = await _firestore
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
