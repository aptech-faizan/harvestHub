/// Model representing a farm product listed by a farmer.
class FarmerProduct {
  final String id;
  final String farmerId;
  String name;
  String category;
  double pricePerUnit;
  String unit; // e.g., kg, dozen, piece
  int stockQty;
  String description;
  String? imageUrl; // null means no image yet
  DateTime createdAt;
  DateTime updatedAt;

  FarmerProduct({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.category,
    required this.pricePerUnit,
    required this.unit,
    required this.stockQty,
    required this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Business rule: out-of-stock when stockQty == 0
  bool get isOutOfStock => stockQty == 0;

  /// Returns the display label for stock status
  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (stockQty <= 5) return 'Low Stock';
    return 'In Stock';
  }

  // ── Firestore serialisation ────────────────────────────────────────────────

  factory FarmerProduct.fromMap(Map<String, dynamic> map, String docId) {
    return FarmerProduct(
      id: docId,
      farmerId: map['farmerId'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      pricePerUnit: (map['pricePerUnit'] as num).toDouble(),
      unit: map['unit'] as String,
      stockQty: (map['stockQty'] as num).toInt(),
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'name': name,
      'category': category,
      'pricePerUnit': pricePerUnit,
      'unit': unit,
      'stockQty': stockQty,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Deep-copy helper used when editing
  FarmerProduct copyWith({
    String? name,
    String? category,
    double? pricePerUnit,
    String? unit,
    int? stockQty,
    String? description,
    String? imageUrl,
  }) {
    return FarmerProduct(
      id: id,
      farmerId: farmerId,
      name: name ?? this.name,
      category: category ?? this.category,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      unit: unit ?? this.unit,
      stockQty: stockQty ?? this.stockQty,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
