import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PerenualService {
  final String apiKey = 'sk-ge5c6912442d042af13420'; 
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<File?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) return File(pickedFile.path);
    return null;
  }

  // Search species by name
  Future<List<dynamic>?> searchSpecies({required String query, int page = 1}) async {
    try {
      final uri = Uri.parse(
        'https://perenual.com/api/v2/species-list?key=$apiKey&page=$page&q=${Uri.encodeComponent(query)}'
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        print('Error searchSpecies: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in searchSpecies: $e');
    }
    return null;
  }

  // Get species details
  Future<Map<String, dynamic>?> getSpeciesDetail(int speciesId) async {
    try {
      final uri = Uri.parse('https://perenual.com/api/v2/species/details/$speciesId?key=$apiKey');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        print('Error getSpeciesDetail: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getSpeciesDetail: $e');
    }
    return null;
  }
}
