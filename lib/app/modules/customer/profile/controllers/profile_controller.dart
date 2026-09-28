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

  bool _isDisposed = false;
  bool get isDisposed => _isDisposed || isClosed;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    _isDisposed = true;
    nameC.dispose();
    phoneC.dispose();
    addressC.dispose();
    currentPassC.dispose();
    newPassC.dispose();
    super.onClose();
  }

  void reset() {
    user.value = null;
    if (!isDisposed) {
      nameC.clear();
      phoneC.clear();
      addressC.clear();
      currentPassC.clear();
      newPassC.clear();
    }
  }

  Future<void> load() => loadProfile();

  Future<void> loadProfile() async {
    if (isDisposed) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      reset();
      return;
    }
    if (user.value != null && user.value!.uid != uid) {
      reset();
    }
    isLoading.value = true;
    try {
      final u = await _userRepo.getUser(uid);
      if (isDisposed) return;
      user.value = u;
      if (u != null && !isDisposed) {
        nameC.text = u.name;
        phoneC.text = u.phone;
        addressC.text = u.address;
      }
    } catch (e) {
      if (!isDisposed) {
        AppSnackbar.error('Could not load profile: $e');
      }
    } finally {
      if (!isDisposed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> saveProfile() async {
    if (isClosed) return;
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
      if (isClosed) return;
      await loadProfile();
      if (!isClosed) {
        AppSnackbar.success('Profile updated successfully', title: 'Profile Saved');
      }
    } catch (e) {
      if (!isClosed) {
        AppSnackbar.error('Could not update profile: $e');
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> changePassword(String current, String newPass) async {
    if (isClosed) return;
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
      if (isClosed) return;
      await currentUser.updatePassword(newPass);
      if (!isClosed) {
        currentPassC.clear();
        newPassC.clear();
        AppSnackbar.success('Password changed successfully', title: 'Password Updated');
      }
    } on FirebaseAuthException catch (e) {
      if (!isClosed) {
        String msg;
        switch (e.code) {
          case 'wrong-password': msg = 'Current password is incorrect'; break;
          case 'invalid-credential': msg = 'Email or password is incorrect'; break;
          case 'weak-password': msg = 'New password is too weak'; break;
          case 'requires-recent-login': msg = 'Please log in again and retry'; break;
          default: msg = e.message ?? 'Could not change password';
        }
        AppSnackbar.error(msg);
      }
    } catch (e) {
      if (!isClosed) {
        AppSnackbar.error('Something went wrong: $e');
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> pickAndUploadPhoto(ImageSource source) async {
    if (isClosed) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final file = await _picker.pickImage(source: source, imageQuality: 80);
      if (file == null || isClosed) return;

      isUploadingPhoto.value = true;
      final url = await _cloudinary.uploadImage(file);
      if (isClosed) return;
      await _userRepo.updateUser(uid, {'photoUrl': url});
      if (isClosed) return;

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
      if (!isClosed) {
        AppSnackbar.error('Could not upload photo: $e', title: 'Upload Failed');
      }
    } finally {
      if (!isClosed) {
        isUploadingPhoto.value = false;
      }
    }
  }

  Future<void> removePhoto() async {
    if (isClosed) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      isUploadingPhoto.value = true;
      await _userRepo.updateUser(uid, {'photoUrl': ''});
      if (isClosed) return;

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
      if (!isClosed) {
        AppSnackbar.error('Could not remove photo: $e', title: 'Remove Failed');
      }
    } finally {
      if (!isClosed) {
        isUploadingPhoto.value = false;
      }
    }
  }

  Future<void> logout() async {
    // Clear in-memory state so stale data is not visible during the transition.
    // Do NOT delete this controller here — it is registered as permanent in
    // CustomerShellBinding. Deleting it before Get.offAllNamed causes a
    // "ProfileController not found" crash because IndexedStack still holds
    // ProfileView in its widget tree during the outgoing frame.
    // GetX disposes permanent controllers automatically once the shell route
    // is removed from the navigation stack by offAllNamed.
    reset();
    await Get.find<AuthService>().logout();
  }
}
