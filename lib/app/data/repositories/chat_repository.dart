import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

/// Real-time chat between a customer and a farmer.
///
/// Schema:
///   chats/{chatId}                     - one conversation per pair
///   chats/{chatId}/messages/{messageId} - the messages
///
/// [chatIdFor] is deterministic (`customerId_farmerId`), so a pair can never
/// accumulate duplicate conversations no matter how many times either side
/// taps "Chat" - the same id is derived every time.
class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const chats = 'chats';
  static const messages = 'messages';

  String chatIdFor(String customerId, String farmerId) => '${customerId}_$farmerId';

  CollectionReference<Map<String, dynamic>> _chats() =>
      _firestore.collection(chats);

  DocumentReference<Map<String, dynamic>> _chat(String chatId) =>
      _chats().doc(chatId);

  /// Creates the conversation if it does not exist yet, and returns its id.
  ///
  /// Peers join from several places (product page, farmer page, market sheet),
  /// so this must be safe to call repeatedly - `create` with a merge is a no-op
  /// when the document is already there.
  Future<String> ensureChat({
    required String customerId,
    required String farmerId,
    String customerName = '',
    String farmerName = '',
  }) async {
    final id = chatIdFor(customerId, farmerId);
    final ref = _chat(id);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'customerId': customerId,
        'farmerId': farmerId,
        'customerName': customerName,
        'farmerName': farmerName,
        'lastMessage': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Names change over time; keep them current without clobbering anything.
      final patch = <String, dynamic>{};
      if (customerName.isNotEmpty && snap.data()?['customerName'] != customerName) {
        patch['customerName'] = customerName;
      }
      if (farmerName.isNotEmpty && snap.data()?['farmerName'] != farmerName) {
        patch['farmerName'] = farmerName;
      }
      if (patch.isNotEmpty) await ref.update(patch);
    }
    return id;
  }

  /// Appends a message and denormalises it onto the chat document so the inbox
  /// can be rendered without loading every conversation's messages.
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    required String senderName,
    required String senderRole,
  }) async {
    final body = text.trim();
    if (body.isEmpty) return;

    final chatRef = _chat(chatId);
    final msgRef = chatRef.collection(messages).doc();

    // Write the message and the inbox preview together, so the inbox can never
    // show a summary for a message that was not stored.
    final batch = _firestore.batch();
    batch.set(msgRef, {
      'text': body,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(chatRef, {
      'lastMessage': body,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  /// Newest-last stream of the conversation, capped to the most recent page.
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _chat(chatId)
        .collection(messages)
        .orderBy('createdAt', descending: true)
        .limit(_pageSize)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(ChatMessage.fromDoc).toList();
      // Query is newest-first for the limit to work; flip for display.
      return list.reversed.toList();
    });
  }

  /// Marks the conversation as read for [myRole].
  Future<void> markRead(String chatId, String myRole) {
    return _chat(chatId).update({
      ChatSummary.readFieldFor(myRole): FieldValue.serverTimestamp(),
    });
  }

  /// Inbox stream, newest conversation first.
  Stream<List<ChatSummary>> watchInbox(String uid, String role) {
    final field = role == 'farmer' ? 'farmerId' : 'customerId';
    return _chats()
        .where(field, isEqualTo: uid)
        .orderBy('lastMessageAt', descending: true)
        .limit(_pageSize)
        .snapshots()
        .map((snap) => snap.docs.map(ChatSummary.fromDoc).toList());
  }

  static const _pageSize = 50;
}
