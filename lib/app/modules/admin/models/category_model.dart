import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return CategoryModel(id: doc.id, name: (doc.data()?['name'] ?? '').toString());
  }
}
