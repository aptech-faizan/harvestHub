// Ye farmer ka business profile model hai
class FarmerModel {
  final String id;
  final String userId;
  final String marketId;
  final String businessName;
  final String description;
  final double rating;
  final int lowStockThreshold;

  // Constructor
  FarmerModel({
    required this.id,
    this.userId = '',
    this.marketId = '',
    required this.businessName,
    this.description = '',
    this.rating = 0.0,
    this.lowStockThreshold = 5,
  });

  // Map se FarmerModel banane ke liye
  factory FarmerModel.fromMap(Map<String, dynamic> map, String id) {
    return FarmerModel(
      id: id,
      userId: map['userId'] ?? '',
      marketId: map['marketId'] ?? '',
      businessName: map['businessName'] ?? '',
      description: map['description'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      lowStockThreshold: (map['lowStockThreshold'] ?? 5).toInt(),
    );
  }

  // Model ko Map mein convert karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'marketId': marketId,
      'businessName': businessName,
      'description': description,
      'rating': rating,
      'lowStockThreshold': lowStockThreshold,
    };
  }
}
