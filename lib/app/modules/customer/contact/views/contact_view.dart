import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contact_controller.dart';

// View rendering contact support information and customer feedback submission form
class ContactView extends GetView<ContactController> {
  const ContactView({super.key});

  // Builds contact info cards and interactive feedback form
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us & Feedback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Contact Information Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get in Touch',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, color: Colors.green, size: 20),
                        SizedBox(width: 10),
                        Text('support@harvesthub.com', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, color: Colors.green, size: 20),
                        SizedBox(width: 10),
                        Text('+92 300 1234567', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.green, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'HarvestHub Farm Support Center, Karachi, Pakistan',
                            style: TextStyle(fontSize: 14),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your Feedback / Message',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
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
    );
  }
}
