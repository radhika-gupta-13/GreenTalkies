import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'models.dart'; // Import PlantTask and GTColors

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Initialize timezone data
  tz.initializeTimeZones();
}

Future<void> scheduleNotification(String taskName, DateTime scheduledTime) async {
  final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'plant_tasks_channel',
    'Plant Tasks',
    channelDescription: 'Reminders for plant care tasks',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    scheduledTime.millisecondsSinceEpoch ~/ 1000, // unique id
    'Plant Task Reminder',
    taskName,
    tzScheduled,
    platformDetails,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

// --- ScheduleTaskForm: The widget that renders the form on the page ---

class ScheduleTaskForm extends StatefulWidget {
  final void Function(PlantTask) onTaskAdded;
  final String backendUrl;
  final String? userId;

  const ScheduleTaskForm({
    super.key,
    required this.onTaskAdded,
    required this.backendUrl,
    this.userId,
  });

  @override
  State<ScheduleTaskForm> createState() => _ScheduleTaskFormState();
}

class _ScheduleTaskFormState extends State<ScheduleTaskForm> {
  String _plantName = '';
  String _taskName = '';
  DateTime? _taskDateTime;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  Future<void> _pickDateTime() async {
    // 1️⃣ Date picker
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      // 2️⃣ Time picker
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
      );

      if (pickedTime != null) {
        setState(() {
          _taskDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_taskDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time for the task.')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() { _isLoading = true; });

    final formattedTime = "${_taskDateTime!.year}-${_taskDateTime!.month.toString().padLeft(2,'0')}-${_taskDateTime!.day.toString().padLeft(2,'0')} "
        "${_taskDateTime!.hour.toString().padLeft(2,'0')}:${_taskDateTime!.minute.toString().padLeft(2,'0')}";

    final newTask = PlantTask(
      key: UniqueKey().toString(),
      id: '',
      plantName: _plantName,
      task: _taskName,
      time: formattedTime,
    );

    // 1️⃣ FRONTEND SAVE: Update local list and schedule notification
    widget.onTaskAdded(newTask);
    await scheduleNotification(_taskName, _taskDateTime!);

    bool backendSuccess = true;
    String message = 'Task saved successfully.';

    // 2️⃣ BACKEND SAVE: Send to server (Persistence)
    if (widget.backendUrl.isNotEmpty && widget.userId != null) {
      try {
        final response = await http.post(
          Uri.parse('${widget.backendUrl}/tasks'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': widget.userId,
            'plantName': _plantName,
            'task': _taskName,
            'time': formattedTime,
          }),
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          backendSuccess = false;
          message = 'Task saved locally, but failed to sync to server.';
          print('Backend post failed with status: ${response.statusCode}');
        }

      } catch (e) {
        backendSuccess = false;
        message = 'Task saved locally, but failed to connect to server.';
        print('Backend error: $e');
      }
    }

    setState(() { _isLoading = false; });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backendSuccess ? Colors.green : Colors.orange,
      ),
    );

    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Schedule Plant Care Task',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: GTColors.forestGreen),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Plant Name Input
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Enter Plant Name',
                hintText: 'e.g. Monstera Deliciosa',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onSaved: (value) => _plantName = value ?? '',
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a plant name' : null,
            ),
            const SizedBox(height: 15),

            // Task Name Input
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Task Name',
                hintText: 'e.g. Water, Fertilize, Rotate',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onSaved: (value) => _taskName = value ?? '',
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a task name' : null,
            ),
            const SizedBox(height: 15),

            // Select Date & Time Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    _taskDateTime != null
                        ? 'Scheduled: ${_taskDateTime!.day}/${_taskDateTime!.month}/${_taskDateTime!.year} '
                          '${_taskDateTime!.hour.toString().padLeft(2,'0')}:${_taskDateTime!.minute.toString().padLeft(2,'0')}'
                        : 'Select Date & Time',
                    style: const TextStyle(fontSize: 16, color: GTColors.forestGreen),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickDateTime,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Pick'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GTColors.radiantGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Save Task Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: GTColors.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save Task', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// ORIGINAL ScheduleTask CLASS (Kept for compatibility)
// -------------------------------------------------------------

class ScheduleTask {
  Future<void> navigateToScheduleTaskPage(
    BuildContext context,
    void Function(PlantTask) onTaskAdded,
    String backendUrl,
    String? userId,
  ) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Schedule Plant Care Task')),
          body: ScheduleTaskForm(
            onTaskAdded: onTaskAdded,
            backendUrl: backendUrl,
            userId: userId,
          ),
        ),
      ),
    );
  }

  Widget buildScheduleTaskButton(
      BuildContext context,
      void Function(PlantTask) onTaskAdded,
      String backendUrl,
      String? userId) {
    return ElevatedButton.icon(
      onPressed: () => navigateToScheduleTaskPage(context, onTaskAdded, backendUrl, userId),
      icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.white),
      label: const Text('Schedule a New Care Task'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 77, 161, 56),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
