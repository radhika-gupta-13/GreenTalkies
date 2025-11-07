import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';

class CartIconWithBadge extends StatelessWidget {
  final int itemCount;
  const CartIconWithBadge({required this.itemCount, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Icon(Icons.shopping_basket_rounded, color: GTColors.darkText, size: 28),
        if (itemCount > 0)
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(color: GTColors.berryRed, borderRadius: BorderRadius.circular(6)),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text('$itemCount',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),
          ),
      ],
    );
  }
}
