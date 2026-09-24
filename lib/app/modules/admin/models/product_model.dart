import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvest_hub/app/core/utils/helpers.dart';

class ProductModel {
  final String id;
  final String farmerId;
  final String itemName;
  final String category; // category name, as in the SRS
  final String description;
  final double pricePerUnit;
  final int stockQty;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.farmerId,
    required this.itemName,
    required this.category,
    required this.description,
    required this.pricePerUnit,
    required this.stockQty,
    required this.imageUrl,
  });

  factory ProductModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ProductModel(
      id: doc.id,
      farmerId: (d['farmerId'] ?? '').toString(),
      itemName: (d['itemName'] ?? '').toString(),
      category: (d['category'] ?? '').toString(),
      description: (d['description'] ?? '').toString(),
      pricePerUnit: readDouble(d['pricePerUnit']),
      stockQty: readInt(d['stockQty']),
      imageUrl: (d['imageUrl'] ?? '').toString(),
    );
  }
}
