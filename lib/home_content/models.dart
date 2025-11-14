import 'package:flutter/material.dart';

/// ------------------------
/// Plant Task Model
/// ------------------------
class PlantTask {
  final String id;      
  final String userId;
  final String plantName;
  final String task;
  final String time;

  PlantTask({
    required this.id,
    required this.userId,
    required this.plantName,
    required this.task,
    required this.time,
  });

  factory PlantTask.fromJson(Map<String, dynamic> json) {
    return PlantTask(
      id: json['_id'] ?? '',  
      userId: json['userId'] ?? '',
      plantName: json['plantName'] ?? '',
      task: json['task'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

/// ------------------------
/// Custom Color Palette
/// ------------------------
class GTColors {
  static const Color radiantGreen = Color.fromARGB(255, 77, 161, 56);
  static const Color forestGreen = Color(0xFF1B5E20); 
  static const Color darkGrey = Color(0xFF424242);
  static const Color lushGreen = Color(0xFF3C5C2B);
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color berryRed = Color(0xFFB22222);
  static const Color primaryBaseDark = Color(0xFF1B3C1B);
  static const Color secondaryBaseLight = Color(0xFFFFFCEE);
}
