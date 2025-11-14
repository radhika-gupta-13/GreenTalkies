import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/plant.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PlantDetailScreen extends StatefulWidget {
  final String plantId;
  final String backendUrl;

  const PlantDetailScreen({
    super.key,
    required this.plantId,
    required this.backendUrl,
  });

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  Plant? plant;
  bool isLoading = true;
  bool hasError = false;
  File? _newImage;

  @override
  void initState() {
    super.initState();
    _fetchPlant();
  }

  // ==================== Fetch single plant ====================
  Future<void> _fetchPlant() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final url = '${widget.backendUrl}/plants/${widget.plantId}';
      final response = await http.get(Uri.parse(url));
      print('Fetch plant response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          plant = Plant.fromJson(decoded);
        } else if (decoded is List && decoded.isNotEmpty && decoded[0] is Map<String, dynamic>) {
          plant = Plant.fromJson(decoded[0]);
        } else {
          print('❌ Unexpected response format');
          hasError = true;
        }
      } else {
        print('❌ Fetch failed: ${response.statusCode}');
        hasError = true;
      }
    } catch (e) {
      print('❌ Error fetching plant: $e');
      hasError = true;
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ==================== Delete plant ====================
  Future<void> _deletePlant() async {
    if (plant?.id == null) return;

    try {
      final response = await http.delete(
        Uri.parse('${widget.backendUrl}/plants/${plant!.id}'),
      );
      if (response.statusCode == 200 && mounted) {
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to delete plant');
      }
    } catch (e) {
      print('❌ Error deleting plant: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Error deleting plant')));
      }
    }
  }

  // ==================== Update plant health ====================
  Future<void> _updateHealth(String newStatus) async {
    if (plant?.id == null) return;

    try {
      final response = await http.put(
        Uri.parse('${widget.backendUrl}/plants/${plant!.id}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"healthStatus": newStatus}),
      );

      if (response.statusCode == 200 && mounted) {
        setState(() => plant = Plant.fromJson(jsonDecode(response.body)));
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Health updated successfully')));
      } else {
        throw Exception('Failed to update health');
      }
    } catch (e) {
      print('❌ Error updating health: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Error updating health')));
      }
    }
  }

  // ==================== Pick and upload plant image ====================
  Future<void> _pickAndUploadImage() async {
    if (plant?.id == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    if (!mounted) return;
    setState(() => _newImage = File(picked.path));

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${widget.backendUrl}/plants/${plant!.id}/image'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', _newImage!.path));

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Uploading image...')));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 && mounted) {
        setState(() => plant = Plant.fromJson(jsonDecode(response.body)));
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Image updated successfully')));
        _newImage = null;
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print('❌ Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Error uploading image')));
      }
    }
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: GTColors.darkText.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPlantImage() {
    ImageProvider imageProvider;

    if (_newImage != null) {
      imageProvider = FileImage(_newImage!);
    } else if (plant?.imageUrl != null && plant!.imageUrl!.isNotEmpty) {
      final url = plant!.imageUrl!;
      if (url.startsWith('http')) {
        imageProvider = NetworkImage(url);
      } else if (url.startsWith('assets/')) {
        imageProvider = AssetImage(url);
      } else {
        imageProvider = const AssetImage('assets/default_plant.jpg');
      }
    } else {
      imageProvider = const AssetImage('assets/default_plant.jpg');
    }

    return Image(
      image: imageProvider,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Image(
          image: AssetImage('assets/default_plant.jpg'),
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Plant Details'),
          backgroundColor: GTColors.lushGreen,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
              const SizedBox(height: 15),
              const Text('Unable to fetch plant 🌱',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchPlant,
                style: ElevatedButton.styleFrom(backgroundColor: GTColors.lushGreen),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (plant == null) return const Scaffold(body: Center(child: Text('Plant not found')));

    final formattedDate = plant!.createdAt != null
        ? DateFormat('dd MMM yyyy').format(plant!.createdAt!)
        : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(plant!.nickname),
        backgroundColor: GTColors.lushGreen,
        actions: [
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _deletePlant),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickAndUploadImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _buildPlantImage(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plant!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Nickname: ${plant!.nickname}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 5),
                  Text('Date Added: $formattedDate', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text('Health: ${plant!.healthStatus}', style: TextStyle(color: plant!.healthColor, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text('Next Action: ${plant!.nextAction}', style: const TextStyle(fontSize: 16)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: Divider()),
                  Row(
                    children: [
                      const Text('Update Health: ', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: plant!.healthStatus,
                        items: <String>[
                          'Excellent Health',
                          'Good Health',
                          'Needs Water',
                          'Pest Alert!',
                          'Recently Added',
                        ]
                            .map((status) => DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) _updateHealth(value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
