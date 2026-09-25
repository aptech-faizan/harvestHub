import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../data/models/farmer_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/farmer_repository.dart';
import '../../../../data/repositories/follow_repository.dart';
import '../../../../data/repositories/product_repository.dart';

// Ye farmers list, products aur follow state manage karta hai
class FarmersController extends GetxController {
  final RxList<FarmerModel> farmers = <FarmerModel>[].obs;
  final RxBool isLoading = false.obs;

  // Followed farmer IDs ka reactive set
  final RxSet<String> followedIds = <String>{}.obs;

  StreamSubscription<Set<String>>? _followSub;

  @override
  void onInit() {
    super.onInit();
    loadFarmers();
    _listenFollows();
  }

  @override
  void onClose() {
    // Stream subscription cancel karta hai
    _followSub?.cancel();
    super.onClose();
  }

  // Current user ka UID returns karta hai, null agar logged out
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // followedFarmerIds stream sun kar followedIds update karta hai
  void _listenFollows() {
    final uid = _uid;
    if (uid == null) return;
    _followSub = FollowRepository().followedFarmerIds(uid).listen(
          (ids) => followedIds.assignAll(ids),
        );
  }

  // Firestore se farmers load karta hai (users + farmers join)
  Future<void> loadFarmers() async {
    isLoading.value = true;
    try {
      final list = await FarmerRepository().getFarmers();
      farmers.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Farmers load nahi ho sake: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Kisi farmer ko follow hai ya nahi check karta hai
  bool isFollowed(String farmerId) => followedIds.contains(farmerId);

  // Follow ya unfollow toggle karta hai; fail par snackbar dikhata hai
  Future<void> toggleFollow(String farmerId) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      if (isFollowed(farmerId)) {
        await FollowRepository().unfollow(uid, farmerId);
      } else {
        await FollowRepository().follow(uid, farmerId);
      }
    } catch (e) {
      Get.snackbar('Error', 'Follow nahi ho saka: $e');
    }
  }

  // Kisi farmer ke products farmerId ya userId se filter karta hai
  Future<List<ProductModel>> getProductsForFarmer(FarmerModel farmer) async {
    final all = await ProductRepository().getActiveProducts();
    return all
        .where((p) => p.farmerId == farmer.id || p.farmerId == farmer.userId)
        .toList();
  }
}