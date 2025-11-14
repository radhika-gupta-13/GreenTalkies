import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/bud & basket/widgets/checkout_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/backend_config.dart';

class CartScreen extends StatefulWidget {
  final String userId;

  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
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
    fetchCartItems();
  }

  // ---------------- Fetch Cart ----------------
  Future<void> fetchCartItems() async {
    if (serverUrl.isEmpty) return;
    setState(() => isLoading = true);

    try {
      final response =
          await http.get(Uri.parse('$serverUrl/cart/list/${widget.userId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          cartItems = data.map((item) {
            final product = item["product"];
            // Use asset fallback if imageUrl is missing
            final imageUrl = product["imageUrl"] != null &&
                    product["imageUrl"].toString().isNotEmpty
                ? product["imageUrl"]
                : "assets/images/default_plant.png";

            return {
              "cartId": item["_id"],
              "productId": product["_id"],
              "name": product["name"],
              "price": product["price"],
              "quantity": item["quantity"],
              "imageUrl": imageUrl,
            };
          }).toList();
        });
      } else {
        setState(() => cartItems = []);
      }
    } catch (e) {
      print("Fetch cart error: $e");
      setState(() => cartItems = []);
    }

    setState(() => isLoading = false);
  }

  // ---------------- Total ----------------
  double getTotal() {
    double total = 0;
    for (var item in cartItems) {
      total += (item["price"] * item["quantity"]);
    }
    return total;
  }

  // ---------------- Clear Cart ----------------
  Future<void> clearCart() async {
    if (serverUrl.isEmpty) return;

    try {
      final response =
          await http.delete(Uri.parse('$serverUrl/cart/clear/${widget.userId}'));

      if (response.statusCode == 200) {
        print("Cart cleared successfully");
      } else {
        print("Failed to clear cart: ${response.statusCode}");
      }
    } catch (e) {
      print("Error clearing cart: $e");
    }
  }

  // ---------------- Update Quantity ----------------
  Future<void> updateQuantity(String productId, int newQuantity) async {
    if (serverUrl.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$serverUrl/cart/set'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'productId': productId,
          'quantity': newQuantity,
        }),
      );

      if (response.statusCode == 200) {
        fetchCartItems();
      } else {
        print("Failed to update quantity: ${response.statusCode}");
      }
    } catch (e) {
      print("Update quantity error: $e");
    }
  }

  // ---------------- Remove Item ----------------
  Future<void> removeFromCart(String productId) async {
    if (serverUrl.isEmpty) return;

    try {
      final response = await http
          .delete(Uri.parse('$serverUrl/cart/remove/${widget.userId}/$productId'));

      if (response.statusCode == 200) {
        fetchCartItems();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Removed from cart")));
      } else {
        print("Failed to remove item: ${response.statusCode}");
      }
    } catch (e) {
      print("Remove error: $e");
    }
  }

  // ---------------- Checkout ----------------
  void checkout() {
    if (cartItems.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          userId: widget.userId,
          isBuyNow: false,
          totalAmount: getTotal(),
          items: cartItems,
          onOrderPlaced: () async {
            await clearCart();
            setState(() => cartItems.clear());
          },
        ),
      ),
    );
  }

  // ---------------- Build Image ----------------
  Widget _buildCartItemImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('assets/')) {
        return Image.asset(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        );
      } else {
        return Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              "assets/images/default_plant.png",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            );
          },
        );
      }
    } else {
      return Image.asset(
        "assets/images/default_plant.png",
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTColors.backgroundBeige,
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(color: Colors.white)),
        backgroundColor: GTColors.lushGreen,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: ListTile(
                              leading:
                                  ClipRRect(borderRadius: BorderRadius.circular(8),
                                      child: _buildCartItemImage(item["imageUrl"])),
                              title: Text(item["name"] ?? "Product"),
                              subtitle: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      size: 20,
                                    ),
                                    onPressed: item["quantity"] > 1
                                        ? () => updateQuantity(
                                            item["productId"],
                                            item["quantity"] - 1)
                                        : null,
                                  ),
                                  Text("${item["quantity"]}",
                                      style:
                                          const TextStyle(fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      size: 20,
                                    ),
                                    onPressed: () => updateQuantity(
                                        item["productId"],
                                        item["quantity"] + 1),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "₹${(item["price"] * item["quantity"]).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        color: Colors.black54),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () =>
                                    removeFromCart(item["productId"]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total: ₹${getTotal().toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: GTColors.primaryGreen,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GTColors.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            onPressed: checkout,
                            child: const Text(
                              "Proceed to Checkout",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
