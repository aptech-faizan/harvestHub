import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvest_hub/app/core/constants/app_constants.dart';
import 'package:harvest_hub/app/modules/admin/models/category_model.dart';
import 'package:harvest_hub/app/modules/admin/models/farmer_model.dart';
import 'package:harvest_hub/app/modules/admin/models/market_model.dart';
import 'package:harvest_hub/app/modules/admin/models/order_model.dart';
import 'package:harvest_hub/app/modules/admin/models/product_model.dart';
import 'package:harvest_hub/app/modules/admin/models/user_model.dart';

// All Firestore work for the admin panel lives here.
// Lists are sorted in Dart so no composite Firestore indexes are needed.
class AdminRepository {
  final _db = FirebaseFirestore.instance;

  // ---------- counts ----------
  Future<int> count(String collection, {String? role}) async {
    Query<Map<String, dynamic>> query = _db.collection(collection);
    if (role != null) query = query.where('role', isEqualTo: role);
    final snap = await query.count().get();
    return snap.count ?? 0;
  }

  // ---------- users / customers ----------
  Future<List<UserModel>> getUsersByRole(String role) async {
    final snap = await _db
        .collection(Db.users)
        .where('role', isEqualTo: role)
        .get();
    final list = snap.docs.map(UserModel.fromDoc).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) {
    return _db.collection(Db.users).doc(id).update(data);
  }

  // Deletes only the Firestore profile (the Firebase Auth login stays; use deactivate to block it).
  Future<void> deleteUser(String id) {
    return _db.collection(Db.users).doc(id).delete();
  }

  Future<Map<String, String>> getUserNames() async {
    final snap = await _db.collection(Db.users).get();
    return {
      for (final d in snap.docs) d.id: (d.data()['name'] ?? '').toString(),
    };
  }

  // ---------- farmers ----------
  Future<List<FarmerModel>> getFarmers() async {
    final farmerSnap = await _db.collection(Db.farmers).get();
    final users = await getUsersByRole(Roles.farmer);
    final userMap = {for (final u in users) u.id: u};
    final list = farmerSnap.docs.map((doc) {
      final userId = (doc.data()['userId'] ?? doc.id).toString();
      return FarmerModel.fromDoc(doc, userMap[userId]);
    }).toList();
    list.sort(
      (a, b) =>
          a.businessName.toLowerCase().compareTo(b.businessName.toLowerCase()),
    );
    return list;
  }

  Future<Map<String, String>> getFarmerNames() async {
    final snap = await _db.collection(Db.farmers).get();
    return {
      for (final d in snap.docs)
        d.id: (d.data()['businessName'] ?? d.id).toString(),
    };
  }

  Future<void> updateFarmer(
    FarmerModel farmer,
    Map<String, dynamic> farmerData,
    Map<String, dynamic> userData,
  ) async {
    final batch = _db.batch();
    batch.update(_db.collection(Db.farmers).doc(farmer.id), farmerData);
    batch.update(_db.collection(Db.users).doc(farmer.userId), userData);
    await batch.commit();
  }

  // Removes the farmer profile, the user profile and all of the farmer's products.
  Future<void> deleteFarmer(FarmerModel farmer) async {
    final batch = _db.batch();
    final products = await _db
        .collection(Db.products)
        .where('farmerId', isEqualTo: farmer.id)
        .get();
    for (final p in products.docs) {
      batch.delete(p.reference);
    }
    batch.delete(_db.collection(Db.farmers).doc(farmer.id));
    batch.delete(_db.collection(Db.users).doc(farmer.userId));
    await batch.commit();
  }

  // ---------- categories ----------
  Future<List<CategoryModel>> getCategories() async {
    final snap = await _db.collection(Db.categories).get();
    final list = snap.docs.map(CategoryModel.fromDoc).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  Future<void> addCategory(String name) {
    return _db.collection(Db.categories).add({'name': name});
  }

  // Products store the category name, so they are renamed together with the category.
  Future<void> renameCategory(String id, String oldName, String newName) async {
    final batch = _db.batch();
    batch.update(_db.collection(Db.categories).doc(id), {'name': newName});
    final products = await _db
        .collection(Db.products)
        .where('category', isEqualTo: oldName)
        .get();
    for (final p in products.docs) {
      batch.update(p.reference, {'category': newName});
    }
    await batch.commit();
  }

  Future<void> deleteCategory(String id, String name) async {
    final used = await _db
        .collection(Db.products)
        .where('category', isEqualTo: name)
        .limit(1)
        .get();
    if (used.docs.isNotEmpty) {
      throw Exception(
        'Some products still use this category. Change or delete them first.',
      );
    }
    await _db.collection(Db.categories).doc(id).delete();
  }

  // ---------- markets ----------
  Future<List<MarketModel>> getMarkets() async {
    final snap = await _db.collection(Db.markets).get();
    final list = snap.docs.map(MarketModel.fromDoc).toList();
    list.sort(
      (a, b) =>
          a.marketName.toLowerCase().compareTo(b.marketName.toLowerCase()),
    );
    return list;
  }

  Future<void> addMarket(Map<String, dynamic> data) {
    return _db.collection(Db.markets).add(data);
  }

  Future<void> updateMarket(String id, Map<String, dynamic> data) {
    return _db.collection(Db.markets).doc(id).update(data);
  }

  Future<void> deleteMarket(String id) async {
    final used = await _db
        .collection(Db.farmers)
        .where('marketId', isEqualTo: id)
        .limit(1)
        .get();
    if (used.docs.isNotEmpty) {
      throw Exception(
        'Some farmers are assigned to this market. Move them first.',
      );
    }
    await _db.collection(Db.markets).doc(id).delete();
  }

  // ---------- products ----------
  Future<List<ProductModel>> getProducts() async {
    final snap = await _db.collection(Db.products).get();
    final list = snap.docs.map(ProductModel.fromDoc).toList();
    list.sort(
      (a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()),
    );
    return list;
  }

  Future<List<ProductModel>> getProductsByFarmer(String farmerId) async {
    final snap = await _db
        .collection(Db.products)
        .where('farmerId', isEqualTo: farmerId)
        .get();
    return snap.docs.map(ProductModel.fromDoc).toList();
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) {
    return _db.collection(Db.products).doc(id).update(data);
  }

  Future<void> deleteProduct(String id) {
    return _db.collection(Db.products).doc(id).delete();
  }

  // ---------- orders ----------
  Future<List<OrderModel>> getOrders() async {
    final snap = await _db.collection(Db.orders).get();
    final list = snap.docs.map(OrderModel.fromDoc).toList();
    final old = DateTime(2000);
    list.sort(
      (a, b) => (b.createdAt ?? old).compareTo(a.createdAt ?? old),
    ); // newest first
    return list;
  }

  Future<void> updateOrderStatus(String id, String status) {
    return _db.collection(Db.orders).doc(id).update({'status': status});
  }

  // ---------- simple calculations shared by dashboard and reports ----------
  // Cancelled orders are not counted as revenue.
  double totalRevenue(List<OrderModel> orders) {
    return orders
        .where((o) => o.status != OrderStatus.cancelled)
        // ignore: avoid_types_as_parameter_names
        .fold(0.0, (sum, o) => sum + o.totalPrice);
  }

  // Returns (farmerId, orderCount) pairs, highest first.
  List<MapEntry<String, int>> mostActiveFarmers(
    List<OrderModel> orders, {
    int limit = 5,
  }) {
    final counts = <String, int>{};
    for (final o in orders) {
      if (o.farmerId.isEmpty) continue;
      counts[o.farmerId] = (counts[o.farmerId] ?? 0) + 1;
    }
    final list = counts.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list.take(limit).toList();
  }
}
