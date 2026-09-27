import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import '../controllers/chat_room_controller.dart';

/// One real-time conversation.
class ChatRoomView extends GetView<ChatRoomController> {
  const ChatRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final peer = controller.args.peerName;
    final myRole = controller.args.myRole;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(peer.isEmpty ? 'Chat' : peer),
            Text(
              myRole == 'farmer' ? 'Customer' : 'Farmer',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.error.value.isNotEmpty &&
                  controller.messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(controller.error.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent)),
                  ),
                );
              }
              final messages = controller.messages;
              if (messages.isEmpty) {
                return const Center(
                  child: Text('No messages yet.\nSay hello!',
                      textAlign: TextAlign.center),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  final mine = m.senderId == controller.uid;
                  return Align(
                    alignment:
                        mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78,
                      ),
                      decoration: BoxDecoration(
                        color: mine
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(mine ? 16 : 4),
                          bottomRight: Radius.circular(mine ? 4 : 16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.text,
                            style: TextStyle(
                              color: mine
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatDate(m.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: mine
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withValues(alpha: 0.7)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.inputC,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => controller.send(),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: controller.send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
