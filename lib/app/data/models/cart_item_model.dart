import 'product_model.dart';

// Ye cart ke single item ka model hai
class CartItem {
  final ProductModel product;
  int qty;

  // Constructor
  CartItem({
    required this.product,
    this.qty = 1,
  });

  // Is item ka total price nikalne ke liye getter
  double get total => product.pricePerUnit * qty;

  // Map se CartItem banane ke liye (agar zaroorat pade)
  factory CartItem.fromMap(Map<String, dynamic> map, ProductModel product) {
    return CartItem(
      product: product,
      qty: (map['qty'] ?? 1).toInt(),
    );
  }

  // Model ko Map mein convert karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'qty': qty,
    };
  }
}
