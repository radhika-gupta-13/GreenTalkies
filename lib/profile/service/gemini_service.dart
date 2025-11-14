import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:network_info_plus/network_info_plus.dart';

class GeminiService {
  final ImagePicker _picker = ImagePicker();

  String? _baseUrl; // Will be set dynamically

  // ---------------------------
  // Get Local IP Dynamically
  // ---------------------------
  Future<void> _initBaseUrl() async {
    if (_baseUrl != null) return; // already set

    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP(); // e.g. 192.168.0.103
    if (wifiIP != null) {
      // Change PORT to your backend's port
      _baseUrl = "http://$wifiIP:4000/api";
    } else {
      // fallback: you can add your default backend link here if no Wi-Fi
      _baseUrl = "http://10.0.2.2:4000/api"; // emulator fallback
    }

    print("🌐 Backend Base URL: $_baseUrl");
  }

  // ---------------------------
  // Pick Image from Gallery
  // ---------------------------
  Future<File?> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    return File(image.path);
  }

  // ---------------------------
  // Helper: Send request to backend
  // ---------------------------
  Future<Map<String, dynamic>> _sendRequest(
    String endpoint,
    File? image, {
    String? manualQuery,
  }) async {
    await _initBaseUrl();
    final uri = Uri.parse("$_baseUrl/$endpoint");

    var request = http.MultipartRequest('POST', uri);

    // Attach image if available
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    // Add manual query (if user typed instead of uploaded)
    if (manualQuery != null && manualQuery.isNotEmpty) {
      request.fields['query'] = manualQuery;
    }

    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        return decoded;
      } catch (e) {
        return {'diagnosis': {'name': response.body, 'cause': '', 'organic_treatment': []}};
      }
    } else {
      throw Exception('Server error: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  // ---------------------------
  // Identify Plant
  // ---------------------------
  Future<Map<String, dynamic>> identifyPlant(File? image, {String? manualQuery}) async {
    return await _sendRequest('diagnose', image, manualQuery: manualQuery);
  }

  // ---------------------------
  // Diagnose Plant
  // ---------------------------
  Future<Map<String, dynamic>> diagnosePlant(File? image, {String? manualQuery}) async {
    return await _sendRequest('diagnose', image, manualQuery: manualQuery);
  }

  // ---------------------------
  // Diagnose Soil
  // ---------------------------
  Future<Map<String, dynamic>> diagnoseSoil(File? image, {String? manualQuery}) async {
    return await _sendRequest('soil-diagnose', image, manualQuery: manualQuery);
  }
}
