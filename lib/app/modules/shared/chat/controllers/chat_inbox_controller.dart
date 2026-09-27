import 'dart:async';

import 'package:get/get.dart';
import 'package:harvest_hub/app/data/models/chat_message.dart';
import 'package:harvest_hub/app/data/repositories/chat_repository.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/routes/app_routes.dart';
import 'chat_room_controller.dart' show ChatRoomArgs;

/// Conversation list for whichever role is signed in.
///
/// One controller serves both sides: the role comes from [AuthService], so a
/// farmer and a customer see the same screen filtered to their own side.
class ChatInboxController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final _repo = ChatRepository();

  final chats = <ChatSummary>[].obs;
  final error = ''.obs;
  final isLoading = true.obs;

  StreamSubscription<List<ChatSummary>>? _sub;

  String get uid => authService.currentUser?.uid ?? '';
  String get role => authService.role.value;

  int get unreadCount => chats.where((c) => c.hasUnreadFor(role)).length;

  @override
  void onInit() {
    super.onInit();
    listen();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void listen() {
    _sub?.cancel();
    error.value = '';
    isLoading.value = true;

    if (uid.isEmpty) {
      isLoading.value = false;
      return;
    }
    _sub = _repo.watchInbox(uid, role).listen(
      (list) {
        chats.assignAll(list);
        isLoading.value = false;
      },
      onError: (Object _) {
        isLoading.value = false;
        error.value =
            'Could not load your chats. Check that Firestore rules are deployed.';
      },
    );
  }

  /// Opens a conversation, creating it on first use.
  Future<void> openWith(String peerId, String peerName) async {
    if (uid.isEmpty) return;
    if (role == 'farmer') {
      // A farmer always opens the customer -> farmer conversation.
      final id = _repo.chatIdFor(peerId, uid);
      await _repo.ensureChat(
        customerId: peerId,
        farmerId: uid,
        customerName: peerName,
      );
      Get.toNamed(Routes.chatRoom,
          arguments: ChatRoomArgs(
            chatId: id,
            peerId: peerId,
            peerName: peerName,
            myRole: role,
          ));
    } else {
      final id = await _repo.ensureChat(
        customerId: uid,
        farmerId: peerId,
        customerName: myName,
        farmerName: peerName,
      );
      Get.toNamed(Routes.chatRoom,
          arguments: ChatRoomArgs(
            chatId: id,
            peerId: peerId,
            peerName: peerName,
            myRole: role,
          ));
    }
  }

  String get myName => authService.currentUserModel.value?.name ?? '';

  Future<void> markRead(String chatId) async {
    try {
      await _repo.markRead(chatId, role);
    } catch (_) {
      // A failed read receipt must never block opening the conversation.
    }
  }
}
