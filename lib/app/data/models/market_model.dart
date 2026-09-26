import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';

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

  bool get hasCoordinates => lat != 0.0 || lng != 0.0;

  GeoPoint get gpsCoordinates => GeoPoint(lat, lng);

  // Map se MarketModel banane ke liye
  factory MarketModel.fromMap(Map<String, dynamic> map, String id) {
    final coords = readLatLng(map);
    return MarketModel(
      id: id,
      marketName: readString(map, ['marketName', 'Market_Name']),
      address: readString(map, ['address', 'Address']),
      lat: coords.lat,
      lng: coords.lng,
      operatingHours: readString(map, ['operatingHours', 'Operating_Hours']),
      isActive: readBool(map['isActive'] ?? map['activeStatus'] ?? map['Active_Status']),
    );
  }

  // Model ko Map mein convert karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'marketName': marketName,
      'address': address,
      'lat': lat,
      'lng': lng,
      'gpsCoordinates': GeoPoint(lat, lng),
      'operatingHours': operatingHours,
      'isActive': isActive,
    };
  }
}
