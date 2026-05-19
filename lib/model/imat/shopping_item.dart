import 'package:imat/model/imat/product.dart';

class ShoppingItem {
  Product product;
  double amount;

  ShoppingItem(this.product, {this.amount = 1.0});

  double get total => product.price * amount;

  ShoppingItem.fromJson(Map<String, dynamic> json)
    : product = Product.fromJson(json[_product]),
      amount = (json[_amount] as num).toDouble();

  Map<String, dynamic> toJson() => {
    _product: product.toJson(),
    _amount: amount,
  };

  static const _product = 'product';
  static const _amount = 'amount';
}
