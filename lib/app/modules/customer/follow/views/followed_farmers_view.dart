import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/data/models/farmer_model.dart';
import 'package:harvest_hub/app/modules/customer/follow/controllers/follow_controller.dart';
import 'package:harvest_hub/app/modules/customer/follow/widgets/follow_farmer_button.dart';
import 'package:harvest_hub/app/modules/shared/chat/widgets/chat_farmer_button.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';

/// Followed ("favourite") farmers, reachable from the customer profile.
///
/// Driven by the single shared [FollowController] subscription, so unfollowing
/// here updates every other follow button immediately.
class FollowedFarmersView extends StatelessWidget {
  const FollowedFarmersView({super.key});

  @override
  Widget build(BuildContext context) {
    final follow = FollowController.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Followed Farmers')),
      body: Obx(() {
        if (follow.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        // Never show an empty list for a failed read - that is indistinguishable
        // from "you follow nobody".
        if (follow.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 42, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    follow.error.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: follow.refreshForCurrentUser,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final farmers = follow.followedFarmers;
        if (farmers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'You have not followed any farmers yet.\n\n'
                'Use the Follow button on a farmer or product page to get '
                'restock alerts when their produce is available again.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: follow.loadFollowedFarmers,
          child: ListView.separated(
            itemCount: farmers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) => _tile(context, farmers[i], follow),
          ),
        );
      }),
    );
  }

  Widget _tile(
      BuildContext context, FarmerModel farmer, FollowController follow) {
    final subtitle = <String>[
      if (farmer.marketName.isNotEmpty) farmer.marketName,
      if (farmer.rating > 0) 'Rated ${farmer.rating.toStringAsFixed(1)}',
    ].join('  •  ');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.agriculture, color: Colors.white),
      ),
      title: Text(farmer.businessName),
      subtitle: Text(subtitle.isEmpty ? 'Followed' : subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChatFarmerButton(
            farmerId: farmer.id.isEmpty ? farmer.userId : farmer.id,
            farmerName: farmer.businessName,
            compact: true,
          ),
          FollowFarmerButton(
            farmerId: farmer.id.isEmpty ? farmer.userId : farmer.id,
            farmerName: farmer.businessName,
            compact: true,
          ),
        ],
      ),
      onTap: () => Get.toNamed(
        Routes.customerFarmerDetails,
        arguments: farmer,
      ),
    );
  }
}
