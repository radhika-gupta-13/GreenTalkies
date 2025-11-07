import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:greentalkies/profile/service/gemini_service.dart';

class IdentifyDiagnosePage extends StatefulWidget {
  const IdentifyDiagnosePage({super.key});

  @override
  State<IdentifyDiagnosePage> createState() => _IdentifyDiagnosePageState();
}

class _IdentifyDiagnosePageState extends State<IdentifyDiagnosePage> {
  final GeminiService _gemini = GeminiService();
  final TextEditingController _searchController = TextEditingController();

  File? _selectedImage;
  String? _resultText;
  bool _isLoading = false;
  String _currentMode = 'identify'; // Modes: identify, diagnose, soil

  List<String>? _tips;
  bool _showTips = false;

  /// Pick an image and process it according to mode
  Future<void> _pickAndProcessImage() async {
    setState(() => _isLoading = true);
    try {
      final File? pickedFile = await _gemini.pickImage();
      if (pickedFile == null) return;

      setState(() {
        _selectedImage = pickedFile;
        _resultText = null;
        _showTips = false;
      });

      Map<String, dynamic> result;
      if (_currentMode == 'identify') {
        final res = await _gemini.identifyPlant(pickedFile);
        result = _parseBackendResponse(res);
      } else if (_currentMode == 'diagnose') {
        final res = await _gemini.diagnosePlant(pickedFile);
        result = _parseBackendResponse(res);
      } else {
        final res = await _gemini.diagnoseSoil(pickedFile);
        result = _parseBackendResponse(res);
      }

      _processResult(result);
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Manual text-based search
  Future<void> _manualSearch(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
      _selectedImage = null;
      _resultText = null;
      _showTips = false;
    });

    try {
      Map<String, dynamic> result;
      if (_currentMode == 'identify') {
        final res = await _gemini.identifyPlant(null, manualQuery: query);
        result = _parseBackendResponse(res);
      } else if (_currentMode == 'diagnose') {
        final res = await _gemini.diagnosePlant(null, manualQuery: query);
        result = _parseBackendResponse(res);
      } else {
        final res = await _gemini.diagnoseSoil(null, manualQuery: query);
        result = _parseBackendResponse(res);
      }

      _processResult(result);
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Parse backend response JSON to Map
  Map<String, dynamic> _parseBackendResponse(dynamic res) {
    if (res is String) {
      // fallback if backend returns string
      return {'name': res, 'cause': '', 'organic_treatment': []};
    }
    if (res is Map<String, dynamic> && res.containsKey('diagnosis')) {
      return Map<String, dynamic>.from(res['diagnosis']);
    }
    return Map<String, dynamic>.from(res);
  }

  /// Processes diagnosis result and generates tips
  void _processResult(Map<String, dynamic> result) {
    final name = result['name'] ?? 'Unknown';
    final cause = result['cause'] ?? '';
    final List<String> backendTips = List<String>.from(result['organic_treatment'] ?? []);

    // Generate extra tips based on keywords
    final List<String> extraTips = _generateDynamicTips(name, cause);

    setState(() {
      _resultText = '$name\nCause: $cause';
      _tips = [...backendTips, ...extraTips].toSet().toList(); // remove duplicates
      _showTips = _tips!.isNotEmpty;
    });
  }

  /// Generate extra organic tips based on keywords
  List<String> _generateDynamicTips(String name, String cause) {
    final tips = <String>[];
    final lowerName = name.toLowerCase();
    final lowerCause = cause.toLowerCase();

    if (lowerName.contains('yellow leaves') || lowerCause.contains('nitrogen')) {
      tips.add('Add compost or banana peel water for nitrogen boost.');
      tips.add('Avoid overwatering; check soil moisture before watering.');
    }
    if (lowerName.contains('mildew') || lowerName.contains('fungus') || lowerCause.contains('fungal')) {
      tips.add('Spray diluted neem oil or cinnamon powder solution.');
      tips.add('Improve air circulation and avoid water on leaves.');
    }
    if (lowerName.contains('pest') || lowerName.contains('aphid') || lowerCause.contains('insect')) {
      tips.add('Spray neem oil or soapy water on leaves.');
      tips.add('Use garlic or turmeric water to repel pests.');
    }
    if (lowerName.contains('wilting') || lowerCause.contains('root rot')) {
      tips.add('Ensure proper drainage and avoid overwatering.');
      tips.add('Add compost tea or seaweed extract to strengthen roots.');
    }
    if (lowerCause.contains('nutrient deficiency')) {
      tips.add('Use organic compost or diluted cow dung manure.');
      tips.add('Add a mix of crushed eggshells for calcium boost.');
    }
    if (lowerName.contains('dry soil') || lowerCause.contains('moisture')) {
      tips.add('Add organic mulch or cocopeat to retain water.');
    }
    if (lowerName.contains('compact soil')) {
      tips.add('Loosen soil and mix sand for better aeration.');
    }

    return tips;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: GTColors.lushGreen),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTColors.secondaryBaseLight,
      appBar: AppBar(
        title: const Text(
          'Identify / Diagnose / Soil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: GTColors.primaryBaseDark,
          ),
        ),
        backgroundColor: GTColors.lushGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Mode:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _modeButton('Identify', 'identify', GTColors.lushGreen),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _modeButton('Diagnose', 'diagnose', Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _modeButton('Soil Diagnose', 'soil', Colors.brown),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildPhotoSection(),
            const SizedBox(height: 15),
            _buildQuickTipsCard(),
            const SizedBox(height: 20),
            _buildManualSearchField(),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: GTColors.lushGreen),
              )
            else if (_resultText != null)
              _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String label, String mode, Color color) {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () {
              setState(() {
                _currentMode = mode;
                _selectedImage = null;
                _resultText = null;
                _tips = null;
                _showTips = false;
                _searchController.clear();
              });
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: _currentMode == mode ? color : color.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Or pick a photo:'),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _pickAndProcessImage,
          icon: const Icon(Icons.photo_library),
          label: const Text('Select Photo'),
          style: ElevatedButton.styleFrom(backgroundColor: GTColors.lushGreen),
        ),
        if (_selectedImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Image.file(_selectedImage!, height: 220, fit: BoxFit.cover),
          ),
      ],
    );
  }

  Widget _buildQuickTipsCard() {
    String tip;
    if (_currentMode == 'identify') {
      tip = 'Take a clear, well-lit photo of the entire plant.';
    } else if (_currentMode == 'diagnose') {
      tip = 'Capture affected leaves or stems clearly.';
    } else {
      tip = 'Take a close-up photo of soil texture and color.';
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: GTColors.lushGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: GTColors.lushGreen, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14, color: GTColors.darkText, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Enter plant/soil name or symptom',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search, color: GTColors.lushGreen),
          onPressed: _isLoading ? null : () => _manualSearch(_searchController.text.trim()),
        ),
      ),
      onSubmitted: (value) {
        if (!_isLoading) _manualSearch(value.trim());
      },
    );
  }

  Widget _buildResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: GTColors.lushGreen, width: 1.2),
          ),
          child: Text(
            _resultText ?? '',
            style: const TextStyle(fontSize: 14, color: GTColors.darkText, height: 1.5),
          ),
        ),
        const SizedBox(height: 10),
        if (_tips != null && _showTips)
          ExpansionTile(
            initiallyExpanded: true,
            title: const Text(
              'Organic Remedies',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: GTColors.primaryBaseDark,
              ),
            ),
            children: _tips!
                .map(
                  (tip) => ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: GTColors.lushGreen),
                    title: Text(tip, style: const TextStyle(fontSize: 14)),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
