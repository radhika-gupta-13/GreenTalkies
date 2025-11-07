import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class GeminiService {
  final String baseUrl = "http://192.168.0.103:4000/api"; // your backend

  final ImagePicker _picker = ImagePicker();

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
      String endpoint, File? image, {String? manualQuery}) async {
    final uri = Uri.parse("$baseUrl/$endpoint");

    var request = http.MultipartRequest('POST', uri);

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    if (manualQuery != null && manualQuery.isNotEmpty) {
      request.fields['manualQuery'] = manualQuery;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      // always return a Map with 'diagnosis'
      return Map<String, dynamic>.from(decoded);
    } else {
      throw Exception(
          'Server error: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  // ---------------------------
  // Identify Plant
  // ---------------------------
  Future<Map<String, dynamic>> identifyPlant(File? image,
      {String? manualQuery}) async {
    return await _sendRequest('diagnose', image, manualQuery: manualQuery);
  }

  // ---------------------------
  // Diagnose Plant
  // ---------------------------
  Future<Map<String, dynamic>> diagnosePlant(File? image,
      {String? manualQuery}) async {
    return await _sendRequest('diagnose', image, manualQuery: manualQuery);
  }

  // ---------------------------
  // Diagnose Soil
  // ---------------------------
  Future<Map<String, dynamic>> diagnoseSoil(File? image,
      {String? manualQuery}) async {
    return await _sendRequest('soil-diagnose', image, manualQuery: manualQuery);
  }
}
