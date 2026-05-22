import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:imat/model/imat/credit_card.dart';
import 'package:imat/model/imat/customer.dart';
import 'package:imat/model/imat/order.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat/product_detail.dart';
import 'package:imat/model/imat/settings.dart';
import 'package:imat/model/imat/shopping_cart.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'package:imat/model/imat/user.dart';
import 'package:imat/model/internet_handler.dart';

// ImatDataHandler is the single source of truth for all app state.
// It replaces both CartProvider and the static products_data.dart.
// Extends ChangeNotifier so all Provider.watch<ImatDataHandler>() calls
// rebuild when state changes.

class ImatDataHandler extends ChangeNotifier {
  ImatDataHandler() {
    _setUp();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // ── Products ──────────────────────────────────────────────────────────────

  final List<Product> _products = [];
  final List<Product> _selectProducts = [];
  final List<ProductDetail> _details = [];

  List<Product> get products => List.unmodifiable(_products);
  List<Product> get selectProducts => List.unmodifiable(_selectProducts);
  List<ProductDetail> get details => List.unmodifiable(_details);

  void selectAllProducts() {
    _selectProducts
      ..clear()
      ..addAll(_products);
    notifyListeners();
  }

  void selectFavorites() {
    _selectProducts
      ..clear()
      ..addAll(favorites);
    notifyListeners();
  }

  void selectSelection(List<Product> selection) {
    _selectProducts
      ..clear()
      ..addAll(selection);
    notifyListeners();
  }

  List<Product> findProductsByCategory(ProductCategory category) =>
      _products.where((p) => p.category == category).toList();

  List<Product> findProducts(String search) {
    final q = search.toLowerCase();
    return _products.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  Product? getProduct(int id) =>
      _products.cast<Product?>().firstWhere((p) => p?.productId == id, orElse: () => null);

  ProductDetail? getDetail(Product p) => getDetailWithId(p.productId);

  ProductDetail? getDetailWithId(int id) =>
      _details.cast<ProductDetail?>().firstWhere((d) => d?.productId == id, orElse: () => null);

  // ── Images ────────────────────────────────────────────────────────────────

  // Returns cached image or placeholder while fetching in background.
  // Call inside a Consumer<ImatDataHandler> / watch<ImatDataHandler>() to
  // get automatic rebuild when the image arrives.
  Image getImage(Product p) {
    final img = InternetHandler.cachedImage(p.productId);
    return img ?? Image.asset('assets/images/placeholder.png', fit: BoxFit.cover);
  }

  // ── Favorites ─────────────────────────────────────────────────────────────

  final Map<int, Product> _favorites = {};

  List<Product> get favorites => _favorites.values.toList();

  bool isFavorite(Product product) => _favorites.containsKey(product.productId);

  void toggleFavorite(Product product) {
    if (_favorites.containsKey(product.productId)) {
      _favorites.remove(product.productId);
      InternetHandler.removeFavorite(product.productId);
    } else {
      _favorites[product.productId] = product;
      InternetHandler.addFavorite(product.productId);
    }
    notifyListeners();
  }

  // ── Shopping cart ─────────────────────────────────────────────────────────

  ShoppingCart _shoppingCart = ShoppingCart([]);

  ShoppingCart getShoppingCart() => _shoppingCart;

  List<ShoppingItem> get cartItems => _shoppingCart.items;

  int get cartItemCount =>
      _shoppingCart.items.fold(0, (sum, i) => sum + i.amount.round());

  double shoppingCartTotal() =>
      _shoppingCart.items.fold(0.0, (sum, i) => sum + i.total);

  void shoppingCartAdd(ShoppingItem item) {
    _shoppingCart.addItem(item);
    _syncCart();
  }

  void shoppingCartUpdate(ShoppingItem item, {double delta = 0.0}) {
    _shoppingCart.updateItem(item, delta: delta);
    _syncCart();
  }

  void shoppingCartRemove(ShoppingItem item) {
    _shoppingCart.removeItem(item);
    _syncCart();
  }

  void shoppingCartClear() {
    _shoppingCart.clear();
    _syncCart();
  }

  void _syncCart() {
    InternetHandler.setShoppingCart(_shoppingCart);
    notifyListeners();
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  final List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders);

  Future<void> placeOrder() async {
    await InternetHandler.placeOrder();
    _shoppingCart.clear();
    notifyListeners();
    await _loadOrders();
  }

  // ── Customer / User / Card ────────────────────────────────────────────────

  Customer _customer = Customer('', '', '', '', '', '', '', '');
  User _user = User('', '');
  CreditCard _creditCard = CreditCard('', '', 12, 25, '', 0);

  Customer getCustomer() => _customer;
  User getUser() => _user;
  CreditCard getCreditCard() => _creditCard;

  void setCustomer(Customer customer) async {
    _customer = customer;
    await InternetHandler.setCustomer(customer);
    notifyListeners();
  }

  void setUser(User user) async {
    _user = user;
    await InternetHandler.setUser(user);
    notifyListeners();
  }

  void setCreditCard(CreditCard card) async {
    _creditCard = card;
    await InternetHandler.setCreditCard(card);
    notifyListeners();
  }

  // ── Extras ────────────────────────────────────────────────────────────────

  Map<String, dynamic> _extras = {};

  Map<String, dynamic> getExtras() => Map.unmodifiable(_extras);

  void addExtra(String key, dynamic value) {
    _extras[key] = value;
    InternetHandler.setExtras(_extras);
    notifyListeners();
  }

  void removeExtra(String key) {
    _extras.remove(key);
    InternetHandler.setExtras(_extras);
    notifyListeners();
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  void _setUp() async {
    InternetHandler.kGroupId = Settings.groupId;
    InternetHandler.onImageLoaded = notifyListeners;

    // Products (blocking — needed before anything renders)
    final productsJson = await InternetHandler.getProducts();
    if (productsJson.isNotEmpty) {
      final list = jsonDecode(productsJson) as List;
      _products.addAll(list.map((j) => Product.fromJson(j)));
      _selectProducts.addAll(_products);
    }

    // Details
    final detailsJson = await InternetHandler.getDetails();
    if (detailsJson.isNotEmpty) {
      final list = jsonDecode(detailsJson) as List;
      _details.addAll(list.map((j) => ProductDetail.fromJson(j)));
    }

    // Favorites
    final favJson = await InternetHandler.getFavorites();
    if (favJson.isNotEmpty) {
      final list = jsonDecode(favJson) as List;
      for (final p in list.map((j) => Product.fromJson(j))) {
        _favorites[p.productId] = p;
      }
    }

    _isLoading = false;
    notifyListeners();

    // Load remaining data in parallel (non-blocking for UI)
    await Future.wait([
      _loadCustomer(),
      _loadUser(),
      _loadCreditCard(),
      _loadOrders(),
      _loadCart(),
      _loadExtras(),
    ]);
  }

  Future<void> _loadCustomer() async {
    final json = await InternetHandler.getCustomer();
    if (json.isNotEmpty) _customer = Customer.fromJson(jsonDecode(json));
    notifyListeners();
  }

  Future<void> _loadUser() async {
    final json = await InternetHandler.getUser();
    if (json.isNotEmpty) _user = User.fromJson(jsonDecode(json));
    notifyListeners();
  }

  Future<void> _loadCreditCard() async {
    final json = await InternetHandler.getCreditCard();
    if (json.isNotEmpty) _creditCard = CreditCard.fromJson(jsonDecode(json));
    notifyListeners();
  }

  Future<void> _loadOrders() async {
    final json = await InternetHandler.getOrders();
    if (json.isNotEmpty) {
      final list = jsonDecode(json) as List;
      _orders
        ..clear()
        ..addAll(list.map((j) => Order.fromJson(j)));
    }
    notifyListeners();
  }

  Future<void> _loadCart() async {
    final json = await InternetHandler.getShoppingCart();
    if (json.isNotEmpty) _shoppingCart = ShoppingCart.fromJson(jsonDecode(json));
    notifyListeners();
  }

  Future<void> _loadExtras() async {
    final json = await InternetHandler.getExtras();
    if (json.isNotEmpty) _extras = jsonDecode(json) as Map<String, dynamic>;
    notifyListeners();
  }
}
