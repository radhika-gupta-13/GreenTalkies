import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PlantIdService {
  /// Hardcoded Plant.id API key
  final String apiKey = 'MmDyB4aIsEcJ0CgsrBJQidtuyfVwuA6WCJZLzJO7l86IlHTBOi';

  /// Pick image from gallery
  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  /// Convert image to base64
  String _imageToBase64(File image) {
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }

  /// Identify plant using Plant.id
  Future<Map<String, dynamic>> identifyPlant(File image) async {
    final url = Uri.parse('https://api.plant.id/v3/identify');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Api-Key': apiKey,
      },
      body: jsonEncode({
        "images": [_imageToBase64(image)],
        "modifiers": ["similar_images"],
        "plant_language": "en",
        "plant_details": ["common_names", "url", "wiki_description"]
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to identify plant: ${response.body}');
    }
  }
}
