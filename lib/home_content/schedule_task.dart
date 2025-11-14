import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '/backend_config.dart';
import 'models.dart'; 

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

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

  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledTime.millisecondsSinceEpoch,
      'Plant Task Reminder',
      taskName,
      tzScheduled,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'task_reminder',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  } catch (e) {
    print("Error scheduling notification: $e");
  }
}

class ScheduleTaskForm extends StatefulWidget {
  final void Function(PlantTask) onTaskAdded;
  final String? userId;

  const ScheduleTaskForm({
    super.key,
    required this.onTaskAdded,
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
  String? _backendUrl;

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    _initBackend();
  }

  Future<void> _initBackend() async {
    final ip = await BackendConfig.getServerIp();
    setState(() {
      _backendUrl = BackendConfig.apiBase(ip);
    });
    print("🌿 Using backend: $_backendUrl");
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
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
    setState(() => _isLoading = true);

    final formattedTime =
        "${_taskDateTime!.year}-${_taskDateTime!.month.toString().padLeft(2, '0')}-${_taskDateTime!.day.toString().padLeft(2, '0')} "
        "${_taskDateTime!.hour.toString().padLeft(2, '0')}:${_taskDateTime!.minute.toString().padLeft(2, '0')}";

    final newTask = PlantTask(
      id: UniqueKey().toString(),
      userId: '',
      plantName: _plantName,
      task: _taskName,
      time: formattedTime,
    );

    print("🌱 Saving task: $_taskName for plant: $_plantName at $_taskDateTime");

    // Add task locally
    widget.onTaskAdded(newTask);

    // Schedule local notification
    try {
      await scheduleNotification(_taskName, _taskDateTime!);
      print("✅ Notification scheduled for $_taskName at $_taskDateTime");
    } catch (e) {
      print("⚠️ Notification error: $e");
    }

    // Save to backend
    bool backendSuccess = true;
    String message = 'Task saved successfully.';

    if (_backendUrl != null && widget.userId != null) {
      try {
        final response = await http.post(
          Uri.parse('$_backendUrl/tasks'),
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
          message = 'Task saved locally, but failed to sync with server.';
          print('❌ Server returned ${response.statusCode}: ${response.body}');
        } else {
          print('✅ Server synced successfully');
        }
      } catch (e) {
        backendSuccess = false;
        message = 'Task saved locally, but failed to connect to server.';
        print('🌐 Backend error: $e');
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

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
                color: GTColors.forestGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Enter Plant Name',
                hintText: 'e.g. Monstera Deliciosa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSaved: (value) => _plantName = value ?? '',
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a plant name' : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Task Name',
                hintText: 'e.g. Water, Fertilize, Rotate',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSaved: (value) => _taskName = value ?? '',
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a task name' : null,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _taskDateTime != null
                        ? 'Scheduled: ${_taskDateTime!.day}/${_taskDateTime!.month}/${_taskDateTime!.year} '
                            '${_taskDateTime!.hour.toString().padLeft(2, '0')}:${_taskDateTime!.minute.toString().padLeft(2, '0')}'
                        : 'Select Date & Time',
                    style: const TextStyle(
                        fontSize: 16, color: GTColors.forestGreen),
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
