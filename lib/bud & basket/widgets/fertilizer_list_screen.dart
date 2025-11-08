import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/fertilzer_model.dart';
import 'package:greentalkies/models/product_model.dart';
import 'package:greentalkies/bud & basket/fertilizer_service.dart';
import 'package:greentalkies/bud & basket/widgets/product_card_list.dart';
import 'package:greentalkies/bud & basket/widgets/product_details.dart'; // ProductDetailPage

class FertilizerListScreen extends StatefulWidget {
  final String userId;

  const FertilizerListScreen({super.key, required this.userId});

  @override
  State<FertilizerListScreen> createState() => _FertilizerListScreenState();
}

class _FertilizerListScreenState extends State<FertilizerListScreen> {
  final _service = FertilizerService();
  late Future<List<Fertilizer>> _futureFertilizers;

  @override
  void initState() {
    super.initState();
    _futureFertilizers = _service.fetchFertilizers();
  }

  // Convert Fertilizer to Product
  List<Product> _convertToProducts(List<Fertilizer> fertilizers) {
    return fertilizers
        .map((f) => Product(
              id: f.id,
              name: f.name,
              description: f.description,
              price: f.price,
              imageUrl: f.imageUrl,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organic Fertilizers'),
        backgroundColor: GTColors.lushGreen,
        foregroundColor: Colors.white,
      ),
      backgroundColor: GTColors.background,
      body: FutureBuilder<List<Fertilizer>>(
        future: _futureFertilizers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: GTColors.lushGreen));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No fertilizers found.'));
          }

          final fertilizers = snapshot.data!;
          final products = _convertToProducts(fertilizers);

          // Use GridView with ProductCard for full grid layout
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.70,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  userId: widget.userId,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailPage(product: product, userId: widget.userId),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
