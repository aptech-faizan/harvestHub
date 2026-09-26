import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';
import 'package:harvest_hub/app/modules/admin/models/user_model.dart';

// A document from "farmers" combined with the owner's "users" document.
class FarmerModel {
  final String id; // same as the user's uid
  final String userId;
  final String marketId;
  final String marketName;
  final String businessName;
  final String description;
  final double rating;
  final int lowStockThreshold;
  final String ownerName;
  final String email;
  final String phone;
  final bool isActive;

  FarmerModel({
    required this.id,
    required this.userId,
    required this.marketId,
    this.marketName = '',
    required this.businessName,
    required this.description,
    required this.rating,
    this.lowStockThreshold = 5,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.isActive,
  });

  // Creates FarmerModel from Firestore document snapshot and joined user
  factory FarmerModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc, UserModel? user) {
    final d = doc.data() ?? {};
    return FarmerModel(
      id: doc.id,
      userId: (d['userId'] ?? doc.id).toString(),
      marketId: (d['marketId'] ?? '').toString(),
      marketName: (d['marketName'] ?? '').toString(),
      businessName: (d['businessName'] ?? '').toString(),
      description: (d['description'] ?? '').toString(),
      rating: readDouble(d['rating']),
      lowStockThreshold: readInt(d['lowStockThreshold'] ?? 5),
      ownerName: user?.name ?? '',
      email: user?.email ?? '',
      phone: user?.phone ?? '',
      isActive: user?.isActive ?? true,
    );
  }
}
