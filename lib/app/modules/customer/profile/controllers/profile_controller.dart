import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/services/auth_service.dart';

// Ye customer profile details, update, password change aur logout manage karta hai
class ProfileController extends GetxController {
  final UserRepository _userRepo = UserRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;

  // Form input controllers
  final TextEditingController nameC = TextEditingController();
  final TextEditingController phoneC = TextEditingController();
  final TextEditingController addressC = TextEditingController();
  final TextEditingController currentPassC = TextEditingController();
  final TextEditingController newPassC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    // Form controllers ko memory se dispose karna
    nameC.dispose();
    phoneC.dispose();
    addressC.dispose();
    currentPassC.dispose();
    newPassC.dispose();
    super.onClose();
  }

  // User profile Firestore se load karta hai
  Future<void> loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    isLoading.value = true;
    try {
      final u = await _userRepo.getUser(uid);
      user.value = u;
      if (u != null) {
        nameC.text = u.name;
        phoneC.text = u.phone;
        addressC.text = u.address;
      }
    } catch (e) {
      Get.snackbar('Error', 'Profile load nahi ho saki: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Profile data validate karke Firestore par update karta hai
  Future<void> saveProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final name = nameC.text.trim();
    final phone = phoneC.text.trim();
    final address = addressC.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      Get.snackbar('Ghalat Input', 'Naam aur phone khali nahi ho sakte');
      return;
    }

    isLoading.value = true;
    try {
      await _userRepo.updateUser(uid, {'name': name, 'phone': phone, 'address': address});
      await loadProfile();
      Get.snackbar('Kamyabi', 'Profile update ho gayi');
    } catch (e) {
      Get.snackbar('Error', 'Update fail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Re-authenticate karke naya password set karta hai
  Future<void> changePassword(String current, String newPass) async {
    if (newPass.length < 6) {
      Get.snackbar('Ghalat Input', 'Naya password kam az kam 6 characters ka hona chahiye');
      return;
    }
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.email == null) return;

    isLoading.value = true;
    try {
      final cred = EmailAuthProvider.credential(email: currentUser.email!, password: current);
      await currentUser.reauthenticateWithCredential(cred);
      await currentUser.updatePassword(newPass);
      currentPassC.clear();
      newPassC.clear();
      Get.snackbar('Kamyabi', 'Password kamyabi se tabdeel ho gaya');
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'wrong-password': msg = 'Purana password galat hai'; break;
        case 'invalid-credential': msg = 'Email ya password galat hai'; break;
        case 'weak-password': msg = 'Naya password kamzor hai'; break;
        case 'requires-recent-login': msg = 'Dobara login karke koshish karein'; break;
        default: msg = e.message ?? 'Password tabdeel nahi ho saka';
      }
      Get.snackbar('Error', msg);
    } catch (e) {
      Get.snackbar('Error', 'Kuch masla hua: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Logs out user and cleans up session via AuthService
  Future<void> logout() async {
    await Get.find<AuthService>().logout();
  }
}
