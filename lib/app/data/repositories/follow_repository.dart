import 'package:cloud_firestore/cloud_firestore.dart';

// Ye farmer follow/unfollow aur followed list ka Firestore repository hai
class FollowRepository {
  final _db = FirebaseFirestore.instance;

  // users/{uid}/follows/{farmerId} collection path
  CollectionReference<Map<String, dynamic>> _followsRef(String uid) =>
      _db.collection('users').doc(uid).collection('follows');

  // Followed farmer IDs ki live stream return karta hai
  Stream<Set<String>> followedFarmerIds(String uid) {
    return _followsRef(uid).snapshots().map(
          (snap) => snap.docs.map((d) => d.id).toSet(),
        );
  }

  // Kisi farmer ko follow karta hai
  Future<void> follow(String uid, String farmerId) {
    return _followsRef(uid).doc(farmerId).set({'followedAt': DateTime.now()});
  }

  // Kisi farmer ko unfollow karta hai
  Future<void> unfollow(String uid, String farmerId) {
    return _followsRef(uid).doc(farmerId).delete();
  }
}