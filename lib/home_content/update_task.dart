import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'task_page.dart'; // For PlantTask

class UpdateTaskPage extends StatelessWidget {
  final PlantTask taskData;
  final Function(PlantTask) onCompleted;
  final Function(PlantTask) onSnoozed;

  const UpdateTaskPage({
    super.key,
    required this.taskData,
    required this.onCompleted,
    required this.onSnoozed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Task'),
        backgroundColor: GTColors.radiantGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(taskData.task, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Plant: ${taskData.plantName}'),
            const SizedBox(height: 10),
            Text('Due: ${taskData.time}'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                onCompleted(taskData);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: GTColors.lushGreen),
              child: const Text('Mark as Done'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                onSnoozed(taskData);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: GTColors.skyBlue),
              child: const Text('Snooze Task'),
            ),
          ],
        ),
      ),
    );
  }
}
