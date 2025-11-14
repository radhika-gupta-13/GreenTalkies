import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/product_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:greentalkies/utils/search_helper.dart';
import 'package:greentalkies/bud & basket/widgets/product_card_list.dart';
import 'package:greentalkies/bud & basket/widgets/product_details.dart';

class BudBasketSearchBar extends StatefulWidget {
  final String userId; // Add userId to pass to ProductCard and ProductDetailPage
  const BudBasketSearchBar({super.key, required this.userId});

  @override
  State<BudBasketSearchBar> createState() => _BudBasketSearchBarState();
}

class _BudBasketSearchBarState extends State<BudBasketSearchBar> {
  final TextEditingController _controller = TextEditingController();
  List<Product> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Popular searches
  final List<String> _popularSearches = [
    'Snake Plant',
    'Aloe Vera',
    'Terracotta Pot',
    'Spider Plant',
    'Peace Lily',
  ];

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse(BackendHelper.getProductsUrl(query));
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<Product> results = [];

        if (decoded is List) {
          results = decoded.map((item) => Product.fromJson(item)).toList();
        } else if (decoded is Map && decoded['products'] is List) {
          results = (decoded['products'] as List)
              .map((item) => Product.fromJson(item))
              .toList();
        } else {
          setState(() {
            _errorMessage = 'Unexpected response format from server.';
            _isLoading = false;
          });
          return;
        }

        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Server error: ${response.statusCode}. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch products: $e';
        _isLoading = false;
      });
    }
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

            // Popular Searches
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
                            backgroundColor:
                                GTColors.lushGreen.withOpacity(0.2),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // Search Results / Loading / Error
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ))
                      : isSearching && _searchResults.isEmpty
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
                                return ProductCard(
                                  product: item,
                                  userId: widget.userId,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailPage(
                                          product: item,
                                          userId: widget.userId,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
