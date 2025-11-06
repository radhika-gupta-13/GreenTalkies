import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/plant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class AddPlantScreen extends StatefulWidget {
  final String userId;
  final String backendUrl; 
  const AddPlantScreen({super.key, required this.userId, required this.backendUrl});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();

  File? _pickedImage;
  bool isSaving = false;

  // =========================
  // Pick image from gallery or camera
  // =========================
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // =========================
  // Save Plant to backend
  // =========================
  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final newPlant = {
      "userId": widget.userId,
      "name": _nameController.text,
      "nickname": _nicknameController.text,
      "healthStatus": "Recently Added",
      "nextAction": "Check in 1 week",
      "imageUrl": "", // Initially empty, will upload separately
    };

    try {
      // Step 1: Create plant entry
      final response = await http.post(
        Uri.parse('${widget.backendUrl}/plants'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newPlant),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final Plant createdPlant = Plant.fromJson(data);

        // Step 2: Upload image if selected
        if (_pickedImage != null) {
          final uploadUri = Uri.parse('${widget.backendUrl}/plants/${createdPlant.id}/image');
          final request = http.MultipartRequest('PUT', uploadUri);
          request.files.add(await http.MultipartFile.fromPath('image', _pickedImage!.path));
          final streamedResponse = await request.send();
          final uploadResponse = await http.Response.fromStream(streamedResponse);

          if (uploadResponse.statusCode == 200) {
            final updatedData = jsonDecode(uploadResponse.body);
            createdPlant.imageUrl = updatedData['imageUrl'];
          } else {
            print('❌ Image upload failed: ${uploadResponse.statusCode}');
          }
        }

        Navigator.pop(context, createdPlant);
      } else {
        throw Exception('Failed to save plant: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving plant: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error saving plant')));
    } finally {
      setState(() => isSaving = false);
    }
  }

  // =========================
  // Build UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Plant'),
        backgroundColor: GTColors.lushGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Image picker
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (_) => SizedBox(
                              height: 120,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text("Gallery"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.gallery);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text("Camera"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.camera);
                                    },
                                  ),
                                ],
                              ),
                            ));
                  },
                  child: _pickedImage == null
                      ? Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Icon(Icons.add_a_photo, size: 40),
                        )
                      : Image.file(_pickedImage!,
                          width: 100, height: 100, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),

                // Nickname
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(labelText: 'Nickname'),
                  validator: (v) => v!.isEmpty ? 'Enter nickname' : null,
                ),
                const SizedBox(height: 15),

                // Plant Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Plant Name'),
                  validator: (v) => v!.isEmpty ? 'Enter plant name' : null,
                ),
                const SizedBox(height: 30),

                // Save Button
                ElevatedButton(
                  onPressed: isSaving ? null : _savePlant,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: GTColors.lushGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Plant'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
