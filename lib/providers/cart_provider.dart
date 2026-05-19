import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/products_data.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user_data.dart';

// ─── CartProvider ──────────────────────────────────────────────────────────────
// Direct port of CartContext.tsx — same interface, same localStorage patterns.
// React: useContext(CartContext) → Flutter: context.read<CartProvider>()

class CartProvider extends ChangeNotifier {
  List<CartItem> _cart = [];
  UserData? _userData;
  List<Order> _orders = [];

  List<CartItem> get cart => List.unmodifiable(_cart);
  UserData? get userData => _userData;
  List<Order> get orders => List.unmodifiable(_orders);

  // ── Hydration (mirrors CartContext useEffect on mount) ────────────────────

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load cart
    final cartJson = prefs.getString('cart');
    if (cartJson != null) {
      final List<dynamic> decoded = jsonDecode(cartJson);
      _cart = decoded
          .map((item) => _cartItemFromJson(item as Map<String, dynamic>))
          .whereType<CartItem>()
          .toList();
    }

    // Load userData
    final userJson = prefs.getString('userData');
    if (userJson != null) {
      _userData = UserData.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
    }

    // Load orders
    final ordersJson = prefs.getString('orders');
    if (ordersJson != null) {
      final List<dynamic> decoded = jsonDecode(ordersJson);
      _orders = decoded
          .map((o) => _orderFromJson(o as Map<String, dynamic>))
          .whereType<Order>()
          .toList();
    }

    notifyListeners();
  }

  // ── Cart mutations ────────────────────────────────────────────────────────

  void addToCart(Product product, {bool isOrganic = false}) {
    final idx = _cart.indexWhere(
      (i) => i.product.id == product.id && i.isOrganic == isOrganic,
    );
    if (idx >= 0) {
      _cart[idx] = _cart[idx].copyWith(quantity: _cart[idx].quantity + 1);
    } else {
      _cart.add(CartItem(product: product, quantity: 1, isOrganic: isOrganic));
    }
    _persistCart();
    notifyListeners();
  }

  void removeFromCart(int productId, {bool isOrganic = false}) {
    _cart.removeWhere(
      (i) => i.product.id == productId && i.isOrganic == isOrganic,
    );
    _persistCart();
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity, {bool isOrganic = false}) {
    if (quantity <= 0) {
      removeFromCart(productId, isOrganic: isOrganic);
      return;
    }
    final idx = _cart.indexWhere(
      (i) => i.product.id == productId && i.isOrganic == isOrganic,
    );
    if (idx >= 0) {
      _cart[idx] = _cart[idx].copyWith(quantity: quantity);
      _persistCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _cart = [];
    _persistCart();
    notifyListeners();
  }

  double getCartTotal() {
    return _cart.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  int get cartItemCount => _cart.fold(0, (sum, i) => sum + i.quantity);

  // ── User data ─────────────────────────────────────────────────────────────

  Future<void> saveUserData(UserData data) async {
    _userData = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(data.toJson()));
    notifyListeners();
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<void> createOrder(UserData data) async {
    final order = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      items: List.from(_cart),
      total: getCartTotal(),
      userData: data,
    );
    await saveUserData(data);
    _orders.insert(0, order);
    clearCart();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'orders',
      jsonEncode(_orders.map((o) => o.toJson()).toList()),
    );
    notifyListeners();
  }

  // ── Persistence helpers ───────────────────────────────────────────────────

  Future<void> _persistCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cart',
      jsonEncode(_cart.map((i) => i.toJson()).toList()),
    );
  }

  CartItem? _cartItemFromJson(Map<String, dynamic> json) {
    final product = products.cast<Product?>().firstWhere(
          (p) => p?.id == json['productId'],
          orElse: () => null,
        );
    if (product == null) return null;
    return CartItem(
      product: product,
      quantity: json['quantity'] as int,
      isOrganic: json['isOrganic'] as bool? ?? false,
    );
  }

  Order? _orderFromJson(Map<String, dynamic> json) {
    try {
      final items = (json['items'] as List<dynamic>)
          .map((i) => _cartItemFromJson(i as Map<String, dynamic>))
          .whereType<CartItem>()
          .toList();
      return Order(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        items: items,
        total: (json['total'] as num).toDouble(),
        userData: UserData.fromJson(json['userData'] as Map<String, dynamic>),
      );
    } catch (_) {
      return null;
    }
  }
}
