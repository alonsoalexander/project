import 'product.dart';

// Maps CartItem interface (extends Product) from CartContext.tsx

class CartItem {
  final Product product;
  final int quantity;
  final bool isOrganic;

  const CartItem({
    required this.product,
    required this.quantity,
    this.isOrganic = false,
  });

  double get lineTotal =>
      (isOrganic ? (product.organicPrice ?? product.price) : product.price) *
      quantity;

  double get unitPrice =>
      isOrganic ? (product.organicPrice ?? product.price) : product.price;

  CartItem copyWith({int? quantity, bool? isOrganic}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      isOrganic: isOrganic ?? this.isOrganic,
    );
  }

  // JSON serialization for shared_preferences persistence (mirrors localStorage)
  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'quantity': quantity,
        'isOrganic': isOrganic,
      };
}
