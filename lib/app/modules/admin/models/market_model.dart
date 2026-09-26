import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';

class MarketModel {
  final String id;
  final String marketName;
  final String address;
  final double latitude;
  final double longitude;
  final String operatingHours;
  final bool activeStatus;

  MarketModel({
    required this.id,
    required this.marketName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.operatingHours,
    required this.activeStatus,
  });

  bool get hasCoordinates => latitude != 0.0 || longitude != 0.0;

  factory MarketModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final coords = readLatLng(d);
    return MarketModel(
      id: doc.id,
      marketName: readString(d, ['marketName', 'Market_Name']),
      address: readString(d, ['address', 'Address']),
      latitude: coords.lat,
      longitude: coords.lng,
      operatingHours: readString(d, ['operatingHours', 'Operating_Hours']),
      activeStatus: readBool(d['isActive'] ?? d['activeStatus'] ?? d['Active_Status']),
    );
  }

  Map<String, dynamic> toWriteMap() {
    return {
      'marketName': marketName,
      'address': address,
      'lat': latitude,
      'lng': longitude,
      'gpsCoordinates': GeoPoint(latitude, longitude),
      'operatingHours': operatingHours,
      'isActive': activeStatus,
    };
  }
}
