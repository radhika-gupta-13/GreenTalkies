import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'checkout_page.dart';

class BuyNowScreen extends StatefulWidget {
  final String userId;
  final List<Map<String, dynamic>> products; // Products to buy immediately

  const BuyNowScreen({super.key, required this.userId, required this.products});

  @override
  State<BuyNowScreen> createState() => _BuyNowScreenState();
}

class _BuyNowScreenState extends State<BuyNowScreen> {
  late List<Map<String, dynamic>> buyItems;

  @override
  void initState() {
    super.initState();
    buyItems = widget.products.map((p) {
      // Ensure image fallback
      final imageUrl = p["image"] != null && p["image"].toString().isNotEmpty
          ? p["image"]
          : "assets/images/default_plant.png";
      return {...p, "imageUrl": imageUrl};
    }).toList();
  }

  // Update quantity locally
  void updateQuantity(String productId, int delta) {
    setState(() {
      final index = buyItems.indexWhere((item) => item["productId"] == productId);
      if (index != -1) {
        buyItems[index]["quantity"] += delta;
        if (buyItems[index]["quantity"] <= 0) buyItems.removeAt(index);
      }
    });
  }

  // Calculate total
  double getTotal() {
    double total = 0;
    for (var item in buyItems) {
      total += (item["price"] ?? 0) * (item["quantity"] ?? 1);
    }
    return total;
  }

  // Navigate to unified CheckoutPage
  void checkout() {
    if (buyItems.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          userId: widget.userId,
          isBuyNow: true,
          totalAmount: getTotal(),
          items: buyItems,
        ),
      ),
    );
  }

  // ---------------- Build image widget with fallback ----------------
  Widget _buildItemImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            "assets/images/default_plant.png",
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GTColors.primaryGreen,
        title: const Text('Buy Now'),
      ),
      body: buyItems.isEmpty
          ? _buildEmptyBuyNow()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: buyItems.length,
                    itemBuilder: (context, index) {
                      final item = buyItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildItemImage(item["imageUrl"]),
                          ),
                          title: Text(item["name"] ?? "Product"),
                          subtitle: Text(
                              "Price: ₹${item["price"]}  |  Qty: ${item["quantity"]}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.orangeAccent),
                                onPressed: () => updateQuantity(item["productId"], -1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.green),
                                onPressed: () => updateQuantity(item["productId"], 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: GTColors.primaryGreen.withOpacity(0.1),
                    border: Border(top: BorderSide(color: GTColors.primaryGreen)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total: ₹${getTotal().toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: checkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GTColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 12),
                        ),
                        child: const Text("Checkout", style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyBuyNow() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 80, color: GTColors.primaryGreen.withOpacity(0.7)),
          const SizedBox(height: 20),
          const Text(
            'No products selected',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          const Text(
            'Select products to buy now.',
            style: TextStyle(fontSize: 16, color: Colors.black38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
