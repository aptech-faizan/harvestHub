import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import '../models/farmer_model.dart';

/// Followed ("favourite") farmers, stored as a sub-collection under each user.
///
/// Why a sub-collection and not a `followed_farmers` array on the user document:
/// restock alerts (STEP 3) need "every customer who follows *this* farmer".
/// With a sub-collection that is one indexed `collectionGroup` query. With an
/// array it would mean reading every user document in the platform and checking
/// each one - unusable at any real scale.
///
/// It also mirrors the existing wishlist storage
/// (`users/{uid}/wishlist/{productId}`), so the two personal lists behave
/// identically.
class FollowRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      _firestore.collection(Db.users).doc(uid).collection('followed_farmers');

  /// Idempotent: following twice is a no-op, not a duplicate error.
  Future<void> follow({
    required String uid,
    required String farmerId,
    String farmerName = '',
  }) {
    if (uid.isEmpty || farmerId.isEmpty) {
      return Future.value();
    }
    return _ref(uid).doc(farmerId).set({
      'farmerId': farmerId,
      // Denormalised so the followed-farms list renders without extra reads.
      'farmerName': farmerName,
      'followedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unfollow({required String uid, required String farmerId}) {
    if (uid.isEmpty || farmerId.isEmpty) {
      return Future.value();
    }
    return _ref(uid).doc(farmerId).delete();
  }

  /// Followed farmer ids, for reactive toggle state.
  Future<Set<String>> getFollowedFarmerIds(String uid) async {
    if (uid.isEmpty) return <String>{};
    final snap = await _ref(uid).get();
    return snap.docs.map((d) => d.id).toSet();
  }

  /// Live stream of followed farmer ids, so every follow button on screen stays
  /// in sync without each screen re-querying after a toggle.
  Stream<Set<String>> watchFollowedFarmerIds(String uid) {
    if (uid.isEmpty) return Stream.value(<String>{});
    return _ref(uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  /// Resolves the followed ids into full farmer profiles, dropping any farmer
  /// document that has since been deleted.
  Future<List<FarmerModel>> getFollowedFarmers(String uid) async {
    final ids = await getFollowedFarmerIds(uid);
    if (ids.isEmpty) return <FarmerModel>[];

    final snap = await _firestore
        .collection(Db.farmers)
        .where(FieldPath.documentId, isEqualTo: ids.toList())
        .get();
    final list = snap.docs
        .map((d) => FarmerModel.fromMap(d.data(), d.id))
        .toList();
    list.sort(
      (a, b) =>
          a.businessName.toLowerCase().compareTo(b.businessName.toLowerCase()),
    );
    return list;
  }

  /// Live stream of the resolved farmer profiles, for the followed-farms list.
  Stream<List<FarmerModel>> watchFollowedFarmers(String uid) {
    return watchFollowedFarmerIds(uid)
        .asyncMap((ids) => getFollowedFarmers(uid));
  }

  /// Every customer uid that follows [farmerId].
  ///
  /// Used by the restock / new-order notification triggers. Requires a
  /// `followed_farmers` collection-group index on `farmerId`.
  Future<List<String>> getFollowerUids(String farmerId) async {
    if (farmerId.isEmpty) return <String>[];
    final snap = await _firestore
        .collectionGroup('followed_farmers')
        .where('farmerId', isEqualTo: farmerId)
        .get();
    // The parent document is users/{uid}, so uid is the second-to-last segment.
    return snap.docs
        .map((d) => d.reference.parent.parent?.id)
        .whereType<String>()
        .toSet()
        .toList();
  }
}
