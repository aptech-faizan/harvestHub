import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/cloudinary_service.dart';
import '../../../../core/widgets/app_snackbar.dart';

/// Manages customer profile details, updates, password changes and logout.
class ProfileController extends GetxController {
  final UserRepository _userRepo = UserRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinary = CloudinaryService();

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxBool isUploadingPhoto = false.obs;

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
    nameC.dispose();
    phoneC.dispose();
    addressC.dispose();
    currentPassC.dispose();
    newPassC.dispose();
    super.onClose();
  }

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
      AppSnackbar.error('Could not load profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final name = nameC.text.trim();
    final phone = phoneC.text.trim();
    final address = addressC.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      AppSnackbar.warning('Name and phone number are required', title: 'Invalid Input');
      return;
    }

    isLoading.value = true;
    try {
      await _userRepo.updateUser(uid, {'name': name, 'phone': phone, 'address': address});
      await loadProfile();
      AppSnackbar.success('Profile updated successfully', title: 'Profile Saved');
    } catch (e) {
      AppSnackbar.error('Could not update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(String current, String newPass) async {
    if (newPass.length < 6) {
      AppSnackbar.warning('New password must be at least 6 characters', title: 'Invalid Input');
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
      AppSnackbar.success('Password changed successfully', title: 'Password Updated');
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'wrong-password': msg = 'Current password is incorrect'; break;
        case 'invalid-credential': msg = 'Email or password is incorrect'; break;
        case 'weak-password': msg = 'New password is too weak'; break;
        case 'requires-recent-login': msg = 'Please log in again and retry'; break;
        default: msg = e.message ?? 'Could not change password';
      }
      AppSnackbar.error(msg);
    } catch (e) {
      AppSnackbar.error('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadPhoto(ImageSource source) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final file = await _picker.pickImage(source: source, imageQuality: 80);
      if (file == null) return;

      isUploadingPhoto.value = true;
      final url = await _cloudinary.uploadImage(file);
      await _userRepo.updateUser(uid, {'photoUrl': url});

      if (user.value != null) {
        user.value = user.value!.copyWith(photoUrl: url);
      }
      if (Get.isRegistered<AuthService>()) {
        final authService = Get.find<AuthService>();
        if (authService.currentUserModel.value != null) {
          authService.currentUserModel.value =
              authService.currentUserModel.value!.copyWith(photoUrl: url);
        }
      }

      AppSnackbar.success('Profile photo updated', title: 'Photo Updated');
    } catch (e) {
      AppSnackbar.error('Could not upload photo: $e', title: 'Upload Failed');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<void> removePhoto() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      isUploadingPhoto.value = true;
      await _userRepo.updateUser(uid, {'photoUrl': ''});

      if (user.value != null) {
        user.value = user.value!.copyWith(photoUrl: '');
      }
      if (Get.isRegistered<AuthService>()) {
        final authService = Get.find<AuthService>();
        if (authService.currentUserModel.value != null) {
          authService.currentUserModel.value =
              authService.currentUserModel.value!.copyWith(photoUrl: '');
        }
      }

      AppSnackbar.success('Profile photo removed', title: 'Photo Removed');
    } catch (e) {
      AppSnackbar.error('Could not remove photo: $e', title: 'Remove Failed');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<void> logout() async {
    await Get.find<AuthService>().logout();
  }
}
