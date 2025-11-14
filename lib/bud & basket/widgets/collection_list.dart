import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/product_model.dart';
import 'product_details.dart';
import 'package:greentalkies/backend_config.dart';
import 'product_card_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CollectionListScreen extends StatefulWidget {
  final String collectionTitle;
  final String userId;

  const CollectionListScreen({super.key, required this.collectionTitle, required this.userId});

  @override
  State<CollectionListScreen> createState() => _CollectionListScreenState();
}

class _CollectionListScreenState extends State<CollectionListScreen> {
  final Set<String> _wishlist = {};
  List<Product> collectionProducts = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCollectionProducts();
  }

  Future<void> fetchCollectionProducts() async {
    setState(() { isLoading = true; error = null; });

    try {
      final ip = await BackendConfig.getServerIp();
      final backendUrl = BackendConfig.apiBase(ip);
      final uri = Uri.parse('$backendUrl/api/products/collection/${Uri.encodeComponent(widget.collectionTitle)}');
      final response = await http.get(uri);

      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          collectionProducts = data.map((json) => Product.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() { error = 'Failed to fetch products: ${response.statusCode}'; isLoading = false; });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { error = 'Error fetching collection products: $e'; isLoading = false; });
    }
  }

  void _addToCart(Product item) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} added to cart!')));
  }

  void _toggleWishlist(Product item) {
    if (!mounted) return;
    setState(() {
      if (_wishlist.contains(item.id)) {
        _wishlist.remove(item.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} removed from wishlist!')));
      } else {
        _wishlist.add(item.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} added to wishlist!')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionTitle),
        backgroundColor: GTColors.lushGreen,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : collectionProducts.isEmpty
                  ? const Center(child: Text('No products found.'))
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: GridView.builder(
                        itemCount: collectionProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemBuilder: (context, index) {
                          final item = collectionProducts[index];
                          return GestureDetector(
                            onTap: () {
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(product: item, userId: widget.userId),
                                ),
                              );
                            },
                            child: ProductCard(product: item, userId: widget.userId, onTap: () {}),
                          );
                        },
                      ),
                    ),
    );
  }
}
