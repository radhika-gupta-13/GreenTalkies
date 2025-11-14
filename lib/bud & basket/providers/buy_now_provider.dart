import 'package:flutter/material.dart';

class BuyNowProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void setItems(List<Map<String, dynamic>> products) {
    _items = products.map((p) => {...p}).toList();
    notifyListeners();
  }

  void addItem(Map<String, dynamic> product) {
    final index = _items.indexWhere((item) => item['productId'] == product['productId']);
    if (index != -1) {
      _items[index]['quantity'] += product['quantity'];
    } else {
      _items.add({...product});
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item['productId'] == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int delta) {
    final index = _items.indexWhere((item) => item['productId'] == productId);
    if (index != -1) {
      _items[index]['quantity'] += delta;
      if (_items[index]['quantity'] <= 0) _items.removeAt(index);
      notifyListeners();
    }
  }

  double getTotal() {
    double total = 0;
    for (var item in _items) {
      total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
    }
    return total;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
