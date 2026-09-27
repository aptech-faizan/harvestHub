import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import '../controllers/chat_inbox_controller.dart';
import '../controllers/chat_room_controller.dart' show ChatRoomArgs;

/// Conversation list, shared by customers and farmers.
class ChatInboxView extends GetView<ChatInboxController> {
  const ChatInboxView({super.key});

  @override
  Widget build(BuildContext context) {
    final role = controller.role;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(onPressed: controller.listen, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 42, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(controller.error.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.listen,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final chats = controller.chats;
        if (chats.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                role == 'farmer'
                    ? 'No customer conversations yet.\nThey will appear here '
                        'once a customer messages you.'
                    : 'No conversations yet.\nTap "Chat with Farmer" on a '
                        'farmer, product or market to start one.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final c = chats[i];
            final unread = c.hasUnreadFor(role);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  role == 'farmer' ? Icons.person : Icons.agriculture,
                  color: Colors.white,
                ),
              ),
              title: Text(
                c.peerName(role),
                style: TextStyle(fontWeight: unread ? FontWeight.bold : null),
              ),
              subtitle: Text(
                c.lastMessage.isEmpty ? 'No messages yet' : c.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (c.lastMessageAt != null)
                    Text(formatDate(c.lastMessageAt),
                        style: const TextStyle(fontSize: 10)),
                  if (unread)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'New',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                controller.markRead(c.id);
                Get.toNamed(
                  Routes.chatRoom,
                  arguments: ChatRoomArgs(
                    chatId: c.id,
                    peerId: c.peerId(role),
                    peerName: c.peerName(role),
                    myRole: role,
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}
