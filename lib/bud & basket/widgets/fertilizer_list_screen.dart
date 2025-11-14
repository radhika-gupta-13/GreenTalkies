import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/fertilzer_model.dart';
import 'package:greentalkies/models/product_model.dart';
import 'package:greentalkies/bud & basket/fertilizer_service.dart';
import 'package:greentalkies/bud & basket/widgets/product_card_list.dart';
import 'package:greentalkies/bud & basket/widgets/product_details.dart';

class FertilizerListScreen extends StatefulWidget {
  final String userId;
  final String serverIp;

  const FertilizerListScreen({
    super.key,
    required this.userId,
    required this.serverIp,
  });

  @override
  State<FertilizerListScreen> createState() => _FertilizerListScreenState();
}

class _FertilizerListScreenState extends State<FertilizerListScreen> {
  late Future<List<Fertilizer>> _futureFertilizers;
  late FertilizerService _service;

  @override
  void initState() {
    super.initState();
    _service = FertilizerService(serverIp: widget.serverIp);
    _futureFertilizers = _service.fetchFertilizers();
  }

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

  Future<void> _refreshFertilizers() async {
    try {
      final result = await _service.fetchFertilizers();
      if (!mounted) return;
      setState(() {
        _futureFertilizers = Future.value(result);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to refresh fertilizers')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organic Fertilizers'),
        backgroundColor: GTColors.lushGreen,
      ),
      body: FutureBuilder<List<Fertilizer>>(
        future: _futureFertilizers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: GTColors.lushGreen),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: GTColors.berryRed),
                  const SizedBox(height: 10),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _refreshFertilizers,
                    style: ElevatedButton.styleFrom(backgroundColor: GTColors.lushGreen),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.local_florist, size: 60, color: GTColors.lushGreen),
                  SizedBox(height: 10),
                  Text('No fertilizers found.'),
                ],
              ),
            );
          }

          final fertilizers = snapshot.data!;
          final products = _convertToProducts(fertilizers);

          return RefreshIndicator(
            onRefresh: _refreshFertilizers,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
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
                          builder: (_) =>
                              ProductDetailPage(product: product, userId: widget.userId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
