import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';

// A document from the "users" collection (used for customers).
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return UserModel(
      id: doc.id,
      name: (d['name'] ?? '').toString(),
      email: (d['email'] ?? '').toString(),
      phone: (d['phone'] ?? '').toString(),
      address: (d['address'] ?? '').toString(),
      role: (d['role'] ?? '').toString().toLowerCase(),
      isActive: d['isActive'] ?? true,
      createdAt: readDate(d['createdAt']),
    );
  }
}
