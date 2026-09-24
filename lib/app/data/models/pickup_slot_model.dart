import 'package:cloud_firestore/cloud_firestore.dart';

// Ye farmer ke pickup time slot ka model hai
class PickupSlotModel {
  final String id;
  final String farmerId;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final int bookedCount;

  // Constructor
  PickupSlotModel({
    required this.id,
    required this.farmerId,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.bookedCount = 0,
  });

  // Check karta hai ke slot full hai ya nahi
  bool get isFull => bookedCount >= capacity;

  // Human-readable slot label format (maslan: 25 Sep, 10:00 AM - 11:00 AM)
  String get label {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    String formatTime(DateTime dt) {
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }
    return '${startTime.day} ${months[startTime.month - 1]}, ${formatTime(startTime)} - ${formatTime(endTime)}';
  }

  // Map se PickupSlotModel banane ke liye
  factory PickupSlotModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return PickupSlotModel(
      id: id,
      farmerId: map['farmerId'] ?? '',
      startTime: parseDate(map['startTime']),
      endTime: parseDate(map['endTime']),
      capacity: (map['capacity'] ?? 0).toInt(),
      bookedCount: (map['bookedCount'] ?? 0).toInt(),
    );
  }

  // Model ko Map mein convert karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'capacity': capacity,
      'bookedCount': bookedCount,
    };
  }
}
