import 'package:flutter/material.dart';

class PlantTask {
  final String id;
  final String key;
  final String plantName;
  final String task;
  final String time;

  PlantTask({
    required this.id,
    required this.key,
    required this.plantName,
    required this.task,
    required this.time,
  });

  factory PlantTask.fromJson(Map<String, dynamic> json) {
    final String taskId = json['_id'] ?? '';
    return PlantTask(
      id: taskId,
      key: taskId, // Use MongoDB _id as key
      plantName: json['plantName'] ?? '',
      task: json['task'] ?? '',
      time: json['time'] ?? '',
    );
  }

  PlantTask snooze(String newTime) {
    return PlantTask(
      id: id,
      key: key,
      plantName: plantName,
      task: task,
      time: newTime,
    );
  }

  // ✅ Method to convert PlantTask to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantName': plantName,
      'task': task,
      'time': time,
    };
  }
}

// Custom Color Palette
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
