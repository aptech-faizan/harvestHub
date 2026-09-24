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

  factory MarketModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return MarketModel(
      id: doc.id,
      marketName: (d['marketName'] ?? '').toString(),
      address: (d['address'] ?? '').toString(),
      latitude: readDouble(d['latitude']),
      longitude: readDouble(d['longitude']),
      operatingHours: (d['operatingHours'] ?? '').toString(),
      activeStatus: d['activeStatus'] ?? true,
    );
  }
}
