import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';

// ==========================================================================
//                              BudBasketScreen
// ==========================================================================

class BudBasketScreen extends StatelessWidget {
  const BudBasketScreen({super.key});

  // Helper method for showing a SnackBar
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Helper method for the Section Header
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeAll,
  ) {
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
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'See All →',
              style: TextStyle(color: GTColors.skyBlue, fontSize: 16),
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
        backgroundColor: const Color.fromARGB(255, 60, 162, 65),
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
            icon: const _CartIconWithBadge(itemCount: 3),
            onPressed: () {
              _showSnackbar(context, 'Navigating to Shopping Cart...');
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5.0,
              ),
              child: _SearchBar(
                onTap: () => _showSnackbar(context, 'Opening Search Input...'),
              ),
            ),
            const SizedBox(height: 25),

            // 2. Product Categories
            _buildSectionHeader(
              context,
              'Shop by Category',
              () => _showSnackbar(context, 'View all categories'),
            ),
            const SizedBox(height: 15),
            _CategoryGrid(
              onCategoryTap: (name) =>
                  _showSnackbar(context, 'Navigating to $name category.'),
            ),
            const SizedBox(height: 30),

            // 3. Featured Products/Deals
            _buildSectionHeader(
              context,
              'Today\'s Green Deals',
              () => _showSnackbar(context, 'View all deals'),
            ),
            const SizedBox(height: 15),
            const _ProductCardList(),
            const SizedBox(height: 30),

            // 4. Highlighted Banner
            _HighlightBanner(
              onTap: () => _showSnackbar(
                context,
                'Navigating to Organic Fertilizers collection!',
              ),
            ),
            const SizedBox(height: 30),

            // 5. Image Carousel/Recommendations
            _buildSectionHeader(
              context,
              'Explore Collections',
              () => _showSnackbar(context, 'View all collections'),
            ),
            const SizedBox(height: 15),
            _ImageCarousel(
              onCollectionTap: (title) =>
                  _showSnackbar(context, 'Navigating to "$title" collection.'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 🎯 Custom Widget: Search Bar
// --------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: GTColors.primaryBaseDark.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: GTColors.darkText, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search plants, soil, or tools...',
                hintStyle: TextStyle(color: GTColors.darkText.withOpacity(0.6)),
                border: InputBorder.none,
                isDense: true,
              ),
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 🎯 Custom Widget: Category Grid
// --------------------------------------------------------------------------

class _CategoryGrid extends StatelessWidget {
  final void Function(String) onCategoryTap;
  const _CategoryGrid({required this.onCategoryTap});

  final List<Map<String, dynamic>> categories = const [
    {
      'name': 'Plants',
      'icon': Icons.local_florist,
      'color': GTColors.lushGreen,
    },
    {'name': 'Pots', 'icon': Icons.home_work, 'color': GTColors.terracotta},
    {
      'name': 'Soil & Mixes',
      'icon': Icons.grass,
      'color': GTColors.primaryBaseDark,
    },
    {'name': 'Tools', 'icon': Icons.handyman, 'color': GTColors.skyBlue},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: categories.map((category) {
          final name = category['name'] as String;
          return InkWell(
            onTap: () => onCategoryTap(name),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: GTColors.darkText,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 🎯 Custom Widget: Product Card List (Horizontal Scroll)
// --------------------------------------------------------------------------

class _ProductCardList extends StatelessWidget {
  const _ProductCardList();

  final List<Map<String, dynamic>> products = const [
    {
      'name': 'ZZ Plant',
      'price': 89.99,
      'imageUrl': 'assets/snake_plant.jpg', // Asset Path
      'imageColor': GTColors.primaryBaseDark,
      'discount': '20% Off',
    },
    {
      'name': 'Monstera Potting Soil',
      'price': 58.50,
      'imageUrl': 'assets/monstera.jpg', // Asset Path
      'imageColor': GTColors.terracotta,
      'discount': null,
    },
    {
      'name': 'AeroGarden Kit',
      'price': 300.00,
      'imageUrl': 'assets/aerogarden.jpg', // Asset Path
      'imageColor': GTColors.skyBlue,
      'discount': 'New!',
    },
    {
      'name': 'Small Succulent Set',
      'price': 90.00,
      'imageUrl': 'assets/succulent.jpg', // Asset Path
      'imageColor': GTColors.radiantGreen,
      'discount': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        padding: const EdgeInsets.only(left: 10),
        itemBuilder: (context, index) {
          final product = products[index];
          return _ProductCard(
            name: product['name'] as String,
            price: product['price'] as double,
            imageColor: product['imageColor'] as Color,
            imageUrl: product['imageUrl'] as String, // <-- PASSING IMAGE URL
            discount: product['discount'] as String?,
          );
        },
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 🎯 Custom Widget: Product Card (FIXED IMAGE DISPLAY)
// --------------------------------------------------------------------------

class _ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final Color imageColor;
  final String imageUrl; // <-- ADDED
  final String? discount;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.imageColor,
    required this.imageUrl, // <-- ADDED
    this.discount,
  });

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showSnackbar(context, 'Viewing details for $name'),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: GTColors.primaryBaseDark.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Display Area (FIXED)
            Container(
              height: 120,
              decoration: BoxDecoration(
                // Use DecorationImage to load the asset path
                image: DecorationImage(
                  image: AssetImage(imageUrl), // <-- USE IMAGE URL HERE
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                color: imageColor.withOpacity(0.2), // Fallback background color
              ),
              child: Stack(
                children: [
                  // Discount Badge
                  if (discount != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: GTColors.berryRed,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          discount!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: GTColors.primaryBaseDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\₹ ${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: GTColors.lushGreen,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 🎯 Custom Widget: Highlight Banner
// --------------------------------------------------------------------------

class _HighlightBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _HighlightBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [GTColors.lushGreen, GTColors.radiantGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: GTColors.lushGreen.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Organic Fertilizers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Nourish your plants naturally!',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              Icon(
                Icons.spa_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 🎯 Custom Widget: Image Carousel/Recommendations
// --------------------------------------------------------------------------

class _ImageCarousel extends StatelessWidget {
  final void Function(String) onCollectionTap;
  const _ImageCarousel({required this.onCollectionTap});

  final List<Map<String, dynamic>> collections = const [
    {
      'title': 'Pet-Friendly Plants',
      'subtitle': 'Safe for your furry friends',
      'icon': Icons.pets,
      'color': GTColors.skyBlue,
    },
    {
      'title': 'Indoor Air Purifiers',
      'subtitle': 'Breathe easier at home',
      'icon': Icons.air,
      'color': GTColors.lushGreen,
    },
    {
      'title': 'Terracotta Pots Sale',
      'subtitle': 'Up to 30% off!',
      'icon': Icons.format_paint,
      'color': GTColors.terracotta,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: collections.length,
        padding: const EdgeInsets.only(left: 10),
        itemBuilder: (context, index) {
          final collection = collections[index];
          return _CollectionBanner(
            title: collection['title'] as String,
            subtitle: collection['subtitle'] as String,
            icon: collection['icon'] as IconData,
            color: collection['color'] as Color,
            onTap: () => onCollectionTap(collection['title'] as String),
          );
        },
      ),
    );
  }
}

class _CollectionBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CollectionBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: GTColors.primaryBaseDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: GTColors.darkText.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 🎯 Custom Widget: Cart Icon with Item Count Badge
// --------------------------------------------------------------------------

class _CartIconWithBadge extends StatelessWidget {
  final int itemCount;
  const _CartIconWithBadge({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Icon(
          Icons.shopping_basket_rounded,
          color: GTColors.darkText,
          size: 28,
        ),
        if (itemCount > 0)
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: GTColors.berryRed,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                '$itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
