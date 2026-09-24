// Ye category ka data model hai
class CategoryModel {
  final String id;
  final String name;
  final String iconUrl;
  final bool isActive;

  // Constructor
  CategoryModel({
    required this.id,
    required this.name,
    this.iconUrl = '',
    this.isActive = true,
  });

  // Map se CategoryModel banane ke liye
  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  // Model ko Map mein convert karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconUrl': iconUrl,
      'isActive': isActive,
    };
  }
}
