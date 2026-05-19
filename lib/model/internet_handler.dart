import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:imat/model/imat/credit_card.dart';
import 'package:imat/model/imat/customer.dart';
import 'package:imat/model/imat/shopping_cart.dart';
import 'package:imat/model/imat/user.dart';
import 'package:imat/model/imat/util/functions.dart';

class InternetHandler {
  static const baseURL = 'https://dat216.cse.chalmers.se/imat2/api/';

  static int kGroupId = 0;

  static const apiKey = 'a27bg892h-jgdfg6-81kwna22lmq-sidfha9361zw-jj221112abkm77';

  static const apiKeyHeader = {'X-API-Key': apiKey};
  static const apiKeyPlusJsonHeader = {
    'X-API-Key': apiKey,
    'Content-Type': 'application/json',
  };

  static String getImageUrl(int pid) => '${baseURL}image/$pid';

  // ── GET endpoints ─────────────────────────────────────────────────────────
  static Future<String> getProducts() => _get('products');
  static Future<String> getDetails() => _get('details');
  static Future<String> getCreditCard() => _get('creditcard', id: kGroupId);
  static Future<String> getCustomer() => _get('customer', id: kGroupId);
  static Future<String> getUser() => _get('user', id: kGroupId);
  static Future<String> getFavorites() => _get('favorites', id: kGroupId);
  static Future<String> getOrders() => _get('orders', id: kGroupId);
  static Future<String> getShoppingCart() => _get('shoppingcart', id: kGroupId);
  static Future<String> getExtras() => _get('extras', id: kGroupId);

  static Future<String> _get(String endpoint, {int id = 0}) async {
    final url = _url(endpoint, cid: id);
    try {
      final res = await http.get(Uri.parse(url), headers: apiKeyHeader);
      if (res.statusCode == 200) return res.body;
      dbugPrint('GET $endpoint → ${res.statusCode}');
    } catch (e) {
      dbugPrint('GET $endpoint error: $e');
    }
    return '';
  }

  // ── PUT endpoints ─────────────────────────────────────────────────────────
  static Future<String> setCreditCard(CreditCard card) =>
      _put('creditcard', jsonEncode(card), cid: kGroupId);

  static Future<String> setCustomer(Customer customer) =>
      _put('customer', jsonEncode(customer), cid: kGroupId);

  static Future<String> setUser(User user) =>
      _put('user', jsonEncode(user), cid: kGroupId);

  static Future<String> setShoppingCart(ShoppingCart cart) =>
      _put('shoppingcart', jsonEncode(cart), cid: kGroupId);

  static Future<String> setExtras(Map<String, dynamic> extras) =>
      _put('extras', jsonEncode(extras), cid: kGroupId);

  static Future<String> addFavorite(int pid) =>
      _put('favorites', jsonEncode(pid), cid: kGroupId, pid: pid);

  static Future<String> placeOrder() =>
      _put('orders', jsonEncode([]), cid: kGroupId);

  static Future<String> _put(String endpoint, String body, {int cid = 0, int pid = 0}) async {
    final url = _url(endpoint, cid: cid, pid: pid);
    try {
      final res = await http.put(Uri.parse(url), headers: apiKeyPlusJsonHeader, body: body);
      if (res.statusCode == 200) return res.body;
      dbugPrint('PUT $endpoint → ${res.statusCode}');
    } catch (e) {
      dbugPrint('PUT $endpoint error: $e');
    }
    return '';
  }

  // ── DELETE endpoints ──────────────────────────────────────────────────────
  static Future<String> removeFavorite(int pid) =>
      _delete('favorites', cid: kGroupId, pid: pid);

  static Future<String> _delete(String endpoint, {int cid = 0, int pid = 0}) async {
    final url = _url(endpoint, cid: cid, pid: pid);
    try {
      final res = await http.delete(Uri.parse(url), headers: apiKeyHeader);
      if (res.statusCode == 200) return res.body;
      dbugPrint('DELETE $endpoint → ${res.statusCode}');
    } catch (e) {
      dbugPrint('DELETE $endpoint error: $e');
    }
    return '';
  }

  static String _url(String endpoint, {int cid = 0, int pid = 0}) {
    var path = baseURL + endpoint;
    if (cid > 0) path = '$path/$cid';
    if (pid > 0) path = '$path/$pid';
    return path;
  }

  // ── Image cache ───────────────────────────────────────────────────────────
  static final Map<String, Uint8List> _imageCache = {};
  static final Set<String> _loading = {};
  static final Queue<String> _queue = Queue();
  static const _maxConcurrent = 5;
  static int _active = 0;

  // Returns a cached Image widget, or null and starts background fetch.
  // Call inside a watch<ImatDataHandler>() context so the widget rebuilds.
  static Image? cachedImage(int pid, {BoxFit fit = BoxFit.cover}) {
    final url = getImageUrl(pid);
    final bytes = _imageCache[url];
    if (bytes != null) return Image.memory(bytes, fit: fit);
    _enqueue(url);
    return null;
  }

  static void _enqueue(String url) {
    if (_imageCache.containsKey(url) || _loading.contains(url) || _queue.contains(url)) return;
    _queue.add(url);
    _drainQueue();
  }

  static void _drainQueue() {
    while (_active < _maxConcurrent && _queue.isNotEmpty) {
      final url = _queue.removeFirst();
      _loading.add(url);
      _active++;
      _fetchImage(url).whenComplete(() {
        _loading.remove(url);
        _active--;
        _drainQueue();
      });
    }
  }

  static Future<void> _fetchImage(String url) async {
    try {
      final res = await http.get(Uri.parse(url), headers: apiKeyHeader);
      if (res.statusCode == 200) _imageCache[url] = res.bodyBytes;
    } catch (e) {
      dbugPrint('Image fetch error $url: $e');
    }
  }
}
