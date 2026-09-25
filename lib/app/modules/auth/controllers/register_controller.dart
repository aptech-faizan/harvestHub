import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';

class RegisterController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();

  /// Role selection: Customer or Farmer only. Public Admin registration is forbidden.
  final RxString selectedRole = Roles.customer.obs;

  final RxBool isLoading = false.obs;
  final RxBool hidePassword = true.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    hidePassword.toggle();
  }

  void setRole(String role) {
    if (role == Roles.customer || role == Roles.farmer) {
      selectedRole.value = role;
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Registration failed: ${e.code}';
    }
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedRole.value != Roles.customer && selectedRole.value != Roles.farmer) {
      showError('Please select a valid role (Customer or Farmer).');
      return;
    }

    isLoading.value = true;
    try {
      final role = await authService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        address: addressController.text.trim(),
        role: selectedRole.value,
      );
      showSuccess('Registration successful!');
      authService.navigateToRoleHome(role);
    } on FirebaseAuthException catch (e) {
      showError(_getAuthErrorMessage(e));
    } catch (e) {
      showError(errorText(e));
    } finally {
      isLoading.value = false;
    }
  }
}
