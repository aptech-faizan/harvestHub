// TODO: teammate ke version se replace karna
// Ye product ka data model hai
class ProductModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String itemName;
  final double pricePerUnit;
  final String unit;
  final int stockQty;
  final String imageUrl;
  final String description;
  final String categoryId;
  final String categoryName;
  final String marketId;
  final String marketName;
  final double lat;
  final double lng;
  final String itemNameLower;
  final bool isActive;

  // Constructor
  ProductModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.itemName,
    required this.pricePerUnit,
    required this.unit,
    required this.stockQty,
    required this.imageUrl,
    this.description = '',
    this.categoryId = '',
    this.categoryName = '',
    this.marketId = '',
    this.marketName = '',
    this.lat = 0.0,
    this.lng = 0.0,
    this.itemNameLower = '',
    this.isActive = true,
  });

  // Map se ProductModel banane ke liye
  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      itemName: map['itemName'] ?? '',
      pricePerUnit: (map['pricePerUnit'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      stockQty: (map['stockQty'] ?? 0).toInt(),
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      marketId: map['marketId'] ?? '',
      marketName: map['marketName'] ?? '',
      lat: (map['lat'] ?? 0).toDouble(),
      lng: (map['lng'] ?? 0).toDouble(),
      itemNameLower: map['itemNameLower'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  // Model ko Map mein convert karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'itemName': itemName,
      'pricePerUnit': pricePerUnit,
      'unit': unit,
      'stockQty': stockQty,
      'imageUrl': imageUrl,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'marketId': marketId,
      'marketName': marketName,
      'lat': lat,
      'lng': lng,
      'itemNameLower': itemNameLower,
      'isActive': isActive,
    };
  }
}
