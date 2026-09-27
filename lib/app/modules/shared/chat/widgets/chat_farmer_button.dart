import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/shared/chat/controllers/chat_inbox_controller.dart';

/// "Chat with farmer" action.
///
/// Creates the conversation on first tap and then opens the room, so the same
/// button works from the product page, farmer page, market sheet and the
/// followed-farmers list without any of them knowing about chat ids.
class ChatFarmerButton extends StatelessWidget {
  final String farmerId;
  final String farmerName;
  final bool compact;
  final String label;

  const ChatFarmerButton({
    super.key,
    required this.farmerId,
    required this.farmerName,
    this.compact = false,
    this.label = 'Chat with Farmer',
  });

  @override
  Widget build(BuildContext context) {
    if (farmerId.isEmpty) return const SizedBox.shrink();
    final inbox = Get.isRegistered<ChatInboxController>()
        ? Get.find<ChatInboxController>()
        : Get.put(ChatInboxController(), permanent: true);

    return compact
        ? IconButton(
            tooltip: 'Chat',
            onPressed: () => inbox.openWith(farmerId, farmerName),
            icon: const Icon(Icons.chat_bubble_outline),
          )
        : OutlinedButton.icon(
            onPressed: () => inbox.openWith(farmerId, farmerName),
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(label),
          );
  }
}
