import 'package:cloud_firestore/cloud_firestore.dart';

// Ye user (customer/farmer/admin) ka profile model hai
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String fcmToken;
  final bool isActive;
  final DateTime? createdAt;

  // Constructor
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.role = 'customer',
    this.fcmToken = '',
    this.isActive = true,
    this.createdAt,
  });

  // Map se UserModel banane ke liye
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      role: map['role'] ?? 'customer',
      fcmToken: map['fcmToken'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: parseDate(map['createdAt']),
    );
  }

  // Model ko Map mein convert karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'fcmToken': fcmToken,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
