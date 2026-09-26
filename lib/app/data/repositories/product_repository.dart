import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/data/models/category_model.dart';
import 'package:harvest_hub/app/data/models/farmer_model.dart';
import 'package:harvest_hub/app/data/models/market_model.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ProductModel>> getActiveProducts() async {
    final snapshot = await _firestore
        .collection(Db.products)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    final doc = await _firestore.collection(Db.products).doc(id).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return ProductModel.fromMap(doc.data()!, doc.id);
  }

  Future<List<ProductModel>> getProductsByFarmer(String farmerId) async {
    final snapshot = await _firestore
        .collection(Db.products)
        .where('farmerId', isEqualTo: farmerId)
        .get();
    final list = snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
    return list;
  }

  Map<String, dynamic> buildFarmerProductMap({
    required FarmerModel farmer,
    required MarketModel? market,
    required CategoryModel category,
    required String itemName,
    required String description,
    required double pricePerUnit,
    required String unit,
    required int stockQty,
    required String imageUrl,
  }) {
    return {
      'farmerId': farmer.id,
      'farmerName': farmer.businessName,
      'itemName': itemName,
      'itemNameLower': itemName.toLowerCase(),
      'description': description,
      'categoryId': category.id,
      'categoryName': category.name,
      'category': category.name,
      'marketId': farmer.marketId,
      'marketName': market?.marketName ?? '',
      'pricePerUnit': pricePerUnit,
      'unit': unit,
      'stockQty': stockQty,
      'imageUrl': imageUrl,
      'lat': market?.lat ?? 0.0,
      'lng': market?.lng ?? 0.0,
      'gpsCoordinates': GeoPoint(market?.lat ?? 0.0, market?.lng ?? 0.0),
      'isActive': true,
    };
  }

  Future<String> addProduct(Map<String, dynamic> data) async {
    final ref = await _firestore.collection(Db.products).add(data);
    return ref.id;
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) {
    return _firestore.collection(Db.products).doc(id).update(data);
  }

  Future<void> updateStock(String id, int stockQty) {
    if (stockQty < 0) {
      throw Exception('Stock cannot be negative.');
    }
    return _firestore.collection(Db.products).doc(id).update({'stockQty': stockQty});
  }

  Future<void> deleteProduct(String id) {
    return _firestore.collection(Db.products).doc(id).delete();
  }

  Future<void> syncFarmerDenormOnProducts({
    required String farmerId,
    required String farmerName,
    required String marketId,
    required String marketName,
    required double lat,
    required double lng,
  }) async {
    final snap = await _firestore
        .collection(Db.products)
        .where('farmerId', isEqualTo: farmerId)
        .get();
    if (snap.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {
        'farmerName': farmerName,
        'marketId': marketId,
        'marketName': marketName,
        'lat': lat,
        'lng': lng,
        'gpsCoordinates': GeoPoint(lat, lng),
      });
    }
    await batch.commit();
  }
}
