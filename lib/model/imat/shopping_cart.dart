import 'package:imat/model/imat/shopping_item.dart';

class ShoppingCart {
  List<ShoppingItem> items;

  ShoppingCart(this.items);

  factory ShoppingCart.fromJson(Map<String, dynamic> json) {
    final jsonItems = json[_items] as List;
    return ShoppingCart(
      jsonItems.map((i) => ShoppingItem.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    _items: items.map((item) => item.toJson()).toList(),
  };

  void addItem(ShoppingItem sci, {bool merge = true}) {
    if (merge) {
      for (final item in items) {
        if (item.product.productId == sci.product.productId) {
          item.amount += sci.amount;
          return;
        }
      }
    }
    items.add(sci);
  }

  void updateItem(ShoppingItem sci, {double delta = 0.0, bool removeEmpty = true}) {
    for (final item in items) {
      if (item.product.productId == sci.product.productId) {
        item.amount += delta;
        if (removeEmpty && item.amount <= 0.0) items.remove(item);
        return;
      }
    }
    items.add(sci);
  }

  void removeItem(ShoppingItem sci) {
    items.removeWhere((i) => i.product.productId == sci.product.productId);
  }

  void clear() => items.clear();

  static const _items = 'items';
}
