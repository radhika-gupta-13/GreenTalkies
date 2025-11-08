import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';

class CurrentOrdersScreen extends StatefulWidget {
  final String userId;

  const CurrentOrdersScreen({super.key, required this.userId});

  @override
  State<CurrentOrdersScreen> createState() => _CurrentOrdersScreenState();
}

class _CurrentOrdersScreenState extends State<CurrentOrdersScreen> {
  List<String> currentOrders = []; // Replace with real order objects later

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GTColors.lushGreen,
        title: const Text('Current Orders'),
      ),
      body: currentOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: GTColors.lushGreen.withOpacity(0.7),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Current Orders',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'You have not placed any orders yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: currentOrders.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.local_shipping, color: GTColors.lushGreen),
                    title: Text(currentOrders[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          currentOrders.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
