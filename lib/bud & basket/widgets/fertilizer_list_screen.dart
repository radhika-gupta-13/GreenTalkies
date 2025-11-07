import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/fertilzer_model.dart';
import 'package:greentalkies/bud & basket/fertilizer_service.dart';

class FertilizerListScreen extends StatefulWidget {
  const FertilizerListScreen({super.key});

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
          return Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              itemCount: fertilizers.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.70,
              ),
              itemBuilder: (context, index) {
                final item = fertilizers[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Image.asset(
                          item.imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: GTColors.darkText),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 5),
                                Text(item.description,
                                    style: const TextStyle(
                                        color: Colors.black54, fontSize: 12),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Text('₹${item.price}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: GTColors.lushGreen)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
