// Ye farmer ka business profile model hai
class FarmerModel {
  final String id;
  final String userId;
  final String marketId;
  final String marketName;
  final String businessName;
  final String description;
  final double rating;
  final int lowStockThreshold;
  final bool isVerified;

  // Constructor
  FarmerModel({
    required this.id,
    this.userId = '',
    this.marketId = '',
    this.marketName = '',
    required this.businessName,
    this.description = '',
    this.rating = 0.0,
    this.lowStockThreshold = 5,
    this.isVerified = false,
  });

  // Map se FarmerModel banane ke liye
  factory FarmerModel.fromMap(Map<String, dynamic> map, String id) {
    return FarmerModel(
      id: id,
      userId: (map['userId'] ?? '').toString(),
      marketId: (map['marketId'] ?? '').toString(),
      marketName: (map['marketName'] ?? '').toString(),
      businessName: (map['businessName'] ?? '').toString(),
      description: (map['description'] ?? map['bio'] ?? map['farmStory'] ?? '').toString(),
      rating: (map['rating'] ?? 0).toDouble(),
      lowStockThreshold: (map['lowStockThreshold'] ?? 5).toInt(),
      isVerified: map['isVerified'] == true,
    );
  }

  // Model ko Map mein convert karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'marketId': marketId,
      'marketName': marketName,
      'businessName': businessName,
      'description': description,
      'rating': rating,
      'lowStockThreshold': lowStockThreshold,
    };
  }
}
