import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/product_model.dart';
import 'widgets/bud_search_bar.dart';
import 'widgets/category_grid.dart';
import 'widgets/product_card_list.dart';
import 'widgets/highlight_banner.dart';
import 'widgets/image_carousel.dart';
import 'widgets/collection_list.dart';
import 'widgets/current_orders.dart';
import 'widgets/previous_orders.dart';
import 'widgets/wishlist.dart';
import 'widgets/cart_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/backend_config.dart';

class BudBasketScreen extends StatefulWidget {
  final String userId;

  const BudBasketScreen({super.key, required this.userId});

  @override
  State<BudBasketScreen> createState() => _BudBasketScreenState();
}

class _BudBasketScreenState extends State<BudBasketScreen> {
  List<Product> greenDeals = [];
  bool isLoadingDeals = true;
  String? errorDeals;
  String backendUrl = "";

  @override
  void initState() {
    super.initState();
    _initBackendAndFetch();
  }

  /// Determine backend URL dynamically and fetch deals
  Future<void> _initBackendAndFetch() async {
    try {
      final ip = await BackendConfig.getServerIp();
      backendUrl = BackendConfig.apiBase(ip);
      await fetchGreenDeals();
    } catch (e) {
      print("❌ Failed to initialize backend or fetch deals: $e");
      if (mounted) {
        setState(() {
          errorDeals = "Failed to fetch deals: $e";
          isLoadingDeals = false;
        });
      }
    }
  }

  Future<void> fetchGreenDeals() async {
    if (!mounted || backendUrl.isEmpty) return;

    setState(() {
      isLoadingDeals = true;
      errorDeals = null;
    });

    final url = '$backendUrl/api/products?section=green_deals';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        greenDeals = data.map((json) => Product.fromJson(json)).toList();
      } else {
        errorDeals = 'Failed to load deals (status: ${response.statusCode})';
        greenDeals = [];
      }
    } catch (e) {
      errorDeals = 'Error fetching deals: $e';
      greenDeals = [];
    } finally {
      if (mounted) setState(() => isLoadingDeals = false);
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: GTColors.primaryBaseDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: GTColors.lushGreen),
      title: Text(title),
      onTap: () {
        if (mounted) Navigator.pop(context);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTColors.secondaryBaseLight,
      appBar: AppBar(
        backgroundColor: GTColors.lushGreen,
        elevation: 1,
        title: const Text(
          'Bud & Basket',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDrawerItem(Icons.favorite, 'Wishlist', WishlistScreen(userId: widget.userId)),
                      _buildDrawerItem(Icons.shopping_cart, 'Cart', CartScreen(userId: widget.userId)),
                      _buildDrawerItem(Icons.history, 'Previous Orders', PreviousOrdersScreen(userId: widget.userId)),
                      _buildDrawerItem(Icons.pending_actions, 'Current Orders', MyOrdersScreen(userId: widget.userId)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 25),
            _buildSectionHeader('Shop by Category', () => _showSnackbar('View all categories')),
            const SizedBox(height: 15),
            CategoryGrid(userId: widget.userId),
            const SizedBox(height: 30),
            _buildSectionHeader("Today's Green Deals", () => _showSnackbar('View all deals')),
            const SizedBox(height: 15),
            _buildGreenDeals(),
            const SizedBox(height: 30),
            _buildHighlightBanner(),
            const SizedBox(height: 30),
            _buildSectionHeader('Explore Collections', () => _showSnackbar('View all collections')),
            const SizedBox(height: 15),
            ImageCarousel(
              onCollectionTap: (title) {
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CollectionListScreen(collectionTitle: title, userId: widget.userId),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        readOnly: true,
        onTap: () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BudBasketSearchBar(userId: widget.userId)),
            );
          }
        },
        decoration: InputDecoration(
          hintText: 'Search products or categories...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        ),
      ),
    );
  }

  Widget _buildGreenDeals() {
    if (isLoadingDeals) return const Center(child: CircularProgressIndicator());
    if (errorDeals != null) return Center(child: Text(errorDeals!));
    if (greenDeals.isEmpty) return const Text('No deals found.');
    return ProductCardList(products: greenDeals, userId: widget.userId);
  }

  Widget _buildHighlightBanner() => const HighlightBanner();
}
