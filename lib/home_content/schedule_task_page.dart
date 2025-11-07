import 'package:flutter/material.dart';
import 'schedule_task.dart'; 
import 'models.dart'; 

class ScheduleTaskAutoOpenPage extends StatefulWidget {
  final String? userId;
  final String backendUrl;

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
  void _handleTaskAdded(PlantTask task) {
    // Optionally show a confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "${task.task}" added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Plant Care Task'),
        backgroundColor: GTColors.radiantGreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ScheduleTaskForm(
            onTaskAdded: _handleTaskAdded,
            backendUrl: widget.backendUrl, // use the value from constructor
            userId: widget.userId,
          ),
        ),
      ),
    );
  }
}
