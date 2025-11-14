import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/utils/extensions.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  OrderDetailScreen({super.key, required this.orderData});

  final List<String> stages = ["placed", "confirmed", "shipped", "delivered"];

  @override
  Widget build(BuildContext context) {
    final orderDateStr = orderData["createdAt"] ?? DateTime.now().toString();
    final orderDate = DateTime.tryParse(orderDateStr) ?? DateTime.now();
    final deliveryDate = orderDate.add(const Duration(days: 5));

    final products = List<Map<String, dynamic>>.from(orderData["products"]);
    final currentStatus = ((orderData["status"] ?? "placed") as String).toLowerCase();

    int currentStageIndex = stages.indexOf(currentStatus);
    if (currentStageIndex == -1) currentStageIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: GTColors.lushGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: ${orderData["_id"]}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Order Status: ${currentStatus.capitalize()}"),
            const SizedBox(height: 8),
            Text(
              "Delivery By: ${deliveryDate.day}-${deliveryDate.month}-${deliveryDate.year}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: stages.map((stage) {
                int index = stages.indexOf(stage);
                bool isCompleted = index <= currentStageIndex;
                return Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor:
                                isCompleted ? GTColors.lushGreen : Colors.grey[300],
                            child: Icon(
                              isCompleted ? Icons.check : Icons.circle_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          if (index != stages.length - 1)
                            Expanded(
                              child: Container(
                                height: 3,
                                color: (index < currentStageIndex)
                                    ? GTColors.lushGreen
                                    : Colors.grey[300],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(stage.capitalize(), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text("Products:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  final product = p["product"];
                  return ListTile(
                    leading: product != null && product["image"] != null
                        ? Image.network(product["image"],
                            width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.shopping_bag),
                    title: Text(product?["name"] ?? "Unknown Product"),
                    subtitle: Text("Qty: ${p["quantity"] ?? 1}"),
                    trailing:
                        Text("₹${product?["price"]?.toStringAsFixed(2) ?? '0.00'}"),
                  );
                },
              ),
            ),
            Text("Total Amount: ₹${orderData["totalAmount"].toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GTColors.lushGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                ),
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text("Back to Home", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
