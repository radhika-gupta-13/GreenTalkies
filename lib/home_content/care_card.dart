import 'package:flutter/material.dart';
import 'package:greentalkies/home_content/models.dart';

class CareReminderCard extends StatelessWidget {
  final PlantTask taskData;
  final Color cardColor;
  final Function(PlantTask) onCompleted;
  final Function(PlantTask) onSnoozed;

  const CareReminderCard({
    super.key,
    required this.taskData,
    required this.cardColor,
    required this.onCompleted,
    required this.onSnoozed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Updated: shrink-wrap the Column
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plant name
          Text(
            taskData.plantName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          // Task description
          Text(taskData.task, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          // Task time
          Text(taskData.time, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 10), // Replaces Spacer() safely
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () => onCompleted(taskData),
              ),
              IconButton(
                icon: const Icon(Icons.snooze, color: Colors.orange),
                onPressed: () => onSnoozed(taskData),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
