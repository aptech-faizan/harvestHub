import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

DateTime? readDate(dynamic value) => value is Timestamp ? value.toDate() : null;

double readDouble(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

int readInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

String formatDate(DateTime? d) {
  if (d == null) return '-';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}

String money(num value) => 'Rs ${value.toStringAsFixed(2)}';

String errorText(Object e) => e.toString().replaceFirst('Exception: ', '');

void showError(String message) {
  Get.snackbar('Error', message,
      snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
}

void showSuccess(String message) {
  Get.snackbar('Done', message,
      snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);
}

Future<bool> confirmDialog(String title, String message) async {
  final result = await Get.dialog<bool>(AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
      TextButton(
        onPressed: () => Get.back(result: true),
        child: const Text('Confirm', style: TextStyle(color: Colors.red)),
      ),
    ],
  ));
  return result ?? false;
}

// Returns the first item matching [test], or null.
T? findOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
