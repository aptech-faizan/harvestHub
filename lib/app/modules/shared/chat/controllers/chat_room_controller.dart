import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/data/models/chat_message.dart';
import 'package:harvest_hub/app/data/repositories/chat_repository.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';

/// Arguments used to open a conversation.
class ChatRoomArgs {
  final String chatId;
  final String peerId;
  final String peerName;
  final String myRole;

  const ChatRoomArgs({
    required this.chatId,
    required this.peerId,
    required this.peerName,
    required this.myRole,
  });
}

/// Drives one real-time conversation via a Firestore stream.
class ChatRoomController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final _repo = ChatRepository();

  late final ChatRoomArgs args;

  final messages = <ChatMessage>[].obs;
  final error = ''.obs;
  final isLoading = true.obs;
  final inputC = TextEditingController();

  StreamSubscription<List<ChatMessage>>? _sub;

  String get uid => authService.currentUser?.uid ?? '';
  String get myRole => authService.role.value;
  String get myName => authService.currentUserModel.value?.name ?? '';

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    args = a is ChatRoomArgs ? a : const ChatRoomArgs(chatId: '', peerId: '', peerName: '', myRole: 'customer');
    if (args.chatId.isEmpty) {
      error.value = 'Chat could not be opened.';
      isLoading.value = false;
      return;
    }
    _subscribe();
    markRead();
  }

  @override
  void onClose() {
    // The room is pushed as a route, so this controller is created and disposed
    // repeatedly. Without cancelling here, each visit would leak an open
    // Firestore stream.
    _sub?.cancel();
    inputC.dispose();
    super.onClose();
  }

  void _subscribe() {
    _sub?.cancel();
    _sub = _repo.watchMessages(args.chatId).listen(
      (list) {
        messages.assignAll(list);
        isLoading.value = false;
        error.value = '';
      },
      onError: (Object _) {
        isLoading.value = false;
        // Almost always an undeployed/restrictive firestore.rules.
        error.value =
            'Could not load messages. Check that Firestore rules are deployed.';
      },
    );
  }

  Future<void> markRead() async {
    if (args.chatId.isEmpty) return;
    try {
      await _repo.markRead(args.chatId, myRole);
    } catch (_) {
      // A failed read receipt must never break the conversation.
    }
  }

  Future<void> send() async {
    final text = inputC.text.trim();
    if (text.isEmpty) return;
    inputC.clear();
    try {
      await _repo.sendMessage(
        chatId: args.chatId,
        text: text,
        senderId: uid,
        senderName: myName.isEmpty ? 'Me' : myName,
        senderRole: myRole,
      );
    } catch (e) {
      // Put the text back so the message is not silently lost.
      inputC.text = text;
      error.value = 'Message not sent: $e';
    }
  }
}
