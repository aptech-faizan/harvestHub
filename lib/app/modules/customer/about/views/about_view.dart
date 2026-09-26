import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/about_controller.dart';

// View displaying HarvestHub mission, story, and values
class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  // Builds the static About Us presentation UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(Icons.eco, size: 64, color: Colors.green),
                  const SizedBox(height: 12),
                  const Text(
                    'HarvestHub',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Fresh from Farms, Direct to You',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Our Purpose & Objective',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'HarvestHub is designed to directly bridge the gap between local hardworking farmers and conscious consumers. Our mission is to eliminate middlemen, ensuring fair returns for producers while providing families with 100% fresh, locally grown farm produce.',
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            const Text(
              'By facilitating direct connections, schedule-based pickup slots, and transparent pricing, we strengthen local agricultural communities and foster sustainable farm-to-table access for everyone.',
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why HarvestHub?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text('• Direct farmer-to-consumer relationship'),
                    SizedBox(height: 4),
                    Text('• Freshness guaranteed without long storage'),
                    SizedBox(height: 4),
                    Text('• Support local farmers and local economy'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
