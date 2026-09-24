import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../farmer_theme.dart';
import '../controllers/slots_controller.dart';

/// Pickup-slot management screen – placeholder for next sprint.
class SlotsView extends GetView<SlotsController> {
  const SlotsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerColors.background,
      appBar: AppBar(
        backgroundColor: FarmerColors.primary,
        title: const Text('Pickup Slots',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, size: 72, color: FarmerColors.secondary),
              SizedBox(height: 16),
              Text('Coming Soon',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text('Pickup slot scheduling is planned for the next sprint.',
                  textAlign: TextAlign.center,
                  style: FarmerTextStyles.body),
            ],
          ),
        ),
      ),
    );
  }
}
