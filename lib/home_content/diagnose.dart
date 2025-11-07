import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:greentalkies/colors.dart';

class IdentifyDiagnosePage extends StatefulWidget {
  const IdentifyDiagnosePage({super.key});

  @override
  State<IdentifyDiagnosePage> createState() => _IdentifyDiagnosePageState();
}

class _IdentifyDiagnosePageState extends State<IdentifyDiagnosePage> {
  File? _image;
  String? _diagnosisResult;
  bool _isLoading = false;
  final TextEditingController _queryController = TextEditingController();

  final String apiUrl = "http://192.168.0.103:4000/api/diagnose"; // 🔹 Change to your local IP

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _diagnose() async {
    setState(() {
      _isLoading = true;
      _diagnosisResult = null;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      } else if (_queryController.text.isNotEmpty) {
        request.fields['manualQuery'] = _queryController.text;
      } else {
        setState(() {
          _diagnosisResult = "Please upload an image or enter a query.";
          _isLoading = false;
        });
        return;
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        if (data["diagnosis"] != null) {
          final diagnosis = data["diagnosis"];
          setState(() {
            _diagnosisResult = """
🌿 **Diagnosis:** ${diagnosis["name"]}
💡 **Cause:** ${diagnosis["cause"]}
🌱 **Organic Treatment:** 
- ${(diagnosis["organic_treatment"] as List).join("\n- ")}
""";
          });
        } else {
          setState(() {
            _diagnosisResult = "No diagnosis data found.";
          });
        }
      } else {
        setState(() {
          _diagnosisResult = "Failed to diagnose. Server error.";
        });
      }
    } catch (e) {
      setState(() {
        _diagnosisResult = "Failed to diagnose: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Identify & Diagnose"),
        backgroundColor: GTColors.primaryGreen,
      ),
      backgroundColor: GTColors.backgroundBeige,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Input field
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: "Describe the plant issue",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),

            // Image preview
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, height: 200, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Pick Image"),
                  style: ElevatedButton.styleFrom(backgroundColor: GTColors.accentGreen),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _diagnose,
                  icon: const Icon(Icons.medical_services),
                  label: _isLoading
                      ? const Text("Diagnosing...")
                      : const Text("Diagnose"),
                  style: ElevatedButton.styleFrom(backgroundColor: GTColors.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Diagnosis Result
            if (_diagnosisResult != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  _diagnosisResult!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
