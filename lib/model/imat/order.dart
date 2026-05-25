import 'dart:convert';
import 'package:imat/model/imat/shopping_item.dart';

class Order {
  int orderNumber;
  DateTime date;
  List<ShoppingItem> items;

  Order(this.orderNumber, this.date, this.items);

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json[_items];
    // The API may return items as a JSON string or as a parsed List
    final List itemsList = rawItems is String ? jsonDecode(rawItems) as List : (rawItems as List? ?? []);
    return Order(
      (json[_orderNumber] as num).toInt(),
      DateTime.fromMillisecondsSinceEpoch((json[_date] as num).toInt()),
      itemsList.map((i) => ShoppingItem.fromJson(i as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    _orderNumber: orderNumber,
    _date: date.millisecondsSinceEpoch,
    _items: jsonEncode(items.map((i) => i.toJson()).toList()),
  };

  double getTotal() =>
      items.fold(0.0, (sum, i) => sum + i.product.price * i.amount);

  static const _orderNumber = 'orderNumber';
  static const _date = 'date';
  static const _items = 'items';
}
