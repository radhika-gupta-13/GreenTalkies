import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/product_model.dart';
import 'product_details.dart';
import 'buy_now.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/backend_config.dart';

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
                  builder: (_) =>
                      ProductDetailPage(product: product, userId: userId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

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
      // Cart
      final cartResp =
          await http.get(Uri.parse('$serverUrl/cart/list/${widget.userId}'));
      if (cartResp.statusCode == 200) {
        final cartData = jsonDecode(cartResp.body) as List;
        if (!mounted) return;
        setState(() {
          isInCart = cartData.any((item) => item['product']['_id'] == widget.product.id);
        });
      }

      // Wishlist
      final wishlistResp =
          await http.get(Uri.parse('$serverUrl/wishlist/list/${widget.userId}'));
      if (wishlistResp.statusCode == 200) {
        final wishlistData = jsonDecode(wishlistResp.body) as List;
        if (!mounted) return;
        setState(() {
          isLiked = wishlistData.any((item) => item['product']['_id'] == widget.product.id);
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
          'quantity': 1,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() => isInCart = true);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Added to cart')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to add to cart')));
      }
    } catch (e) {
      print("Cart error: $e");
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
        setState(() => isLiked = !isLiked);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isLiked ? 'Added to wishlist' : 'Removed from wishlist'),
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
              "quantity": 1,
              "image": widget.product.imageUrl,
            }
          ],
        ),
      ),
    );
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
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              child: Image.asset(
                widget.product.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
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
                          fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${widget.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: GTColors.lushGreen,
                          fontWeight: FontWeight.w900,
                          fontSize: 15),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          iconSize: 22,
                          padding: EdgeInsets.zero,
                          onPressed: addToCart,
                          icon: Icon(
                            isInCart
                                ? Icons.shopping_cart
                                : Icons.add_shopping_cart_outlined,
                            color: GTColors.lushGreen,
                          ),
                        ),
                        IconButton(
                          iconSize: 22,
                          padding: EdgeInsets.zero,
                          onPressed: toggleWishlist,
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: GTColors.berryRed,
                          ),
                        ),
                        IconButton(
                          iconSize: 22,
                          padding: EdgeInsets.zero,
                          onPressed: buyNow,
                          icon: const Icon(
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
