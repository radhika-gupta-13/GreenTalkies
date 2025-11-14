import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/product_model.dart';
import 'buy_now.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/backend_config.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final String userId;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.userId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  bool isWishlist = false;
  bool isInCart = false;
  String serverUrl = "";

  @override
  void initState() {
    super.initState();
    _initServerUrl();
  }

  Future<void> _initServerUrl() async {
    final ip = await BackendConfig.getServerIp();
    if (!mounted) return;
    setState(() {
      serverUrl = BackendConfig.apiBase(ip);
    });
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    if (serverUrl.isEmpty) return;
    try {
      // Check cart status
      final cartResp = await http.get(Uri.parse('$serverUrl/cart/list/${widget.userId}'));
      if (cartResp.statusCode == 200) {
        final cartData = jsonDecode(cartResp.body) as List;
        if (!mounted) return;
        setState(() {
          isInCart = cartData.any((item) => item['product']['_id'] == widget.product.id);
        });
      }

      // Check wishlist status
      final wishlistResp = await http.get(Uri.parse('$serverUrl/wishlist/list/${widget.userId}'));
      if (wishlistResp.statusCode == 200) {
        final wishlistData = jsonDecode(wishlistResp.body) as List;
        if (!mounted) return;
        setState(() {
          isWishlist = wishlistData.any((item) => item['product']['_id'] == widget.product.id);
        });
      }
    } catch (e) {
      print("Initial status error: $e");
    }
  }

  Future<void> addToCart() async {
    if (serverUrl.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/cart/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'productId': widget.product.id,
          'quantity': quantity,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() => isInCart = true);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Added to cart')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add to cart: ${response.body}')));
      }
    } catch (e) {
      print("Add to cart error: $e");
    }
  }

  Future<void> toggleWishlist() async {
    if (serverUrl.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/wishlist/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'productId': widget.product.id,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() => isWishlist = !isWishlist);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isWishlist ? 'Added to wishlist' : 'Removed from wishlist'),
        ));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Wishlist update failed: ${response.body}')));
      }
    } catch (e) {
      print("Wishlist error: $e");
    }
  }

  void buyNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuyNowScreen(
          userId: widget.userId,
          products: [
            {
              "productId": widget.product.id,
              "name": widget.product.name,
              "price": widget.product.price,
              "quantity": quantity,
              "image": widget.product.imageUrl,
            }
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTColors.background,
      appBar: AppBar(
        backgroundColor: GTColors.lushGreen,
        title: Text(widget.product.name, style: const TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(
              isWishlist ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: toggleWishlist,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: widget.product.imageUrl.isNotEmpty
                  ? Image.asset(
                      widget.product.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 250,
                      color: GTColors.lushGreen.withOpacity(0.1),
                      child: const Icon(Icons.local_florist,
                          color: GTColors.lushGreen, size: 60),
                    ),
            ),
            const SizedBox(height: 15),
            Text(widget.product.name,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: GTColors.darkText)),
            const SizedBox(height: 5),
            Text('₹${widget.product.price}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GTColors.lushGreen)),
            const SizedBox(height: 15),
            Text(widget.product.description,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Quantity:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 15),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (quantity > 1) setState(() => quantity--);
                          }),
                      Text(quantity.toString(),
                          style: const TextStyle(fontSize: 16)),
                      IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() => quantity++);
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: GTColors.lushGreen,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: addToCart,
                  child: const Text('Add to Cart')),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  onPressed: buyNow,
                  child: const Text('Buy Now')),
            ),
          ],
        ),
      ),
    );
  }
}
