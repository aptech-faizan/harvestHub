import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';

class OrderItem {
  final String productId;
  final String itemName;
  final int quantity;
  final double price;
  final String unit;

  OrderItem({
    required this.productId,
    required this.itemName,
    required this.quantity,
    required this.price,
    this.unit = '',
  });

  // Maps Firestore item map to OrderItem
  factory OrderItem.fromMap(Map<String, dynamic> m) {
    return OrderItem(
      productId: (m['productId'] ?? '').toString(),
      itemName: (m['name'] ?? m['itemName'] ?? '').toString(),
      quantity: readInt(m['quantity'] ?? m['qty']),
      price: readDouble(m['price'] ?? m['pricePerUnit']),
      unit: (m['unit'] ?? '').toString(),
    );
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String farmerId;
  final String farmerName;
  final String deliveryAddress;
  final List<OrderItem> items;
  final String pickupSlot;
  final String status;
  final double totalPrice;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.farmerId,
    this.farmerName = '',
    this.deliveryAddress = '',
    required this.items,
    required this.pickupSlot,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
  });

  // Creates OrderModel from Firestore document snapshot
  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final rawItems = d['items'];
    final items = rawItems is List
        ? rawItems.map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map))).toList()
        : <OrderItem>[];
    final slot = d['pickupSlotTime'] ?? d['pickupSlotId'] ?? d['pickupSlot'];
    final rawStatus = (d['status'] ?? 'pending').toString().toLowerCase().trim();
    final status = rawStatus == 'ready for pickup' ? 'ready_for_pickup' : rawStatus;
    return OrderModel(
      id: doc.id,
      customerId: (d['customerId'] ?? '').toString(),
      farmerId: (d['farmerId'] ?? '').toString(),
      farmerName: (d['farmerName'] ?? '').toString(),
      deliveryAddress: (d['deliveryAddress'] ?? '').toString(),
      items: items,
      pickupSlot: slot is Timestamp ? formatDate(slot.toDate()) : (slot ?? '').toString(),
      status: status,
      totalPrice: readDouble(d['totalPrice']),
      createdAt: readDate(d['createdAt']),
    );
  }
}
