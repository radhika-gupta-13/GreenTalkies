import 'package:flutter/material.dart';
import 'package:greentalkies/models/product_model.dart';

class WishlistProvider with ChangeNotifier {
  final List<Product> _wishlist = [];

  List<Product> get wishlist => _wishlist;

  bool isInWishlist(String productId) {
    return _wishlist.any((p) => p.id == productId);
  }

  void toggleProduct(Product product) {
    if (isInWishlist(product.id)) {
      _wishlist.removeWhere((p) => p.id == product.id);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }

  void addProduct(Product product) {
    if (!isInWishlist(product.id)) {
      _wishlist.add(product);
      notifyListeners();
    }
  }

  void removeProduct(String productId) {
    _wishlist.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void clear() {
    _wishlist.clear();
    notifyListeners();
  }
}
