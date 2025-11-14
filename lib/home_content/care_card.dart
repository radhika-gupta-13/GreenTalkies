import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:greentalkies/backend_config.dart';
import 'models.dart';

/// ------------------------
/// CareReminderCard Widget
/// ------------------------
class CareReminderCard extends StatefulWidget {
  final PlantTask taskData;
  final Color cardColor;
  final String userId;

  const CareReminderCard({
    super.key,
    required this.taskData,
    required this.cardColor,
    required this.userId,
  });

  @override
  State<CareReminderCard> createState() => _CareReminderCardState();
}

class _CareReminderCardState extends State<CareReminderCard> {
  late PlantTask _task;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _task = widget.taskData;
  }

  /// Format backend date string → dd/mm/yyyy hh:mm
  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (e) {
      return "Not Scheduled";
    }
  }

  /// DELETE Task
  Future<void> _markAsDone() async {
    // Optimistic update: remove card immediately
    setState(() => _isVisible = false);

    try {
      final ip = await BackendConfig.getServerIp();
      final url = Uri.parse('${BackendConfig.apiBase(ip)}/tasks/${_task.id}');
      await http.delete(url).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  /// SNOOZE Task
  Future<void> _snoozeTask() async {
    // Optimistic update: add 24 hours locally
    setState(() {
      final newTime = DateTime.parse(_task.time).add(const Duration(hours: 24));
      _task = PlantTask(
        id: _task.id,
        userId: _task.userId,
        plantName: _task.plantName,
        task: _task.task,
        time: newTime.toIso8601String(),
      );
    });

    try {
      final ip = await BackendConfig.getServerIp();
      final url = Uri.parse('${BackendConfig.apiBase(ip)}/tasks/${_task.id}/status');
      await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": "snoozed"}),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error snoozing task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: widget.cardColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_task.plantName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(_task.task, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          Text(
            _formatDateTime(_task.time),
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: _markAsDone,
              ),
              IconButton(
                icon: const Icon(Icons.snooze, color: Colors.orange),
                onPressed: _snoozeTask,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
