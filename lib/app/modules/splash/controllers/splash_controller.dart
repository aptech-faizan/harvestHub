import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../customer/shell/bindings/customer_shell_binding.dart';
import '../../customer/shell/views/customer_shell_view.dart';
import '../../customer/wishlist/controllers/wishlist_controller.dart';
import '../../role_select/role_select_view.dart';

// Ye app launch par authentication state aur user role check karta hai
class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onReady() {
    super.onReady();
    checkAuthAndRedirect();
  }

  // Auth status aur user role verify karke relevant screen par le jata hai
  Future<void> checkAuthAndRedirect() async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.offAll(() => const RoleSelectView());
        return;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists || doc.data() == null) {
        await _auth.signOut();
        Get.offAll(() => const RoleSelectView());
        return;
      }

      final data = doc.data()!;
      final role = data['role'] as String? ?? '';
      final isActive = data['isActive'] as bool? ?? true;

      if (!isActive) {
        await _auth.signOut();
        Get.offAll(() => const RoleSelectView());
        return;
      }

      if (role == 'customer') {
        if (Get.isRegistered<WishlistController>()) {
          Get.find<WishlistController>().loadWishlist();
        }
        Get.offAll(
          () => const CustomerShellView(),
          binding: CustomerShellBinding(),
        );
      } else {
        // TODO: Dev 2/3 ka redirect
        await _auth.signOut();
        Get.offAll(() => const RoleSelectView());
      }
    } catch (e) {
      Get.offAll(() => const RoleSelectView());
    }
  }
}
