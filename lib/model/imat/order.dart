import 'dart:convert';
import 'package:imat/model/imat/shopping_item.dart';

class Order {
  int orderNumber;
  DateTime date;
  List<ShoppingItem> items;

  Order(this.orderNumber, this.date, this.items);

  factory Order.fromJson(Map<String, dynamic> json) {
    final jsonItems = json[_items] as List;
    return Order(
      json[_orderNumber] as int,
      DateTime.fromMillisecondsSinceEpoch(json[_date] as int),
      jsonItems.map((i) => ShoppingItem.fromJson(i)).toList(),
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
