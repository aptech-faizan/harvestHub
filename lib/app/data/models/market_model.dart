// Ye mandi ya market ka data model hai
class MarketModel {
  final String id;
  final String marketName;
  final String address;
  final double lat;
  final double lng;
  final String operatingHours;
  final bool isActive;

  // Constructor
  MarketModel({
    required this.id,
    required this.marketName,
    required this.address,
    this.lat = 0.0,
    this.lng = 0.0,
    this.operatingHours = '',
    this.isActive = true,
  });

  // Map se MarketModel banane ke liye
  factory MarketModel.fromMap(Map<String, dynamic> map, String id) {
    return MarketModel(
      id: id,
      marketName: map['marketName'] ?? '',
      address: map['address'] ?? '',
      lat: (map['lat'] ?? 0).toDouble(),
      lng: (map['lng'] ?? 0).toDouble(),
      operatingHours: map['operatingHours'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  // Model ko Map mein convert karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'marketName': marketName,
      'address': address,
      'lat': lat,
      'lng': lng,
      'operatingHours': operatingHours,
      'isActive': isActive,
    };
  }
}
