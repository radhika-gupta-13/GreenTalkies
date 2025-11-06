import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:greentalkies/models/grove_model.dart';

class NewPostScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUsername;

  const NewPostScreen({
    required this.currentUserId,
    required this.currentUsername,
    super.key,
  });

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController topicController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  File? selectedImage;
  String? uploadedImageUrl;
  String? baseUrl;
  final List<int> portsToTry = [3000, 4000];

  @override
  void initState() {
    super.initState();
    _setDynamicBaseUrl();
  }

  Future<void> _setDynamicBaseUrl() async {
    final info = NetworkInfo();
    final ip = await info.getWifiIP();
    if (ip == null) return;

    for (int port in portsToTry) {
      final url = 'http://$ip:$port';
      try {
        final response = await http.get(Uri.parse('$url/'));
        if (response.statusCode == 200 || response.statusCode == 404) {
          setState(() {
            baseUrl = url;
          });
          return;
        }
      } catch (_) {
        continue;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backend not found on local network')),
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void removeImage() {
    setState(() {
      selectedImage = null;
      uploadedImageUrl = null;
    });
  }

  Future<void> submitPost() async {
    if (baseUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecting to backend... Please wait.')),
      );
      return;
    }

    final topic = topicController.text.trim();
    final content = contentController.text.trim();
    if (topic.isEmpty || content.isEmpty) return;

    try {
      http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/grove'),
      );

      request.fields['userId'] = widget.currentUserId;
      request.fields['username'] = widget.currentUsername;
      request.fields['topic'] = topic;
      request.fields['content'] = content;

      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', selectedImage!.path),
        );
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(respStr);
        final newPost = GrovePostModel.fromJson(responseData);

        Navigator.pop(context, newPost); // Return the new post to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $respStr')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Create a Post'),
        backgroundColor: GTColors.lushGreen,
      ),
      body: baseUrl == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + keyboardSpace),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: topicController,
                        decoration: InputDecoration(
                          labelText: 'Topic',
                          prefixIcon: const Icon(Icons.topic),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (selectedImage != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                selectedImage!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: removeImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  selectedImage == null
                                      ? Icons.add_a_photo
                                      : Icons.edit,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  selectedImage == null
                                      ? 'Add an image'
                                      : 'Change image',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: contentController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Content',
                          prefixIcon: const Icon(Icons.text_fields),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: submitPost,
                        icon: const Icon(Icons.send),
                        label: const Text('Post'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GTColors.lushGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
