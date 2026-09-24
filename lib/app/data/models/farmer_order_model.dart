import 'package:cloud_firestore/cloud_firestore.dart';

/// Valid order statuses for farmer workflow.
enum OrderStatus {
  pending,
  confirmed,
  readyForPickup,
  completed,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  /// Firestore snake_case status string value.
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.readyForPickup:
        return 'ready_for_pickup';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  /// Human-readable label shown in UI
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromValue(String v) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == v,
      // Also accept old camelCase values from existing Firestore data
      orElse: () {
        if (v == 'readyForPickup') return OrderStatus.readyForPickup;
        return OrderStatus.pending;
      },
    );
  }
}

/// One line item inside an order.
class OrderItem {
  final String productId;
  final String productName;
  final double pricePerUnit;
  final int quantity;
  final String unit;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.pricePerUnit,
    required this.quantity,
    required this.unit,
  });

  double get subtotal => pricePerUnit * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> m) {
    return OrderItem(
      productId: m['productId'] as String? ?? '',
      productName: m['name'] as String? ?? m['productName'] as String? ?? '',
      pricePerUnit: (m['price'] as num?)?.toDouble() ??
          (m['pricePerUnit'] as num?)?.toDouble() ??
          0.0,
      quantity: (m['qty'] as num?)?.toInt() ??
          (m['quantity'] as num?)?.toInt() ??
          0,
      unit: m['unit'] as String? ?? '',
    );
  }

  /// Serialises using Firestore schema field names: name, price, qty.
  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': productName,
        'price': pricePerUnit,
        'qty': quantity,
        'unit': unit,
      };
}

/// Full order placed by a customer, managed by the farmer.
class FarmerOrder {
  final String id;
  final String farmerId;
  final String customerId;
  final String customerName;
  final List<OrderItem> items;
  OrderStatus status;
  final double totalAmount;
  final DateTime createdAt;
  DateTime updatedAt;
  final String? notes;

  FarmerOrder({
    required this.id,
    required this.farmerId,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory FarmerOrder.fromMap(Map<String, dynamic> map, String docId) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return FarmerOrder(
      id: docId,
      farmerId: map['farmerId'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      items: rawItems
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      status: OrderStatusX.fromValue(map['status'] as String? ?? 'pending'),
      totalAmount: (map['totalPrice'] as num?)?.toDouble() ??
          (map['totalAmount'] as num?)?.toDouble() ??
          0.0,
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
      notes: map['notes'] as String?,
    );
  }

  /// Serialises using Firestore schema field names.
  Map<String, dynamic> toMap() => {
        'farmerId': farmerId,
        'customerId': customerId,
        'customerName': customerName,
        'items': items.map((i) => i.toMap()).toList(),
        'status': status.value,
        'totalPrice': totalAmount,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'notes': notes,
      };

  // ── Private helpers ───────────────────────────────────────────────────────

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
