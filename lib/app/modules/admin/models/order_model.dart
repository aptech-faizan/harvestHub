import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';

class OrderItem {
  final String productId;
  final String itemName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> m) {
    return OrderItem(
      productId: (m['productId'] ?? '').toString(),
      itemName: (m['itemName'] ?? m['name'] ?? '').toString(),
      quantity: readInt(m['quantity']),
      price: readDouble(m['pricePerUnit'] ?? m['price']),
    );
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String farmerId;
  final List<OrderItem> items;
  final String pickupSlot;
  final String status;
  final double totalPrice;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.farmerId,
    required this.items,
    required this.pickupSlot,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
  });

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final rawItems = d['items'];
    final items = rawItems is List
        ? rawItems.map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map))).toList()
        : <OrderItem>[];
    final slot = d['pickupSlot'];
    return OrderModel(
      id: doc.id,
      customerId: (d['customerId'] ?? '').toString(),
      farmerId: (d['farmerId'] ?? '').toString(),
      items: items,
      pickupSlot: slot is Timestamp ? formatDate(slot.toDate()) : (slot ?? '').toString(),
      status: (d['status'] ?? 'Pending').toString(),
      totalPrice: readDouble(d['totalPrice']),
      createdAt: readDate(d['createdAt']),
    );
  }
}
