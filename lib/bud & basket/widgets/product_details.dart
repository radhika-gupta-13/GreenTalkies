import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/product_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

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
  List<Map<String, dynamic>> reviews = [];
  String baseUrl = "http://"; // will be updated dynamically

  @override
  void initState() {
    super.initState();
    initBaseUrl();
    fetchReviews();
    final wishlist = Provider.of<WishlistProvider>(context, listen: false);
    isWishlist = wishlist.isInWishlist(widget.product.id);
  }

  Future<void> initBaseUrl() async {
    final info = NetworkInfo();
    final ip = await info.getWifiIP(); // fetch local IP dynamically
    setState(() {
      baseUrl = "http://${ip ?? "127.0.0.1"}:5000";
    });
  }

  Future<void> fetchReviews() async {
    if (baseUrl.isEmpty) return;
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products/${widget.product.id}/reviews'));
      if (response.statusCode == 200) {
        setState(() {
          reviews = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      }
    } catch (e) {
      // handle error silently
    }
  }

  Future<void> addToCart() async {
    final url = Uri.parse("$baseUrl/cart/add");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body:
            jsonEncode({'productId': widget.product.id, 'quantity': quantity}),
      );
      if (response.statusCode == 200) {
        Provider.of<CartProvider>(context, listen: false)
            .addProduct(widget.product, quantity);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to cart!')),
        );
      } else {
        throw Exception('Failed');
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add to cart.')),
      );
    }
  }

  Future<void> buyNow() async {
    final url = Uri.parse("$baseUrl/order/create");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body:
            jsonEncode({'productId': widget.product.id, 'quantity': quantity}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
      } else {
        throw Exception('Failed');
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order.')),
      );
    }
  }

  void toggleWishlist() {
    final wishlist = Provider.of<WishlistProvider>(context, listen: false);
    wishlist.toggleProduct(widget.product);
    setState(() {
      isWishlist = wishlist.isInWishlist(widget.product.id);
    });
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
            icon: Icon(isWishlist ? Icons.favorite : Icons.favorite_border,
                color: Colors.red),
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
              child: Image.asset(
                widget.product.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
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
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          }),
                      Text(quantity.toString(),
                          style: const TextStyle(fontSize: 16)),
                      IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text('Reviews',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            reviews.isEmpty
                ? const Text('No reviews yet.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(review['user']),
                        subtitle: Text(review['comment']),
                        trailing: Icon(Icons.star, color: Colors.amber),
                      );
                    },
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
