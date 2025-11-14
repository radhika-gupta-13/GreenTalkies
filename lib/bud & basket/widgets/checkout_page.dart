import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../colors.dart';
import 'package:greentalkies/backend_config.dart';

class CheckoutPage extends StatefulWidget {
  final String userId;
  final double totalAmount;
  final bool isBuyNow;
  final List<Map<String, dynamic>>? items; // Cart or Buy Now items
  final VoidCallback? onOrderPlaced; // Callback to clear cart

  const CheckoutPage({
    super.key,
    required this.userId,
    required this.totalAmount,
    required this.isBuyNow,
    this.items,
    this.onOrderPlaced,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  late Razorpay _razorpay;
  String? baseUrl;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _initBaseUrl();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initBaseUrl() async {
    final ip = await BackendConfig.getServerIp();
    setState(() {
      baseUrl = BackendConfig.apiBase(ip);
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (baseUrl == null || widget.items == null) return;

    setState(() => isProcessing = true);

    try {
      // Map products to backend format: { product: ObjectId, quantity }
      final productsArray = widget.items!.map((item) {
        final productId = item["productId"] ?? item["_id"];
        final quantity = item["quantity"] ?? 1;
        return {"product": productId, "quantity": quantity};
      }).toList();

      final orderResponse = await http.post(
        Uri.parse('$baseUrl/api/orders/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": widget.userId,
          "cartItems": productsArray,
          "totalAmount": widget.totalAmount,
          "address": _addressController.text,
          "phone": _phoneController.text,
          "paymentId": response.paymentId,
        }),
      );

      if (orderResponse.statusCode == 200 || orderResponse.statusCode == 201) {
        // Clear cart if not Buy Now
        if (!widget.isBuyNow && widget.onOrderPlaced != null) {
          widget.onOrderPlaced!();
          await http.delete(Uri.parse('$baseUrl/api/cart/clear/${widget.userId}'));
        }

        final orderData = json.decode(orderResponse.body)["order"];

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderData: orderData),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order creation failed: ${orderResponse.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating order: $e")),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  void _pay() {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your delivery address")),
      );
      return;
    }
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your phone number")),
      );
      return;
    }

    var options = {
      'key': 'rzp_test_Rdl4HL3NTYlg9b',
      'amount': (widget.totalAmount * 100).toInt(),
      'name': 'GreenTalkies',
      'description': 'Order Payment',
      'prefill': {'contact': _phoneController.text, 'email': ''},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout"), backgroundColor: GTColors.lushGreen),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Delivery Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Enter your delivery address"),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text("Phone Number", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Enter your phone number"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              Text("Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GTColors.lushGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _pay,
                        child: const Text("Pay with Razorpay", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------- Order Detail Screen --------
class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  OrderDetailScreen({super.key, required this.orderData});

  final List<String> stages = ["placed", "confirmed", "shipped", "delivered"];

  @override
  Widget build(BuildContext context) {
    final deliveryDate = DateTime.now().add(const Duration(days: 5));
    final products = List<Map<String, dynamic>>.from(orderData["products"]);
    final currentStatus = (orderData["status"] ?? "placed").toLowerCase();

    int currentStageIndex = stages.indexOf(currentStatus);
    if (currentStageIndex == -1) currentStageIndex = 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details"), backgroundColor: GTColors.lushGreen),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: ${orderData["_id"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Order Status: ${orderData["status"]}"),
            const SizedBox(height: 10),
            Text("Delivery By: ${deliveryDate.day}-${deliveryDate.month}-${deliveryDate.year}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: stages.map((stage) {
                int index = stages.indexOf(stage);
                bool isCompleted = index <= currentStageIndex;
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isCompleted ? GTColors.lushGreen : Colors.grey[300],
                      child: Icon(isCompleted ? Icons.check : Icons.circle_outlined, size: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(stage.capitalize(), style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text("Products:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  final product = p["product"] ?? {};
                  return ListTile(
                    leading: product["image"] != null
                        ? Image.network(product["image"], width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.shopping_bag),
                    title: Text(product["name"] ?? "Unknown Product"),
                    subtitle: Text("Qty: ${p["quantity"] ?? 1}"),
                    trailing: Text("₹${product["price"]?.toStringAsFixed(2) ?? '0.00'}"),
                  );
                },
              ),
            ),
            Text("Total Amount: ₹${orderData["totalAmount"].toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

// -------- String extension for capitalization --------
extension StringCasingExtension on String {
  String capitalize() => length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
