import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../role_select/role_select_view.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../../shell/bindings/customer_shell_binding.dart';
import '../../shell/views/customer_shell_view.dart';

// Ye customer login aur register ki logic handle karta hai
class CustomerAuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Loading state aur password visibility
  final RxBool isLoading = false.obs;
  final RxBool hidePassword = true.obs;

  // Form input controllers
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  @override
  void onClose() {
    // Memory free karne ke liye dispose karna zaroori hai
    emailCtrl.dispose();
    passwordCtrl.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    super.onClose();
  }

  // Firebase error codes ke hisaab se user-friendly message deta hai
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Ye email pehle se registered hai.';
      case 'wrong-password': return 'Password galat hai.';
      case 'user-not-found': return 'Ye email registered nahi hai.';
      case 'invalid-credential': return 'Email ya password galat hai.';
      case 'weak-password': return 'Password kam az kam 6 characters ka hona chahiye.';
      case 'network-request-failed': return 'Internet connection check karein.';
      default: return 'Kuch masla hua: $code';
    }
  }

  // Input validation karne ka method
  String? _validate(String name, String email, String phone, String password) {
    if (name.trim().isEmpty) return 'Naam khali nahi ho sakta.';
    if (email.trim().isEmpty || !email.contains('@')) return 'Sahih email dalein.';
    if (phone.trim().isEmpty) return 'Phone number khali nahi ho sakta.';
    if (password.length < 6) return 'Password kam az kam 6 chars ka hona chahiye.';
    return null;
  }

  // Naya customer account banane ka method
  Future<void> register(String name, String email, String phone, String password, String address) async {
    final error = _validate(name, email, phone, password);
    if (error != null) {
      Get.snackbar('Galat Input', error);
      return;
    }
    isLoading.value = true;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
        'role': 'customer',
        'fcmToken': '',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.find<WishlistController>().loadWishlist();
      Get.offAll(() => const CustomerShellView(), binding: CustomerShellBinding());
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', _getErrorMessage(e.code));
    } catch (e) {
      Get.snackbar('Error', 'Kuch masla hua: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Existing customer account se login karne ka method
  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      Get.snackbar('Galat Input', 'Email aur password dalein.');
      return;
    }
    isLoading.value = true;
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null ||
          doc.data()!['role'] != 'customer' ||
          doc.data()!['isActive'] == false) {
        await _auth.signOut();
        Get.snackbar('Access Denied', 'Ye account customer nahi hai ya blocked hai.');
        return;
      }
      Get.find<WishlistController>().loadWishlist();
      Get.offAll(() => const CustomerShellView(), binding: CustomerShellBinding());
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', _getErrorMessage(e.code));
    } catch (e) {
      Get.snackbar('Error', 'Kuch masla hua: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // User ko logout karne aur state saaf karne ka method
  Future<void> logout() async {
    await _auth.signOut();
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().clear();
    }
    if (Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().clearAll();
    }
    Get.offAll(() => const RoleSelectView());
  }

  // Password show/hide toggle karne ka method
  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }
}
