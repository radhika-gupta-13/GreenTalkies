import 'package:flutter/material.dart';
import '../colors.dart';

class Plant {
  final String id;
  final String userId;
  final String name;
  final String nickname;
  String? imageUrl; // mutable field to store backend URL
  String healthStatus;
  String nextAction;
  DateTime? createdAt;

  Plant({
    required this.id,
    required this.userId,
    required this.name,
    required this.nickname,
    this.imageUrl,
    required this.healthStatus,
    required this.nextAction,
    this.createdAt,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
        id: json['_id'],
        userId: json['userId'],
        name: json['name'],
        nickname: json['nickname'],
        imageUrl: json['imageUrl'], // map backend field
        healthStatus: json['healthStatus'],
        nextAction: json['nextAction'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'name': name,
        'nickname': nickname,
        'imageUrl': imageUrl,
        'healthStatus': healthStatus,
        'nextAction': nextAction,
        'createdAt': createdAt?.toIso8601String(),
      };

  /// ✅ Safe getter for images
  String get safePhotoUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('http')) return imageUrl!;
      if (imageUrl!.startsWith('assets/')) return imageUrl!;
    }
    return 'assets/default_plant.jpg';
  }

  /// Optional helper for ImageProvider
  ImageProvider get imageProvider {
    if (safePhotoUrl.startsWith('http')) return NetworkImage(safePhotoUrl);
    return AssetImage(safePhotoUrl);
  }

  /// Helper to get color based on health status
  Color get healthColor => _getColorFromStatus(healthStatus);

  static Color _getColorFromStatus(String status) {
    switch (status) {
      case 'Excellent Health':
        return GTColors.lushGreen;
      case 'Good Health':
        return GTColors.radiantGreen;
      case 'Needs Water':
        return GTColors.skyBlue;
      case 'Pest Alert!':
        return GTColors.berryRed;
      case 'Recently Added':
        return GTColors.sunburstYellow;
      default:
        return GTColors.darkText;
    }
  }
}
