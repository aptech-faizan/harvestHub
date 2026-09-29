import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/theme/app_colors.dart';
import '../controllers/contact_controller.dart';
import 'package:harvest_hub/app/core/utils/validators.dart';

// View rendering contact support information and customer feedback submission form
class ContactView extends GetView<ContactController> {
  const ContactView({super.key});

  // Builds contact info cards and interactive feedback form
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Matches every other pushed Customer Module screen (profile, personal
      // info, change password, followed farmers) - they sit on surfaceMuted so
      // the white cards read as raised surfaces.
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        title: const Text('Contact Us & Feedback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Contact Information Card
            Card(
              // White fill + hairline divider, matching AppCard's surface
              // treatment. Default elevation 0 so the border, not a shadow,
              // defines the card edge.
              color: AppColors.surfaceWhite,
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.divider),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get in Touch',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'support@harvesthub.com',
                          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
                        SizedBox(width: 10),
                        Text(
                          '+92 300 1234567',
                          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'HarvestHub Farm Support Center, Karachi, Pakistan',
                            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Send us your Feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              textInputAction: TextInputAction.next,
              validator: AppValidators.name(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller.messageController,
              maxLines: 4,
              minLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your Feedback / Message',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: AppValidators.text(
                minLength: 10,
                label: 'Feedback message',
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => ElevatedButton.icon(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.submitFeedback(),
                  icon: controller.isSubmitting.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(controller.isSubmitting.value ? 'Submitting...' : 'Submit Feedback'),
                )),
            ],
          ),
        ),
      ),
    );
  }
}

