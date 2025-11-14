import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:greentalkies/config.dart';
import 'package:greentalkies/models/plant.dart'; // import your PlantTask model

class BackendHelper {
  final String userId;
  final String baseUrl;

  BackendHelper({required this.userId, String? customUrl})
      : baseUrl = customUrl ?? RuntimeConfig().backendUrl;

  String getServerUrl() => baseUrl;

  // Fetch tasks
  Future<List<PlantTask>> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tasks/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PlantTask.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Add task
  Future<void> addTask(PlantTask task) async {
    try {
      final url = Uri.parse('$baseUrl/tasks');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson(userId)),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to save task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saving task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      final url = Uri.parse('$baseUrl/tasks/$taskId');
      final response = await http.delete(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }

  // Update status
  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      final url = Uri.parse('$baseUrl/tasks/$taskId/status');
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }
}
