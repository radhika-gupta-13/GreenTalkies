import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'plants_detail.dart';
import 'add_plant.dart';
import '../models/plant.dart';
import '../backend_config.dart';

// =======================================================
//                MY PLANTS SCREEN
// =======================================================

class MyPlantsScreen extends StatefulWidget {
  final String userId;

  const MyPlantsScreen({super.key, required this.userId});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  List<Plant> _plants = [];
  bool isLoading = true;
  bool hasError = false;
  String? backendUrl;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  /// ==================== Initialize backend URL and fetch plants ====================
  Future<void> _initializeScreen() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final ip = await BackendConfig.getServerIp();
      backendUrl = BackendConfig.apiBase(ip);

      await _fetchPlants();
    } catch (e) {
      print("❌ Error initializing MyPlantsScreen: $e");
      setState(() => hasError = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ==================== Fetch Plants ====================
  Future<void> _fetchPlants() async {
    if (backendUrl == null) return;

    try {
      final response = await http
          .get(Uri.parse('$backendUrl/plants/user/${widget.userId}'))
          .timeout(const Duration(seconds: 10));

      print('Fetch plants response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _plants = data.map((p) => Plant.fromJson(p)).toList();
          hasError = false;
        });
      } else {
        print('❌ Failed with status ${response.statusCode}');
        setState(() => hasError = true);
      }
    } catch (e) {
      print('❌ Error fetching plants: $e');
      setState(() => hasError = true);
    }
  }

  Future<void> _refreshPlants() async {
    await _fetchPlants();
  }

  /// ==================== UI BUILD ====================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (hasError) return _buildErrorScreen();

    return Scaffold(
      backgroundColor: GTColors.secondaryBaseLight,
      appBar: AppBar(
        title: const Text(
          'My Plants',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: GTColors.lushGreen,
        toolbarHeight: 80,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPlants,
        child: _plants.isEmpty ? _buildEmptyScreen() : _buildPlantsList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GTColors.radiantGreen,
        foregroundColor: Colors.white,
        onPressed: () async {
          if (backendUrl == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backend URL not ready yet')),
            );
            return;
          }

          final newPlant = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPlantScreen(
                userId: widget.userId,
                backendUrl: backendUrl!,
              ),
            ),
          );

          if (newPlant != null && newPlant is Plant) {
            _refreshPlants();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// ==================== Error Screen ====================
  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Plants',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: GTColors.lushGreen,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to connect to backend 🌧\nCheck your Wi-Fi connection',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _initializeScreen,
              child: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GTColors.lushGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ==================== Empty Screen ====================
  Widget _buildEmptyScreen() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 200),
        Center(
          child: Text(
            'No plants yet 🌱\nTap below to add one!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// ==================== Plants List ====================
  Widget _buildPlantsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _plants.length,
      itemBuilder: (context, index) {
        final plant = _plants[index];
        return GestureDetector(
          onTap: () {
            if (backendUrl != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlantDetailScreen(
                    plantId: plant.id,
                    backendUrl: backendUrl!,
                  ),
                ),
              ).then((_) => _refreshPlants());
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Backend URL not available, try again')),
              );
            }
          },
          child: PlantListCard(
            plant: plant,
            backendUrl: backendUrl ?? '',
            onPhotoUpdated: _refreshPlants,
          ),
        );
      },
    );
  }
}

// =======================================================
//                 PLANT CARD UI (with dynamic image)
// =======================================================
class PlantListCard extends StatelessWidget {
  final Plant plant;
  final String backendUrl;
  final VoidCallback onPhotoUpdated;

  const PlantListCard({
    super.key,
    required this.plant,
    required this.backendUrl,
    required this.onPhotoUpdated,
  });

  Future<void> _updatePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final uri = Uri.parse('$backendUrl/plants/${plant.id}/image');
    final request = http.MultipartRequest('PUT', uri);
    request.files.add(await http.MultipartFile.fromPath('image', file.path));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Uploading photo...')));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo updated successfully ✅')),
        );
        onPhotoUpdated(); // Refresh UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider =
        (plant.imageUrl != null && plant.imageUrl!.isNotEmpty)
            ? NetworkImage(plant.imageUrl!) as ImageProvider
            : const AssetImage('assets/default_plant.jpg');

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: GTColors.darkText.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _updatePhoto(context),
            child: Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.nickname,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GTColors.primaryBaseDark,
                  ),
                ),
                Text(
                  plant.name,
                  style: TextStyle(
                    fontSize: 13,
                    color: GTColors.darkText.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: plant.healthColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    plant.healthStatus,
                    style: TextStyle(
                      color: plant.healthColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: GTColors.darkText.withOpacity(0.4),
            size: 16,
          ),
        ],
      ),
    );
  }
}
