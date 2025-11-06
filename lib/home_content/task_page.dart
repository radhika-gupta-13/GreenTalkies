import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// -----------------------------
// Plant Task Model
// -----------------------------
class PlantTask {
  final String id;
  final String key;
  final String plantName;
  final String task;
  final String time;
  final String status;

  PlantTask({
    required this.key,
    required this.plantName,
    required this.task,
    required this.time,
    this.id = '',
    this.status = 'pending',
  });

  PlantTask snooze(String newTime) {
    return PlantTask(
      id: id,
      key: key,
      plantName: plantName,
      task: task,
      time: newTime,
      status: status,
    );
  }

  PlantTask copyWith({String? status, String? time}) {
    return PlantTask(
      id: id,
      key: key,
      plantName: plantName,
      task: task,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }

  factory PlantTask.fromJson(Map<String, dynamic> json) {
    return PlantTask(
      id: json['_id'] ?? '',
      key: json['key'] ?? UniqueKey().toString(),
      plantName: json['plantName'] ?? 'Unknown Plant',
      task: json['task'] ?? 'Unnamed Task',
      time: json['time'] ?? 'Not Scheduled',
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson(String userId) => {
        if (id.isNotEmpty) '_id': id,
        'key': key,
        'plantName': plantName,
        'task': task,
        'time': time,
        'status': status,
        'userId': userId,
      };
}

// -----------------------------
// Task Manager State
// -----------------------------
class TaskManagerState extends StatefulWidget {
  const TaskManagerState({super.key, required this.userId});
  final String userId;

  @override
  State<TaskManagerState> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManagerState> {
  List<PlantTask> _careTasks = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String? _backendUrl;
  final TextEditingController _newTaskController = TextEditingController();

  // 🎨 Task card color palette (cycled)
  final List<Color> _taskColors = [
    Colors.green.shade200,
    Colors.orange.shade200,
    Colors.purple.shade200,
    Colors.blue.shade200,
    Colors.yellow.shade200,
    Colors.teal.shade200,
    Colors.pink.shade200,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _setBackendUrl();
      await _fetchTasks();
    });
  }

  // -----------------------------
  // Dynamic Backend URL
  // -----------------------------
  Future<void> _setBackendUrl() async {
    String baseUrl = '10.0.2.2'; // Android emulator fallback
    final info = NetworkInfo();
    try {
      if (kIsWeb) {
        baseUrl = 'localhost';
      } else {
        final wifiIp = await info.getWifiIP();
        if (wifiIp != null) baseUrl = wifiIp;
      }
    } catch (e) {
      print("❌ Error detecting Wi-Fi IP: $e");
    }
    setState(() {
      _backendUrl = 'http://$baseUrl:4000';
      print("✅ Backend URL: $_backendUrl");
    });
  }

  String _getServerUrl() => _backendUrl ?? 'http://10.0.2.2:4000';

  // -----------------------------
  // Fetch Tasks from Backend
  // -----------------------------
  Future<void> _fetchTasks() async {
    if (_backendUrl == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response =
          await http.get(Uri.parse('${_getServerUrl()}/tasks/${widget.userId}'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _careTasks = data.map((json) => PlantTask.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load tasks: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  // -----------------------------
  // Add Task
  // -----------------------------
  Future<void> _addTask(String taskName, String dueTime) async {
    if (_backendUrl == null) return;

    final newTask = PlantTask(
      key: UniqueKey().toString(),
      plantName: 'Custom Plant',
      task: taskName,
      time: dueTime, // Use picked date and time
    );

    try {
      final url = Uri.parse('${_getServerUrl()}/tasks');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newTask.toJson(widget.userId)),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await _fetchTasks();
      } else {
        print('❌ Failed to save task: ${response.body}');
      }
    } catch (e) {
      print('❌ Error saving task: $e');
    }
  }

  // -----------------------------
  // Delete Task
  // -----------------------------
  Future<void> _deleteTask(PlantTask task) async {
    if (_backendUrl == null || task.id.isEmpty) return;

    try {
      final url = Uri.parse('${_getServerUrl()}/tasks/${task.id}');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        await _fetchTasks();
      } else {
        print('❌ Failed to delete task: ${response.body}');
      }
    } catch (e) {
      print('❌ Error deleting task: $e');
    }
  }

  // -----------------------------
  // Update Task Status
  // -----------------------------
  Future<void> _updateTaskStatus(PlantTask task, String status) async {
    if (_backendUrl == null || task.id.isEmpty) return;

    try {
      final url =
          Uri.parse('${_getServerUrl()}/tasks/${task.id}/status'); // PATCH
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        await _fetchTasks();
      } else {
        print('❌ Failed to update task: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating task: $e');
    }
  }

  // -----------------------------
  // Get Icon
  // -----------------------------
  IconData _getTaskIcon(String task) {
    final t = task.toLowerCase();
    if (t.contains('water')) return Icons.water_drop_outlined;
    if (t.contains('fertilize')) return Icons.grass;
    if (t.contains('repot')) return Icons.local_florist;
    if (t.contains('mist')) return Icons.cloud;
    return Icons.task_alt_rounded;
  }

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plant Tasks 🌱'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          // Add new task input with date & time picker
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTaskController,
                    decoration: const InputDecoration(
                      hintText: 'Enter new task name...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (_newTaskController.text.trim().isEmpty) return;

                    // Show date picker
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );

                    if (pickedDate != null) {
                      // Show time picker
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 9, minute: 0),
                      );

                      if (pickedTime != null) {
                        // Format date and time
                        String formattedDateTime =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')} "
                            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";

                        // Add task with selected date & time
                        _addTask(_newTaskController.text.trim(), formattedDateTime);
                        _newTaskController.clear();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                  ),
                  child: const Text('Add Task'),
                ),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: _careTasks.length,
                        itemBuilder: (context, index) {
                          final task = _careTasks[index];
                          final cardColor =
                              _taskColors[index % _taskColors.length];

                          return Stack(
                            children: [
                              Card(
                                color: cardColor.withOpacity(0.9),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    _getTaskIcon(task.task),
                                    color: Colors.black87,
                                  ),
                                  title: Text(
                                    task.task,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'For: ${task.plantName}\nDue: ${task.time}',
                                  ),
                                  isThreeLine: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check_circle,
                                            color: Colors.green),
                                        onPressed: () =>
                                            _updateTaskStatus(task, 'done'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _deleteTask(task),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (task.status == 'done')
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
