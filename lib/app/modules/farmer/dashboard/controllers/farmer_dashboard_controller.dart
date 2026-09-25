import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';

class FarmerDashboardController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final FirebaseFirestore? _firestoreOverride;

  FarmerDashboardController({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  final RxString businessName = ''.obs;
  final RxDouble rating = 0.0.obs;
  final RxInt productCount = 0.obs;
  final RxInt orderCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFarmerData();
  }

  Future<void> loadFarmerData() async {
    final uid = authService.currentUser?.uid;
    if (uid == null) return;

    isLoading.value = true;
    try {
      final doc = await _firestore.collection(Db.farmers).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final d = doc.data()!;
        businessName.value = (d['businessName'] ?? '').toString();
        rating.value = (d['rating'] is num) ? (d['rating'] as num).toDouble() : 0.0;
      } else {
        businessName.value = authService.currentUserModel.value?.name ?? 'Farmer';
      }

      // Load summary counts
      final prodSnap = await _firestore
          .collection(Db.products)
          .where('farmerId', isEqualTo: uid)
          .count()
          .get();
      productCount.value = prodSnap.count ?? 0;

      final orderSnap = await _firestore
          .collection(Db.orders)
          .where('farmerId', isEqualTo: uid)
          .count()
          .get();
      orderCount.value = orderSnap.count ?? 0;
    } catch (_) {
      businessName.value = authService.currentUserModel.value?.name ?? 'Farmer';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await authService.logout();
  }
}
