/// Farmer profile document stored at farmers/{uid}.
///
/// Firestore schema:
///   userId           – String (same as doc id)
///   businessName     – String
///   description      – String
///   marketId         – String
///   rating           – number
///   lowStockThreshold – number
///
/// users/{uid} (owned by Auth team):
///   displayName / name – String
///   phone              – String
class FarmerProfile {
  final String userId;
  String businessName;
  String description;
  String marketId;
  double rating;
  int lowStockThreshold;

  // From users/{uid} – read-only here, edited by auth team
  String displayName;
  String phone;

  FarmerProfile({
    required this.userId,
    this.businessName = '',
    this.description = '',
    this.marketId = '',
    this.rating = 0.0,
    this.lowStockThreshold = 5,
    this.displayName = '',
    this.phone = '',
  });

  factory FarmerProfile.fromMap(Map<String, dynamic> map, String uid) {
    return FarmerProfile(
      userId: uid,
      businessName: map['businessName'] as String? ?? '',
      description: map['description'] as String? ?? '',
      marketId: map['marketId'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      lowStockThreshold:
          (map['lowStockThreshold'] as num?)?.toInt() ?? 5,
    );
  }

  /// Serialises for set-with-merge writes.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'businessName': businessName,
      'description': description,
      'marketId': marketId,
      'lowStockThreshold': lowStockThreshold,
      // rating is managed externally; never overwrite here
    };
  }
}

/// A market entry read from the markets collection.
class MarketInfo {
  final String id;
  final String name;
  final double lat;
  final double lng;

  const MarketInfo({
    required this.id,
    required this.name,
    this.lat = 0.0,
    this.lng = 0.0,
  });

  factory MarketInfo.fromMap(Map<String, dynamic> map, String docId) {
    return MarketInfo(
      id: docId,
      name: map['name'] as String? ?? map['marketName'] as String? ?? '',
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
