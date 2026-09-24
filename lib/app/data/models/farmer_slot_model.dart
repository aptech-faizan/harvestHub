import 'package:cloud_firestore/cloud_firestore.dart';

/// A pickup slot created by a farmer.
///
/// Firestore schema (collection: pickup_slots):
///   farmerId      – String
///   startTime     – Timestamp  (NOT a string)
///   endTime       – Timestamp  (NOT a string)
///   capacity      – number     (max orders allowed)
///   bookedCount   – number     (set to 0 at creation; customers manage this)
///   isActive      – bool
///
/// RULES:
///   - Never write/change bookedCount after creation (customers own it).
///   - Delete blocked if bookedCount > 0.
///   - Edit blocked on time fields if bookedCount > 0.
///   - capacity must be >= bookedCount when editing.
class PickupSlot {
  final String id;
  final String farmerId;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final int bookedCount; // read-only after creation
  final bool isActive;

  const PickupSlot({
    required this.id,
    required this.farmerId,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.bookedCount = 0,
    this.isActive = true,
  });

  bool get isFull => bookedCount >= capacity;
  int get available => capacity - bookedCount;

  factory PickupSlot.fromMap(Map<String, dynamic> map, String docId) {
    return PickupSlot(
      id: docId,
      farmerId: map['farmerId'] as String? ?? '',
      startTime: _parseTimestamp(map['startTime']),
      endTime: _parseTimestamp(map['endTime']),
      capacity: (map['capacity'] as num?)?.toInt() ?? 1,
      bookedCount: (map['bookedCount'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  /// Serialises for the initial creation write.
  /// bookedCount is set to 0 here and never touched again by farmer code.
  Map<String, dynamic> toCreateMap() {
    return {
      'farmerId': farmerId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'capacity': capacity,
      'bookedCount': 0, // always 0 on creation
      'isActive': isActive,
    };
  }

  /// Serialises only the fields the farmer is allowed to update.
  /// Never includes bookedCount.
  Map<String, dynamic> toUpdateMap() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'capacity': capacity,
      'isActive': isActive,
    };
  }

  PickupSlot copyWith({
    DateTime? startTime,
    DateTime? endTime,
    int? capacity,
    bool? isActive,
  }) {
    return PickupSlot(
      id: id,
      farmerId: farmerId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      bookedCount: bookedCount,
      isActive: isActive ?? this.isActive,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
