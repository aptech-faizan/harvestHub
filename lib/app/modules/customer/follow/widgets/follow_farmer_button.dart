import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/customer/follow/controllers/follow_controller.dart';

/// Follow / unfollow toggle for a farmer.
///
/// Registered globally, so every instance on screen shares one subscription and
/// unfollowing on the farmer page immediately updates the button on the product
/// page behind it.
class FollowFarmerButton extends StatelessWidget {
  final String farmerId;
  final String farmerName;
  final bool compact;

  const FollowFarmerButton({
    super.key,
    required this.farmerId,
    this.farmerName = '',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final follow = FollowController.instance;
    if (farmerId.isEmpty) return const SizedBox.shrink();

    return Obx(() {
      final following = follow.isFollowing(farmerId);
      return compact
          ? IconButton(
              tooltip: following ? 'Unfollow' : 'Follow',
              onPressed: () => follow.toggle(farmerId, farmerName: farmerName),
              icon: Icon(
                following ? Icons.notifications_active : Icons.notifications_none,
                color: following ? Colors.green : null,
              ),
            )
          : ElevatedButton.icon(
              style: following
                  ? ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    )
                  : null,
              onPressed: () => follow.toggle(farmerId, farmerName: farmerName),
              icon: Icon(following ? Icons.check : Icons.person_add),
              label: Text(following ? 'Following' : 'Follow'),
            );
    });
  }
}
