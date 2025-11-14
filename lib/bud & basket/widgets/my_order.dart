import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/backend_config.dart';
import 'order_detail.dart';
import 'package:greentalkies/utils/extensions.dart';

class MyOrdersScreen extends StatefulWidget {
  final String userId;
  const MyOrdersScreen({super.key, required this.userId});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String? error;
  String? baseUrl;

  @override
  void initState() {
    super.initState();
    _initBaseUrl();
  }

  Future<void> _initBaseUrl() async {
    final ip = await BackendConfig.getServerIp();
    baseUrl = BackendConfig.apiBase(ip);
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    if (baseUrl == null) return;
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response =
          await http.get(Uri.parse('$baseUrl/orders/list/${widget.userId}'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() => orders = data);
      } else {
        setState(() => error = "Failed to fetch orders (${response.statusCode})");
      }
    } catch (e) {
      setState(() => error = "Error fetching orders: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: GTColors.lushGreen,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : orders.isEmpty
                  ? _buildEmptyOrders()
                  : RefreshIndicator(
                      onRefresh: fetchOrders,
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final totalAmount = (order["totalAmount"] ?? 0).toDouble();
                          final status = ((order["status"] ?? "placed") as String).capitalize();
                          final orderId = order["_id"] ?? "";
                          final date = order["createdAt"] ?? "";

                          // Preview first product
                          final products = List<Map<String, dynamic>>.from(order["products"]);
                          String productPreview = "";
                          if (products.isNotEmpty) {
                            final firstProduct = products[0]["product"];
                            final qty = products[0]["quantity"] ?? 1;
                            productPreview = "${firstProduct?["name"] ?? "Unknown Product"} x$qty";
                            if (products.length > 1) {
                              productPreview += " +${products.length - 1} more";
                            }
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                            child: ListTile(
                              title: Text("Order #${orderId.substring(0, 6)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Status: $status"),
                                  Text("Date: ${date.toString().substring(0, 10)}"),
                                  if (productPreview.isNotEmpty) Text(productPreview),
                                ],
                              ),
                              trailing: Text("₹${totalAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        OrderDetailScreen(orderData: order),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long,
              size: 80, color: GTColors.lushGreen.withOpacity(0.7)),
          const SizedBox(height: 20),
          const Text(
            'No Orders Yet',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your orders will appear here after you place one.',
            style: TextStyle(fontSize: 16, color: Colors.black38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
