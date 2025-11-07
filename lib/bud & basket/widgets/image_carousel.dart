import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';

class ImageCarousel extends StatelessWidget {
  final void Function(String) onCollectionTap;
  const ImageCarousel({required this.onCollectionTap, super.key});

  final List<Map<String, dynamic>> collections = const [
    {'title': 'Pet-Friendly Plants', 'subtitle': 'Safe for your furry friends', 'icon': Icons.pets, 'color': GTColors.skyBlue},
    {'title': 'Indoor Air Purifiers', 'subtitle': 'Breathe easier at home', 'icon': Icons.air, 'color': GTColors.lushGreen},
    {'title': 'Terracotta Pots Sale', 'subtitle': 'Up to 30% off!', 'icon': Icons.format_paint, 'color': GTColors.terracotta},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 10),
        itemCount: collections.length,
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

  const _CollectionBanner({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap, super.key});

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
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: GTColors.primaryBaseDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(fontSize: 13, color: GTColors.darkText.withOpacity(0.7)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
