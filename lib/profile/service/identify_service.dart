import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PlantService {
  // 🔑 Your API keys
  static const String plantIdApiKey = "MmDyB4aIsEcJ0CgsrBJQidtuyfVwuA6WCJZLzJO7l86IlHTBOi";
  static const String perenualApiKey = "sk-ge5c6912442d042af13420";

  /// Pick image from gallery
  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  /// Convert image to Base64
  String _imageToBase64(File image) {
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }

  /// 🌿 Identify plant using Plant.id API
  Future<Map<String, dynamic>> identifyPlant(File image) async {
    final url = Uri.parse('https://api.plant.id/v3/identification');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Api-Key': plantIdApiKey,
      },
      body: jsonEncode({
        "images": [_imageToBase64(image)],
        "modifiers": {
          "similar_images": true,
        },
        "plant_language": "en",
        "plant_details": ["common_names", "wiki_description", "url"]
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to identify plant: ${response.body}');
    }
  }

  /// 🩺 Diagnose plant health using Plant.id API
  Future<Map<String, dynamic>> diagnosePlant(File image) async {
    final url = Uri.parse('https://api.plant.id/v3/health_assessment');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Api-Key': plantIdApiKey,
      },
      body: jsonEncode({
        "images": [_imageToBase64(image)],
        "modifiers": {
          "health": "auto",
          "similar_images": true,
          "symptoms": true
        },
        "disease_details": ["common_names", "treatment", "description"]
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to diagnose plant: ${response.body}');
    }
  }

  /// 🔎 Manual plant search using Perenual API
  Future<List<dynamic>?> searchPlants(String query) async {
    final uri = Uri.parse(
        'https://perenual.com/api/species-list?key=$perenualApiKey&q=${Uri.encodeComponent(query)}');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to fetch plant list: ${response.body}');
    }
  }
}
