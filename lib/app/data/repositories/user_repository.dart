import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// Ye user profiles aur unki wishlist manage karne ka repository hai
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User profile fetch karne ke liye
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  // User profile data update karne ke liye
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // User ki wishlist mein se tamaam product IDs lana
  Future<List<String>> getWishlist(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Wishlist subcollection mein product ID add karna
  Future<void> addToWishlist(String uid, String productId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId)
        .set({'addedAt': FieldValue.serverTimestamp()});
  }

  // Wishlist subcollection se product ID delete karna
  Future<void> removeFromWishlist(String uid, String productId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }
}
