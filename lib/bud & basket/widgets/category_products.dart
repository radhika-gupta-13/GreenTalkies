import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/product_model.dart';
import 'product_card_list.dart';
import 'product_details.dart';
import 'package:greentalkies/backend_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;
  final String userId;

  const CategoryProductsScreen({required this.categoryName, required this.userId, super.key});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> products = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() { isLoading = true; error = null; });

    try {
      final ip = await BackendConfig.getServerIp();
      final backendUrl = BackendConfig.apiBase(ip);
      final uri = Uri.parse('$backendUrl/api/products/category/${Uri.encodeComponent(widget.categoryName)}');
      final response = await http.get(uri);

      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          products = data.map((json) => Product.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() { error = 'Failed to load products: ${response.statusCode}'; isLoading = false; });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { error = 'Error fetching products: $e'; isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName} Products'),
        backgroundColor: GTColors.lushGreen,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : products.isEmpty
                  ? const Center(child: Text('No products found.'))
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: GridView.builder(
                        itemCount: products.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            userId: widget.userId,
                            onTap: () {
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(product: product, userId: widget.userId),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}
