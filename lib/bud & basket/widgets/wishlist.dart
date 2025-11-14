import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:greentalkies/models/product_model.dart';
import 'package:greentalkies/bud & basket/widgets/product_details.dart';
import '/backend_config.dart';

class WishlistScreen extends StatefulWidget {
  final String userId;

  const WishlistScreen({super.key, required this.userId});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Map<String, dynamic>> wishlistItems = [];
  bool isLoading = true;
  String? error;
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
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    if (serverUrl.isEmpty) return;
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(Uri.parse('$serverUrl/wishlist/list/${widget.userId}'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          wishlistItems = data.map((item) {
            final product = item["product"];
            // Use asset image from seeded product
            String imageUrl = product["imageUrl"] ?? "assets/images/default_plant.png";

            return {
              "_id": item["_id"],
              "productId": product["_id"],
              "name": product["name"],
              "price": product["price"] ?? 0.0,
              "image": imageUrl,
              "description": product["description"] ?? "",
            };
          }).toList();
        });
      } else {
        setState(() => error = "Failed to fetch wishlist (${response.statusCode})");
      }
    } catch (e) {
      setState(() => error = "Error fetching wishlist: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> removeItem(String wishlistId) async {
    if (serverUrl.isEmpty) return;
    final url = Uri.parse('$serverUrl/wishlist/remove/${widget.userId}/$wishlistId');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          wishlistItems.removeWhere((item) => item["_id"] == wishlistId);
        });
      } else {
        print("Failed to remove item: ${response.statusCode}");
      }
    } catch (e) {
      print("Error removing item: $e");
    }
  }

  void openProductDetail(Map<String, dynamic> item) {
    final product = Product(
      id: item["productId"],
      name: item["name"],
      price: item["price"].toDouble(),
      description: item["description"],
      imageUrl: item["image"],
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetailPage(product: product, userId: widget.userId)),
    );
  }

  // ---------------- Build Image ----------------
  Widget _buildWishlistItemImage(String imageUrl) {
    if (imageUrl.startsWith("assets/")) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
      );
    } else if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: GTColors.lushGreen.withOpacity(0.1),
            child: const Icon(Icons.local_florist, color: GTColors.lushGreen, size: 40),
          );
        },
      );
    } else {
      return Container(
        color: GTColors.lushGreen.withOpacity(0.1),
        child: const Icon(Icons.local_florist, color: GTColors.lushGreen, size: 40),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GTColors.lushGreen,
        title: const Text('Your Wishlist'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : wishlistItems.isEmpty
                  ? _buildEmptyWishlist()
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: wishlistItems.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final item = wishlistItems[index];
                        return GestureDetector(
                          onTap: () => openProductDetail(item),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12)),
                                    child: _buildWishlistItemImage(item["image"]),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item["name"],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 5),
                                      Text("₹${item["price"]}",
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: GTColors.lushGreen)),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                            onPressed: () => removeItem(item["_id"]),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: GTColors.lushGreen.withOpacity(0.7)),
          const SizedBox(height: 20),
          const Text(
            'Your Wishlist is Empty',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add your favorite plants and products here.',
            style: TextStyle(fontSize: 16, color: Colors.black38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
