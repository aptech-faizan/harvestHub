// TEMP: test data, baad mein delete karna
import 'package:cloud_firestore/cloud_firestore.dart';

// Firestore mein initial testing data daalne ka function
Future<void> seedTestData() async {
  final firestore = FirebaseFirestore.instance;

  // 1. Categories
  await firestore.collection('categories').doc('cat_fruits').set({
    'name': 'Fruits',
    'iconUrl': '',
    'isActive': true,
  });

  await firestore.collection('categories').doc('cat_veg').set({
    'name': 'Vegetables',
    'iconUrl': '',
    'isActive': true,
  });

  // 2. Markets
  await firestore.collection('markets').doc('market1').set({
    'marketName': 'City Market',
    'address': 'Karachi',
    'lat': 24.86,
    'lng': 67.01,
    'operatingHours': '8am-6pm',
    'isActive': true,
  });

  // 3. Products (6 docs: p1..p6)
  final products = [
    {
      'id': 'p1',
      'itemName': 'Fresh Apples',
      'itemNameLower': 'fresh apples',
      'description': 'Crisp organic red apples.',
      'farmerId': 'farmer1',
      'farmerName': 'Ali Farms',
      'categoryId': 'cat_fruits',
      'categoryName': 'Fruits',
      'marketId': 'market1',
      'marketName': 'City Market',
      'pricePerUnit': 250.0,
      'unit': 'kg',
      'stockQty': 20,
      'imageUrl': '',
      'lat': 24.86,
      'lng': 67.01,
      'isActive': true,
    },
    {
      'id': 'p2',
      'itemName': 'Ripe Bananas',
      'itemNameLower': 'ripe bananas',
      'description': 'Sweet farm fresh bananas.',
      'farmerId': 'farmer1',
      'farmerName': 'Ali Farms',
      'categoryId': 'cat_fruits',
      'categoryName': 'Fruits',
      'marketId': 'market1',
      'marketName': 'City Market',
      'pricePerUnit': 120.0,
      'unit': 'kg',
      'stockQty': 15,
      'imageUrl': '',
      'lat': 24.86,
      'lng': 67.01,
      'isActive': true,
    },
    {
      'id': 'p3',
      'itemName': 'Red Tomatoes',
      'itemNameLower': 'red tomatoes',
      'description': 'Juicy cooking tomatoes.',
      'farmerId': 'farmer1',
      'farmerName': 'Ali Farms',
      'categoryId': 'cat_veg',
      'categoryName': 'Vegetables',
      'marketId': 'market1',
      'marketName': 'City Market',
      'pricePerUnit': 90.0,
      'unit': 'kg',
      'stockQty': 30,
      'imageUrl': '',
      'lat': 24.86,
      'lng': 67.01,
      'isActive': true,
    },
    {
      'id': 'p4',
      'itemName': 'Farm Potatoes',
      'itemNameLower': 'farm potatoes',
      'description': 'Clean washed potatoes.',
      'farmerId': 'farmer2',
      'farmerName': 'Sara Organics',
      'categoryId': 'cat_veg',
      'categoryName': 'Vegetables',
      'marketId': 'market1',
      'marketName': 'City Market',
      'pricePerUnit': 70.0,
      'unit': 'kg',
      'stockQty': 40,
      'imageUrl': '',
      'lat': 24.86,
      'lng': 67.01,
      'isActive': true,
    },
    {
      'id': 'p5',
      'itemName': 'Green Spinach',
      'itemNameLower': 'green spinach',
      'description': 'Freshly picked leafy spinach.',
      'farmerId': 'farmer2',
      'farmerName': 'Sara Organics',
      'categoryId': 'cat_veg',
      'categoryName': 'Vegetables',
      'marketId': 'market1',
      'marketName': 'City Market',
      'pricePerUnit': 50.0,
      'unit': 'kg',
      'stockQty': 10,
      'imageUrl': '',
      'lat': 24.86,
      'lng': 67.01,
      'isActive': true,
    },
    {
      'id': 'p6',
      'itemName': 'Sweet Oranges',
      'itemNameLower': 'sweet oranges',
      'description': 'Out of stock seasonal oranges.',
      'farmerId': 'farmer2',
      'farmerName': 'Sara Organics',
      'categoryId': 'cat_fruits',
      'categoryName': 'Fruits',
      'marketId': 'market1',
      'marketName': 'City Market',
      'pricePerUnit': 200.0,
      'unit': 'kg',
      'stockQty': 0, // Out of stock test
      'imageUrl': '',
      'lat': 24.86,
      'lng': 67.01,
      'isActive': true,
    },
  ];

  for (var p in products) {
    final docId = p['id'] as String;
    final data = Map<String, dynamic>.from(p)..remove('id');
    await firestore.collection('products').doc(docId).set(data);
  }

  // 4. Pickup Slots
  final now = DateTime.now();
  final slots = [
    // Farmer 1 slots
    {
      'id': 's_f1_1',
      'farmerId': 'farmer1',
      'startTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 2))),
      'endTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 3))),
      'capacity': 5,
      'bookedCount': 0,
    },
    {
      'id': 's_f1_2',
      'farmerId': 'farmer1',
      'startTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 4))),
      'endTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 5))),
      'capacity': 5,
      'bookedCount': 2,
    },
    {
      'id': 's_f1_3',
      'farmerId': 'farmer1',
      'startTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 6))),
      'endTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 7))),
      'capacity': 5,
      'bookedCount': 5, // Full slot test
    },
    // Farmer 2 slots
    {
      'id': 's_f2_1',
      'farmerId': 'farmer2',
      'startTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 2))),
      'endTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 3))),
      'capacity': 5,
      'bookedCount': 0,
    },
    {
      'id': 's_f2_2',
      'farmerId': 'farmer2',
      'startTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 4))),
      'endTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 5))),
      'capacity': 5,
      'bookedCount': 1,
    },
    {
      'id': 's_f2_3',
      'farmerId': 'farmer2',
      'startTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 6))),
      'endTime': Timestamp.fromDate(now.add(const Duration(days: 1, hours: 7))),
      'capacity': 5,
      'bookedCount': 0,
    },
  ];

  for (var s in slots) {
    final docId = s['id'] as String;
    final data = Map<String, dynamic>.from(s)..remove('id');
    await firestore.collection('pickup_slots').doc(docId).set(data);
  }
}
