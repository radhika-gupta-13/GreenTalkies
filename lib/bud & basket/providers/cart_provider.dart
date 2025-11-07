import 'package:flutter/material.dart';
import 'package:greentalkies/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  void addProduct(Product product, int quantity) {
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _cartItems[index].quantity += quantity; // increase quantity if already in cart
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  int getTotalItems() {
    int total = 0;
    for (var item in _cartItems) {
      total += item.quantity;
    }
    return total;
  }

  double getTotalPrice() {
    double total = 0;
    for (var item in _cartItems) {
      total += item.product.price * item.quantity;
    }
    return total;
  }
}
