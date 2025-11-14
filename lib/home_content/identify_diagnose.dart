import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class IdentifyDiagnosePage extends StatefulWidget {
  const IdentifyDiagnosePage({Key? key}) : super(key: key);

  @override
  State<IdentifyDiagnosePage> createState() => _IdentifyDiagnosePageState();
}

class _IdentifyDiagnosePageState extends State<IdentifyDiagnosePage> {
  // APIs
  final String plantIdApiKey =
      "MmDyB4aIsEcJ0CgsrBJQidtuyfVwuA6WCJZLzJO7l86IlHTBOi";

  File? _selectedImage;
  String? _identifiedPlant;
  List<String>? _tips;
  bool _isLoading = false;

  File? _diagnoseImage;
  String? _diagnosis;
  List<String>? _diagnosisTips;
  String? _diagnosisImageUrl;

  /// Pick image for identification or diagnosis
  Future<void> _pickImage({required bool isDiagnosis}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (isDiagnosis) {
        setState(() => _diagnoseImage = File(pickedFile.path));
        _diagnosePlant(_diagnoseImage!);
      } else {
        setState(() => _selectedImage = File(pickedFile.path));
        _identifyPlant(_selectedImage!);
      }
    }
  }

  /// Convert image to base64
  String _imageToBase64(File image) {
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }

  /// Identify plant using Plant.id v2 endpoint
  Future<void> _identifyPlant(File image) async {
    setState(() {
      _isLoading = true;
      _identifiedPlant = null;
      _tips = null;
    });

    try {
      final url = Uri.parse('https://api.plant.id/v2/identify');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': plantIdApiKey,
        },
        body: jsonEncode({
          "images": [_imageToBase64(image)],
          "organs": ["leaf"],
          "plant_details": ["common_names", "wiki_description"],
          "plant_language": "en"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final suggestion = data['suggestions']?[0];
        final name = suggestion?['plant_name'] ?? 'Unknown';
        final description =
            suggestion?['plant_details']?['wiki_description']?['value'] ?? '';

        setState(() {
          _identifiedPlant = name;
          _tips = description.isNotEmpty ? [description] : null;
        });
      } else {
        setState(() {
          _identifiedPlant = "Failed to identify";
          _tips = [];
        });
      }
    } catch (e) {
      setState(() {
        _identifiedPlant = "Failed to identify";
        _tips = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Diagnose plant using Plant.id Health Assessment API
  Future<void> _diagnosePlant(File image) async {
    setState(() {
      _isLoading = true;
      _diagnosis = null;
      _diagnosisTips = null;
      _diagnosisImageUrl = null;
    });

    try {
      final url = Uri.parse('https://api.plant.id/v3/health_assessment');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': plantIdApiKey,
        },
        body: jsonEncode({
          "images": [_imageToBase64(image)],
          "health": "only",
          "similar_images": true,
          "symptoms": true,
          "details":
              "local_name,description,url,treatment,classification,common_names,cause",
          "language": "en"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'] ?? {};
        final diseaseData = result['disease'] ?? {};
        final suggestions = diseaseData['suggestions'] as List<dynamic>?;

        if (suggestions == null || suggestions.isEmpty) {
          setState(() {
            _diagnosis = "Plant appears healthy";
            _diagnosisTips = [];
          });
        } else {
          // Take first non-redundant suggestion if available
          final suggestion = suggestions.firstWhere(
              (s) => s['redundant'] != true,
              orElse: () => suggestions[0]);

          final name = suggestion['name'] ?? "Unknown disease";
          final probability = suggestion['probability'] ?? 0.0;
          final images = suggestion['similar_images'] as List<dynamic>?;

          final imageUrl =
              (images != null && images.isNotEmpty) ? images[0]['url'] : null;

          setState(() {
            _diagnosis = name;
            _diagnosisTips = [
              "Probability: ${(probability * 100).toStringAsFixed(1)}%"
            ];
            _diagnosisImageUrl = imageUrl;
          });
        }
      } else {
        setState(() {
          _diagnosis = "Failed to diagnose";
          _diagnosisTips = [];
        });
      }
    } catch (e) {
      setState(() {
        _diagnosis = "Failed to diagnose";
        _diagnosisTips = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildPlantCard(
      String title, String name, List<String>? tips, File? image,
      {String? networkImage}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 8),
            if (image != null)
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(image,
                      height: 180, width: double.infinity, fit: BoxFit.cover)),
            if (image == null && networkImage != null)
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(networkImage,
                      height: 180, width: double.infinity, fit: BoxFit.cover)),
            const SizedBox(height: 8),
            Text(name,
                style: const TextStyle(fontSize: 18, color: Colors.black87)),
            const SizedBox(height: 10),
            if (tips != null)
              ...tips.map((tip) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_outline,
                        color: Colors.green),
                    title: Text(tip),
                  )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identify & Diagnose'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IDENTIFY SECTION
            Text('Plant Identification',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed:
                  _isLoading ? null : () => _pickImage(isDiagnosis: false),
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick Image to Identify'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(height: 10),
            if (_selectedImage != null || _identifiedPlant != null)
              _buildPlantCard('Identified Plant', _identifiedPlant ?? '', _tips,
                  _selectedImage),

            const SizedBox(height: 20),

            // DIAGNOSE SECTION
            Text('Plant Diagnosis',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed:
                  _isLoading ? null : () => _pickImage(isDiagnosis: true),
              icon: const Icon(Icons.healing),
              label: const Text('Pick Image to Diagnose'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(height: 10),
            if (_diagnoseImage != null || _diagnosis != null)
              _buildPlantCard(
                  'Diagnosis', _diagnosis ?? '', _diagnosisTips, _diagnoseImage,
                  networkImage: _diagnosisImageUrl),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                    child: CircularProgressIndicator(color: Colors.green)),
              ),
          ],
        ),
      ),
    );
  }
}
