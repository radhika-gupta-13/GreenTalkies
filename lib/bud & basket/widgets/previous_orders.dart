import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';

class PreviousOrdersScreen extends StatefulWidget {
  final String userId;

  const PreviousOrdersScreen({super.key, required this.userId});

  @override
  State<PreviousOrdersScreen> createState() => _PreviousOrdersScreenState();
}

class _PreviousOrdersScreenState extends State<PreviousOrdersScreen> {
  List<Map<String, dynamic>> previousOrders = []; // Replace with real order objects later

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GTColors.lushGreen,
        title: const Text('Previous Orders'),
      ),
      body: previousOrders.isEmpty
          ? _buildEmptyOrders()
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: previousOrders.length,
              itemBuilder: (context, index) {
                final order = previousOrders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag, color: GTColors.lushGreen),
                    title: Text(order["name"]),
                    subtitle: Text("Status: ${order["status"]}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        if (!mounted) return;
                        setState(() {
                          previousOrders.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyOrders() {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 80, color: GTColors.lushGreen.withOpacity(0.7)),
              const SizedBox(height: 20),
              const Text(
                'No Previous Orders',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              const Text(
                'You haven’t placed any orders yet.',
                style: TextStyle(fontSize: 16, color: Colors.black38),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
