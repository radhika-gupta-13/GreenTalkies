import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'fertilizer_list_screen.dart';

class HighlightBanner extends StatelessWidget {
  final String userId; // ✅ add userId

  const HighlightBanner({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FertilizerListScreen(userId: userId), // pass userId
            ),
          );
        },
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
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Nourish your plants naturally!',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              Icon(Icons.spa_rounded,
                  color: Colors.white.withOpacity(0.8), size: 40),
            ],
          ),
        ),
      ),
    );
  }
}
