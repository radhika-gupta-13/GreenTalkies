import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/product_model.dart';
import 'widgets/bud_search_bar.dart';
import 'widgets/category_grid.dart';
import 'widgets/product_card_list.dart';
import 'widgets/highlight_banner.dart';
import 'widgets/image_carousel.dart';
import 'widgets/cart_icon_with_badge.dart';
import 'widgets/collection_list.dart';
import 'widgets/product_dummy.dart';

class BudBasketScreen extends StatelessWidget {
  final String userId; // ✅ added userId

  BudBasketScreen({super.key, required this.userId});

  // SnackBar helper
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Section Header helper
  Widget _buildSectionHeader(
      BuildContext context, String title, VoidCallback onSeeAll) {
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
            icon: const CartIconWithBadge(itemCount: 3),
            onPressed: () =>
                _showSnackbar(context, 'Navigating to Shopping Cart...'),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 🔍 Search Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BudBasketSearchBar(
                        allProducts: allProducts,
                      ),
                    ),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search products or categories...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 🛍 Shop by Category
            _buildSectionHeader(context, 'Shop by Category',
                () => _showSnackbar(context, 'View all categories')),
            const SizedBox(height: 15),
            CategoryGrid(userId: userId), // ✅ pass userId
            const SizedBox(height: 30),

            // 🌱 Today's Green Deals
            _buildSectionHeader(context, "Today's Green Deals",
                () => _showSnackbar(context, 'View all deals')),
            const SizedBox(height: 15),
            ProductCardList(
              products: allProducts,
              userId: userId, // ✅ pass userId
            ),
            const SizedBox(height: 30),

            // 🏷 Highlighted Banner
            const HighlightBanner(),
            const SizedBox(height: 30),

            // 🎞 Explore Collections
            _buildSectionHeader(context, 'Explore Collections',
                () => _showSnackbar(context, 'View all collections')),
            const SizedBox(height: 15),
            ImageCarousel(
              onCollectionTap: (title) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CollectionListScreen(collectionTitle: title),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
