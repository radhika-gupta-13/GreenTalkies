import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';

class WishlistScreen extends StatefulWidget {
  final String userId;

  const WishlistScreen({super.key, required this.userId});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<String> wishlistItems = []; // Replace with real product objects later

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GTColors.lushGreen,
        title: const Text('Wishlist'),
      ),
      body: wishlistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: GTColors.lushGreen.withOpacity(0.7),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your Wishlist is Empty',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Add your favorite plants and products here.',
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
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.local_florist, color: GTColors.lushGreen),
                    title: Text(wishlistItems[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          wishlistItems.removeAt(index);
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
