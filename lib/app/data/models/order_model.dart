import 'package:cloud_firestore/cloud_firestore.dart';

// Ye customer aur farmer ke order ka data model hai
class OrderModel {
  final String id;
  final String customerId;
  final String farmerId;
  final String farmerName;
  final List<Map<String, dynamic>> items;
  final double totalPrice;
  final String deliveryAddress;
  final String pickupSlotId;
  final String pickupSlotTime;
  final String status;
  final DateTime? createdAt;

  // Constructor
  OrderModel({
    required this.id,
    required this.customerId,
    required this.farmerId,
    required this.farmerName,
    required this.items,
    required this.totalPrice,
    required this.deliveryAddress,
    required this.pickupSlotId,
    required this.pickupSlotTime,
    this.status = 'pending',
    this.createdAt,
  });

  // Check karta hai ke order modify/cancel kiya ja sakta hai ya nahi
  bool get canModify => status == 'pending' || status == 'confirmed';

  // Map se OrderModel banane ke liye
  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final rawItems = map['items'];
    final List<Map<String, dynamic>> parsedItems = [];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          parsedItems.add(Map<String, dynamic>.from(item));
        }
      }
    }

    return OrderModel(
      id: id,
      customerId: map['customerId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      items: parsedItems,
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      deliveryAddress: map['deliveryAddress'] ?? '',
      pickupSlotId: map['pickupSlotId'] ?? '',
      pickupSlotTime: map['pickupSlotTime'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: parseDate(map['createdAt']),
    );
  }

  // Model ko Firestore map format mein convert karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'items': items,
      'totalPrice': totalPrice,
      'deliveryAddress': deliveryAddress,
      'pickupSlotId': pickupSlotId,
      'pickupSlotTime': pickupSlotTime,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
