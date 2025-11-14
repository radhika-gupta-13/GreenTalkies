import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'category_products.dart';

class CategoryGrid extends StatefulWidget {
  final String userId;

  const CategoryGrid({super.key, required this.userId});

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  // Categories data
  final List<Map<String, dynamic>> categories = [
    {'name': 'Plants', 'icon': Icons.local_florist, 'color': GTColors.lushGreen},
    {'name': 'Fertilizers', 'icon': Icons.shopping_bag, 'color': GTColors.terracotta},
    {'name': 'Soil & Mixes', 'icon': Icons.grass_rounded, 'color': GTColors.sunsetOrange},
    {'name': 'Pots', 'icon': Icons.rice_bowl, 'color': GTColors.mossGreen},
    {'name': 'Home Decor', 'icon': Icons.home_work, 'color': GTColors.primaryBaseDark},
    {'name': 'Tools', 'icon': Icons.handyman, 'color': GTColors.skyBlue},
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          separatorBuilder: (_, __) => const SizedBox(width: 20),
          itemBuilder: (context, index) {
            final category = categories[index];
            final name = category['name'] as String;

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryProductsScreen(
                      categoryName: name,
                      userId: widget.userId,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 70,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: GTColors.darkText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
