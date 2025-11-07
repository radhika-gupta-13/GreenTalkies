import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'category_products.dart'; // import your updated products page

class CategoryGrid extends StatelessWidget {
  final String userId; // ✅ Accept userId from parent

  const CategoryGrid({super.key, required this.userId});

  final List<Map<String, dynamic>> categories = const [
    {
      'name': 'Plants',
      'icon': Icons.local_florist,
      'color': GTColors.lushGreen
    },
    {'name': 'Pots', 'icon': Icons.home_work, 'color': GTColors.terracotta},
    {
      'name': 'Soil & Mixes',
      'icon': Icons.grass,
      'color': GTColors.primaryBaseDark
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
            onTap: () {
              // ✅ Now we can safely pass userId here
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryProductsScreen(
                    categoryName: name,
                    userId: userId,
                  ),
                ),
              );
            },
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
