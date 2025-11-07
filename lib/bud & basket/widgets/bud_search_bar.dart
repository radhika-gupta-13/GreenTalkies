import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/product_model.dart';

class BudBasketSearchBar extends StatefulWidget {
  final List<Product> allProducts;

  const BudBasketSearchBar({super.key, required this.allProducts});

  @override
  State<BudBasketSearchBar> createState() => _BudBasketSearchBarState();
}

class _BudBasketSearchBarState extends State<BudBasketSearchBar> {
  final TextEditingController _controller = TextEditingController();
  List<Product> _searchResults = [];

  // Popular searches (dummy keywords)
  final List<String> _popularSearches = [
    'Snake Plant',
    'Aloe Vera',
    'Terracotta Pot',
    'Spider Plant',
    'Peace Lily',
  ];

  void _performSearch(String query) {
    final lowerQuery = query.toLowerCase();

    final categoryMap = {
      'plants': ['fiddle', 'snake', 'monstera', 'aloe', 'succulent', 'zz'],
      'pet-friendly': ['spider', 'areca', 'bamboo', 'calathea', 'parlor'],
      'indoor air purifiers': ['snake', 'peace', 'aloe', 'areca', 'rubber'],
      'terracotta': ['classic', 'terracotta', 'mini', 'large', 'planter', 'bowl']
    };

    List<Product> results = [];

    if (categoryMap.containsKey(lowerQuery)) {
      results = widget.allProducts
          .where((p) => categoryMap[lowerQuery]!
              .any((keyword) => p.name.toLowerCase().contains(keyword)))
          .toList();
    } else {
      results = widget.allProducts
          .where((p) =>
              p.name.toLowerCase().contains(lowerQuery) ||
              p.description.toLowerCase().contains(lowerQuery))
          .toList();
    }

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _controller.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bud & Basket'),
        backgroundColor: GTColors.lushGreen,
      ),
      backgroundColor: GTColors.background,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search products or categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _performSearch,
            ),
            const SizedBox(height: 10),

            // If no query, show popular searches
            if (!isSearching)
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular Searches:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: GTColors.darkText,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _popularSearches.map((keyword) {
                        return GestureDetector(
                          onTap: () {
                            _controller.text = keyword;
                            _performSearch(keyword);
                          },
                          child: Chip(
                            label: Text(keyword),
                            backgroundColor: GTColors.lushGreen.withOpacity(0.2),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // Search Results
            Expanded(
              child: isSearching
                  ? _searchResults.isEmpty
                      ? const Center(
                          child: Text(
                            'No results found in Bud & Basket.',
                            style: TextStyle(
                                color: Colors.black54, fontSize: 16),
                          ),
                        )
                      : GridView.builder(
                          itemCount: _searchResults.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.70,
                          ),
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
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
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                color: Colors.black54,
                                                fontSize: 12),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 8),
                                        Text('₹${item.price}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: GTColors.lushGreen)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
