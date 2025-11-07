import 'package:flutter/material.dart';
import 'schedule_task.dart'; 
import 'models.dart'; 
import 'package:greentalkies/config.dart';

class ScheduleTaskAutoOpenPage extends StatefulWidget {
  final String? userId; // Can be null
  final String backendUrl; // Non-nullable
  

  const ScheduleTaskAutoOpenPage({
    super.key,
    required this.userId,
    required this.backendUrl,
  });

  @override
  State<ScheduleTaskAutoOpenPage> createState() =>
      _ScheduleTaskAutoOpenPageState();
}

class _ScheduleTaskAutoOpenPageState extends State<ScheduleTaskAutoOpenPage> {
  // Callback after a task is added in the ScheduleTaskForm
  void _handleTaskAdded(PlantTask task) {
    // Optional: update parent list if needed
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Task "${task.task}" added!')),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Task'),
        backgroundColor: GTColors.radiantGreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea( // Added SafeArea for better layout on devices
        child: ScheduleTaskForm(
          onTaskAdded: _handleTaskAdded,
          backendUrl: RuntimeConfig().backendUrl, // <-- fetch dynamically here
          userId: widget.userId,
        ),
      ),
    );
  }
}
