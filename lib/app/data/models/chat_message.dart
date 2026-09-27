import 'package:cloud_firestore/cloud_firestore.dart';

/// One message inside `chats/{chatId}/messages/{messageId}`.
class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String senderRole;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.createdAt,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ChatMessage(
      id: doc.id,
      text: (d['text'] ?? '').toString(),
      senderId: (d['senderId'] ?? '').toString(),
      senderName: (d['senderName'] ?? '').toString(),
      senderRole: (d['senderRole'] ?? '').toString(),
      createdAt: (d['createdAt'] is Timestamp)
          ? (d['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'text': text,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

/// The `chats/{chatId}` document: one conversation per customer/farmer pair.
class ChatSummary {
  final String id;
  final String customerId;
  final String farmerId;
  final String customerName;
  final String farmerName;
  final String lastMessage;
  final DateTime? lastMessageAt;

  /// Read receipts keyed by role ('customer' / 'farmer').
  final Map<String, DateTime?> lastReadAt;

  const ChatSummary({
    required this.id,
    required this.customerId,
    required this.farmerId,
    this.customerName = '',
    this.farmerName = '',
    this.lastMessage = '',
    this.lastMessageAt,
    this.lastReadAt = const {},
  });

  factory ChatSummary.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final reads = <String, DateTime?>{};
    for (final entry in {'customer': 'customerLastReadAt', 'farmer': 'farmerLastReadAt'}.entries) {
      final v = d[entry.value];
      reads[entry.key] = v is Timestamp ? v.toDate() : null;
    }
    return ChatSummary(
      id: doc.id,
      customerId: (d['customerId'] ?? '').toString(),
      farmerId: (d['farmerId'] ?? '').toString(),
      customerName: (d['customerName'] ?? '').toString(),
      farmerName: (d['farmerName'] ?? '').toString(),
      lastMessage: (d['lastMessage'] ?? '').toString(),
      lastMessageAt: d['lastMessageAt'] is Timestamp
          ? (d['lastMessageAt'] as Timestamp).toDate()
          : null,
      lastReadAt: reads,
    );
  }

  /// The other party, from [myRole]'s point of view.
  String peerName(String myRole) {
    final name = myRole == 'farmer' ? customerName : farmerName;
    return name.isEmpty ? 'Unknown' : name;
  }

  String peerId(String myRole) => myRole == 'farmer' ? customerId : farmerId;

  /// True when the peer has sent a message after my last read receipt.
  bool hasUnreadFor(String myRole) {
    final at = lastMessageAt;
    if (at == null) return false;
    final read = lastReadAt[myRole];
    if (read == null) return true;
    return at.isAfter(read);
  }

  /// Field name of the read receipt belonging to [myRole].
  static String readFieldFor(String myRole) =>
      myRole == 'farmer' ? 'farmerLastReadAt' : 'customerLastReadAt';
}
