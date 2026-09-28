import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_snackbar.dart';

// Controller managing contact details, feedback form inputs, and Firestore submission
class ContactController extends GetxController {
  final nameController = TextEditingController();
  final messageController = TextEditingController();
  final RxBool isSubmitting = false.obs;

  // Initializes form with current user's name if logged in
  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && (user.displayName?.isNotEmpty ?? false)) {
      nameController.text = user.displayName!;
    }
  }

  // Disposes text editing controllers on controller teardown
  @override
  void onClose() {
    nameController.dispose();
    messageController.dispose();
    super.onClose();
  }

  // Submits user feedback to Firestore 'feedback' collection
  Future<void> submitFeedback() async {
    final name = nameController.text.trim();
    final message = messageController.text.trim();

    if (name.isEmpty || message.isEmpty) {
      AppSnackbar.warning('Please enter your name and message', title: 'Required Fields');
      return;
    }

    isSubmitting.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('feedback').add({
        'userId': user?.uid ?? 'guest',
        'name': name,
        'message': message,
        'createdAt': Timestamp.now(),
      });

      messageController.clear();
      AppSnackbar.success('Thank you for your feedback');
    } catch (e) {
      AppSnackbar.error('Failed to send feedback: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}
