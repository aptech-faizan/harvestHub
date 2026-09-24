import 'package:get/get.dart';
import '../../../../data/models/cart_item_model.dart';
import '../../../../data/models/product_model.dart';

// Ye cart ki tamaam logic aur state manage karta hai
class CartController extends GetxController {
  // Cart items ki reactive list
  final RxList<CartItem> items = <CartItem>[].obs;

  // Poore cart ka total bill nikalne ke liye
  double get subtotal {
    double sum = 0.0;
    for (var item in items) {
      sum += item.total;
    }
    return sum;
  }

  // Cart mein total kitni items hain
  int get itemCount {
    int count = 0;
    for (var item in items) {
      count += item.qty;
    }
    return count;
  }

  // Items ko farmer ke hisaab se group karne ke liye
  Map<String, List<CartItem>> get groupedByFarmer {
    final Map<String, List<CartItem>> map = {};
    for (var item in items) {
      final farmerId = item.product.farmerId;
      if (!map.containsKey(farmerId)) {
        map[farmerId] = [];
      }
      map[farmerId]!.add(item);
    }
    return map;
  }

  // Product ko cart mein add karne ke liye
  void add(ProductModel p) {
    if (p.stockQty <= 0) {
      Get.snackbar('Stock khatam', '${p.itemName} is out of stock');
      return;
    }

    final index = items.indexWhere((item) => item.product.id == p.id);
    if (index >= 0) {
      if (items[index].qty < p.stockQty) {
        items[index].qty++;
        items.refresh();
      } else {
        Get.snackbar('Limit reach', 'Available stock se zyada add nahi ho sakta');
      }
    } else {
      items.add(CartItem(product: p, qty: 1));
    }
  }

  // Item ki quantity update karne ke liye
  void setQty(String productId, int qty) {
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    if (qty <= 0) {
      remove(productId);
      return;
    }

    final maxStock = items[index].product.stockQty;
    if (qty > maxStock) {
      items[index].qty = maxStock;
      items.refresh();
      Get.snackbar('Stock limit', 'Sirf $maxStock items stock mein hain');
    } else {
      items[index].qty = qty;
      items.refresh();
    }
  }

  // Kisi ek product ko cart se hatane ke liye
  void remove(String productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  // Poora cart saaf karne ke liye
  void clear() {
    items.clear();
  }
}
