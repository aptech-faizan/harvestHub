import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

// Ye categories collection se data fetch karne ka repository hai
class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Active categories fetch karne ke liye.
  // Case-insensitive deduplication bhi karta hai taake Firestore mein agar
  // "fruits" aur "Fruits" dono documents hon, to UI mein sirf ek dikhe.
  Future<List<CategoryModel>> getActiveCategories() async {
    final snapshot = await _firestore.collection('categories').get();

    final all = snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
        .where((c) => c.isActive)
        .toList();

    // Sort first so the Title-Case version wins over lowercase duplicate
    all.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    // Case-insensitive deduplication: pehla occurrence rakho, baaki hata do
    final seen = <String>{};
    final unique = <CategoryModel>[];
    for (final cat in all) {
      final key = cat.name.trim().toLowerCase();
      if (seen.add(key)) {
        unique.add(cat);
      }
    }
    return unique;
  }
}
