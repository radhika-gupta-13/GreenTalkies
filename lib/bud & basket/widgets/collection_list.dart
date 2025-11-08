import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/product_model.dart';
import 'product_details.dart';

class CollectionListScreen extends StatefulWidget {
  final String collectionTitle;
  final String userId;

  const CollectionListScreen({
    super.key,
    required this.collectionTitle,
    required this.userId,
  });

  @override
  State<CollectionListScreen> createState() => _CollectionListScreenState();
}

class _CollectionListScreenState extends State<CollectionListScreen> {
  final Set<String> _wishlist = {};

  List<Product> getProductsForCollection(String collection) {
    switch (collection) {
      case 'Pet-Friendly Plants':
        return const [
          Product(
              id: '1',
              name: 'Spider Plant',
              description: 'Safe for cats and dogs.',
              price: 399,
              imageUrl: 'assets/spider_plant.jpg'),
          Product(
              id: '2',
              name: 'Areca Palm',
              description: 'Non-toxic and purifies air.',
              price: 799,
              imageUrl: 'assets/areca_palm.webp'),
          Product(
              id: '3',
              name: 'Bamboo Palm',
              description: 'Pet-safe indoor palm.',
              price: 699,
              imageUrl: 'assets/bambo_palm.jpg'),
          Product(
              id: '4',
              name: 'Calathea',
              description: 'Colorful foliage, safe for pets.',
              price: 499,
              imageUrl: 'assets/calathea.webp'),
          Product(
              id: '5',
              name: 'Parlor Palm',
              description: 'Elegant indoor palm.',
              price: 599,
              imageUrl: 'assets/parlor_palm.webp'),
        ];

      case 'Indoor Air Purifiers':
        return const [
          Product(
              id: '6',
              name: 'Snake Plant',
              description: 'Cleans indoor air.',
              price: 499,
              imageUrl: 'assets/snake_p.jpg'),
          Product(
              id: '7',
              name: 'Peace Lily',
              description: 'Removes indoor toxins.',
              price: 549,
              imageUrl: 'assets/peacelily.jpg'),
          Product(
              id: '8',
              name: 'Aloe Vera',
              description: 'Purifies air and medicinal plant.',
              price: 299,
              imageUrl: 'assets/aleovera.jpg'),
          Product(
              id: '9',
              name: 'Areca Palm',
              description: 'Moisturizes air naturally.',
              price: 799,
              imageUrl: 'assets/areca_palm.webp'),
          Product(
              id: '10',
              name: 'Rubber Plant',
              description: 'Removes indoor pollutants.',
              price: 699,
              imageUrl: 'assets/rubber_plant.jpg'),
        ];

      case 'Terracotta Pots Sale':
        return const [
          Product(
              id: '11',
              name: 'Classic Terracotta Pot',
              description: 'Perfect for indoor plants.',
              price: 199,
              imageUrl: 'assets/classic_pot.jpg'),
          Product(
              id: '12',
              name: 'Terracotta Hanging Pot',
              description: 'Decorative and functional.',
              price: 299,
              imageUrl: 'assets/tera_hanging.jpg'),
          Product(
              id: '13',
              name: 'Mini Terracotta Set',
              description: 'Set of 3 small pots.',
              price: 249,
              imageUrl: 'assets/mini_tera.jpg'),
          Product(
              id: '14',
              name: 'Large Terracotta Pot',
              description: 'Ideal for bigger plants.',
              price: 399,
              imageUrl: 'assets/large_tera.jpg'),
          Product(
              id: '15',
              name: 'Terracotta Planter Bowl',
              description: 'Wide bowl planter.',
              price: 349,
              imageUrl: 'assets/planter_bowl.jpg'),
        ];

      default:
        return [];
    }
  }

  void _addToCart(Product item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} added to cart!')),
    );
  }

  void _toggleWishlist(Product item) {
    setState(() {
      if (_wishlist.contains(item.id)) {
        _wishlist.remove(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} removed from wishlist!')),
        );
      } else {
        _wishlist.add(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} added to wishlist!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final collectionProducts =
        getProductsForCollection(widget.collectionTitle);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionTitle),
        backgroundColor: GTColors.lushGreen,
      ),
      backgroundColor: GTColors.background,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double crossAxisSpacing = 10;
            double width = (constraints.maxWidth - crossAxisSpacing) / 2;

            return GridView.builder(
              itemCount: collectionProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: 10,
                childAspectRatio: width / 270, // auto-adjust height
              ),
              itemBuilder: (context, index) {
                final item = collectionProducts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(
                          product: item,
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                  child: Container(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: GTColors.darkText),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item.description,
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '₹${item.price}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: GTColors.lushGreen),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      onPressed: () => _addToCart(item),
                                      icon: const Icon(
                                        Icons.shopping_cart,
                                        color: GTColors.lushGreen,
                                      ),
                                    ),
                                    IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      onPressed: () => _toggleWishlist(item),
                                      icon: Icon(
                                        _wishlist.contains(item.id)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: GTColors.berryRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
