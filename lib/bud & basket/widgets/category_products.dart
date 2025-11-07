import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/product_model.dart';
import 'product_card_list.dart'; // for ProductCard widget
import 'product_details.dart'; // for ProductDetailPage

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;
  final String userId; 

  const CategoryProductsScreen({
    required this.categoryName,
    required this.userId,
    super.key,
  });

  // Convert dummy map data into List<Product>
  List<Product> getProductsForCategory() {
    switch (categoryName) {
      case 'Plants':
        return [
          Product(
              id: '1',
              name: 'Fiddle Leaf Fig',
              price: 120,
              description: 'Beautiful indoor plant',
              imageUrl: 'assets/fiddle.jpg',
              discount: '15% Off'),
          Product(
              id: '2',
              name: 'Snake Plant',
              price: 100,
              description: 'Low maintenance plant',
              imageUrl: 'assets/snake_p.jpg',
              discount: '10% Off'),
          Product(
              id: '3',
              name: 'Monstera Deliciosa',
              price: 150,
              description: 'Large tropical plant',
              imageUrl: 'assets/monstera.webp'),
          Product(
              id: '4',
              name: 'Aloe Vera',
              price: 60,
              description: 'Medicinal plant',
              imageUrl: 'assets/aleovera.jpg',
              discount: 'New!'),
          Product(
              id: '5',
              name: 'Succulent',
              price: 90,
              description: 'Easy to grow succulent',
              imageUrl: 'assets/succulent.jpg'),
        ];
      case 'Pots':
        return [
          Product(
              id: '6',
              name: 'Terracotta Pot',
              price: 40,
              description: 'Classic clay pot',
              imageUrl: 'assets/plastic_pots.jpg',
              discount: '20% Off'),
          Product(
              id: '7',
              name: 'Ceramic Planter',
              price: 55,
              description: 'Stylish ceramic planter',
              imageUrl: 'assets/ceramic_pot.webp'),
          Product(
              id: '8',
              name: 'Hanging Pot',
              price: 70,
              description: 'Perfect for small spaces',
              imageUrl: 'assets/hanging_pot.webp',
              discount: '10% Off'),
          Product(
              id: '9',
              name: 'Square Pot',
              price: 45,
              description: 'Modern design',
              imageUrl: 'assets/square_pot.jpg'),
          Product(
              id: '10',
              name: 'Mini Glass Pots Set',
              price: 900,
              description: 'Decorative glass pots',
              imageUrl: 'assets/painted_glass_pot.jpg',
              discount: 'New!'),
        ];
      case 'Soil & Mixes':
        return [
          Product(
              id: '11',
              name: 'Potting Soil',
              price: 30,
              description: 'High quality potting soil',
              imageUrl: 'assets/potting_soil_mix.webp'),
          Product(
              id: '12',
              name: 'Compost Mix',
              price: 25,
              description: 'Organic compost mix',
              imageUrl: 'assets/compost_mix.webp',
              discount: '10% Off'),
          Product(
              id: '13',
              name: 'Cactus Mix',
              price: 28,
              description: 'Soil mix for cacti',
              imageUrl: 'assets/cactus_mix.webp'),
          Product(
              id: '14',
              name: 'Seedling Mix',
              price: 22,
              description: 'Seed starter soil mix',
              imageUrl: 'assets/seedlin_mix.jpg',
              discount: '15% Off'),
          Product(
              id: '15',
              name: 'Organic Fertilizer',
              price: 35,
              description: 'Plant nutrient mix',
              imageUrl: 'assets/organic_fertilizer.jpg',
              discount: 'New!'),
        ];
      case 'Tools':
        return [
          Product(
              id: '16',
              name: 'Garden Shovel',
              price: 50,
              description: 'Durable garden shovel',
              imageUrl: 'assets/garden_sovles.jpg'),
          Product(
              id: '17',
              name: 'Pruning Shears',
              price: 40,
              description: 'Sharp pruning shears',
              imageUrl: 'assets/pruning_shears.jpg',
              discount: '10% Off'),
          Product(
              id: '18',
              name: 'Watering Can',
              price: 35,
              description: 'Lightweight watering can',
              imageUrl: 'assets/watering_can.jpg'),
          Product(
              id: '19',
              name: 'Garden Gloves',
              price: 20,
              description: 'Comfortable gloves',
              imageUrl: 'assets/gardening_gloves.webp'),
          Product(
              id: '20',
              name: 'Mini Rake',
              price: 25,
              description: 'Handy mini rake',
              imageUrl: 'assets/mini_rake.jpg',
              discount: 'New!'),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = getProductsForCategory();

    return Scaffold(
      appBar: AppBar(
        title: Text('$categoryName Products'),
        backgroundColor: GTColors.lushGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cards per row
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.7, // height adjustment
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              userId: userId, // ✅ Pass userId here
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(
                      product: product,
                      userId: userId, // ✅ Pass again for details
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
