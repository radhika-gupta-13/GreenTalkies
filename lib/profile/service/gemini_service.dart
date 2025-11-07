import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:network_info_plus/network_info_plus.dart';

class GeminiService {
  late String baseUrl; // initialize later
  final String? backendUrl;

  GeminiService({this.backendUrl});

  /// Initialize base URL (call this before using the service)
  Future<void> init() async {
    if (backendUrl != null) {
      baseUrl = backendUrl!;
    } else {
      baseUrl = await _getAutoBaseUrl();
    }
  }

  String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<String> _getAutoBaseUrl() async {
    final info = NetworkInfo();
    String? ip = await info.getWifiIP(); // get device IP
    ip ??= '192.168.0.103'; // fallback
    return 'http://$ip:4000/api';
  }

  Future<String> identifyPlant(XFile imageFile) async {
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

  Future<String> diagnosePlant(XFile imageFile) async {
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
