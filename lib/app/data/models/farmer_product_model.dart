import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a farm product listed by a farmer.
class FarmerProduct {
  final String id;
  final String farmerId;
  String farmerName;   // from farmers/{uid}.businessName
  String name;
  String category;
  String categoryId;   // e.g. 'vegetables'
  String marketId;
  String marketName;
  double lat;
  double lng;
  double pricePerUnit;
  String unit; // e.g., kg, dozen, litre
  int stockQty;
  String description;
  String imageUrl; // always a String; "" when no image (never null)
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  FarmerProduct({
    required this.id,
    required this.farmerId,
    this.farmerName = '',
    required this.name,
    required this.category,
    this.categoryId = '',
    this.marketId = '',
    this.marketName = '',
    this.lat = 0.0,
    this.lng = 0.0,
    required this.pricePerUnit,
    required this.unit,
    required this.stockQty,
    required this.description,
    String? imageUrl,
    bool? isActive,
    required this.createdAt,
    required this.updatedAt,
  })  : imageUrl = imageUrl ?? '',
        isActive = isActive ?? (stockQty > 0);

  /// Business rule: out-of-stock when stockQty == 0
  bool get isOutOfStock => stockQty == 0;

  /// Returns the display label for stock status
  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (stockQty <= 5) return 'Low Stock';
    return 'In Stock';
  }

  // ── Firestore serialisation ────────────────────────────────────────────────

  /// Creates a [FarmerProduct] from a Firestore document snapshot.
  /// Handles both [Timestamp] (Firestore) and ISO [String] (mock) timestamps.
  factory FarmerProduct.fromMap(Map<String, dynamic> map, String docId) {
    return FarmerProduct(
      id: docId,
      farmerId: map['farmerId'] as String? ?? '',
      farmerName: map['farmerName'] as String? ?? '',
      name: map['itemName'] as String? ?? map['name'] as String? ?? '',
      category:
          map['categoryName'] as String? ?? map['category'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      marketId: map['marketId'] as String? ?? '',
      marketName: map['marketName'] as String? ?? '',
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      pricePerUnit: (map['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] as String? ?? 'kg',
      stockQty: (map['stockQty'] as num?)?.toInt() ?? 0,
      description: map['description'] as String? ?? '',
      // imageUrl must always be a String, never null
      imageUrl: map['imageUrl'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  /// Serialises this product for writing to Firestore.
  /// Uses the FIXED customer-facing schema field names.
  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'itemName': name,
      'itemNameLower': name.toLowerCase(),
      'description': description,
      'categoryId': categoryId,
      'categoryName': category,
      'marketId': marketId,
      'marketName': marketName,
      'lat': lat,
      'lng': lng,
      'pricePerUnit': pricePerUnit,
      'unit': unit,
      'stockQty': stockQty,
      // imageUrl is always a String – never null
      'imageUrl': imageUrl.isEmpty ? '' : imageUrl,
      'isActive': isActive,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Deep-copy helper used when editing
  FarmerProduct copyWith({
    String? farmerName,
    String? name,
    String? category,
    String? categoryId,
    String? marketId,
    String? marketName,
    double? lat,
    double? lng,
    double? pricePerUnit,
    String? unit,
    int? stockQty,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) {
    final newQty = stockQty ?? this.stockQty;
    return FarmerProduct(
      id: id,
      farmerId: farmerId,
      farmerName: farmerName ?? this.farmerName,
      name: name ?? this.name,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      marketId: marketId ?? this.marketId,
      marketName: marketName ?? this.marketName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      unit: unit ?? this.unit,
      stockQty: newQty,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? (newQty > 0),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
