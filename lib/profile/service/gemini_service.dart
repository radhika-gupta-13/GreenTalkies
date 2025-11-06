import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String baseUrl;

  GeminiService({String? backendUrl})
      : baseUrl = backendUrl ?? dotenv.env['API_BASE_URL'] ?? "http://192.168.0.103:4000/api";

  /// Lazy getter for API key
  String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<String> identifyPlant(File imageFile) async {
    final uri = Uri.parse('$baseUrl/identify');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    if (apiKey.isNotEmpty) request.headers['x-api-key'] = apiKey;

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['result'] ?? 'No result found';
    } else {
      throw Exception('Failed to identify plant: ${response.statusCode} - $responseBody');
    }
  }

  Future<String> diagnosePlant(File imageFile) async {
    final uri = Uri.parse('$baseUrl/diagnose');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    if (apiKey.isNotEmpty) request.headers['x-api-key'] = apiKey;

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['diagnosis'] ?? 'No diagnosis found';
    } else {
      throw Exception('Failed to diagnose plant: ${response.statusCode} - $responseBody');
    }
  }
}
