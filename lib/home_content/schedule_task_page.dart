import 'package:flutter/material.dart';
import 'schedule_task.dart';
import 'models.dart';
import '/backend_config.dart';

class ScheduleTaskAutoOpenPage extends StatefulWidget {
  final String? userId;

  const ScheduleTaskAutoOpenPage({
    super.key,
    required this.userId,
  });

  @override
  State<ScheduleTaskAutoOpenPage> createState() =>
      _ScheduleTaskAutoOpenPageState();
}

class _ScheduleTaskAutoOpenPageState extends State<ScheduleTaskAutoOpenPage> {
  String? _backendUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initBackend();
  }

  Future<void> _initBackend() async {
    final ip = await BackendConfig.getServerIp();
    setState(() {
      _backendUrl = BackendConfig.apiBase(ip);
      _loading = false;
    });
    print("🌱 ScheduleTaskAutoOpenPage using backend: $_backendUrl");
  }

  void _handleTaskAdded(PlantTask task) {
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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ScheduleTaskForm(
                  onTaskAdded: _handleTaskAdded,
                  userId: widget.userId,
                ),
              ),
      ),
    );
  }
}
