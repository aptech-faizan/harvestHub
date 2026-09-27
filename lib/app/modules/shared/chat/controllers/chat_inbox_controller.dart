import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
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
  Worker? _userWorker;
  Worker? _roleWorker;

  /// Last (uid, role) the stream was built for, so a rebuild is skipped unless
  /// the signed-in account actually changed.
  String _streamKey = '';

  String get uid => authService.currentUser?.uid ?? '';
  String get role => authService.role.value;

  int get unreadCount => chats.where((c) => c.hasUnreadFor(role)).length;

  @override
  void onInit() {
    super.onInit();

    // This controller is permanent, so it is constructed at app start - before
    // the splash screen has resolved who is signed in. At that point `uid` may
    // be empty AND `role` is still '', so a one-shot listen() queried the wrong
    // field: with role == '' the repository fell through to the customer branch
    // and a farmer ended up querying `customerId == <farmer uid>`, which never
    // matches. That is why only the farmer inbox appeared broken.
    //
    // Both inputs are therefore watched, and the stream is only built once a
    // uid and a real role are both known.
    _userWorker = ever(authService.firebaseUser, (_) => listen());
    _roleWorker = ever(authService.role, (_) => listen());
    listen();
  }

  @override
  void onClose() {
    _userWorker?.dispose();
    _roleWorker?.dispose();
    _sub?.cancel();
    super.onClose();
  }

  /// (Re)builds the inbox stream for the currently signed-in account.
  void listen() {
    final id = uid;
    final myRole = role;

    // Wait until we actually know who is signed in and as what. Without this,
    // an early call queries with role == '' and silently picks the wrong field.
    if (id.isEmpty || (myRole != Roles.farmer && myRole != Roles.customer)) {
      _sub?.cancel();
      _sub = null;
      _streamKey = '';
      chats.clear();
      isLoading.value = false;
      return;
    }

    final key = '$id:$myRole';
    if (_streamKey == key && _sub != null) return; // already correct
    _streamKey = key;

    _sub?.cancel();
    error.value = '';
    isLoading.value = true;

    _sub = _repo.watchInbox(id, myRole).listen(
      (list) {
        chats.assignAll(list);
        isLoading.value = false;
      },
      onError: (Object e, StackTrace _) {
        isLoading.value = false;
        debugPrint('ChatInbox stream error for $key: $e');
        // A missing composite index and a denied query both land here, and they
        // have completely different fixes, so name the likely cause rather than
        // hiding the error.
        final text = '$e';
        error.value = text.contains('index')
            ? 'This query needs a Firestore index. Run: '
                'firebase deploy --only firestore:indexes'
            : 'Could not load your chats. Check that Firestore rules are '
                'deployed. ($text)';
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
