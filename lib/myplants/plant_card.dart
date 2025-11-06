import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/plant.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  const PlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    // Safe image provider
    ImageProvider imageProvider;
    if (plant.imageUrl != null && plant.imageUrl!.isNotEmpty) {
      if (plant.imageUrl!.startsWith('http')) {
        imageProvider = NetworkImage(plant.imageUrl!);
      } else {
        imageProvider = AssetImage(plant.imageUrl!) as ImageProvider;
      }
    } else {
      imageProvider = const AssetImage('assets/default_plant.jpg');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: GTColors.darkText.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.nickname,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  plant.name,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 5),
                Text(
                  plant.healthStatus,
                  style: TextStyle(color: plant.healthColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
