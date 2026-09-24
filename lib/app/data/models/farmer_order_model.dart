/// Valid order statuses for farmer workflow.
enum OrderStatus {
  pending,
  confirmed,
  readyForPickup,
  completed,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  /// Firestore-safe string value (camelCase)
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.readyForPickup:
        return 'readyForPickup';
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
      orElse: () => OrderStatus.pending,
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
      productId: m['productId'] as String,
      productName: m['productName'] as String,
      pricePerUnit: (m['pricePerUnit'] as num).toDouble(),
      quantity: (m['quantity'] as num).toInt(),
      unit: m['unit'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'pricePerUnit': pricePerUnit,
        'quantity': quantity,
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
    final rawItems = map['items'] as List<dynamic>;
    return FarmerOrder(
      id: docId,
      farmerId: map['farmerId'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String,
      items: rawItems
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      status: OrderStatusX.fromValue(map['status'] as String),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'farmerId': farmerId,
        'customerId': customerId,
        'customerName': customerName,
        'items': items.map((i) => i.toMap()).toList(),
        'status': status.value,
        'totalAmount': totalAmount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'notes': notes,
      };
}
