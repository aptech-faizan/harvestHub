import 'package:get/get.dart';
import '../../../../data/models/cart_item_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../core/widgets/app_snackbar.dart';

class CartController extends GetxController {
  final RxList<CartItem> items = <CartItem>[].obs;

  double get subtotal {
    double sum = 0.0;
    for (var item in items) {
      sum += item.total;
    }
    return sum;
  }

  int get itemCount {
    int count = 0;
    for (var item in items) {
      count += item.qty;
    }
    return count;
  }

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

  void add(ProductModel p) {
    if (p.stockQty <= 0) {
      AppSnackbar.warning('${p.itemName} is out of stock', title: 'Out of Stock');
      return;
    }

    final index = items.indexWhere((item) => item.product.id == p.id);
    if (index >= 0) {
      if (items[index].qty < p.stockQty) {
        items[index].qty++;
        items.refresh();
        AppSnackbar.success('${p.itemName} quantity updated',
            title: 'Cart Updated', duration: const Duration(seconds: 1));
      } else {
        AppSnackbar.warning('Cannot add more than available stock',
            title: 'Stock Limit');
      }
    } else {
      items.add(CartItem(product: p, qty: 1));
      AppSnackbar.success('${p.itemName} added to cart',
          title: 'Item Added', duration: const Duration(seconds: 1));
    }
  }

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
      AppSnackbar.warning('Only $maxStock items available in stock',
          title: 'Stock Limit');
    } else {
      items[index].qty = qty;
      items.refresh();
    }
  }

  void remove(String productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  void clear() {
    items.clear();
  }
}
