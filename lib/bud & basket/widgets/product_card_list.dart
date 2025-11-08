import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/product_model.dart';
import 'package:greentalkies/bud & basket/widgets/product_details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:network_info_plus/network_info_plus.dart';

/// Horizontally scrollable list of product cards
class ProductCardList extends StatelessWidget {
  final List<Product> products;
  final String userId;

  const ProductCardList({
    super.key,
    required this.products,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 10),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            userId: userId,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product, userId: userId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Individual product card with cart, wishlist, and buy now
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final String userId;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.userId,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isInCart = false;
  bool isLiked = false;
  String serverIp = "10.0.2.2"; // default Android emulator

  @override
  void initState() {
    super.initState();
    _getLocalIp();
  }

  /// Fetch local IP dynamically
  Future<void> _getLocalIp() async {
    final info = NetworkInfo();
    final ip = await info.getWifiIP();
    if (ip != null) {
      setState(() {
        serverIp = ip;
      });
      _checkInitialStatus(); // fetch cart & wishlist after getting IP
    }
  }

  /// Fetch current cart and wishlist status
  Future<void> _checkInitialStatus() async {
    try {
      // Cart
      final cartResp = await http.get(Uri.parse('http://$serverIp:4000/cart/${widget.userId}'));
      if (cartResp.statusCode == 200) {
        final cartData = jsonDecode(cartResp.body) as List;
        setState(() {
          isInCart = cartData.any((item) => item['product']['_id'] == widget.product.id);
        });
      }

      // Wishlist
      final wishlistResp = await http.get(Uri.parse('http://$serverIp:4000/wishlist/${widget.userId}'));
      if (wishlistResp.statusCode == 200) {
        final wishlistData = jsonDecode(wishlistResp.body) as List;
        setState(() {
          isLiked = wishlistData.any((item) => item['product']['_id'] == widget.product.id);
        });
      }
    } catch (e) {
      print("Failed to fetch initial status: $e");
    }
  }

  /// Add product to cart and refresh status
  Future<void> addToCart() async {
    try {
      final response = await http.post(
        Uri.parse('http://$serverIp:4000/cart/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'productId': widget.product.id,
          'quantity': 1,
        }),
      );
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Added to cart')),
      );
      await _checkInitialStatus(); // refresh button
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add to cart')),
      );
    }
  }

  /// Toggle wishlist and refresh status
  Future<void> toggleWishlist() async {
    try {
      final response = await http.post(
        Uri.parse('http://$serverIp:4000/wishlist/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'productId': widget.product.id,
        }),
      );
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Wishlist updated')),
      );
      await _checkInitialStatus(); // refresh button
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update wishlist')),
      );
    }
  }

  /// Place order (Buy Now)
  Future<void> buyNow() async {
    try {
      final response = await http.post(
        Uri.parse('http://$serverIp:4000/order/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'productId': widget.product.id,
          'quantity': 1,
        }),
      );
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Order placed successfully')),
      );
      await _checkInitialStatus(); // refresh buttons
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: GTColors.primaryBaseDark.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.asset(
                    widget.product.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (widget.product.discount != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: GTColors.berryRed,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        widget.product.discount!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Product info + actions
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: GTColors.primaryBaseDark,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${widget.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: GTColors.lushGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          onPressed: addToCart,
                          icon: Icon(
                            isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                            color: GTColors.lushGreen,
                          ),
                        ),
                        IconButton(
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          onPressed: toggleWishlist,
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: GTColors.berryRed,
                          ),
                        ),
                        IconButton(
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          onPressed: buyNow,
                          icon: Icon(
                            Icons.payment,
                            color: GTColors.primaryBaseDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
