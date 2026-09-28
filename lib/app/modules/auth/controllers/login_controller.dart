import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();

  // Initialized directly as fields — no manual disposal needed.
  // fenix: true in LoginBinding guarantees a brand-new LoginController
  // (and therefore brand-new TextEditingControllers) every time the
  // Login route is mounted. The GC reclaims them when the controller
  // is collected; explicit .dispose() calls cause the crash because
  // Flutter's TextField can still hold a reference at that point.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool hidePassword = true.obs;

  void togglePasswordVisibility() {
    hidePassword.toggle();
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication failed: ${e.code}';
    }
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final role = await authService.login(
        emailController.text.trim(),
        passwordController.text,
      );
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
