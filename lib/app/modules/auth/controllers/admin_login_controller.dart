import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';


class AdminLoginController extends GetxController {
  final auth = Get.find<AuthService>();
  final formKey = GlobalKey<FormState>();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final isLoading = false.obs;
  final hidePassword = true.obs;

  @override
  void onReady() {
    super.onReady();
    _skipLoginIfAlreadySignedIn();
  }

  // If the admin is still signed in from before, go straight to the dashboard.
  Future<void> _skipLoginIfAlreadySignedIn() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    try {
      if (await auth.loadRole()) Get.offAllNamed(Routes.adminDashboard);
    } catch (_) {
      // stay on login page
    }
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await auth.loginAdmin(emailC.text.trim(), passC.text);
      Get.offAllNamed(Routes.adminDashboard);
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? 'Login failed');
    } catch (e) {
      showError(errorText(e));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailC.dispose();
    passC.dispose();
    super.onClose();
  }
}
